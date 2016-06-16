	#!/usr/bin/perl 
	use strict;

	my $key = 'welcome';
	my %data = (
		'this' => qw(that), 
		'tom' => q(and jerry),
		'welcome' => q(Hello World),
		'zip' => q(welcome),
	);
	my @data = keys %data;

        print "All OK\n" if grep($key, keys %data);
        print "$data{$key}\n";
        print "done: '$data{$key}'\n";
	print "$data{$key}\n";
	exit;  
