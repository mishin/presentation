use Modern::Perl;
use Win32::Unicode::Console;
# use open qw/:std :utf8/;
# binmode(STDIN, ':encoding(cp866)');
# binmode(STDOUT,':encoding(cp866)');
# use utf8;
# use encoding 'utf8';
# use Devel::Peek;
#спасибо http://habrahabr.ru/post/163439/
# http://habrahabr.ru/users/kshiian/
use Encode::Locale;
use Encode;
use encoding 'utf8';
# if (-t) 
# {
    # binmode(STDIN, ":encoding(console_in)");
	# binmode(STDOUT, ":encoding(console_out)");
	# binmode(STDERR, ":encoding(console_out)");
# }
# use open IN => ':encoding(utf8)';
# use open OUT => ':encoding(cp866)';
# use Encode;
# use open OUT => ':encoding(cp1251)';
my $x = "cat dog house"; # 3 слова
    while ($x =~ /(\w+)/g) {
        printW "Слово $1, заканчивается в позиции ", pos $x, "\n";
        # print Encode::from_to(("Слово $1, заканчивается в позиции ". pos( $x). "\n"),'utf8','cp866');
    }
	
# Dump $x;	
