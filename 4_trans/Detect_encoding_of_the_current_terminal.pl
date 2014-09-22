use strict;
use warnings;
use Modern::Perl;

use Term::Encoding qw(term_encoding);
my $encoding = term_encoding;
say $encoding;