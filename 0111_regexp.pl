use v5.10;

$_ =<<'HERE';
Amelia said "I am a camel"'
HERE

say "Matched" if m/
    ( ['"] ['"]) /xg;
