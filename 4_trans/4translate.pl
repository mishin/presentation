use utf8;
use Modern::Perl;
use utf8;
binmode( STDOUT, ":utf8" );
use HTML::Strip;
use HTML::Entities;
use WWW::Mechanize::Firefox;
use File::Slurp;
use Try::Tiny;
use English qw(-no_match_vars);
use Carp;

my $url = 'http://www.translate.ru/';
my $firemech;
$firemech = WWW::Mechanize::Firefox->new(
    tab => qr/PROMT/,
);

die "Cannot connect to $url\n" if !$firemech->success();

fill_jira($firemech);

sub fill_jira {
    my $mech          = shift;
    my $submit_button = 'id="bTranslate"';
    wait_for( $mech, $submit_button );
    my $test_sentence = <<END
This tutorial assumes that the make program that Perl is configured to
use is called C<make>.  Instead of running "make" in the examples that
follow, you may have to substitute whatever make program Perl has been
configured to use.  Running B<perl -V:make> should tell you what it is.
END
      ;
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
console.warn('line1 '+res.result);
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            GetErrMsg("К сожалению, сервис временно недоступен. Попробуйте повторить запрос позже.");
            trDirCode = "";
        }
    });


JS

	sleep 0.5;
    my ( $value, $type ) = $mech->eval(<<'JS');
console.warn('line2 '+$("#editResult_test")[0].innerHTML);	
$("#editResult_test")[0].innerHTML;
JS

say decode_entities($value);

}

sub wait_for {
    my $mech   = shift;
    my $choice = shift;

    #'value="Submit"';
    my $retries = 10;
    while ( $retries--
        and !$mech->is_visible( xpath => '//*[@' . ${choice} . ']' ) )
    {
        sleep 1;
    }
    die "Timeout" if 0 > $retries;

}
