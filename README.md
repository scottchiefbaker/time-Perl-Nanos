## Name

Time::Nanos - Nanosecond time resolution via clock\_gettime().

## Synopsis

```perl
use Time::Nanos;

my $nanoseconds             = nanos();
my ($seconds, $nanoseconds) = nanos(1);

my $microseconds            = micros();
my $milliseconds            = millis();
```

## Functions

### nanos

```perl
my $ns = nanos();
my ($sec, $nsec) = nanos(1);
```

Returns nanoseconds. In scalar context returns total nanoseconds. In list context
returns (seconds, nanoseconds).

Accepts optional arguments: `nanos($list, $clock)` where `$list` selects list
context and `$clock` is `'monotonic'` (default) or `'realtime'`.

### micros

```perl
my $us = micros();
```

Returns microseconds as an integer. Accepts optional clock argument:
`micros(undef, 'realtime')`.

### millis

```perl
my $ms = millis();
```

Returns milliseconds as an integer. Accepts optional clock argument:
`millis(undef, 'realtime')`.

## Description

Returns high resolution time via `clock_gettime()`.

By default uses `CLOCK_MONOTONIC`. Pass a second argument to select the clock:
`'monotonic'` or `'realtime'`.

## Usage

```
nanos()                       # CLOCK_MONOTONIC, nanoseconds
nanos(1)                      # CLOCK_MONOTONIC, list (sec, nsec)

micros()                      # CLOCK_MONOTONIC, microseconds
millis()                      # CLOCK_MONOTONIC, milliseconds

nanos(undef, 'realtime')      # CLOCK_REALTIME, nanoseconds
nanos(1, 'realtime')          # CLOCK_REALTIME, list (sec, nsec)

micros(undef, 'realtime')     # CLOCK_REALTIME, microseconds
millis(undef, 'realtime')     # CLOCK_REALTIME, milliseconds
```
