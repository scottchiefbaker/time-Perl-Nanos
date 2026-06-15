#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifdef HAS_CLOCK_GETTIME
#include <time.h>
#include <errno.h>
#include <string.h>
#include <stdint.h>
#endif

MODULE = Time::Hrtime    PACKAGE = Time::Hrtime

PROTOTYPES: DISABLE

void
hrtime(...)
    PPCODE:
#ifndef HAS_CLOCK_GETTIME
        croak("hrtime(): clock_gettime() is not available on this platform");
#else
        {
            struct timespec ts;
            clockid_t clock_id = CLOCK_MONOTONIC;
            int want_list = 0;

            if (items > 0 && SvTRUE(ST(0))) {
                want_list = 1;
            }

            if (items > 1 && SvOK(ST(1))) {
                STRLEN len;
                const char *clock_name = SvPV(ST(1), len);
                if (len == 9 && strnEQ(clock_name, "monotonic", 9)) {
                    clock_id = CLOCK_MONOTONIC;
                } else if (len == 8 && strnEQ(clock_name, "realtime", 8)) {
                    clock_id = CLOCK_REALTIME;
                } else {
                    croak("hrtime(): unknown clock source '%s' (valid: 'monotonic', 'realtime')", clock_name);
                }
            }

            if (clock_gettime(clock_id, &ts) != 0) {
                croak("hrtime(): clock_gettime() failed: %s", strerror(errno));
            }

            if (want_list) {
                EXTEND(SP, 2);
                PUSHs(sv_2mortal(newSVuv((UV)ts.tv_sec)));
                PUSHs(sv_2mortal(newSVuv((UV)ts.tv_nsec)));
            } else {
                EXTEND(SP, 1);
                PUSHs(sv_2mortal(newSVuv(
                    (UV)((uint64_t)ts.tv_sec * 1000000000ULL + (uint64_t)ts.tv_nsec)
                )));
            }
        }
#endif
