#!/usr/bin/perl    
use Modern::Perl;

my $i = 1;
while ($i & 8 == 0 || $i & 256 == 0){
    ++$i;
    }
    print $i, "\n";
