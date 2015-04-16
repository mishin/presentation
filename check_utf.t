http://sr-pereezd.ru/pereezd-kvartiry?utm_source=direct&utm_medium=cpc&utm_term=%D0%BD%D0%B5%D0%B4%D0%BE%D1%80%D0%BE%D0%B3%D0%B8%D0%B5_%D0%BF%D0%B5%D1%80%D0%B5%D0%B5%D0%B7%D0%B4%D1%8B_%D0%BA%D0%B2%D0%B0%D1%80%D1%82%D0%B8%D1%80&utm_campaign=9749448&_openstat=ZGlyZWN0LnlhbmRleC5ydTs5NzQ5NDQ4OzQ2Mjk5MzkzMzt5YW5kZXgucnU6cHJlbWl1bQ&yclid=5853644710439358136

+ 7 (499) 398 29 31

INSERT INTO NCI.SRC_STM
  VALUES (70, 'DATAHUB ABS', 'DATAHUB ABS', '1900-01-01', '9999-12-31',
    'DATAHUB STL', NULL); 
	
	cover -ignore_re '[.]t$|prove'
	
	devdwh
	
	10 7 26 23 секретариат отвертка!!
	
	INSERT INTO NCI.SRC_STM (SRC_STM_ID, SRC_STM_CODE, EFF_DT, END_DT,
  NM)
  VALUES (82, 'ABS_BCE', '1900-01-01', '9999-12-31', 'АБС для BCE');
  commit;
	
	1.	АБС делим на два источника:
a.	АБС для BCE (список объектов, которые туда попадают смотри ниже)
b.	АБС все остальное
2.	Соответственно для этих двух источников теперь существует два флага:
a.	591510 – новый флаг для АБС для BCE
b.	550010 – старый флаг, который выставляется автоматически в 2 часа ночи
3.	Новый флаг тоже должен выставляться автоматически в 2 часа ночи (тебе надо это доработать, чтобы он выставлялся)

BEGIN { delete @ENV{qw( LANG LC_ALL LC_DATE )}; }

# Setting for the new UTF-8 terminal support in Lion
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

    PERLDOC="-MPod::Perldoc::ToTextOverstrike"

	
	http://cpancover.com/latest//Pod-Simple-3.30/blib-lib-Pod-Simple-pm.html#135
	
	http://grep.cpan.me/?q=file%3A.t+ENV
	
	http://wiki.cpantesters.org/wiki/CPANAuthorNotes
	
	
	
	http://grep.cpan.me/?q=file%3A.t+ENV
	
	SKIP: {
    my $loc_orig = setlocale(LC_CTYPE);
    if ( !defined $loc_orig || $loc_orig eq 'C' ) {
        my $loc_us = setlocale( LC_CTYPE, 'en_US.UTF-8' );
        skip "Unspported locale(en_US.UTF-8)", 1 unless defined $loc_us;
        $loc_orig = $loc_us;
    }
    subtest "Basic usage" => sub {
        use autolocale;
        $ENV{LANG} = "C";
        my $loc = setlocale(LC_CTYPE);
        is $loc, "C", 'autolocale enable';
        {
            local $ENV{LANG} = $loc_orig;
            $loc = setlocale(LC_CTYPE);
            is $loc, $loc_orig, 'in local scope';
        }
        $loc = setlocale(LC_CTYPE);
        is $loc, "C", "out of 'local' scope";
        no autolocale;
        $ENV{LANG} = $loc_orig;
        $loc = setlocale(LC_CTYPE);
        is $loc, "C", 'no autolocale';
        {
            use autolocale;
            $ENV{LANG} = $loc_orig;
            $loc = setlocale(LC_CTYPE);
            is $loc, $loc_orig, 'lexical use';
        }
        $ENV{LANG} = "C";
        $loc = setlocale(LC_CTYPE);
        is $loc, $loc_orig, 'out of lexical pragma';
    };
 
    subtest "Illegal usage" => sub {
        use autolocale;
        like exception {
            $ENV{"LANG"} = [];
        }, qr/^You must store scalar data to %ENV/;
    };
 
}
 
 
use POSIX ('locale_h');
 
setlocale(LC_COLLATE, 'ru_RU.UTF-8');
setlocale(LC_CTYPE, 'ru_RU.UTF-8');

 POSIX               0    1.30    
 
 use POSIX qw(locale_h);
setlocale(LC_CTYPE, "pt_PT");

http://grep.cpan.me/?q=file%3A.t+LC_CTYPE
http://grep.cpan.me/?q=file%3A.t+LC_CTYPE

use POSIX qw(setlocale LC_CTYPE);

setlocale (LC_CTYPE, $ENV{LC_CTYPE} = 'en_US.UTF-8')
    or plan skip_all => 'cannot set locale to en_US.UTF-8';
	
	use strict;
use warnings;
use Test::More tests => 1;
use I18N::Langinfo qw/langinfo CODESET/;
use PerlIO::locale;
 
use POSIX qw(locale_h);
 
SKIP: {
    setlocale(LC_CTYPE, "en_US.UTF-8") or skip("no such locale", 1) if langinfo(CODESET) ne 'UTF-8';
 
    open(O, ">", "foo") or die $!;
    print O "\xd0\xb0";
    close O;
    open(I, "<:locale", "foo") or die $!;
    is(ord(<I>), 0x430);
    close I;
}
 
END { unlink "foo" }

#diag $ENV{PADRE_HOME};
my $english = setlocale(LC_CTYPE) eq 'en_US.UTF-8' ? 1 : 0;

SKIP: {
    skip "UTF-8 locale needed for the test with UTF-8 commit message", 7,
        unless ( ( setlocale(LC_CTYPE) // '' ) =~ /utf-8$/i );
		 is( $commit->log, 'remove file. Uber cool with cyrillics: здрасти' );
		}
		
=head1 AUTHOR
 
=over
 
=item Martin Ferrari L<tincho@debian.org>
 
=item Damyan Ivanov L<dmn@debian.org>
 
=back		

use Test::More tests => 12;
 
use POSIX qw(locale_h);
setlocale(LC_CTYPE, "pt_PT");
 
use locale;
use Lingua::PT::PLN;
 
$a = 'a';
 
SKIP: {
  skip "not a good locale", 12 unless $a =~ m!^\w$!;
 
 
  $/ = "\n\n";
 
 
  my $input = "";
  my $output = "";
  open T, "t/tokenizer" or die "Cannot open tests file";
  while(<T>) {
    chomp($input = <T>);
    chomp($output = <T>);
 
 
    my $tok2 = tokenize($input); # Braga
    is($tok2, $output);
  }
  close T;
}
 
 
1;

ibm-866_P100-1995	PC Russia

PC866	PC866	PC DOS code page 866 (Cyrillic)

http://www.dsxchange.com/viewtopic.php?t=126693&sid=be143d325a8d36fe1a01780ff86ab0ef

use locale;
use POSIX qw(locale_h);
my $locale = "Russian_Russia.1251";
setlocale(LC_COLLATE, $locale);
setlocale(LC_CTYPE, $locale);
