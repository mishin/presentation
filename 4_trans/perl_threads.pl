#!/usr/bin/env perl

# This script simply shows how to use Perl 5.6 threads. It doesn't actually do anything.

use v5.6;
use strict;
use warnings;

use threads;
use threads::shared;

use Data::Dumper;
use Log::Log4perl;
use Readonly;
use Thread::Queue;

Readonly::Scalar my $NRUNS => 3;
Readonly::Scalar my $NWORKERS => 3;
Readonly::Scalar my $MAX_RECORDS => 10;
Readonly::Scalar my $RUN_INTERVAL => 5;

Log::Log4perl->init({
	'log4perl.rootLogger' => 'ALL, Screen',
	'log4perl.appender.Screen' => 'Log::Log4perl::Appender::Screen',
	'log4perl.appender.Screen.layout' => 'Log::Log4perl::Layout::PatternLayout',
	'log4perl.PatternLayout.cspec.z' => 'sub { return threads->self()->tid() }',
	'log4perl.appender.Screen.layout.ConversionPattern' => "%d [Thread %z] %-8c %-5p %m{chomp}%n",
});

my $queue = new Thread::Queue();
my $finished :shared = 0;
my $report_lock :shared = 0;

$SIG{'KILL'} = $SIG{'TERM'} = $SIG{'INT'} = \&kill_handler;

main();
exit(0);

sub main {
	my $log = Log::Log4perl->get_logger();
	$log->info("Initalizing threads");
	threads->create(\&Reporter);
	threads->create(\&Worker) for 1 .. $NWORKERS;

	for (1 .. $NRUNS) {
		sleep($RUN_INTERVAL) until $queue->pending() == 0;
		$log->info("Queueing $MAX_RECORDS more IDs");
		$queue->enqueue(get_ids($MAX_RECORDS));
	}
	{
		lock($finished);
		$finished = 1;
	}
	$_->join() for threads->list();
	$log->info("All records processed");
}

sub get_ids {
	my $limit = shift;
	return 1 .. ($limit > 10 ? 10 : $limit);
}

sub record_by_id {
	my $id = shift || return;
	return [
		{'name' => 'John'},
		{'name' => 'Adam'},
		{'name' => 'David'},
		{'name' => 'Paul'},
		{'name' => 'Richard'},
		{'name' => 'George'},
		{'name' => 'Steven'},
		{'name' => 'Kevin'},
		{'name' => 'Nick'},
		{'name' => 'Jason'},
	]->[$id];
}

sub Worker {
	my $log = Log::Log4perl->get_logger('Worker');
	while(not $finished) {
		# We can't use $queue->dequeue() because we'll never finish once
		# the queue is empty. Instead poll the queue.
		# TODO: Find a better way of doing this.
		my $id = $queue->dequeue_nb() || (sleep($POLL_INTERVAL) && next);
		my $record = record_by_id($id) || next;
		local $Data::Dumper::Indent = 0;
		$log->info("Processing ID $id (" . Dumper($record) . ')');
		{
			my $sleep_delta = int(rand(5));
			$log->debug("Pretending to work. Napping for $sleep_delta seconds");
			sleep($sleep_delta);
		}
		lock($report_lock);
		cond_signal($report_lock);
	}
	$log->info("Finished");
}

sub Reporter {
	my $log = Log::Log4perl->get_logger('Reporter');
	my $sleep_delta = 1;
	while(not $finished) {
		$log->info($queue->pending() . " items remaining");
		lock($report_lock);
		cond_wait($report_lock);
	}
	$log->info("Finished");
}

sub kill_handler {
	{
		lock($finished);
		$finished = 1;
	}
	$_->join() for threads->list();
	Log::Log4perl->get_logger()->error($queue->pending() . " items not processed!");
	exit(1);
}
