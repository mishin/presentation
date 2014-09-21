#use File::Slurp;
# use utf8;
use Modern::Perl;
use charnames ':full';
binmode( STDOUT, ":utf8" );
use HTML::Strip;
use WWW::Mechanize::Firefox;
use File::Slurp;
use File::Basename;
use Try::Tiny;
use English qw(-no_match_vars);
use Carp;
use YAML::Tiny;
use DDP;

my $conf = YAML::Tiny::LoadFile('config.yml')
  or croak "Couldn't open YAML::Tiny->errstr: $OS_ERROR";

my $url = 'http://www.translate.ru/';

my $fname = basename($url);

# my ($firemech) = WWW::Mechanize::Firefox->new( tab => 'current', );
my $firemech = WWW::Mechanize::Firefox->new( tab => qr/PROMT/, );
my %is_download = ();

# try {
# $firemech->get($url);
# }
# catch {
# warn "caught error: $_";    # not $@
# given ($_) {
# fill_page($firemech) when /Authorization Required/;
# fill_jira($firemech) when /Unauthorized/;
# default { say "Another arror" }
# }
# };

# die "Cannot connect to $url\n" if !$firemech->success();
# print "I'm connected!\n";

fill_jira($firemech);

sub fill_jira {
    say 'Start_login';
    my $mech = shift;

    #my $submit_button = 'id="ctl00_SiteContent_sourceText"';
    my $submit_button = 'id="bTranslate"';
    wait_for( $mech, $submit_button );
    say "$submit_button loaded";

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
	Unfortunately 222134, the service is temporarily unavailable. Try again later.
Weird...I've copied your code and still getting just the message and not the pod section "special". No doubt I must be overlooking something simple. I'll look some more. Thanks toolic. J 
END
      ;
    $mech->field( 'ctl00$SiteContent$sourceText' => $test_sentence );
    say 'login/passw filled';

    #GetTranslationCBK(1);
    #my ($value, $type) = $mech->eval(<<'JS');
    # $mech->eval_in_page('alert("Hello");',
    # { alert => sub { print "Captured alert: '@_'\n" } }
    # );
#document.getElementById('ctl00_SiteContent_sourceText').submit();

    $mech->eval_in_page(
        q{
document.getElementById('ctl00_SiteContent_sourceText').form.submit;
}
    );

	my $console = $mech->js_console;
    
    # $mech->clear_js_errors        if ($clear);
    my $text='ramzes2';
    if ($text) {
            $console->logStringMessage($text);
    }; 
    # $mech->click( { xpath => '//*[@' . $submit_button . ']' });
	say "\$submit_button=$submit_button";
    # $mech->click( { xpath => '//*[@' . $submit_button . ']' },        synchronize => 0 );

=pod   
   $mech->eval_in_page(q{key="";
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
 $("#translationResult")[0].innerHTML=res.result;
  $("#editResult_test")[0].innerHTML=res.result;
 console.log(res.result);
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            GetErrMsg("Unfortunately, the service is temporarily unavailable. Try again later.");
            trDirCode = "";
        }
 });},
  { alert => sub { print "Captured alert: '@_'\n" } });
=cut

    $mech->eval_in_page(
        'alert($("#translationResult")[0].innerHTML);',
        {
            alert => sub { print "Captured alert: '@_'\n" }
        }
    );

    my ( $value, $type ) = $mech->eval(<<'JS');
$("#editResult_test")[0].innerHTML;
JS

    say "$value $type";

