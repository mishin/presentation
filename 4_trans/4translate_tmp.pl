#use File::Slurp;
# use utf8;
use Modern::Perl;
use charnames ':full';
binmode( STDOUT, ":utf8" );
use HTML::Strip;
use WWW::Mechanize::Firefox;
use File::Slurp;
use File::Basename;
use Log::Minimal;
use File::Stamped;
use File::HomeDir;
use File::Spec::Functions qw(catdir catfile);
use POSIX ();
use Try::Tiny;
use English qw(-no_match_vars);
use Carp;
use YAML::Tiny;
use DDP;

#use File::Slurp;
$ENV{LM_DEBUG} = 1;
#my $work_path = '/home/ira/job/gists/';

my $work_path = File::HomeDir->my_documents;
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

my $url = 'http://www.translate.ru/';

my $fname = basename($url);

my ($firemech) = WWW::Mechanize::Firefox->new( tab => 'current', );
my %is_download = ();

try {
    $firemech->get($url);
}
catch {
    warn "caught error: $_";    # not $@
    given ($_) {
        fill_page($firemech) when /Authorization Required/;
        fill_jira($firemech) when /Unauthorized/;
        default { say "Another arror" }
    }
};

die "Cannot connect to $url\n" if !$firemech->success();

#print "I'm connected!\n";
debugf("I'm connected!...");
fill_jira($firemech);

sub fill_jira {
    debugf("Start_login");

    #say 'Start_login';
    my $mech = shift;

    #my $submit_button = 'id="ctl00_SiteContent_sourceText"';
    my $submit_button = 'id="bTranslate"';
    wait_for( $mech, $submit_button );
    debugf("$submit_button loaded");

    #say "$submit_button loaded";

    # $mech->form_with_fields( 'user', 'password' );
    my $form = <<'END'
<textarea class="expand101-2400" style="color: green; overflow: hidden; padding-top: 0px; padding-bottom: 0px; height: 101px; min-height: 101px; background: none repeat scroll 0% 0% white;" spellcheck="false" id="editResult_test" onfocus="javascript:showEditTranslationWin(1);"></textarea>

<div id="btr_web"><input id="bTranslate" class="translit" type="button" name="bTranslate" value="Перевести" onclick="javascript:GetTranslationCBK(1);"></input></div>

<div id="btt" style="display: none;"></div>
      <!--<div id="sourceTextBrdr">-->
    <textarea id="ctl00_SiteContent_sourceText" class="expand101-2400" onfocus="javascript:hideToolTip();" onselect="javascript:captureRefers();" onchange="textLimit();" spellcheck="false" onkeyup="textLimit();" name="ctl00$SiteContent$sourceText" style="height: 101px; overflow: hidden; padding-top: 0px; padding-bottom: 0px;"></textarea>
      <!--</div>-->
    </div>
END
      ;

    # $mech->field( user     => 'nikolay.mishin@db.com' );
    my $test_sentence = <<END
Weird...I've copied your code and still getting just the message and not the pod section "special". No doubt I must be overlooking something simple. I'll look some more. Thanks toolic. J 
END
      ;
    $mech->field( 'ctl00$SiteContent$sourceText' => $test_sentence );

    #say 'login/passw filled';
    debugf('login/passw filled');

    #GetTranslationCBK(1);
    #my ($value, $type) = $mech->eval(<<'JS');
#        $mech->eval_in_page(q{key="";

    $mech->eval_in_page(<<'JS');
     uTrType = "";
    visitLink = false;
    closeTranslationLinks();
    var dir = GetDir();
    var text = rtrim($("#ctl00_SiteContent_sourceText").val());
    text = encodeURIComponent(text).split("'").join("\\'");
    var templ = $("#template").val();
 

// Common ajax caller
	 $.ajax({
        type: "POST",
        contentType: "application/json; charset=utf-8",
        url: "/services/TranslationService.asmx/GetTranslateNew",
        data: "{ dirCode:'" + dir + "', template:'" + templ + "', text:'" + text + "', lang:'ru', limit:" + maxlen + ",useAutoDetect:true, key:'" + key + "', ts:'" + TS + "',tid:'',IsMobile:false}",
        dataType: "json",
        success:   console.log(2,4,6,8,"foo",bar),
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            GetErrMsg("К сожалению, сервис временно недоступен. Попробуйте повторить запрос позже.");
            trDirCode = "";
        }
    });

JS



    #say $mech->content();
    debugf( $mech->content() );
    my ( $value, $type ) = $mech->eval(<<'JS');
$("#editResult_test")[0].innerHTML;
JS

    critf("$value $type");

=pod

