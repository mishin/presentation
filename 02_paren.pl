use Benchmark qw(cmpthese);

use strict;
use warnings;

use vars qw($recursive_regex);

my $str = "0"x50 . "1"x50;
$recursive_regex = qr/0(??{$recursive_regex})*1/;

sub recursive {
  if ($str =~ /^$recursive_regex$/) {
    # do nothing - printing to stdout would
    # be the most expensive operation here
  }
}

sub non_recursive {
  $str =~ /^(0*)/;
  my $num_zeroes = length $1;
  if ($str =~ /^0{$num_zeroes}1{$num_zeroes}$/) {
    # do nothing
  }
}

cmpthese(400000,
     {
     recursive => \&recursive,
     non_recursive => \&non_recursive,
     });
