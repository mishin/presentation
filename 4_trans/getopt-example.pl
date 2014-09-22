#!/usr/bin/env perl

use strict;
use Getopt::Long qw< :config auto_version bundling no_ignore_case >;
use Pod::Usage;

my %Opt = (     # could use %ARGV if so inclined
    'dry-run' => 0,
    'verbose' => 0,
);

GetOptions(
    'dry-run|n' => \$Opt{'dry-run'},
    'verbose|v' => \$Opt{'verbose'},

    # Standard options
    'usage'  => sub { pod2usage(2) },
    'help'   => sub { pod2usage(1) },
    'manual' => sub { pod2usage( -exitstatus => 0, -verbose => 2 ) },
) or pod2usage(2);

__END__

=head1 NAME

getopt-example - example of using Getopt::Long with Pod::Usage

=head1 SYNOPSIS

=for pod2usage:
    This is printed as the usage line by pod2usage.

B<getopt-example> [I<OPTIONS>]

=head1 OPTIONS

=for pod2usage:
    This is printed for the help text by pod2usage.

=over

=item B<-n>, B<--dry-run>

Go through the motions, but don't do anything.

=item B<-v>, B<--verbose>

Enable verbose mode.

=item B<--version>

=item B<--usage>

=item B<--help>

=item B<--man>

Print the usual program information.

=back

=head1 DESCRIPTION

...

=cut
