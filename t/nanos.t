use strict;
use warnings;
use Test::More;

use Time::Nanos;

# $CLOCK defaults to 0 (realtime)
is($Time::Nanos::CLOCK, 0, '$CLOCK defaults to 0 (realtime)');

# nanos() basic tests
ok(defined &nanos, 'nanos is exported');

my $ns = nanos();
ok(defined $ns, 'nanos() returns a value');
ok($ns > 0    , 'nanoseconds value is positive');
ok($ns == int($ns), 'nanoseconds value is an integer');

# micros and millis are exported and return integers
ok(defined &micros, 'micros is exported');
ok(defined &millis, 'millis is exported');

my $us = micros();
ok(defined $us, 'micros() returns a value');
ok($us > 0    , 'microseconds value is positive');
ok($us == int($us), 'microseconds value is an integer');

my $ms = millis();
ok(defined $ms, 'millis() returns a value');
ok($ms > 0    , 'milliseconds value is positive');
ok($ms == int($ms), 'milliseconds value is an integer');

# micros/millis are roughly nanos / 1e3 / 1e6
ok(abs($us * 1000 - $ns) < 1_000_000, 'micros ~= nanos / 1e3');
ok(abs($ms * 1_000_000 - $ns) < 1_000_000, 'millis ~= nanos / 1e6');

# realtime clock (default)
{
    local $Time::Nanos::CLOCK = 0;

    my $rt_ns = nanos();
    ok(defined $rt_ns, 'realtime nanos() returns a value');
    ok($rt_ns > 0, 'realtime nanoseconds is positive');
    ok($rt_ns == int($rt_ns), 'realtime nanoseconds is an integer');

    my $rt_us = micros();
    ok(defined $rt_us, 'realtime micros() returns a value');
    ok($rt_us > 0, 'realtime microseconds is positive');

    my $rt_ms = millis();
    ok(defined $rt_ms, 'realtime millis() returns a value');
    ok($rt_ms > 0, 'realtime milliseconds is positive');
}

# monotonic clock via $CLOCK
{
    local $Time::Nanos::CLOCK = 1;
    my $mono_ns = nanos();
    ok(defined $mono_ns, 'nanos() with monotonic returns a value');
    ok($mono_ns > 0, 'monotonic nanoseconds is positive');

    my $mono_ns2 = nanos();
    ok($mono_ns2 >= $mono_ns, 'monotonic: second call >= first call');
}

# array-return form: nanos(1) / micros(1) / millis(1)
{
    my ($ns_sec, $ns_nsec) = nanos(1);
    ok(defined $ns_sec , 'nanos(1) seconds defined');
    ok(defined $ns_nsec, 'nanos(1) nanoseconds defined');
    ok($ns_sec > 0              , 'nanos(1) seconds is positive');
    ok($ns_nsec >= 0            , 'nanos(1) nanoseconds non-negative');
    ok($ns_nsec < 1_000_000_000 , 'nanos(1) nanoseconds < 1e9');
    ok(abs(($ns_sec * 1_000_000_000 + $ns_nsec) - nanos()) < 1_000_000,
        'nanos(1) list reconciles with scalar');

    my ($us_sec, $us_usec) = micros(1);
    ok(defined $us_sec , 'micros(1) seconds defined');
    ok(defined $us_usec, 'micros(1) microseconds defined');
    ok($us_sec > 0           , 'micros(1) seconds is positive');
    ok($us_usec >= 0         , 'micros(1) microseconds non-negative');
    ok($us_usec < 1_000_000  , 'micros(1) microseconds < 1e6');
    ok(abs(($us_sec * 1_000_000_000 + $us_usec * 1000) - nanos()) < 1_000_000,
        'micros(1) list reconciles with nanos()');

    my ($ms_sec, $ms_msec) = millis(1);
    ok(defined $ms_sec , 'millis(1) seconds defined');
    ok(defined $ms_msec, 'millis(1) milliseconds defined');
    ok($ms_sec > 0        , 'millis(1) seconds is positive');
    ok($ms_msec >= 0      , 'millis(1) milliseconds non-negative');
    ok($ms_msec < 1000    , 'millis(1) milliseconds < 1000');
    ok(abs(($ms_sec * 1_000_000_000 + $ms_msec * 1_000_000) - nanos()) < 1_000_000,
        'millis(1) list reconciles with nanos()');
}

# any true value triggers the array form
{
    my @list = nanos("true");
    is(scalar @list, 2, 'nanos(true) returns a 2-element list');
}

# deterministic check via a mocked hrtime(): ns = 1_783_717_664_756_579_651
{
    local *Time::Nanos::hrtime = sub { 1_783_717_664_756_579_651 };

    my ($ns_s, $ns_n) = nanos(1);
    is($ns_s, 1783717664, 'mocked nanos(1) seconds');
    is($ns_n, 756579651,  'mocked nanos(1) nsec');

    my ($us_s, $us_u) = micros(1);
    is($us_s, 1783717664, 'mocked micros(1) seconds');
    is($us_u, 756579,     'mocked micros(1) usec');

    my ($ms_s, $ms_m) = millis(1);
    is($ms_s, 1783717664, 'mocked millis(1) seconds');
    is($ms_m, 756,        'mocked millis(1) msec');
}

# clock_source() switches the clock
{
    Time::Nanos::clock_source('monotonic');
    is($Time::Nanos::CLOCK, 1, 'clock_source("monotonic") sets $CLOCK = 1');

    Time::Nanos::clock_source('realtime');
    is($Time::Nanos::CLOCK, 0, 'clock_source("realtime") sets $CLOCK = 0');

    Time::Nanos::clock_source(1);
    is($Time::Nanos::CLOCK, 1, 'clock_source(1) sets $CLOCK = 1');

    Time::Nanos::clock_source(0);
    is($Time::Nanos::CLOCK, 0, 'clock_source(0) sets $CLOCK = 0');
}

# invalid clock source string croaks
{
    eval { Time::Nanos::clock_source('invalid') };
    ok($@, 'clock_source() with unknown source croaks');
    like($@, qr/Unknown source/, 'error mentions unknown source');
}

# invalid clock source integer passed to hrtime() croaks
{
    eval { Time::Nanos::hrtime(99) };
    ok($@, 'hrtime() with invalid clock source croaks');
    like($@, qr/invalid clock source/, 'error mentions invalid clock source');
}

done_testing();
