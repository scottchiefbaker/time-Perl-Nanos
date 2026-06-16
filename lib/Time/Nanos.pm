package Time::Nanos;

use strict;
use warnings;
use Exporter 'import';

our $VERSION = '0.01';
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
    my ($seconds, $nanoseconds) = nanos(1);

    my $microseconds            = micros();
    my $milliseconds            = millis();

=head1 FUNCTIONS

=head2 nanos

    my $ns = nanos();
    my ($sec, $nsec) = nanos(1);

Returns nanoseconds. In scalar context returns total nanoseconds. In list context
returns (seconds, nanoseconds).

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

Returns high resolution time via C<clock_gettime()>.

By default uses C<CLOCK_MONOTONIC>. Pass a second argument to select the clock:
C<'monotonic'> or C<'realtime'>.

=head1 USAGE

    nanos()                       # CLOCK_MONOTONIC, nanoseconds
    nanos(1)                      # CLOCK_MONOTONIC, list (sec, nsec)

    micros()                      # CLOCK_MONOTONIC, microseconds
    millis()                      # CLOCK_MONOTONIC, milliseconds

    nanos(undef, 'realtime')      # CLOCK_REALTIME, nanoseconds
    nanos(1, 'realtime')          # CLOCK_REALTIME, list (sec, nsec)

    micros(undef, 'realtime')     # CLOCK_REALTIME, microseconds
    millis(undef, 'realtime')     # CLOCK_REALTIME, milliseconds

=cut
