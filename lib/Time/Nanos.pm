package Time::Nanos;

use strict;
use warnings;
use Exporter 'import';

our $VERSION = 'v0.1.2';
our @EXPORT  = qw(nanos micros millis);

require XSLoader;
XSLoader::load('Time::Nanos', $VERSION);

sub nanos { hrtime(@_) }

sub micros { int(nanos(@_) / 1000) }

sub millis { int(nanos(@_) / 1_000_000) }

1;

__END__

=head1 NAME

Time::Nanos - Nanosecond time resolution via clock_gettime().

=head1 SYNOPSIS

    use Time::Nanos;

    my $nanoseconds             = nanos();
    my $microseconds            = micros();
    my $milliseconds            = millis();

    my ($seconds, $nanoseconds) = nanos(1);

=head1 FUNCTIONS

=head2 nanos

    my $ns = nanos();
    my ($sec, $nsec) = nanos(1);

Returns nanoseconds. In scalar context returns total nanoseconds. With optional
second param returns a list of (seconds, nanoseconds) instead.

Accepts optional arguments: C<nanos($list, $clock)> where C<$list> selects list
context and C<$clock> is C<'monotonic'> (default) or C<'realtime'>.

=head2 micros

    my $us = micros();

Returns microseconds as an integer. Accepts optional clock argument:
C<micros(undef, 'realtime')>.

=head2 millis

    my $ms = millis();

Returns milliseconds as an integer. Accepts optional clock argument:
C<millis(undef, 'realtime')>.

=head1 DESCRIPTION

Returns high resolution time via C<clock_gettime()>. Timing is in reference to
an unknown epoch, so by itself it is not a useful measurement of time. These
timings are only useful when compared against each other to measure the passing
of time.

By default uses C<CLOCK_MONOTONIC>. Pass a second argument to select the clock:
C<'monotonic'> or C<'realtime'>. C<'realtime'> is a measurement of the system's
uptime, but is succeptible to clock skew: user changes clock, NTP updates time,
etc. Using C<'realtime'> it is possible (but rate) to have negative time duration
when comparing two calls.

=head1 USAGE

    nanos()                       # CLOCK_MONOTONIC, nanoseconds
    micros()                      # CLOCK_MONOTONIC, microseconds
    millis()                      # CLOCK_MONOTONIC, milliseconds

	nanos(1)                      # CLOCK_MONOTONIC, list (sec, nsec)
    nanos(undef, 'realtime')      # CLOCK_REALTIME, nanoseconds
    nanos(1, 'realtime')          # CLOCK_REALTIME, list (sec, nsec)

    micros(undef, 'realtime')     # CLOCK_REALTIME, microseconds
    millis(undef, 'realtime')     # CLOCK_REALTIME, milliseconds

=cut
