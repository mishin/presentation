use Modern::Perl;
use CGI::Simple;
use WWW::Facebook::API;
#use Data::Dump qw/dump/;
 
my $q = CGI::Simple->new();
my $fb = WWW::Facebook::API->new(
    desktop => 0,
    api_key => '375324055986753',
    secret  => 'a291d7f26f909c137bba22cdf809c393',
    query   => $q,
);
 
# UTF-8 doesn't seem to play well with Facebook, so let's stick to utf8
print $q->header(
    -charset    => 'ISO-8859-1',
);
 
# FBML to show application name, etc
print '<fb:header/><div>';
 
# This prints proper FBML code to redirect to Application Add page
# if app was not added
$fb->require_add() and exit;
 
# Get canvas parameters (current user, etc...)
my $params = $fb->canvas->validate_sig();
# print dump $params; # Have a look at these
 
# Set session key to the one passed by Facebook
$fb->session_key( $params->{session_key} );
 
print '<h3>First Facebook Application</h3><br />';
 
# Get friends of logged in user (returns a ref to array of uids)
my $user_friends = $fb->friends->get();
 
# Get the fields we need (name) of the user's friends
my $friends_info = $fb->users->get_info(
    uids    => $user_friends,
    fields  => [qw/ name /],
) // [ ];
 
# Print this out "nicely"
print '<h4>Your friends (' . @$friends_info . ')</h4><br />';
print '<ul><li>';
print join '</li><li>', sort map { $_->{name} } @$friends_info;
print '</li></ul>';
 
print '</div>';
 
# Drop session key (in case we are in a persistent environment)
$fb->session_key(undef);
