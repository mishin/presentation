use WWW::Mechanize::Firefox;
my $link=shift;
use File::Basename;
my ($mech) = WWW::Mechanize::Firefox->new(tab => 'current', );
$mech->get_local($link);