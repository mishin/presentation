#!perl
use v5.10;
use strict;
use warnings;
use POSIX qw(strftime);
use File::Slurp;
use File::Spec;

my $base_dir = 'c:/TCPU59/utils/job';
my $date = strftime( '%d%m%Y', localtime(time) );

main( $base_dir, $date );

sub main {
    my ( $base_dir, $date ) = @_;
    my $dir = File::Spec->catpath( '', $base_dir, $date);
    given ($dir) {
        when ( !-d ) {
            mkdir $dir;
            my $file = File::Spec->catpath( '', $dir, $date . '_nb.txt' );
            write_file($file);
        }
    }
}
