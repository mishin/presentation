use v5.18;
$_ = <<'HERE';
He said 'Amelia said "I am a camel"'
HERE

say "Matched [$+{said}]!" if m/ 
           (?<said>              #$1
           (?<quote>['"]) 
                  (?:
                      [^'"]++
                      |
                      (?<said> (?1) )
                  )*
           \g{quote}
           )
           /x;