=pod

 $("#aspnetForm")
 document.f[#aspnetForm].submit();
     <input id="bTranslate" class="translit" type="button" name="bTranslate" value="Перевести" onclick="javascript:GetTranslationCBK(1);"></input>

</div>
$('ctl00$SiteContent$sourceText').change();
#//*[@id="editResult_test"]
#alert($("#translationResult")[0].innerHTML);
#value value
#handle.elem
#//*[@id="editResult_test"]
# $mech->eval_in_page('alert($("#translationResult")[0].innerHTML);',
 # { alert => sub { print "Captured alert: '@_'\n" } }
# );

# },
# { alert => sub { print "Captured alert: '@_'\n" } }
# );



var checkFormulaName = function () {
    var returned;
    this.getFormula = function (text) {
        return $.ajax({
			 type: "POST",
        contentType: "application/json; charset=utf-8",
        url: "/services/TranslationService.asmx/GetTranslateNew",
        data: "{ dirCode:'" + dir + "', template:'" + templ + "', text:'" + text + "', lang:'ru', limit:" + maxlen + ",useAutoDetect:true, key:'" + key + "', ts:'" + TS + "',tid:'',IsMobile:false}",
        dataType: "json",
        success: function (res) {
console.log(res.result);
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            GetErrMsg("К сожалению, сервис временно недоступен. Попробуйте повторить запрос позже.");
            trDirCode = "";
        },
           async: false
			    }).responseText
    }
}



    $.ajax({
        type: "POST",
        contentType: "application/json; charset=utf-8",
        url: "/services/TranslationService.asmx/GetTranslateNew",
        data: "{ dirCode:'" + dir + "', template:'" + templ + "', text:'" + text + "', lang:'ru', limit:" + maxlen + ",useAutoDetect:true, key:'" + key + "', ts:'" + TS + "',tid:'',IsMobile:false}",
        dataType: "json",
        success: function (res) {
updateHTML("#ctl00_SiteContent_sourceText",res.result);
console.log(res.result);
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            GetErrMsg("К сожалению, сервис временно недоступен. Попробуйте повторить запрос позже.");
            trDirCode = "";
        }
    });

#say "$value $type";
#http://forum.jquery.com/topic/how-to-store-the-ajax-response-in-some-variable-please-help-me
#p $value;
my ($value, $type) = $mech->eval(<<'JS');
document.getElementById('translationResult').textContent;
JS

say "$value $type";
updateHTML("#ctl00_SiteContent_sourceText",res.result);

var checkFormulaName = function() {
var returned;
this.getFormula = function(name) {
return $.ajax({
url: '/formula/msp/check',
type: 'POST',
data: 'name='+name,
dataType: 'json',
async: false
}).responseText
}
}
$mech->eval_in_page(<<'JS');
console.log(document.getElementById('translationResult').textContent);
#textarea#
#print "You could click on\n";
#        for my $el ($mech->clickables) {
#            print $el->{innerHTML}, "\n";
#        };

#p $mech;
 #   my ( $value, $type ) = $mech->eval('document.documentElement.textContent');
 #   say "value=$value
 #    type=$type";
=pod
    $mech->eval_in_page(<<'JS');
console.log($("#editResult_test"));
GetTranslationCBK(1);
console.log("2");
var firstTier = $("#translationResult")[0].childNodes;

// firstTier is the NodeList of the direct children of the root element
for (var i = 0; i < firstTier.length; i++) {
   // do something with each direct kid of the root element
   // as firstTier[i]
   console.log(firstTier[i]);
}
//console.log(document.documentElement.textContent);
//console.log($('#translationResult')[0].textContent);
//var productName=$('#translationResult');
//console.dir(productName[0].innerHTML);
console.dir(window.txtForEditor);
//console.dir(productName.prevObject.get(0));
console.log("3");
JS
=cut

    #    $mech->form_id('aspnetForm');
    #    say $mech->current_form->{id};

    #    my @text = $mech->by_id('editResult_test');

    #    p @text;

=pod
var obj =$('#translationResult');

for(var i in obj) {
    if (obj.hasOwnProperty(i)) {
        console.log(i, '' + obj[i]);
        console.log(i, '' + obj[i]);
        
    }
}

//var productName = $('#window').contents().find('h1.productTitle').html()
//alert(productName);
//$(function(){ $('#translationResult').css("color","red"); });
//console.dirxml(document.documentElement);
//GetTranslationCBK(1);
//#editResult_test
//var productName=$(function(){ $('translationResult').get(0).innerHTML;   });
//if(document.getElementById("translationResult") != null){
//var productName=$('#translationResult').get(0).innerHTML 
//console.dir(productName);
//    var idPost=document.getElementById("status").innerHTML;
//}
//var text = document.getElementById("translationResult").textContent;
//var productName = $('#window').contents().find('div.translationResult').val
();

//class="expand101-2400"
//$('textarea*=expand101-2400');
//#$(function(){ $('editResult_test').css("background-color","green"); });
//#$(function(){ $('div').css("background-color","red"); });
//var name = $('#translationResult').innerHTML;
//$("#ctl00_SiteContent_sourceText").attr('class','expand101-2400');
//console.dir($("#editResultWin_test")); //works without console.			
//#$(function(){ alert('jQuery works'); });
Странный... Я скопировал Ваш кодекс и все еще получение просто сообщения а не "особенной" секции стручка. Без сомнения я должен пропускать что-то простое. Я посмотрю еще немного. Спасибо toolic. J
<div id="translationResult" style="display: inline; border: 1px solid transparent;">Странный... Я скопировал Ваш кодекс и все еще получение просто сообщения а не "особенной" секции стручка. Без сомнения я должен пропускать что-то простое. Я посмотрю еще немного. Спасибо toolic. J</div>
#editResultWin_test
#editResult_test
//console.dir($("#editResultWin_test").listHandlers('*', console.info)); //works without console.			
console.dir($._data(htmlElement, "events"));

"Странный... Я скопировал Ваш кодекс и все еще получение просто сообщения а не \"особенной\" секции стручка. Без сомнения я должен пропускать что-то простое. Я посмотрю еще немного. Спасибо toolic. J"

window.temp_var = $("#editResultWin_test")
console.log(window.temp_var);
http://habrahabr.ru/post/76485/
http://habrahabr.ru/post/63797/
http://habrahabr.ru/post/133566/
http://stackoverflow.com/questions/4469340/firebug-problem-cant-use-console-log
http://stackoverflow.com/questions/11048267/firebug-doesnt-display-my-javascript-cant-find-the-error
http://habrahabr.ru/post/31239/
https://www.google.ru/search?client=ubuntu&channel=fs&q=firebug+jquery+cannot&ie=utf-8&oe=utf-8&gws_rd=cr&ei=6J0uUt3VJsT54QTcsIGQCg#channel=fs&newwindow=1&q=firebug+jquery+%D0%BD%D0%B5+%D0%BC%D0%BE%D0%B3%D1%83+%D0%BF%D1%80%D0%BE%D1%87%D0%B8%D1%82%D0%B0%D1%82%D1%8C+%D0%B7%D0%BD%D0%B0%D1%87%D0%B5%D0%BD%D0%B8%D0%B5+%D1%81%D0%B2%D0%BE%D0%B9%D1%81%D1%82%D0%B2%D0%B0


//console.dir($("#editResultWin_test")); //works without console.			
	div#editResultWin_test
alert(textarea#editResult_test.expand101-2400.value);
textarea#editResult_test.expand101-2400.value

console.dir(textarea#editResult_test.expand101-2400.value); //works without console.			
console.log($("#editResultWin_test").text); //works without console.			
<textarea onfocus="javascript:showEditTranslationWin(1);" id="editResult_test" spellcheck="false" style="color: green; overflow: hidden; padding-top: 0px; padding-bottom: 0px; height: 101px; min-height: 101px; background: none repeat scroll 0% 0% white;" class="expand101-2400"></textarea>

i


//*[@id="editResult_test"]
$p.value;
//*[@id="editResult_test"]
//*[@id="editResult_test"]
value
console.dir(document.getElementById('#editResultWin_test').outerHTML); //works without console.			
console.dir($("#editResultWin_test")); //works without console.		

var div = document.getElementById("translationResult");
console.dir(div.childNodes); //works without console.


textContent
childNodes
childNodes
this.childNodes
outerHTML
innerHTML
innerHTML
Странный... Я скопировал Ваш кодекс и все еще получение просто сообщения а не "особенной" секции стручка. Без сомнения я должен пропускать что-то простое. Я посмотрю еще немного. Спасибо toolic. J

showEditTranslationWin(0)

console.dir($("#translationResult")); //works without console.
console.dir(document.getElementById('translationResult')); //works without console.

var table1 = new Array(5);
for (var i=0; i<table1.length; i++)
    table1[i] = [i+1, i+2, i+3, i+4, i+5, i+6, i+7];
console.table(table1);

JQUERY4U = {
    url:'http://www.jquery4u.com',
    mainTopics:'jquery,javascript'
}
console.dir(JQUERY4U); //works without console.
	


var div = document.getElementById('translationResult');

console.dir(div.innerHTML); //works without console.

monitorEvents($("iframe").contentWindow, "message")
//*[@id="bTranslate"]
//*[@id="translationResult"]
//*[@id="translationResult"]
<div id="translationResult" style="display: none; color: transparent; border: 1px solid transparent;">Странный... Я скопировал Ваш кодекс и все еще получение просто сообщения а не "особенной" секции стручка. Без сомнения я должен пропускать что-то простое. Я посмотрю еще немного. Спасибо toolic. J</div>

Странный... Я скопировал Ваш кодекс и все еще получение просто сообщения а не "особенной" секции стручка. Без сомнения я должен пропускать что-то простое. Я посмотрю еще немного. Спасибо toolic. J


=cut

    #p $text;
    #  print $text->{innerHTML}, "\n";

    #p $mech->current_form;

#ixo#
# <div style="display: none; color: transparent; border: 1px solid transparent;" id="translationResult">Странный... Я скопировал Ваш кодекс      и все еще получение просто сообщения а не "особенной" секции стручка. Без сомнения я должен пропускать что-то простое. Я посмотрю еще немного. Сп     асибо toolic. J</div>

    #say $mech->xpath('.//*[@name="#editResult_test"]',
    #    node => $mech->current_form,
    #    single => 1)->{value};

    #$mech->field('#editResult_test', 99);
    #is $mech->xpath('.//*[@name="#editResult_test"]',
    #    node => $mech->current_form,
    #    single => 1)->{value}, 99,
    #    "We set values in the correct form";

#alert($("#translationResult").text())
#document.getElementById('#translationResult').focus()
#alert($("#translationResult").html(res.result))
#Copy1()
#alert('Hello YAPC Europe');
# $mech->click( { xpath => '//*[@' . $submit_button . ']' } , synchronize => 0  );

    #    say 'click';

    #print "You could click on\n";
    #    for my $el ($mech->clickables) {
    #        print $el->{innerHTML}, "\n";
    #    };
    #my @links = $mech->selector('div');
    # $mech->highlight_node(@links);
    #my @text = $mech->by_id('editResult_test');
    #say join @text;
    # id="editResult_test"
    #click_warning();

#<textarea class="expand101-2400" style="background: none repeat scroll 0% 0% white; padding-top: 0px; min-height: 101px; color: red;" spellcheck="false" id="editResult_test" onfocus="javascript:showEditTranslationWin(1);"></textarea>
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

