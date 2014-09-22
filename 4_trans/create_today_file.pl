#!perl
use Modern::Perl;
use POSIX qw(strftime);
use File::Slurp;
use File::Path qw(make_path);
use File::Spec::Functions qw(catdir catfile);
use File::HomeDir;
 
my $base_dir = 'c:/TCPU59/utils'; 
main($base_dir);
 
# Make path tree and file
sub main {
my $work_path=shift;
# my $work_path = File::HomeDir->my_documents;
my $date = strftime( '%d%m%Y', localtime(time) );
my $job_dir = catdir( $work_path, 'job', $date );
make_path($job_dir); # if !-d $job_dir;
 
my $file = catfile( $job_dir, $date . '_nb.txt' );
write_file($file) if !-f $file;
}