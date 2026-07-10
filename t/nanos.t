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

# clock_source() switches the clock
{
    clock_source('monotonic');
    is($Time::Nanos::CLOCK, 1, 'clock_source("monotonic") sets $CLOCK = 1');

    clock_source('realtime');
    is($Time::Nanos::CLOCK, 0, 'clock_source("realtime") sets $CLOCK = 0');

    clock_source(1);
    is($Time::Nanos::CLOCK, 1, 'clock_source(1) sets $CLOCK = 1');

    clock_source(0);
    is($Time::Nanos::CLOCK, 0, 'clock_source(0) sets $CLOCK = 0');
}

# invalid clock source string croaks
{
    eval { clock_source('invalid') };
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
