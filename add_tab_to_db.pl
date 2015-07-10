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
use Text::CSV;
use Data::Dumper;
use DBI;

exit main();

sub main {

    # Argument parsing
    my $verbose = 0;    # frequently referred

    my $log_file = $RealBin . "/add_tab_to_db.log";

    #Init logging
    Log::Log4perl->easy_init(
        {
            level  => $DEBUG,
            file   => ":utf8>>$log_file",
            layout => '%d %p> %m%n'
        }
    );

    #or you can pass it from command line
    my %options = ( 'verbose' => $verbose, );
    GetOptions( \%options, 'verbose', 'file=s', ) or pod2usage(1);
    if ( !exists $options{file} ) {
        pod2usage(1);
    }
    add_file_to_db( \%options );
    return 0;
}

sub add_file_to_db {
    my ($options) = @_;
    my $filename  = $options->{file};
    my $tab_data  = read_csv($filename);
    add_data_to_banners($tab_data)
      or die "Unable to add data to banners table $!";
    my $msg = qq{read $filename with data } . Dumper($tab_data);
    INFO($msg);
}

sub add_data_to_banners {
    my ($data) = @_;

    my $dbh =
      DBI->connect( "dbi:SQLite:dbname=test.db", "", "", { RaiseError => 1 } )
      or die $DBI::errstr;

    my $insert_handle = $dbh->prepare('INSERT INTO banners VALUES (?,?,?)');
    die "Couldn't prepare queries; aborting" unless defined $insert_handle;

    #  start new transaction #
    $dbh->begin_work();

    foreach my $row (@$data) {
        $insert_handle->execute(@$row);
    }

    #  end the transaction #
    $dbh->commit();
    my $rc = $dbh->disconnect;
    return $rc;
}

sub read_csv {
    my ($file) = @_;
    my $csv = Text::CSV->new(
        {
            binary    => 1,
            auto_diag => 1,
            sep_char  => "\t",
        }
    );
    my @result = ();
    open( my $data, '<:encoding(utf8)', $file )
      or die "Could not open '$file' $!\n";

    while ( my $fields = $csv->getline($data) ) {
        push @result, $fields;
    }
    if ( not $csv->eof ) {
        $csv->error_diag();
    }
    close $data;
    return \@result;

}
