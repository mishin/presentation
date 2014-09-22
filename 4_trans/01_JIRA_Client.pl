#!/usr/bin/perl

use Toolkit;
use Smart::Comments;
use Modern::Perl;
use JIRA::Client;
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
      JIRA::Client->new( $jira_base_url, $user, $password,
        proxy => [ "http" => $jira_proxy ] );

    for my $num (21604) {
        my $issue_id = 'FRWA-' . $num;
        my $issue = get_issue( $jira, $issue_id );
### $issue
    }

}

sub get_issue {
    my $jira     = shift;
    my $issue_id = shift;

    my $issue = eval { $jira->getIssue($issue_id) };
    die "Can't getIssue(): $@" if $@;
    return $issue;
}
