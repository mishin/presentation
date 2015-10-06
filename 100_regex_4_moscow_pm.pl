#!/usr/bin/env perl
use utf8;
use Modern::Perl;
use Encode::Locale qw(decode_argv);

 if (-t) 
{
    binmode(STDIN, ":encoding(console_in)");
    binmode(STDOUT, ":encoding(console_out)");
    binmode(STDERR, ":encoding(console_out)");
}

Encode::Locale::decode_argv();
my $lang = shift or die "Usage: $0 What_is_your_language?\n"; 

 $lang =~ /
 (perl|перл) 
 (?{print "use Perl or die!!\nИспользуй Перл или умри!!";}) 
          /ix;






