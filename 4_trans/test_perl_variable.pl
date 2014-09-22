#!/usr/bin/env perl
######################################
#      $URL: http://mishin.narod.ru $
#     $Date: 2011-12-23 19:53:20 +0300 (Web, 14 Sep 2011) $
#   $Author: mishin nikolay $
# $Revision: 1.02 $
#   $Source: convert_var_to_yaml.pl $
#   $Description: convert perl variables to yaml format $
##############################################################################
use YAML::Tiny;
my @input_data    = <DATA>;
my $RGX_PERL_VAR = qr{"([^"]+)","([^"]+)","([^"]+)","([^"]+)","([^"]+)"}smo;
my $RGX_DATE_FULL = qr{.*"(\d{4}-\w{2}-\d{2} \d{2}:\d{2}:\d{2})".*}smo;
my @res =
  grep {
          extract_time($_) >= $start_date
      and extract_time($_) <= $end_date
      and ( extract_four($_) ~~ @list )
  } @input_data;
sub extract_perl_variables {
    my ($search_str) = @_;
    $search_str =~ s/$RGX_DATE_FULL/$1/sm;
    return str2time($search_str);
}
__DATA__
my $count_xml     = 10000;
my $test_file     = 'test_message.xml';
my $orig_idx_file = 'orig_test_message.xml.idx';
my $commit_size   = 1000;
