#!/usr/bin/env perl

=head1 NAME

add_tab_to_db.pl - add tab separated file to Database

=head1 SYNOPSIS

    perl add_tab_to_db.pl [OPTION]... 

    -v, --verbose  use verbose mode
    --help         print this help message
    --file         tab separated file

Examples:

    perl add_tab_to_db.pl --file clients_banners.csv

=head1 DESCRIPTION

This program add tab separated file to table banners

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

=over 1

=item * Nikolay Mishin (L<MISHIN|https://metacpan.org/author/MISHIN>)

=back

=cut

use strict;
use warnings;
use 5.010;
use utf8;
use open qw/:std :utf8/;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd;
use FindBin '$RealBin';
use Log::Log4perl qw(:easy);

use Path::Tiny qw(path);


exit main();

sub main {

    # Argument parsing
    my $verbose = 0;    # frequently referred

    my $log_file = $RealBin . "/add_tab_to_db.log";

    #Init logging
    Log::Log4perl->easy_init(
        {   level  => $DEBUG,
            file   => ":utf8>>$log_file",
            layout => '%d %p> %m%n'
        }
    );

    #or you can pass it from command line
    my %options = (
        'verbose' => $verbose,
    );
    GetOptions(\%options, 'verbose', 'file=s',) or pod2usage(1);
    if (!exists $options{file}) {
        pod2usage(1);
    }
    add_file_to_db(\%options);
    return 0;
}

sub add_file_to_db {
    my ($options) = @_;
    my $filename  = $options->{file};

    my $file = path($filename);

    my $data = $file->slurp_utf8;
    $file->spew_utf8($data);
	
 my $msg =
      qq{replace in $filename with ...};
      INFO($msg);	
}

