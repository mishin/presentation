remove_warnings.pl #!perl -w
use strict;
use 5.01;

# use File::Slurp qw( edit_file_lines );
my $file_name = shift;

# print $file_name;
# # in-place edit to delete all lines with 'foo' from file
# edit_file_lines sub { $_ = '' if /file does not exist!/ }, $file_name;
use File::Slurp qw( :std );

# read in a whole file into an array of lines
my @lines = read_file($file_name);

#my $path_to_files = '/MISHNIK/test';
#my @files = read_dir( $path_to_files, prefix => 1 );
my @needed_lines = grep { !/file does not exist/ } @lines;

# write out a whole file from an array of lines
# write_file( $file_name . '.new', @needed_lines );
write_file( $file_name, @needed_lines );
