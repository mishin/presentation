#!/usr/bin/env perl
use utf8;
use Modern::Perl;
use Encode::Locale;
use Encode qw( decode encode from_to);
use Win32::Unicode::Console;
# each open() automatically uses :encoding(iso-8859-7)
# use open ':encoding(iso-8859-7)';

# use MIME::QuotedPrint ();
 use Convert::Cyrillic;
# use encoding 'utf8';
# use encoding 'cp1251', STDOUT=>'cp866';
# use STDOUT=>'cp866';
# binmode(STDOUT, ":encoding(cp866)");#!!
 # use open ':encoding(iso-8859-7)';

# if (-t) 
# {
    # binmode(STDIN, ":encoding(console_in)");
	# binmode(STDOUT, ":encoding(console_out)");
	# binmode(STDERR, ":encoding(console_out)");
# }
# use open IO  => ":encoding(iso-8859-7)";
	  # use open IO => ':locale';
 my $lang = shift or die "Usage: $0 What_is_your_language?\n"; 
 # use Unicode::String qw(utf8 latin1 utf16be);
 # $u = utf8("string");
 # my $u = latin1("$lang");
 # $u = utf16be("\0s\0t\0r\0i\0n\0g");

 # print $u->utf32be;   # 4 byte characters
 # print $u->utf16le;   # 2 byte characters + surrogates
 # print $u->utf8;      # 1-4 byte characters
 # print $u->utf8;      # 1-4 byte characters
 # $lang= $u->utf8;      # 1-4 byte characters
   # use Encode qw(encode decode);
# my $iso_data=$lang;
    # my $utf8_data=encode('UTF-8',decode('iso-8859-7',$iso_data));
 
 # $lang = Encode::encode("ISO-8859-7", $lang);
 # $lang= Convert::Cyrillic::cstocs ("ISO", "WIN", $lang);
 use Text::Iconv;
 $lang= Convert::Cyrillic::cstocs ("ISO", "UTF-8", $lang);
my $converter = Text::Iconv->new( "cp1251", "utf-8");
 $lang = $converter->convert($lang);
  $lang = Encode::decode("utf8",$lang);
 # utf8::_utf_off($lang);
 # Encode::from_to($lang, 'windows-1251', 'utf-8');
 
 # $lang = encode("utf8", $lang);
 # $lang = encode_utf8($lang);
 # $lang = decode( 'utf8', $lang );
 # decode('cp1251')
 # decode (' cp1251 ', 
# from_to($lang, "cp1251", "utf8");
   # $lang = encode("utf8", decode("iso-8859-7", $lang));
    # $lang = encode("utf8", decode("cp1251", $lang));
   # from_to($lang, "iso-8859-7", "utf8"); #1
   # Encode::decode_utf8
     # $lang = decode 'UTF-8', $lang, sub {
     # my $tmp = chr shift;
     # from_to $tmp, 'ISO-8859-7', 'UTF-8';
     # return $tmp;
     # };
# $lang = MIME::QuotedPrint::encode($lang);
# $lang = MIME::QuotedPrint::decode($lang);

	
	# say utf8::is_utf8($lang);
	# say utf8::is_utf8("перл");
   ###http://perldoc.perl.org/Encode.html#The-UTF8-flag
   #
use Encode::Detect::Detector;
sayW "input var: ".Encode::Detect::Detector::detect(qq{$lang});
sayW "sourse var: ".Encode::Detect::Detector::detect(qq{перл});
sayW $lang;
sayW qq{перл};
 $lang =~ /(perl|перл) (?{print "use Perl or die!!\n";}) /ix;#русский не мачится, почему?
 
 use Data::Dumper qw( Dumper ); 
 { local $Data::Dumper::Useqq = 1;
 local $Data::Dumper::Indent = 0; 
 local $Data::Dumper::Terse = 1; 
 print('my $lang = '.Dumper($lang)."\n");
 print('my $perl = '.Dumper(qq{перл})."\n");
 }
 #http://stackoverflow.com/questions/14453820/convert-an-iso-8859-1-symbol-in-a-string-to-utf-8-in-perl

 # perl -MEncode::Detect::Detector -E "say Encode::Detect::Detector::detect(qq{перл})"
 
 # perl -MEncode::Detect::Detector -MFile::Slurp -E "say Encode::Detect::Detector::detect(read_file( q{100_regex.pl} ))"
 
 # perl conver  ISO-8859-7 to UTF-8
