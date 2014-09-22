use Acme::Porn::Embed;

my $url = 'http://www.yourfilehost.com/media.php?cat=video&file=backwards_piano_player.flv';
my $embed = Acme::Porn::Embed->new;
my $res = $embed->embed( $url );
$res->type;  # now, response type is photo. 
$res->title;
$res->url; # thumbnail url.
$res->width;
$res->height;
$res->provider_name;
$res->provider_url;
