#!/usr/bin/perl --
#!/usr/bin/perl --
use strict;
use warnings;
use autodie qw/ chdir /;
use Data::Dump qw/ dd pp /;
use Path::Tiny qw/ path /;
require 'ppixregexplain.pl';

my $here = path( __FILE__ )->realpath->parent;
chdir $here;
my $outfh = path( 'Tools.pm.html' )->openw_raw;
select $outfh;
my $re = path( 'Tools.pm' )->slurp_raw;
MainXplain( '--html', $re );
__END__
