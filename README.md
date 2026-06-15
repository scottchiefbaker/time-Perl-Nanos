## Name

Time::Hrtime - Nanosecond time resolution via `clock\_gettime()`.

## Synopsis

```perl
use Time::Hrtime;

my $nanoseconds             = hrtime();
my ($seconds, $nanoseconds) = hrtime(1);

my $rt_ns                   = hrtime(undef, 'realtime');
my ($rt_sec, $rt_nsec)      = hrtime(1, 'realtime');
```

## Description

Returns high resolution time via `clock\_gettime()`.

By default uses `CLOCK_MONOTONIC`. Pass a second argument to select the clock:
`'monotonic'` or `'realtime'`.

## Usage

```
hrtime()                       # CLOCK_MONOTONIC, nanoseconds
hrtime(1)                      # CLOCK_MONOTONIC, list (sec, nsec)

hrtime(undef, 'realtime')      # CLOCK_REALTIME, nanoseconds
hrtime(1, 'realtime')          # CLOCK_REALTIME, list (sec, nsec)
```
