use 5.010;
use strict;
use warnings;
use FindBin '$Bin';
print "The script is located in $Bin.\n";
use lib "$FindBin::Bin/lib";
use Smart::Comments;

#say $FindBin;
use Test::Simple tests => 1;

$ENV{PATH} = '.';

my $output = qx{@ARGV};
### @ARGV

ok( $output eq "Hello World\n" );
