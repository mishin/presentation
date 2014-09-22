#!/usr/bin/perl

use strict;
use warnings;

use YAML::Tiny;
use Data::Dumper;

if(!@ARGV) {
        print STDERR "Give me a file to parse.\n";
        exit 1;
}

my $yaml_file = shift @ARGV;

my $yaml = YAML::Tiny->new;
$yaml = YAML::Tiny->read($yaml_file);

print Dumper($yaml);

exit 0;