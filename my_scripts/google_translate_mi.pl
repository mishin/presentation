#!/usr/bin/env perl
# By: Jeremiah LaRocco, Nikolay Mishin (refactoring)
# Use translate.google.com to translate between languages.
# Sample run:
#gtrans.pl --from en --to ru --text "This is a test"
# use POSIX qw(locale_h);
# my $old_locale = setlocale(LC_CTYPE);
# say $old_locale;
# $ENV{LANG}=;
use Modern::Perl;
use LWP::UserAgent;
use WWW::Mechanize::Firefox;
binmode( STDOUT, ":utf8" );
use HTML::Entities;
# use open IO => ':locale';
use Getopt::Long;
use Pod::Usage;

# use utf8;
use open ':locale';

my $man  = 0;
my $help = 0;
my $from = 'en';
my $to   = 'ru';
my $text = 'yapc';

GetOptions(
    'help|?' => \$help,
    'man'    => \$man,
    'from=s' => \$from,
    'to=s'   => \$to,
    'text=s' => \$text
) or pod2usage( -verbose => 2 );

pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

&main;
exit;

sub main {
# say "string to translate:$text";
    say 'google say:';
    translate_text( $from, $to, $text );
    say 'prompt say:';
    say ptrans($text);
}

sub translate_text {
    my ( $from, $to, $words ) = @_;

    my $url =
        'http://translate.google.com/translate_t?langpair=' 
      . $from . '|' 
      . $to
      . '&text=' . '+'
      . $words;
    my $ua = LWP::UserAgent->new;
    $ua->agent('');
    my $res = $ua->get($url);
    die $res->status_line if $res->is_error;
    my $html = $res->decoded_content;

    my @matches =
      $html =~ m{onmouseout="this.style.backgroundColor='#fff'">(.*?)</span>}g;

    say for @matches;
}

sub ptrans {
    my ($test_sentence) = @_;
    my $url = 'http://www.translate.ru/';

    # my $fname = basename($url);
    my %is_download = ();
    my $firemech;
    my $magic = 'PROMT';

    # use Test::More;
    # plan tests => 2;

    # my $myurl       = 'http://google.com';
    my $firefox_bin = 'C:/Program Files/Mozilla Firefox/firefox.exe';

#################### Open URL #########################
## creating firefox obj
    $firemech = WWW::Mechanize::Firefox->new( launch => $firefox_bin );

    # open page/url

    # diag $_->{title} for $firemech->application->openTabs();
    # Now try to connect to "our" now closed tab
    my $lived = eval {
        $firemech = WWW::Mechanize::Firefox->new(
            autodie => 1,
            tab     => qr/$magic/,
        );
        1;
    };
    my $err = $@;

    if ( !defined $lived ) {
        ($firemech) = WWW::Mechanize::Firefox->new( tab => 'current', );
        $firemech->get($url);
    }

    die "Cannot connect to $url\n" if !$firemech->success();
    return fill_jira( $firemech, $test_sentence );
}

sub fill_jira {
    my ( $mech, $test_sentence ) = @_;
    my $submit_button = 'id="bTranslate"';
    wait_for( $mech, $submit_button );

    # my $test_sentence = <<END
    # This tutorial assumes that the make program that Perl is configured to
    # use is called C<make>.  Instead of running "make" in the examples that
    # follow, you may have to substitute whatever make program Perl has been
    # configured to use.  Running B<perl -V:make> should tell you what it is.
    # END
    # ;
    $mech->field( 'ctl00$SiteContent$sourceText' => $test_sentence );
    $mech->eval_in_page(<<'JS');
key="";
var globalJsonVar;
 uTrType = "";
    visitLink = false;
    closeTranslationLinks();
    var dir = GetDir();
    var text = rtrim($("#ctl00_SiteContent_sourceText").val());
    text = encodeURIComponent(text).split("'").join("\\'");
    var templ = $("#template").val();
  $.ajax({
        type: "POST",
        contentType: "application/json; charset=utf-8",
        url: "/services/TranslationService.asmx/GetTranslateNew",
        data: "{ dirCode:'" + dir + "', template:'" + templ + "', text:'" + text + "', lang:'ru', limit:" + maxlen + ",useAutoDetect:true, key:'" + key + "', ts:'" + TS + "',tid:'',IsMobile:false}",
        dataType: "json",
        success: function (res) {
 $("#editResult_test")[0].innerHTML=res.result;
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            GetErrMsg("К сожалению, сервис временно недоступен. Попробуйте повторить запрос позже.");
            trDirCode = "";
        }
    });
JS
    sleep 1;
    my ( $value, $type ) = $mech->eval(<<'JS');
$("#editResult_test")[0].innerHTML;
JS

    return decode_entities($value);
}

sub wait_for {
    my $mech    = shift;
    my $choice  = shift;
    my $retries = 10;
    while ( $retries--
        and !$mech->is_visible( xpath => '//*[@' . ${choice} . ']' ) )
    {
        sleep 1;
    }
    die "Timeout" if 0 > $retries;

}

__END__

=head1 NAME

gtrans.pl - Translate using  translate.google.com

=head1 SYNOPSIS

gtrans.pl --from en --to ru --text "This is a test"
gtrans.pl [options] [text to translate ...]

Options:
-help brief help message
-man full documentation
-from from language
-to to language
-text text to translate

=head1 OPTIONS

=over 2

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

B<This program> will read the given input "text" and translate it to 
 selected language using translate.google.com.

=head1 AUTHOR


Jeremiah LaRocco, Nikolay Mishin(mi@ya.ru) (refactoring)


=cut
