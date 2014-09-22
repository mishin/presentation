use Modern::Perl;
use Config::Auto;
use Getopt::Long;
use Pod::Usage;
use POSIX qw(strftime);
use Smart::Comments;
use English qw( -no_match_vars ) ; # Avoids regex performance penalty
use Carp;
use YAML::Tiny;
use File::Slurp;
use File::Basename;
use Try::Tiny;
use FindBin '$Bin'; #get $path_to_current_script !!!
use WWW::Mechanize::Firefox;

very useful,
PERL5LIB=c:\Strawberry\perl\site\lib 