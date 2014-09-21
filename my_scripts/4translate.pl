use utf8;
use Modern::Perl;
<<<<<<< HEAD
use charnames ':full';
# binmode( STDOUT, ":utf8" );
=======
use utf8;
binmode( STDOUT, ":utf8" );
>>>>>>> 64cbed455f7e2177d2ed041d60f2982ee7db1578
use HTML::Strip;
use HTML::Entities;
use WWW::Mechanize::Firefox;
use File::Slurp;
use Try::Tiny;
use English qw(-no_match_vars);
use Carp;
<<<<<<< HEAD
use YAML::Tiny;
use DDP;

#use File::Slurp;
$ENV{LM_DEBUG} = 1;
my $work_path = 'c:/TCPU59/utils/job/30092013/log';

#my $work_path = File::HomeDir->my_documents;
my $log_fh =
  File::Stamped->new( pattern => catdir( $work_path, "log.%Y-%m-%d.out" ), );

# Overrides Log::Minimal PRINT method
$Log::Minimal::PRINT = sub {
    my ( $time, $type, $message, $trace ) = @_;

    # Removed $trace because it was too long in my environment
    print {$log_fh} "$time [$type] $message\n";
};

debugf("My::Module debugger init.");

#write_file( 'filename', {append => 1 }, @data ) ;

#append_file( $file, @data ) ;
my $conf = YAML::Tiny::LoadFile('config.yml')
  or croak "Couldn't open YAML::Tiny->errstr: $OS_ERROR";
=======
>>>>>>> 64cbed455f7e2177d2ed041d60f2982ee7db1578

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
