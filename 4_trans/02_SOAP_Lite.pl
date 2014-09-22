#!/usr/bin/perl

use Toolkit;
use Smart::Comments;
use Modern::Perl;
use SOAP::Lite;
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

    my $soap =
      SOAP::Lite->proxy( "$jira_base_url/rpc/soap/jirasoapservice-v2?wsdl",
        proxy => [ "http" => $jira_proxy ] );

    # Make all scalars be encoded as strings by default.
    # %{ $soap->typelookup() } = ( default => [ 0, sub { 1 }, 'as_string' ] );

    my $auth = $soap->login( $user, $password );
    croak $auth->faultcode(), ', ', $auth->faultstring()
      if defined $auth->fault();

    say $auth->result();
    my $filter =
'issuetype = "Production Support" AND assignee = mishnik and Resolution=Unresolved';
    my $ref_issues = getIssuesFromJql( $soap, $auth, $filter );
### $ref_issues
}

sub getIssuesFromJql {
    my $soap   = shift;
    my $auth   = shift;
    my $filter = shift;

    my $limit = 100;

    my $cmd = 'getIssuesFromJqlSearch';
    my $ref_issues = $soap->$cmd( $auth->result(), $filter, $limit || 1000 );
    croak $ref_issues->faultcode(), ', ', $ref_issues->faultstring()
      if defined $ref_issues->fault();

    return $ref_issues;
}
