#!/usr/bin/env perl

use strict;
use warnings;
use Mojo::UserAgent;

my $ua = Mojo::UserAgent->new();
my @url;
$url[$_] = "https://example.com/$_" for ( ( 0 .. 999 ) );

my @html;
Mojo::IOLoop->delay(
    sub {
        my $delay = shift;
        for my $url (@url) {
            $ua->get( $url => $delay->begin );
        }
    },
    sub {
        my ($delay) = shift;
        for my $r (@_) {
            push @html, $r->res->body;
        }
    }
)->wait;
