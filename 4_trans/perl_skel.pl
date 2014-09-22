#!/usr/bin/perl

=head1 NAME

simplee - simple program

=head1 SYNOPSIS

    simple [OPTION]... FILE...

    -v, --verbose  use verbose mode
    --help         print this help message

Where I<FILE> is a file name.

Examples:

    simple /etc/passwd /dev/null

=head1 DESCRIPTION

This is as simple program.

=head1 AUTHOR

Me.

=cut

use strict;
use warnings;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;

exit main();

sub main {

    # Argument parsing
    my $verbose;
    GetOptions( 'verbose' => \$verbose, ) or pod2usage(1);
    pod2usage(1) unless @ARGV;
    my (@files) = @ARGV;

    foreach my $file (@files) {
        if ( -e $file ) {
            printf "File $file exists\n" if $verbose;
        }
        else {
            print "File $file doesn't exist\n";
        }
    }

    return 0;
}
