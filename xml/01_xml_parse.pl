#!/use/bin/perl -w
#
use strict;
use warnings;
use Test::More;

BEGIN {
    my $add = 0;
    eval { require Test::NoWarnings; Test::NoWarnings->import; ++$add; 1 }
      or diag "Test::NoWarnings missed, skipping no warnings test";
    plan tests => 3 + $add;

    eval { require Data::Dumper; Data::Dumper::Dumper(1) } and *dd = sub ($) {
        Data::Dumper->new( [ $_[0] ] )->Indent(0)->Terse(1)->Quotekeys(0)
          ->Useqq(1)->Purity(1)->Dump;
      }
      or *dd = \&explain;
}
use XML::Fast 'xml2hash';
my $xml_file = shift or die "use: $0 files.xml  requied!";
diag "testing file $xml_file";
my $xml = do { local $/; open my $f,'<',$xml_file; <$f> };
my $hash = xml2hash $xml;
diag dd($hash), "\n";
