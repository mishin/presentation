#!/usr/bin/env perl
use strict;
use warnings;
 
use utf8;
use Carp;
use lib qw(/rwa/data/team/MISHNIK/perl/utils/TimeDate-1.20/lib);
use Date::Parse;
use English qw(-no_match_vars);
 
our $VERSION = '0.01';
 
my $input_date    = '02-Apr-2011';
my $input_time    = str2time($input_date);
my $RGX_DATE_FULL = qr{(\d{2}-\w{3}-\d{4})}smo;
my $f_date;
while (<DATA>) {
    chomp;
    my $file_name = $_;
    if ( $file_name =~ $RGX_DATE_FULL ) {
        $f_date = $1;
        my $f_time = str2time($f_date);
        if ( $f_time >= $input_time ) {
            print $file_name, " found \n";
        }
    }
 
}
 
__DATA__
N1089767N_7_SWOPT_03-Jul-2011_78919186.xml
N1089767N_7_SWOPT_25-Jun-2011_72745892.xml
N1089772L_9_SWOPT_03-Jul-2011_78979055.xml
N1089772L_9_SWOPT_01-Apr-2011_78979055.xml
N1089772L_9_SWOPT_02-Apr-2011_78979055.xml
N1089772L_9_SWOPT_22-Apr-2011_78979055.xml
N1089772L_9_SWOPT_30-Apr-2011_78979055.xml
N1089772L_9_SWOPT_20-Jul-2011_69380887.xml
N1089772L_9_SWOPT_29-Jun-2011_74754662.xml
message.110530033311A4259348AS26.A4259348AS_26_SWOPT_01-Jul-2011.xml
message.110530033311A4259348AS26.A4259348AS_26_SWOPT_31-May-2011.xml
A4259348AS_26_SWOPT_29-Jun-2011_74754662.xml
N1089772L_9_SWOPT_03-Feb-2011_78979055.xml
N1089772L_9_SWOPT_01-Mar-2011_78979055.xml
N1089772L_9_SWOPT_02-Jan-2011_78979055.xml
N1089772L_9_SWOPT_22-Feb-2011_78979055.xml