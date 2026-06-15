package Time::Hrtime;

use strict;
use warnings;
use Exporter 'import';

our $VERSION = '0.01';
our @EXPORT  = qw(hrtime);

require XSLoader;
XSLoader::load('Time::Hrtime', $VERSION);

1;

__END__

=head1 NAME

Time::Hrtime - Nanosecond time resolution via clock_gettime().

=head1 SYNOPSIS

    use Time::Hrtime;

    my $nanoseconds             = hrtime();
    my ($seconds, $nanoseconds) = hrtime(1);

    my $rt_ns                   = hrtime(undef, 'realtime');
    my ($rt_sec, $rt_nsec)      = hrtime(1, 'realtime');

=head1 DESCRIPTION

Returns high resolution time via C<clock_gettime()>.

By default uses C<CLOCK_MONOTONIC>. Pass a second argument to select the clock:
C<'monotonic'> or C<'realtime'>.

=head1 USAGE

    hrtime()                       # CLOCK_MONOTONIC, nanoseconds
    hrtime(1)                      # CLOCK_MONOTONIC, list (sec, nsec)

    hrtime(undef, 'realtime')      # CLOCK_REALTIME, nanoseconds
    hrtime(1, 'realtime')          # CLOCK_REALTIME, list (sec, nsec)

=cut
