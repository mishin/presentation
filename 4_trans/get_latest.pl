#!/usr/bin/env perl
######################################
#      $URL: http://mishin.narod.ru $
#     $Date: 2011-09-14 19:53:20 +0300 (Web, 14 Sep 2011) $
#   $Author: mishin nikolay $
# $Revision: 1.02 $
#   $Source: get_latest.pl $
#   $Description: Sort trades and get latest $
##############################################################################
use strict;
use warnings;

use utf8;
use Data::Dumper;
use Carp;
use English qw(-no_match_vars);

our $VERSION = '0.01';

my $RGX_SHORT_MESS = qr/^(\w+)_(\d{2})-(\w{3})-(\d{4})_(\d+)/smo;
my $RGX_LONG_MESS  = qr/^message[.](\w+)[.](\w+)_(\d{2})-(\w{3})-(\d{4})/smo;

#create month hash
my %months;

# two symbol for correct literal matching
@months{qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec )} =
  ( '00' .. '11' );

my ( $result, $index );

my $file = shift;    #'file_names.txt';
open my $fh, q{<}, $file or croak "unable to open:$file $ERRNO";
process_data($fh);    #my @file_names = <$fh>;
close $fh or croak "unable to close: $file $ERRNO";

sub process_data {
    my ($fh) = @_;
    while ( my $str = <$fh> ) {

        chomp $str;
        my $search_str = $str;
        my $trade_id;

        if ( $search_str =~ s/$RGX_SHORT_MESS/$4-$months{$3}-$2:$5/sm ) {
            $trade_id = $1;
        }
        elsif ( $search_str =~ s/$RGX_LONG_MESS/$5-$months{$4}-$3:$1/sm ) {
            $trade_id = $2;
        }
        else { next }

        # so, from now we are search BIGGEST value & ignore less
        next
          if ( exists $index->{$trade_id}
            && ( $index->{$trade_id} gt $search_str ) );

        $index->{$trade_id}  = $search_str;
        $result->{$trade_id} = $str;

    }

    # $result

    foreach ( reverse sort keys %{$result} ) {
        print $result->{$_} . "\n";
    }
    return;
}
__DATA__
N1089767N_7_SWOPT_03-Jul-2011_78919186.xml
N1089767N_7_SWOPT_25-Jun-2011_72745892.xml
N1089772L_9_SWOPT_03-Jul-2011_78979055.xml
N1089772L_9_SWOPT_20-Jul-2011_69380887.xml
N1089772L_9_SWOPT_29-Jun-2011_74754662.xml
message.110530033311A4259348AS26.A4259348AS_26_SWOPT_01-Jul-2011.xml
message.110530033311A4259348AS26.A4259348AS_26_SWOPT_31-May-2011.xml
A4259348AS_26_SWOPT_29-Jun-2011_74754662.xml
