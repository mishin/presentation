#!/usr/bin/env perl
use strict;
use warnings;

use 5.010;
use utf8;
use Carp;
use Date::Parse;
use English qw(-no_match_vars);

our $VERSION = '0.01';

my @list = qw(1000 2000 3000);

#say "@list";
# if ( '1000' ~~ @list ) {
# say 'done';
# }

#s (say 2011-11-01 00:00:00 to 2011-11-15 00:00:00).

my $start_date = str2time('2011-11-01 00:00:00');
my $end_date   = str2time('2011-11-15 00:00:00');

#my $input_time    = str2time($input_date);
my $RGX_FOUR_FULL = qr{"([^"]+)","([^"]+)","([^"]+)","([^"]+)","([^"]+)"}smo;
my $RGX_DATE_FULL = qr{.*"(\d{4}-\w{2}-\d{2} \d{2}:\d{2}:\d{2})".*}smo;
my @input_data    = <DATA>;

my @res =
  grep {
          extract_time($_) >= $start_date
      and extract_time($_) <= $end_date
      and ( extract_four($_) ~~ @list )
  } @input_data;

# my @res2 = ();

# # # for my $line (@res) {

# # # #     #    say 'extract_four:' . extract_four($line) . 'ZZ';
# # if ( extract_four($line) ~~ @list ) {
# # push @res2, $line;
# # }

# # # # }

# # @res2 =
# grep { extract_four($_) ~~ @list } @res;

#say 'Z';
print @res;

#say 'Z';

sub extract_time {
    my ($search_str) = @_;
    $search_str =~ s/$RGX_DATE_FULL/$1/sm;
    return str2time($search_str);
}

sub extract_four {
    my ($search_str) = @_;
    $search_str =~ s/$RGX_FOUR_FULL/$4/sm;
    chomp($search_str);

    #print $search_str;
    return $search_str;
}

__DATA__
"00000089-6d83-486d-9ddf-30bbbf722583","2011-08-17 16:25:09","INTNAME","1001","https://mobile.mint.com:443"
"00000089-6d83-486d-9ddf-30bbbf722583","2011-09-17 16:25:09","INTNAME","1001","https://mobile.mint.com:443"
"000004c9-92c6-4764-b320-b1403276321e","2011-11-09 13:52:30","INTNAME","2000","http://m.intel.com/content/intel-us/en/shop/shop-landing.html?t=laptop&p=13"
"000004c9-92c6-4764-b320-b1403276321e","2011-11-10 14:52:30","INTNAME","4000","http://m.intel.com/content/intel-us/en/shop/shop-landing.html?t=laptop&p=13"
"000004c9-92c6-4764-b320-b1403276321e","2011-11-09 13:52:30","INTNAME","3000","http://m.intel.com/content/intel-us/en/shop/shop-landing.html?t=laptop&p=13"
