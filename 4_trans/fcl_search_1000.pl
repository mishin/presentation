#!/usr/bin/env perl
######################################
#      $URL: http://mishin.narod.ru $
#     $Date: Mon Nov  7 18:52:21 2011 $
#   $Author: mishin nikolay $
# $Revision: 0.02 $
#   $Source: 03_test_index.pl $
#   $Description: Make test data for xml indexing $
# set PERL5DB='use Devel::NYTProf'
# set NYTPROF=trace=2:start=init:file=nytprof.out
# perl -d:NYTProf fcl_search.pl
# nytprofhtml
# nytprof/index.html #отчет
#
# # http://blog.timbunce.org/2009/12/24/nytprof-v3-worth-the-wait/
# http://www.slideshare.net/Tim.Bunce/develnytprof-200907
# http://blip.tv/timbunce/nytprof-v3-ipw-2009-2860609)
#
# #  моим идеалом, в частности, является https://github.com/xsawyerx/module-starter/blob/master/bin/module-starter
#
##############################################################################
use strict;
use warnings;

our $VERSION = '0.02';    #other modules
use Carp;
use English qw(-no_match_vars);

use Smart::Comments;
use FindBin;
use lib "$FindBin::Bin/lib";
use FindBin '$Bin';
use YAML::Tiny;
use Test::More tests => 1;
use Test::Files;
use File::Slurp;
use IO::File;
use English qw(-no_match_vars);

my $config_name   = 'trade.yml';
#read config
my $yaml      = YAML::Tiny::LoadFile( $Bin . qq{/} . $config_name );
my @tags      = @{ $yaml->{tags_4_index} };
my $start_tag = shift @tags;
my $count_xml     = 10000;
my $test_file     = 'test_message.xml';
my $orig_idx_file = 'orig_test_message.xml.idx';
my $commit_size   = 1000;


#generate test data
make_test( $count_xml, $test_file );
make_orig( $count_xml, $orig_idx_file );

#create index
create_index($test_file);
compare_ok( $test_file . q{.idx}, $orig_idx_file,
    "index creates successfully" );

sub create_index {
    my $filename = shift;

    my $idx_file = $filename . q{.idx};
    my $fh = IO::File->new( $filename, 'r' )
      or die "Couldn't open $filename for read and write: $ERRNO\n";
    generate_index( $fh, $idx_file );
    $fh->close();
    return 1;
}

sub generate_index {
    my ( $fh, $idx_file ) = @_;

    my ( $idx_out, $start, %empty, @in_add_2_index, $value_of );

    my $num = 0;
    while ( my $line = <$fh> ) {
        $num++;
        for my $tag (@tags) {
            if ( $line =~ /\<$tag\>(.*)\<\/$tag\>/ims ) {
                $value_of->{$tag} = $1;
            }
        }

        if ( ( $line =~ /\Q$start_tag\E/ims ) or (eof) ) {
            my @index_row =
              ( $idx_out, $start, $num, eof, $value_of, $idx_file );
            $idx_out = add_2_index( \@index_row );
            $start   = $num;
        }
    }
    return 1;
}

sub add_2_index {
    my ( $idx_out, $start, $num, $eof, $value_of, $idx_file ) = @{ $_[0] };
    my ( $end, $idx_empty );
    if ($eof) {
        $end = $num;
    }
    else {
        $end = $num - 1;
    }
    my @tag_value = ();
    my $size      = keys %$value_of;
    if ( $size > 0 ) {
        for my $tag (@tags) {
            push @tag_value, $value_of->{$tag};
        }
        my $idx_row = make_string( $start, $end, @tag_value );
        push @$idx_out, $idx_row;

        if ( $size > $commit_size ) {    #commit every 1000 lines
            my $ret = append_file( $idx_file, $idx_out );
            $idx_out = $idx_empty;
        }
    }
    return $idx_out;
}

#make_index_string ($start, $end,$sysid, $ver,$tradetype);
sub make_string {
    my @input      = @_;
    my @input_init = map { !defined $_ ? '' : $_ } @input;
    my $rezult     = join q{,}, @input_init;
    return $rezult . "\n";
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
        $end   = $start + $chunk_size + 1;
        $sysid = "${tradeid}1486420L,${tradeid}56,STYPE";
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
  <Version>${tradeid}56</Version>
  <message-size xmlns="">0184152</message-size>
</GENERIC>

=== UTP_MESSAGE_END ===
END_XML

        push @data, $chunk;
    }

    write_file( $file, \@data );
    return 1;
}