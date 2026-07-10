package Time::Nanos;

use strict;
use warnings;
use Exporter 'import';

use autouse 'Carp' => qw(croak);

our $VERSION = 'v0.1.5';
our @EXPORT  = qw(nanos micros millis);
our $CLOCK   = 0;

require XSLoader;
XSLoader::load('Time::Nanos', $VERSION);

sub nanos {
	return hrtime($Time::Nanos::CLOCK);
}

sub micros {
	return int(nanos() / 1000);
}

sub millis {
	return int(nanos() / 1_000_000);
}

sub clock_source {
	my $input = shift();

	if (!defined $input) {
		croak("clock_source() requires an argument");
	} elsif ($input eq "realtime" || $input eq "0") {
		$CLOCK = 0;
	} elsif ($input eq "monotonic" || $input eq "1") {
		$CLOCK = 1;
	} else {
		croak("Unknown source '$input'");
	}
}

1;

__END__

=head1 NAME

Time::Nanos - Nanosecond time resolution via clock_gettime().

=head1 SYNOPSIS

    use Time::Nanos;

    my $nanoseconds  = nanos();
    my $microseconds = micros();
    my $milliseconds = millis();

=head1 VARIABLES

=head2 $CLOCK

    Time::Nanos::clock_source('monotonic');

Controls which clock source the functions use. Defaults to C<'realtime'>.
Valid values: C<'realtime'> or C<'monotonic'>.

=head1 FUNCTIONS

=head2 nanos()

    my $ns = nanos();

Returns the current time as an integer number of nanoseconds.

=head2 micros()

    my $us = micros();

Returns the current time as an integer number of microseconds.

=head2 millis()

    my $ms = millis();

Returns the current time as an integer number of milliseconds.

=head1 DESCRIPTION

This module provides high-resolution time via C<clock_gettime()>.
The default clock is C<CLOCK_REALTIME>. C<'realtime'> uses the system clock,
which measures time since the Unix epoch. This is susceptible to clock skew from
NTP updates, user clock changes, etc.  When using C<'realtime'>, it is possible
(but rare) to observe a negative duration when comparing two successive calls.

When using C<'monotonic'> the clock reference epoch is unspecified, so a single
reading is not in itself a useful measurement of time. These values are only
meaningful when compared against each other to measure elapsed time.

=cut
