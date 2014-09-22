use strict;
use warnings;
use 5.010;
use File::Slurp qw( :std );
use FindBin '$Bin';    #get $path_to_current_script !!!
my $path_to_current_script = $Bin;

# read in a whole file into an array of lines
#my @lines = read_file('filename');

my @paths = read_dir( $path_to_current_script, prefix => 1 );
for my $file (@paths) {
    say $file;
}

# write out a whole file from an array of lines
#write_file( 'filename', @lines );