#!/usr/bin/env perl
#https://www.cs.tut.fi/~jkorpela/chars.html
# https://metacpan.org/pod/Regexp::Assemble
     
# Regex::PreSuf
# Regexp::Optimizer
# Regexp::Parser
# Regexp::Trie
# Text::Trie
# Tree::Trie
use v5.14.2	;
use charnames ':full';
use utf8;
use Modern::Perl;
use Encode::Locale qw(decode_argv);

 if (-t) 
{
    binmode(STDIN, ":encoding(console_in)");
    binmode(STDOUT, ":encoding(console_out)");
    binmode(STDERR, ":encoding(console_out)");
}


print "\N{GREEK SMALL LETTER SIGMA} is called sigma.\n";


"\N{LATIN SMALL LIGATURE FI}" =~ /fi/i;          # Найдте
"\N{LATIN SMALL LIGATURE FI}" =~ /[fi][fi]/i;    # Не найдет!
"\N{LATIN SMALL LIGATURE FI}" =~ /fi*/i;         # Не найдет!
