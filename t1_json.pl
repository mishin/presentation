#!/usr/bin/perl
#from http://perltrap.com/ru/takoj-neprostoj-tsv/#.VOfWtDWspC0

use strict;
use warnings;

use JSON;

while(<>){
    my $data = eval{decode_json($_)};
    next unless $data;
    next unless is_interesting_id($data->{id}) && is_valid_int($data->{sum});
    print join("\t", $data->{id}, $data->{sum});
    print "\n";
}

sub is_interesting_id
{
    return $_[0] =~ /^5665[0-9]{7,13}$/ ? 1 : 0;
}

sub is_valid_int
{
    return $_[0] =~ /^[0-9]+$/ ? 1 : 0;
}
