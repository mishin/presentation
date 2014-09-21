#!/usr/bin/env perl
use utf8;
use Modern::Perl;
use Encode::Locale;
use Encode qw( decode encode from_to);
# use Win32::Unicode::Console;!!!
use Text::Iconv;
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
my $converter = Text::Iconv->new( "cp1251", "utf-8");
$lang = $converter->convert($lang);
my_dump('lang_02',$lang);
$lang = Encode::decode("utf8",$lang);
my_dump('lang_03',$lang);
my_dump('lang_04_перл',qq{перл});
# say $lang;
# say qq{перл};
# # my_dump('lang_01',$lang);#01

 $lang =~ /(perl|перл) (?{print "use Perl or die!!\nИспользуй Перл или умри!!";}) /ix;#русский не мачится, почему?
 
 sub my_dump
 { 
 my ($name,$var)=@_;
 local $Data::Dumper::Useqq = 1;
 local $Data::Dumper::Indent = 0; 
 local $Data::Dumper::Terse = 1; 
 print(Encode::Detect::Detector::detect(qq{$lang})." ".qq{\$$name }." dump=".Dumper($var)."\n");
 # say ;
 # print('my $lang = '.Dumper($lang)."\n");
 # print('my $perl = '.Dumper(qq{перл})."\n");
 }
 #http://stackoverflow.com/questions/14453820/convert-an-iso-8859-1-symbol-in-a-string-to-utf-8-in-perl

 # perl -MEncode::Detect::Detector -E "say Encode::Detect::Detector::detect(qq{перл})"
 
 # perl -MEncode::Detect::Detector -MFile::Slurp -E "say Encode::Detect::Detector::detect(read_file( q{100_regex.pl} ))"
 
 # perl conver  ISO-8859-7 to UTF-8