function AjaxCall(successfunction){
	 $.ajax({
        type: "POST",
        contentType: "application/json; charset=utf-8",
        url: "/services/TranslationService.asmx/GetTranslateNew",
        data: "{ dirCode:'" + dir + "', template:'" + templ + "', text:'" + text + "', lang:'ru', limit:" + maxlen + ",useAutoDetect:true, key:'" + key + "', ts:'" + TS + "',tid:'',IsMobile:false}",
        dataType: "json",
        async:false,
        success: successfunction,
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            GetErrMsg("К сожалению, сервис временно недоступен. Попробуйте повторить запрос позже.");
            trDirCode = "";
        }
    });

}

// Calling Ajax
$(document).ready(function() {
  AjaxCall(ajaxSuccessFunction);
});

// Function details of success function
function ajaxSuccessFunction(res){
  alert(res);
};


http://stackoverflow.com/questions/3302702/jquery-return-value-using-ajax-result-on-success
.result
,
      { alert => sub { print "Captured alert: '@_'\n" } }
  );

 $mech->eval_in_page('alert("Hello");',
      { alert => sub { print "Captured alert: '@_'\n" } }
  );
	
	
  var targetUrl=url;
  $.ajax({
    'url': targetUrl,
    'type': 'GET',
    'dataType': 'json',
    'success': successfunction,
    'error': function() {
      alert("error");
    }
  });
function (res) {
 $("#editResult_test")[0].innerHTML=res.result;
console.log(res.result);
        }
 $("#translationResult")[0].innerHTML=res.result;
//updateHTML("#ctl00_SiteContent_sourceText",res.result);

=cut

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

# download_page( $url, $target_dir, $firemech );

sub fill_page {
    say 'Start_login';
    my $mech = shift;

    # The submit button is generated after the page has loaded

    #textarea id="ctl00_SiteContent_sourceText" class="expand101-2400"

    my $retries = 10;
    while (
        $retries--

        #and !$mech->is_visible( xpath => '//*[@value="Submit"]' ) )
        and !$mech->is_visible(
            xpath => '//*[@id="ctl00_SiteContent_sourceText"]'
        )
      )
    {
        sleep 1;
    }
    die "Timeout" if 0 > $retries;
    use YAML::Tiny;
    my $conf = YAML::Tiny::LoadFile('config.yml')
      or croak "Couldn't open YAML::Tiny->errstr: $OS_ERROR";

    my $user     = $conf->{WebSSO_user};
    my $password = $conf->{WebSSO_password};

    $mech->form_with_fields( 'user', 'password' );

    $mech->field( user => $user );

    $mech->field( password => $password );

    # Now the element exists
    $mech->click( { xpath => '//*[@value="Submit"]' } );
    $retries = 10;
    while ( $retries--
        and !$mech->is_visible( xpath => '//*[@class="continueButton"]' ) )
    {
        sleep 1;
    }
    die "Timeout" if 0 > $retries;
    $mech->click( { xpath => '//*[@class="continueButton"]' } );

}

sub download_page {
    my $link       = shift;
    my $target_dir = shift;
    my $mech       = shift;
    my $fname      = basename($link);
    say "we are in download_page: $fname";
    if ( !exists $is_download{$fname} ) {

# my $localname='c:/Users/nmishin/Documents/svn/misc/html_extract/t/confl/'.$fname.'.html';
        my $localname = $target_dir . $fname . '.html';
        if ( !-e $localname ) {
            $mech->get($link);
            $mech->save_content( $localname, $localname . ' files' );
        }

# $mech->save_url($link,$localname.'2');#сохранение страницы без картинок только html зато быстро!!
        $is_download{$fname}++;
    }
    else {
        say "$fname already has been downloaded";
    }

}

# save_links( $target_dir, $firemech, $fname );

#Production+Support#
sub save_links {
    my $target_dir = shift;
    my $mech       = shift;
    my $fname      = shift;
    my $content    = '';
    my $hs         = HTML::Strip->new();
    my $text;
    my $link;
    for my $link ( $mech->links ) {
        $text = $hs->parse( $link->text );
        my $link_url = $link->url;
        if (   ( $link_url =~ /FCL/ )
            && ( length $text > 0 )
            && ( $link_url !~ /\Q${fname}#\E/ )
            && ( $link_url !~ /\Q?\E/ ) )
        {
            $content .= $text . " -> " . $link_url . "\n";
            download_page( $link_url, $target_dir, $mech );
        }

    }
    $hs->eof;

    my $link_file = $target_dir . 'link.txt';
    say "\$link_file=$link_file";
    if ( !-e $link_file ) {
        open FILE, ">$link_file" or die "unable to open $link_file $!";
        print FILE $content;
        close FILE;
    }

}

debugf("Finish...");
#debugf($log_fh);
#p $log_fh;

#my @lines = read_file( 'filename' ) ;
#read_file( $log_fh, my @data ) ;
 my $time = time();
 my $pattern="log.%Y-%m-%d.out";                
$fname=catdir( $work_path, POSIX::strftime($pattern, localtime($time)) );
debugf($fname);
my @data=read_file( $fname );
my @res = grep(/CRITICAL/,@data );
say "@res";
