#!/usr/bin/perl -w
use strict;
use warnings;
use 5.010;

my $comment_pred = 'COUNTRY_SU';
for my $coutry (qw/SU USA GB RU/) {
    my $comment = $comment_pred =~ s/(COUNTRY_)SU/$1${coutry}/rg;
    say $comment;
}

