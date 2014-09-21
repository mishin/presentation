#!/usr/bin/perl
use warnings;
use strict;
use Encode;

my @charsets = qw(utf-8 latin1 iso-8859-15 utf-16 iso-8859-7);

# some non-ASCII codepoints:
my $test = 'Ue: ' . chr(220) .'; Euro: '. chr(8364) . "\n";

for (@charsets){
    print "$_: " . encode($_, $test);
}