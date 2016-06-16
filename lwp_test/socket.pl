#!/usr/bin/env perl

use strict;
use warnings;
use IO::Socket::SSL;

my $sock = IO::Socket::SSL->new('example.com:443') or die "ERROR::$@";
my @html;
for ( ( 1 .. 1000 ) ) {
    get();
}

sub get {
    print $sock "GET / HTTP/1.1\nHost: example.com\nConnection: keep-alive\n\n";
    my $html = "";
    while (<$sock>) {
        +next if /\r\n$/;
        $html .= $_;
        last if /<\/body>/;
    }
    push @html, $html;
}
