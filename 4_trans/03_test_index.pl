#!/usr/bin/env perl
######################################
#      $URL: http://mishin.narod.ru $
#     $Date: Mon Nov  7 18:52:21 2011 $
#   $Author: mishin nikolay $
# $Revision: 0.02 $
#   $Source: 01_test_index.pl $
#   $Description: Make test data for xml indexing $
##############################################################################
use strict;
use warnings;

our $VERSION = '0.02';    #other modules
use Carp;
use English qw(-no_match_vars);

#use Smart::Comments;
use FindBin;
use lib "$FindBin::Bin/lib";
use Test::More tests => 1;
use Test::Files;

use File::Slurp;
use IO::File;

my $count_xml     = 2;
my $test_file     = 'test_message.xml';
my $orig_idx_file = 'orig_test_message.xml.idx';

#generate test data
make_test( $count_xml, $test_file );
make_orig( $count_xml, $orig_idx_file );

#create index
create_index($test_file);
compare_ok( $test_file . q{.idx}, $orig_idx_file, "files are the same" );

sub create_index {
    my $filename = shift;

    my $start_tag   = '\<\?xml version="1.0" encoding="UTF-8"\?\>';
    my $end_tag     = '=== UTP_MESSAGE_END ===';
    my $tradeid_tag = 'TradeId';

    my @tags     = ( $start_tag, $end_tag, $tradeid_tag );
    my $ref_tags = \@tags;
    my $idx_file = $filename . q{.idx};
### $ref_tags
    # like stdio's fopen(3)
    my $fh = IO::File->new( $filename, 'r' )
      or die "Couldn't open $filename for read and write: $ERRNO\n";
    generate_index( $fh, $idx_file, $ref_tags );
    $fh->close();
    return 1;
}

sub generate_index {
    my ( $fh, $idx_file, $ref_tags ) = @_;
### $idx_file
    my ( $start_tag, $end_tag, $tradeid_tag ) = @{$ref_tags};

    my ( $start, $sysid, $end, $idx_out, $ret );

    my @idx_out = ();
    my $EMPTY   = q{};
    while ( my $line = $fh->getline() ) {
### $line;
        if ( $line =~ /$start_tag/ims ) {
            $start = $INPUT_LINE_NUMBER;
### $start
        }
        if ( $line =~ /\<$tradeid_tag\>(.*)\<\/$tradeid_tag\>/ims ) {
            $sysid = $1;
### $sysid
        }
        if ( $line =~ /$end_tag/ims ) {
            $end = $INPUT_LINE_NUMBER;
            if ($sysid) {
                push @idx_out, "$start,$end,$sysid\n";
### @idx_out
            }
        }
    }
    $idx_out = join $EMPTY, @idx_out;

    #    print $idx_out;
    $ret = write_file( $idx_file, $idx_out );
    return 1;
}

sub make_orig {
    my $max       = shift;
    my $orig_file = shift;
    my @data      = ();
    my $chunk;
    my $chunk_size = 7;
    my ( $start, $end, $sysid ) = ( 0, 0, '' );
    for my $tradeid ( 1 .. $max ) {
        $start = $end + 1;
        $end   = $start + $chunk_size;
        $sysid = "${tradeid}1486420L";
        $chunk = "$start,$end,$sysid\n";
        push @data, $chunk;
    }

    write_file( $orig_file, \@data );
    return 1;
}

sub make_test {
    my $max  = shift;
    my $file = shift;
    my @data = ();
    my $chunk;
    for my $tradeid ( 1 .. $max ) {
        $chunk = <<"END_XML";
<?xml version="1.0" encoding="UTF-8"?>
<GENERIC xmlns="x-schemas-db-com:utpxml/v1.0/utpxml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <TradeId>${tradeid}1486420L</TradeId>
  <TradeType>STYPE</TradeType>
  <message-size xmlns="">0184152</message-size>
</GENERIC>

=== UTP_MESSAGE_END ===
END_XML

        push @data, $chunk;
    }

    write_file( $file, \@data );
    return 1;
}
