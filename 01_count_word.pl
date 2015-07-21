open F, $ARGV[0] || die $!;
my @lines = ;
my @words = map {split /\s/} @lines;
printf "%8d %8d\n", scalar(@lines), scalar(@words); close(F);
