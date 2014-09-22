#!/usr/bin/perl

use Toolkit;
use Smart::Comments;
use Modern::Perl;
use XMLRPC::Lite;
use Config::Auto;

&main;
exit;

sub main {

    my $cfg = Config::Auto::parse(
"c:/Users/nmishin/Documents/db/20120628/spazm-examples-3700d4c/jira.conf"
    );

    my $user          = $cfg->{username};
    my $password      = $cfg->{password};
    my $jira_base_url = $cfg->{base_url};
    my $jira_proxy    = $cfg->{proxy};

    my $jira =
      XMLRPC::Lite->proxy( "$jira_base_url/rpc/soap/jirasoapservice-v2?wsdl",
        proxy => [ "http" => $jira_proxy ] );
### $jira
    my $auth = $jira->call( "jira1.login", $user, $password )->result();

}
