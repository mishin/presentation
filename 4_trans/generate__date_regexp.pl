#!/usr/bin/env perl
######################################
#      $URL: http://mishin.narod.ru $
#     $Date: 2011-10-12 19:53:20 +0300 (Web, 14 Sep 2011) $
#   $Author: mishin nikolay $
#   $Revision: 1.02 $
#   $Source: gen_date_regexp.pl $
#   $Description: generate regexp basically on date $
#   give 02-Apr-2011 as input
#       Start date limiting the the search scope, i.e. this allows
#       to ignore versions received earlier than the specified date (optional)
#   regexp must be as
#    'qr/.*2011.*[^xg]{1}.zip$/'
##############################################################################
use strict;
use warnings;

use utf8;
use Data::Dumper;
use Carp;
use Time::Local;
use POSIX;
use Smart::Comments;

use English qw(-no_match_vars);
use Regexp::Assemble;

our $VERSION = '0.01';

my $input_date = '02-Apr-2011';

#TODO:generate regexp for period 02-Apr-2011..04-May-2012

#create month hash
my %months;

# two symbol for correct literal matching
@months{qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec )} =
  ( '01' .. '12' );

my $RGX_DATE = qr{(\d{2})-(\w{3})-(\d{4})}smo;
my ( $day, $mon_word, $mon, $year );


#invoke chunks from input date
if ( $input_date =~ /$RGX_DATE/sm ) {
    ( $day, $mon_word, $year ) = ( $1, ucfirst($2), $3, );
    $mon = $months{$mon_word};
}
### $year
### $mon
my $max_day = get_mon_len( $year, $mon );
### $max_day;



#generate test data for generate regexp
my @test_file_name = ();
for my $day ( $day .. $max_day ) {
    push @test_file_name,
      sprintf( '%02d', $day ) . '-' . $mon_word . '-' . $year;
}

my $re = Regexp::Assemble->new->add(@test_file_name);

my @month        = keys %months;
my @next_monthes = ();


#generate months after current month
for my $curr_mon (@month) {
    if ( $months{$curr_mon} > $mon ) {
        push @next_monthes, $curr_mon;
    }
}

my $regex_mon = join '|', @next_monthes;

print "$re\n";    #(?-xism:(?:0[23456789]|[12]\d|30)-Apr-2011)
my $RGX_LATE_FILE = qr{$re|([0-9]{2}-$regex_mon)}smo;

print "$RGX_LATE_FILE\n"
  ; #(?ms-xi:(?-xism:(?:0[23456789]|[12]\d|30)-Apr-2011)|([0-9]{2}-Sep|May|Jul|Jun|Nov|Aug|Dec|Oct))

while (<DATA>) {
    chomp;
    my $file_name = $_;
    if ( $file_name =~ $RGX_LATE_FILE ) {
        print $file_name, " found \n";
    }
}

#calculate day in month
sub get_mon_len {
    my ( $year, $month ) = (@_);
    do { warn "Invalid month: $month\n"; next }
      if $month > 12 or $month < 1;
    my $next_year = ( $month == 12 ) ? $year + 1 : $year;
    my $next_month = timelocal( 0, 0, 0, 1, $month % 12, $next_year );
    my $days = ( localtime( $next_month - 86_400 ) )[3];
    return $days;
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
