#!/usr/bin/env perl

use strict;
use warnings;
use YADA;

my @url;
$url[$_] = "https://example.com/$_" for ( ( 0 .. 999 ) );  # урлы для YADA должны быть разные

my @html;

YADA->new->append( [@url] => sub { push @html, ${ $_[0]->data }; } )->wait;
