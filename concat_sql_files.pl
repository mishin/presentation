use strict;
use warnings;
use 5.010;

use Path::Iterator::Rule;
use File::Slurp;

die "Usage: $0 DIRs" if not @ARGV;

my $rule = Path::Iterator::Rule->new;
$rule->name("*.sql");

my $big_sql = $ARGV[0] . '/big.sql';


my $it = $rule->iter(@ARGV);
while (my $file = $it->()) {
    say "$file was added to $big_sql";
    write_file($big_sql, {append => 1}, read_file($file));
}

#thanks for Gabor
