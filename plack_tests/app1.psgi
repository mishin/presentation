#!/usr/bin/perl
use strict;
use warnings;
 
use Data::Dumper qw(Dumper);
$Data::Dumper::Sortkeys = 1;
 
my $app = sub {
  my $env = shift;
  return [
    '200',
    [ 'Content-Type' => 'text/plain' ],
    [ Dumper $env ],
  ];
};