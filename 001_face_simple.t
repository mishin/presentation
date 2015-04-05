use Modern::Perl;
use CGI::Simple;
my $q = CGI::Simple->new();
 
print $q->header();
print "Hello Facebook"
