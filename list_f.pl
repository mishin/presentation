#!/usr/bin/env perl                                                                             

use strict;
use warnings;
use IO::All;

my $file = shift || die qq(No file specified!);
my @lines;
my $line = 1;

my @found = grep { $_->name =~ /.+\/$file$/i } io(q(.))->all;

die qq($file not found) unless @found;

@lines = map { $_ = $line++ . qq( $_) } io( $found[0] )->slurp;

print for @lines;

__END__