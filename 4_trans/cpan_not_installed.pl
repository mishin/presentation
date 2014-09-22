#!/usr/bin/perl
use YAML::Tiny;
print join "\n", grep { eval("require $_"); $_ if $@; }
  keys %{ YAML::Tiny->read( $ARGV[0] || 'META.yml' )->[0]{requires} };
