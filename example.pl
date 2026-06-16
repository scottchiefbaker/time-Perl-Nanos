#!/usr/bin/env perl
use strict;
use warnings;
use Time::Nanos;

for (1 .. 5) {
	my $ns = nanos();
	printf "Time (monotonic): %s nanoseconds\n", $ns;
}

print "\n";

for (1 .. 5) {
	my ($sec, $nsec) = nanos(1);
	printf "Time (monotonic): %d.%09d seconds\n", $sec, $nsec;
}

print "\n";

for (1 .. 5) {
	my $ns = nanos(0, 'realtime');
	printf "Time (realtime): %s nanoseconds\n", $ns;
}

print "\n";

for (1 .. 5) {
	my ($sec, $nsec) = nanos(1, 'realtime');
	printf "Time (realtime): %d.%09d seconds\n", $sec, $nsec;
}

print "\n";

for (1 .. 5) {
	my $us = micros();
	printf "Time (monotonic): %s microseconds\n", $us;
}

print "\n";

for (1 .. 5) {
	my $ms = millis();
	printf "Time (monotonic): %s milliseconds\n", $ms;
}
