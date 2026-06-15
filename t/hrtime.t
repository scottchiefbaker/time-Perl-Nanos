use strict;
use warnings;
use Test::More;

use Time::Hrtime;

ok(defined &hrtime, 'hrtime is exported');

my $ns = hrtime();
ok(defined $ns, 'hrtime() returns a value');
ok($ns > 0, 'nanoseconds value is positive');

my ($sec, $nsec) = hrtime(1);
ok(defined $sec,  'seconds component defined');
ok(defined $nsec, 'nanoseconds component defined');
ok($sec > 0,      'seconds is positive');
ok($nsec >= 0,    'nanoseconds component is non-negative');
ok($nsec < 1_000_000_000, 'nanoseconds component < 1e9');

my $combined = $sec * 1_000_000_000 + $nsec;
ok(abs($combined - $ns) < 1_000_000, 'combined and scalar values are consistent');

my $ns2 = hrtime();
ok($ns2 >= $ns, 'monotonic: second call >= first call');

my $rt_ns = hrtime(undef, 'realtime');
ok(defined $rt_ns, 'hrtime(undef, realtime) returns a value');
ok($rt_ns > 0, 'realtime nanoseconds is positive');

my ($rt_sec, $rt_nsec) = hrtime(1, 'realtime');
ok(defined $rt_sec,  'realtime seconds defined');
ok(defined $rt_nsec, 'realtime nanoseconds component defined');
ok($rt_sec > 0,      'realtime seconds is positive');
ok($rt_nsec >= 0,    'realtime nsec component is non-negative');
ok($rt_nsec < 1_000_000_000, 'realtime nsec component < 1e9');

my $rt_combined = $rt_sec * 1_000_000_000 + $rt_nsec;
ok(abs($rt_combined - $rt_ns) < 1_000_000, 'realtime combined and scalar values are consistent');

my $mono_explicit = hrtime(undef, 'monotonic');
ok(defined $mono_explicit, 'hrtime(undef, monotonic) returns a value');
ok($mono_explicit > 0, 'explicit monotonic is positive');
ok(abs($mono_explicit - hrtime()) < 10_000_000, 'explicit monotonic matches default');

eval { hrtime(undef, 'invalid') };
ok($@, 'unknown clock source croaks');
like($@, qr/unknown clock source/, 'error mentions unknown clock source');

done_testing();
