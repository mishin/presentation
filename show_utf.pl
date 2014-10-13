#!/usr/bin/env perl
use utf8;
use Modern::Perl;
use Encode::Locale;
use Data::Dumper qw( Dumper );
if (-t) {
    binmode( STDIN,  ":encoding(console_in)" );
    binmode( STDOUT, ":encoding(console_out)" );
    binmode( STDERR, ":encoding(console_out)" );
}
my $love = "Я люблю Перл";

print Dumper ($love);

my $utf_str =
  "\x{42f} \x{43b}\x{44e}\x{431}\x{43b}\x{44e} \x{41f}\x{435}\x{440}\x{43b}";

$utf_str =~ s/\\x\{(\w+)\}/\($1)/g;
say "$utf_str";

my $utf_str_2 =
  "\(42f) \(43b)\(44e)\(431)\(43b)\(44e) \(41f)\(435)\(440)\(43b)";
$utf_str_2 =~ s/\((\w+)\)/\\x{$1}/g;
say 1;
say $utf_str_2;
