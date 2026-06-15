#!/usr/bin/env perl
use strict;
use warnings;
use Time::Hrtime;

for (1 .. 5) {
	my $ns = hrtime();
	printf "Time (monotonic): %s nanoseconds\n", $ns;
}

print "\n";

for (1 .. 5) {
	my ($sec, $nsec) = hrtime(1);
	printf "Time (monotonic): %d.%09d seconds\n", $sec, $nsec;
}

print "\n";

for (1 .. 5) {
	my $ns = hrtime(0, 'realtime');
	printf "Time (realtime): %s nanoseconds\n", $ns;
}

print "\n";

for (1 .. 5) {
	my ($sec, $nsec) = hrtime(1, 'realtime');
	printf "Time (realtime): %d.%09d seconds\n", $sec, $nsec;
}
