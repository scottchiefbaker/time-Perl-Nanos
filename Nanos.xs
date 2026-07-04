/*
 * Nanos.xs - XS implementation of Time::Nanos
 *
 * Provides a single XS function, hrtime(), that returns a high-resolution
 * timestamp in nanoseconds.  Two backends are supported:
 *
 *   HAS_CLOCK_GETTIME - POSIX clock_gettime(2) (Linux, macOS, BSD, ...)
 *   HAS_WINHR         - Windows high-resolution timers
 *
 * If neither is defined at compile time, hrtime() croaks at runtime.
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <stdint.h>

#ifdef HAS_CLOCK_GETTIME
#include <time.h>
#include <errno.h>
#include <string.h>
#endif

#ifdef HAS_WINHR
#include <windows.h>
#endif

/*
 * Populate *sec_out / *nsec_out with the current time from the requested
 * clock source.
 * use_realtime=1 -> CLOCK_REALTIME  (wall-clock),
 * use_realtime=0 -> CLOCK_MONOTONIC (time since boot, immune to jumps).
 */
#if defined(HAS_CLOCK_GETTIME) || defined(HAS_WINHR)
static void
get_hrtime(int use_realtime, uint64_t *sec_out, uint64_t *nsec_out)
{
#ifdef HAS_CLOCK_GETTIME
    {
        struct timespec ts;
        clockid_t clock_id = use_realtime ? CLOCK_REALTIME : CLOCK_MONOTONIC;
        if (clock_gettime(clock_id, &ts) != 0) {
            croak("hrtime(): clock_gettime() failed: %s", strerror(errno));
        }
        *sec_out  = (uint64_t)ts.tv_sec;
        *nsec_out = (uint64_t)ts.tv_nsec;
    }
#else
    if (use_realtime) {
        /* Windows: GetSystemTimePreciseAsFileTime gives 100 ns intervals
         * since 1601-01-01.  Adjust epoch to 1970-01-01 and convert. */
        FILETIME ft;
        ULARGE_INTEGER ul;
        GetSystemTimePreciseAsFileTime(&ft);
        ul.LowPart  = ft.dwLowDateTime;
        ul.HighPart = ft.dwHighDateTime;
        ul.QuadPart -= 116444736000000000ULL;                /* 1601 -> 1970 offset */
        *sec_out    = ul.QuadPart / 10000000ULL;             /* 100 ns -> sec       */
        *nsec_out   = (ul.QuadPart % 10000000ULL) * 100ULL;  /* remainder -> ns     */
    } else {
        /* Windows: QueryPerformanceCounter for monotonic time */
        LARGE_INTEGER freq, counter;
        int64_t remainder;
        if (!QueryPerformanceFrequency(&freq)) {
            croak("hrtime(): QueryPerformanceFrequency() failed");
        }
        if (!QueryPerformanceCounter(&counter)) {
            croak("hrtime(): QueryPerformanceCounter() failed");
        }
        *sec_out  = (uint64_t)(counter.QuadPart / freq.QuadPart);
        remainder = counter.QuadPart % freq.QuadPart;
        *nsec_out = (uint64_t)((remainder * 1000000000LL) / freq.QuadPart);
    }
#endif
}
#endif

MODULE = Time::Nanos    PACKAGE = Time::Nanos

PROTOTYPES: DISABLE

void
hrtime(...)
    PPCODE:
        /*
         * Returns a nanosecond-precision timestamp.
         *
         * Scalar / no-true-arg -> integer nanoseconds (sec * 1e9 + nsec).
         * True first argument  -> (seconds, nanoseconds) list.
         *
         * Clock source from $Time::Nanos::CLOCK:
         *   "realtime"  (default) - wall-clock
         *   "monotonic"           - safe for intervals
         */
#if !defined(HAS_CLOCK_GETTIME) && !defined(HAS_WINHR)
        croak("hrtime(): high-resolution clock is not available on this platform");
#else
        {
            uint64_t sec_part, nsec_part;
            int want_list    = 0;
            int use_realtime = 0;

            /* If first argument is true, return (seconds, nanoseconds) */
            if (items > 0 && SvTRUE(ST(0))) {
                want_list = 1;
            }

            /* Read $Time::Nanos::CLOCK to choose realtime vs monotonic */
            {
                STRLEN len;
                const char *clock_name;
                SV *sv = get_sv("Time::Nanos::CLOCK", 0);

                if (!sv || !SvOK(sv)) {
                    use_realtime = 1;
                } else {
                    clock_name = SvPV(sv, len);
                    if (len == 9 && strnEQ(clock_name, "monotonic", 9)) {
                        use_realtime = 0;
                    } else if (len == 8 && strnEQ(clock_name, "realtime", 8)) {
                        use_realtime = 1;
                    } else {
                        croak("hrtime(): unknown clock source '%s' (valid: 'monotonic', 'realtime')", clock_name);
                    }
                }
            }

            get_hrtime(use_realtime, &sec_part, &nsec_part);

            if (want_list) {
                EXTEND(SP, 2);
                PUSHs(sv_2mortal(newSVuv((UV)sec_part)));
                PUSHs(sv_2mortal(newSVuv((UV)nsec_part)));
            } else {
                EXTEND(SP, 1);
                PUSHs(sv_2mortal(newSVuv(
                    (UV)(sec_part * 1000000000ULL + nsec_part)
                )));
            }
        }
#endif
