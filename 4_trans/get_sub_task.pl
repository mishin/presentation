#!/usr/bin/perl

use Modern::Perl;
use Data::Dumper;
use Smart::Comments;

use XMLRPC::Lite;
my $user = 'user';
my $pass = 'password';

my $jiraToken =
  XMLRPC::Lite->proxy('http://jira.com:2020/jira/rpc/xmlrpc');
my $authToken = $jiraToken->call( "jira1.login", $user, $pass )->result();
print Dumper $authToken;

my $issue_id = 'YAPC-17914';

my $iss_token =
  $jiraToken->call( "jira1.getIssue", $authToken, $issue_id )->result();

### $iss_token
my $summary=$iss_token->{'summary'};
### $summary 

my $jql = qq{parent = "$issue_id"};
### $jql
my $sub_task =
  $jiraToken->call( "jira1.getIssuesFromJqlSearch", $authToken, $jql,100 )
  ->result();

### $sub_task

