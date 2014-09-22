use Modern::Perl;
use Test::Files;
use File::Slurp;
use Test::More tests => 1;
my $msg   = 'file are identical';
my $di1   = 'c:/Users/nmishin/Documents/db/20120530/compare/bk2/';
my $di2   = 'c:/Users/nmishin/Documents/db/20120530/compare/21/';
my @paths = read_dir($di2);
for my $file (@paths) {
    compare_ok( $di1 . $file, $di2 . $file, $file . ' ' . $msg );
}
