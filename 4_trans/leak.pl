#!/usr/bin/env perl
use strict;
use warnings;

my $TOKEN_RE = qr/
  (?:
    <(?<tag>
      \s*
      [^>\s]+
    )>
  )??
/xis;

"<html><body></body></html>" =~ m/$TOKEN_RE/gcs;

for ( 1 .. 1000000000 ) {
    my $tag = $+{tag};
}
