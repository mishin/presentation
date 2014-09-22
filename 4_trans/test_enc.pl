#!/usr/bin/perl
 
use URI::Escape;
 
my $string = "Hello world!";
my $encode = uri_escape($string);
 
print "Original string: $string\n";
print "URL Encoded string: $encode\n";