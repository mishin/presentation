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

my $url = 'https://gist.github.com/starred';
my $mech = WWW::Mechanize::Firefox->new( tab => 'current', );
$mech->get($url);

# <a href="/3610649">gist: 3610649</a>
$mech->highlight_node( $mech->selector('a') );

for ( $mech->selector('a') ) {
    # $mech->get( $_->{href} );
    # $mech->save_content( $_->{innerHTML}, $_->{innerHTML} . ' files' );
	if ($_->{innerHTML} =~ /gist: \d+/){
    print $_->{href}, " - ", $_->{innerHTML}, "\n";
	}
}

# $mech->get('http://google.com');
# $mech->save_content('google search page','google search page files');
# <>;
