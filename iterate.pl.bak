use strict;
use warnings;
use 5.010;

use Path::Iterator::Rule;
use File::Slurp;

die "Usage: $0 DIRs" if not @ARGV;

my $rule = Path::Iterator::Rule->new;
$rule->name("*.pm");

my $big_sql = $ARGV[0] . '/big.sql';

my $it = $rule->iter(@ARGV);
while ( my $file = $it->() ) {
    say "use strict added to $file";
    add_strict_to_file($file);
}

sub add_strict_to_file {

    #http://perlmaven.com/splice-to-slice-and-dice-arrays-in-perl
    my ($file) = @_;
    my @lines = read_file($file);
    my @strict = ( 'use strict;', 'use warnings;', '' );
    splice @lines, 1, 0, ( join "\n", @strict );
    write_file( $file, \@lines );
}
