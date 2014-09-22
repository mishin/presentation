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
my $conf = YAML::Tiny::LoadFile('c:\Users\nmishin\Documents\git\gui\config.yml')
  or croak "Couldn't open YAML::Tiny->errstr: $OS_ERROR";

  my $mech = WWW::Mechanize::Firefox->new(
      launch => 'C:/Program Files (x86)/Mozilla Firefox/firefox.exe',
  );
  
# my $url='http://jira.gto.intranet.db.com:2020/jira/secure/Dashboard.jspa';#http://www.quakelive.com/#!profile/matches/MartianBuddy';
# my $url =  'https://wiki.tools.intranet.db.com/confluence/display/FCL/Production+Support';    #http://www.quakelive.com/#!profile/matches/MartianBuddy';
# # my $url =
# 'https://wiki.tools.intranet.db.com/confluence/display/FCL/Production+Support';
# my $url = 'https://ga-uk.gto.intranet.db.com:9051/ga2/logon';
my $url = 'http://jira.gto.intranet.db.com:2020';

# 'https://wiki.tools.intranet.db.com/confluence/display/FCL/Production+Support';    #http://www.quakelive.com/#!profile/matches/MartianBuddy';

# my $target_dir = 'c:/Users/nmishin/Documents/svn/misc/html_extract/t/confl/';
# my $target_dir = shift;
my $fname = basename($url);

#'c:/Users/nmishin/Documents/svn/misc/html_extract/t/confl/';

#my ($firemech) = WWW::Mechanize::Firefox->new();
my ($firemech) = WWW::Mechanize::Firefox->new( tab => 'current', );
my %is_download = ();

# my ($firemech) = WWW::Mechanize::Firefox->new(tab => qr{create}, );
try {
    $firemech->get($url);

    # fill_jira($firemech);

    # die "foo";
}
catch {
    warn "caught error: $_";    # not $@
    given ($_) {
        fill_page($firemech) when /Authorization Required/;
        fill_jira($firemech) when /Unauthorized/;

        # say 'String has letters'  when /[a-zA-Z]/;
        default { say "Another arror" }
    }

    # when Authorization Required
};

die "Cannot connect to $url\n" if !$firemech->success();
print "I'm connected!\n";

fill_jira($firemech);

sub click_warning {
    say 'Click Security_warning';

    # sleep 1;
    use Win32::GuiTest qw(:ALL);
    my @windows = FindWindowLike( 0, "Firefox", "" );
    die "Could not find Total\n" if not @windows;

    SetForegroundWindow( $windows[0] );

    my ( $left, $top, $right, $bottom ) = GetWindowRect( $windows[0] );
    MouseMoveAbsPix( ( $right + $left ) / 2, ( $top + $bottom ) / 2 );
    SendMouse("{LeftClick}");

    # sleep(1);

    # &send_keys;

    SendKeys("{ENTER}");
}

sub fill_jira {
    say 'Start_login';
    my $mech          = shift;
    my $submit_button = 'id="login_submitBtn"';
    wait_for( $mech, $submit_button );
    say 'login_submitBtn loaded';

    # $mech->form_with_fields( 'user', 'password' );

    # $mech->field( user     => 'nikolay.mishin@db.com' );
    $mech->field( username => $conf->{user} );

    # $mech->field( password => '5lSUPjd1' );
    $mech->field( password => $conf->{password} );
    say 'login/passw filled';

    $mech->click( { xpath => '//*[@' . $submit_button . ']' } );

    click_warning();

}

# https://ga-uk.gto.intranet.db.com:9051/ga2/logon

# my ($retries) = 10;
# while ( $retries--
# and !$firemech->is_visible( xpath => '//*[@class="quick-search"]' ) )
# {
# sleep 1;
# }
# die "Timeout" unless $retries;

# my ($content) = $firemech->content();

#write_file( 'Dashboard.html', $content ) ;

# my $fname     = basename($url);
#my $localname = 'c:/Users/nmishin/Documents/svn/misc/html_extract/t/confl/'   . $fname . '.html';

# $mech->get($url); $mech->save_content($localname,$localname. ' files');
#$firemech->save_content( $localname, $localname . ' files' );
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

    my $retries = 10;
    while ( $retries--
        and !$mech->is_visible( xpath => '//*[@value="Submit"]' ) )
    {
        sleep 1;
    }
    die "Timeout" if 0 > $retries;
    use YAML::Tiny;
    my $conf =
      YAML::Tiny::LoadFile('c:\Users\nmishin\Documents\git\gui\config.yml')
      or croak "Couldn't open YAML::Tiny->errstr: $OS_ERROR";

    my $user     = $conf->{WebSSO_user};
    my $password = $conf->{WebSSO_password};

    $mech->form_with_fields( 'user', 'password' );

    # $mech->field( user     => 'nikolay.mishin@db.com' );
    $mech->field( user => $user );

    # $mech->field( password => '5lSUPjd1' );
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

        #		my $clean_text = $hs->parse( $raw_html );
        #print $clean_text,"\n";

    }
    $hs->eof;

    #    print $content;

    my $link_file = $target_dir . 'link.txt';
    say "\$link_file=$link_file";
    if ( !-e $link_file ) {
        open FILE, ">$link_file" or die "unable to open $link_file $!";
        print FILE $content;
        close FILE;
    }

    #write_file( $target_dir . 'links.html', $content );
}

# $firemech->save_url('http://google.com','google_index.html');
# $firemech->save_url($localname,$localname. ' files');
# $mech->save_content( $localname [, $resource_directory] [, %options ] )

# $mech->get('http://google.com'); $mech->save_content('google search page','google search page files');

