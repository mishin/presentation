#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

BEGIN {

    eval { require Data::Dumper; Data::Dumper::Dumper(1) } and *dd = sub ($) {
        Data::Dumper->new( [ $_[0] ] )->Indent(0)->Terse(1)->Quotekeys(0)
          ->Useqq(1)->Purity(1)->Dump;
      }
      or *dd = \&explain;
}

#можно с помощью модуля
use Sort::Maker;
my @array_of_hash = (
    { name => 'Moscow' },
    { name => 'Amsterdam' },
    { name => 'AMsterdam' },
    { name => 'AmstErdam' },
    { name => 'Bonn' },
    { name => 'New York' },
    { name => 'Vladivostok' }
);

my $sorter1 = make_sorter(
    'ST',
    name   => 'townSorter',
    string => { code => '$_->{name}', }
);

my @sorted_array_of_hash = townSorter(@array_of_hash);
diag '1.', dd( \@sorted_array_of_hash ), "\n";

#можно обычным сортом
my @sorted_array_of_hash2 = sort { $a->{name} cmp $b->{name} } @array_of_hash;
diag '2.', dd( \@sorted_array_of_hash2 ), "\n";

# $a->{name} cmp $b->{name}
#а можно и порегулировать слова с каким буквами (большими или маленькими) будут первыми
my @sorted_array_of_hash3 =
  sort {
         ( lc( $a->{name} ) cmp lc( $b->{name} ) )
      or ( $a->{name} cmp $b->{name} )
  } @array_of_hash;

diag '3.', dd( \@sorted_array_of_hash3 ), "\n";

