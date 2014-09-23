#!/usr/bin/env perl
use utf8;
use Modern::Perl;
use Encode::Locale;
use Encode qw( decode encode from_to);
use Encode::Detect::Detector;
use Data::Dumper qw( Dumper ); 

 
if (-t) 
{
    binmode(STDIN, ":encoding(console_in)");
	binmode(STDOUT, ":encoding(console_out)");
	binmode(STDERR, ":encoding(console_out)");
}

my $lang = shift or die "Usage: $0 What_is_your_language?\n"; 
my_dump('lang_01',$lang);
$lang = decode(locale => $lang);
my_dump('lang_02',$lang);
my_dump('lang_03_перл',qq{перл});

 $lang =~ /(perl|перл) (?{print "use Perl or die!!\nИспользуй Перл или умри!!";}) /ix;#русский не мачится, почему?
 
 sub my_dump
 { 
 my ($name,$var)=@_;
 local $Data::Dumper::Useqq = 1;
 local $Data::Dumper::Indent = 0; 
 local $Data::Dumper::Terse = 1; 
 print(Encode::Detect::Detector::detect(qq{$lang})." ".qq{\$$name }." dump=".Dumper($var)."\n");
 }
