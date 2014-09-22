#!/usr/bin/perl

use strict;
use warnings;
use lib qw(/rwa/data/team/MISHNIK/perl/utils/lib);
use File::Slurp qw( :std );
use Perl6::Say;
use Getopt::Long;
use Pod::Usage;

my $man  = 0;
my $help = 0;
my $file_name;

GetOptions(
    'help|?'        => \$help,
    'man'           => \$man,
    'file_name|f=s' => \$file_name,
);



pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;
&pod2usage(2) if !defined $file_name;

my %months;
@months{ '01' .. '12' } = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );

my @tag_names = (
    'version',         'cob_date', 'legal_entity', 'book',
    'management_area', 'isin',     'product_type', 'ccy',
    'pv_ccy'
);

#my $file_name = '06-MAR-2012.csv';    #shift;
#my $file_name = '06-MAR-2012_test.csv';    #shift;

make_whole_doc($file_name);

sub make_whole_doc {
    say '<?xml version="1.0" encoding="UTF-8"?>
<rows>';
    main(shift);
    say '</rows>
';
}

sub main {
    my $file_name = shift;
    my @dare_records = read_file( $file_name, chomp => 1 );

    #all lines except first;
    my @dare_data = @dare_records[ 1 .. $#dare_records ];

    my %curr_values;

    for my $rec (@dare_data) {

        $rec =~ s/"//g;
        $rec =~ s/,/./g;
        $rec =~ s/\r//g;
        $rec =~ s/\n//g;
        @curr_values{@tag_names} = split /;/, $rec;

        say '  <row>';
        make_row( \%curr_values );
        say '  </row>';
    }
}

sub make_row {
    my $ref_curr_values = shift;
    my %curr_values     = %{$ref_curr_values};
    for my $tag (@tag_names) {
        my $value;
        $value = $curr_values{$tag};
        $value = convert_date($value) if $tag eq 'cob_date';
        say '    ' . get_tag( $value, $tag );
    }

}

sub convert_date {

    #    return $format->parse_datetime(shift)->strftime("%d-%b-%Y");
    my ( $date, $mon, $year ) = split /\./, shift;
    return "$date-$months{$mon}-$year";
}

sub get_tag {
    my ( $value, $tag_name ) = @_;
    if ( length($value) == 0 ) {
        return '<' . $tag_name . ' isNull="true" />';
    }
    else {
        return "<$tag_name>$value</$tag_name>";
    }
}

__END__

=head1 NAME

dare_convert.pl - A utility to convert Fbs Dare csv file to xml.

=head1 SYNOPSIS

dare_convert.pl [--file_name <file>  --help --man] > [out_file]

    Options:
        --input_file|-f   Input file in csv format
        --help       brief help message
        --man        full documentation



=head1 DESCRIPTION

This program is used for task to convert Dare csv to xml

https://wiki.tools.intranet.db.com/confluence/display/FCL/FBS+Production+Life+Cycle

=head1 AUTHOR

Nikolay Mishin mi@ya.ru

=head1 COPYRIGHT

© 2012 Deutsche Bank AG, Frankfurt am Main.

All rights reserved.

=cut
