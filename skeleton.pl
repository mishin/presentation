#!/usr/bin/env perl #your script is more portable

=head1 NAME

replace_date.pl - replace LOADING_DT in Datastage parameter file

=head1 SYNOPSIS

    perl replace_date.pl [OPTION]... 

    -v, --verbose  use verbose mode
    --help         print this help message
    --date         date in '2015-02-24'
    --file         path to file

Examples:

    perl replace_date.pl --date "2015-02-24" --file "c:/Users/rb102870/Documents/job/29052015/paramfile_test.txt"

=head1 DESCRIPTION

This program replace date LOADING_DT parameter in parameter file.

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

    my $log_file = $RealBin . "/loading_dt.log";

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
    GetOptions(\%options, 'verbose', 'date=s', 'file=s',) or pod2usage(1);
    if (!exists $options{date} || !exists $options{file}) {
        pod2usage(1);
    }
    replace_loading_dt(\%options);
    return 0;
}

sub replace_loading_dt {
    my ($options) = @_;
    my $filename  = $options->{file};
    my $new_date  = $options->{date};

    my $file = path($filename);

    my $data = $file->slurp_utf8;
    $data =~ s/(LOADING_DT=).*/${1}${new_date}/g;
    $file->spew_utf8($data);
	
 my $msg =
      qq{replace in $filename with LOADING_DT=${new_date} done...};
      INFO($msg);	
}

# 2015-02-24
# 2015-02-25
# 2015-03-03
