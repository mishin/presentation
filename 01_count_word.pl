#!/usr/bin/env perl
open my $fh, $ARGV[0] || die "Usage: $0 file_4_word_count\n errno:$!";
my @lines = <$fh>;
my @words = map { split /\s/ } @lines;
printf "%8d %8d\n", scalar(@lines), scalar(@words);
close $fh;
