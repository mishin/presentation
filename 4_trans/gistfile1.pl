#!/usr/bin/perl -s

use SOAP::Lite;

use constant HOST => 'your.jira.host';

our ($u, $p, $d, $soap, $auth);

if ( ! $d ) {

	if ( ! $u ) { die "Username required" }
	if ( ! $p ) { die "Password required" }

	$soap = SOAP::Lite->proxy(
		sprintf 'http://%s/rpc/soap/jirasoapservice-v2?wsdl', HOST
	);

	$auth = $soap->login(
		SOAP::Data->type(string => $u),
		SOAP::Data->type(string => $p)
	);

	if ( $auth->fault ) {
	  die join( ' ', $auth->faultcode, $auth->faultstring, $auth->faultdetail );
	}

}

while ( <> ) {

	chomp;

	my ($user, $time, $hours, $project, $desc) = split "\t", $_;

	$desc =~ s/\[(\w+\-\d+)\]//g;
	next unless my $issue = $1;
	$desc =~ s/^\s+//;
	$desc =~ s/\s+$//;
	$desc ||= $project;

	warn "Adding work log for $hours starting at $time on issue $issue\n";
	next if $d; # dry-run
	my $addWorklog = $soap->addWorklogAndAutoAdjustRemainingEstimate(
		$auth->result(),
		$issue,
		SOAP::Data->type(
			RemoteWorklog => {
				startDate => $time, # like '2010-02-05T18:54:00Z'
				timeSpent => $hours, # like '4h30m'
				comment => $desc
			},
		)
	);

	if ( $addWorklog->fault ) {
	  die join( ' ', $addWorklog->faultcode, $addWorklog->faultstring, $addWorklog->faultdetail );
	}

}
