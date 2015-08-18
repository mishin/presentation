
    use v5.18;
    $_ = <<'HERE';
    Out "Top 'Middle "Bottom" Middle' Out"
    HERE

    say "Matched [$+{said}]!" if m/
               (?<said>              #$1
               (?<quote>['"])
                      (?:
                          [^'"]++
                          |
                          (?R)
                      )*
               \g{quote}
               )
               (?{say "Inside regex: $+{said}"})
               /x;




