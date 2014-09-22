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
# binmode(STDIN, ":encoding(utf8)"); 
# binmode( STDOUT, ":utf8" );
use HTML::Entities;
#use open IO => ':locale';
use Getopt::Long;
use Pod::Usage;
use open qw/:std :utf8/;
use File::Slurp;  
use IPC::Open3 'open3';
use Carp;
use English qw(-no_match_vars);

#use open qw/:std :utf8/;
# use Convert::Cyrillic;
 # use Encode::Locale;
  # use Encode;
# use Encode;
use utf8;
# use open ':locale';

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
my @out;
# say "string to translate:$text";
    push  @out,'google say:';
    my $google_text=translate_text( $from, $to, $text );
	push  @out,$google_text;
    # say '   prompt say:';
	push  @out,"\nprompt say:";
    my $prompt_text=ptrans($text);
	push  @out,$prompt_text;
	my $fname='c:\\TCPU59\\scripts\\temp_file';
	write_file_utf8($fname,@out);
	# say @out;
	#c:\\Share\\Dwimperl\\perl\\bin\\perl.exe
	my $exec_shell='perl c:\\TCPU59\\scripts\\read_file.pl';
	 my $a=run_shell($exec_shell);
	 say @{$a};

	# write_file($fname,@out);
	# say_file($fname);
	# my $ustr = "simple unicode string \x{0434} indeed";

# {
    # open(my $FH, ">:encoding(UTF-8)", "temp_file")
      # or die "Failed to open file - $!";

    # write_file($FH,  @out)
      # or warn "Failed write_file";
# }
	
	# write_file('temp_file',@out );
}
sub run_shell {
    my ($cmd) = @_;
    my @args  = ();
    my $EMPTY = q{};
    my $ret   = undef;
    my ( $HIS_IN, $HIS_OUT, $HIS_ERR ) = ( $EMPTY, $EMPTY, $EMPTY );
    my $childpid = open3( $HIS_IN, $HIS_OUT, $HIS_ERR, $cmd, @args );
    $ret = print {$HIS_IN} "stuff\n";
    close $HIS_IN or croak "unable to close: $HIS_IN $ERRNO";
    ;    # Give end of file to kid.
      my @outlines=();
    if ($HIS_OUT) {
        @outlines = <$HIS_OUT>;    # Read till EOF.
		# print @outlines;
        # $ret = print " STDOUT:\n", @outlines, "\n";
    }
    if ($HIS_ERR) {
        my @errlines = <$HIS_ERR>;    # XXX: block potential if massive
        # $ret = print " STDERR:\n", @errlines, "\n";
    }
    close $HIS_OUT or croak "unable to close: $HIS_OUT $ERRNO";

    #close $HIS_ERR or croak "unable to close: $HIS_ERR $ERRNO";#bad..todo
    waitpid $childpid, 0;
    if ($CHILD_ERROR) {
        $ret = print "That child exited with wait status of $CHILD_ERROR\n";
    }
    return \@outlines;
}


sub say_file{
my $file_name=shift;
my $text=read_file( $file_name );
use Encode;
Encode::from_to($text, 'utf-8', 'windows-1251');
say $text;
};


sub write_file_utf8 {
    my $name = shift;
     open my $fh, '>:encoding(UTF-8)', $name
    # open my $fh, '>', $name
        or die "Couldn't create '$name': $!";
    local $/;
    print {$fh} $_ for @_;
};
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
    # my $html = $res->decoded_content;
    my $html = $res->decoded_content;

    my @matches =
      $html =~ m{onmouseout="this.style.backgroundColor='#fff'">(.*?)</span>}g;

	  my $out=join ('',@matches);
    # for my $line (@matches){
	    # # my $interm_var = Convert::Cyrillic::cstocs( 'KOI8', 'UTF8', $line );
	# # Encode::from_to( $interm_var, 'utf-8', 'cp1251' );
	# say $line;
	# # say decode_entities($line) ;
	# };
	 return $out;
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
