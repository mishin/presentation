#!/usr/bin/perl

# toy jira perl client using XMLRPC
# logs in, creates an issue
# handles failure or prints issue fields
# logs out.
# https://gist.github.com/3054268#comments
# See the thread:
# http://forums.atlassian.com/thread.jspa?forumID=46&threadID=10484

use Toolkit;
use XMLRPC::Lite;
use Data::Dumper;

my $cfg = Config::Auto::parse(
    "c:/Users/nmishin/Documents/db/20120628/spazm-examples-3700d4c/jira.conf");

my $user          = $cfg->{username};
my $passwd        = $cfg->{password};
my $jira_base_url = $cfg->{base_url};
my $jira_proxy    = $cfg->{proxy};

my $jira =
  XMLRPC::Lite->proxy( "$jira_base_url/rpc/xmlrpc",
    proxy => [ "http" => $jira_proxy ] );
my $auth = $jira->call( "jira1.login", $user, $passwd )->result();
my $call = $jira->call(
    "jira1.createIssue",
    $auth,
    {
        'project'     => 'FRWA',
        'type'        => '73',
        'summary'     => 'Issue created via XMLRPC',
        'description' => 'Created with a Perl client',
        'assignee'    => 'mishnik',
        'priority'    => '2',
        'components'  => [
            bless(
                {
                    id   => '21286',
                    name => 'Core FCL'
                },
                'RemoteComponent'
            )
        ]
    }
);
my $fault = $call->fault();

if ( defined $fault ) {
    die $call->faultstring();
}
else {
    print "issue created:\n";
    print Dumper( $call->result() );
}
$jira->call( "jira1.logout", $auth );
