#!/usr/bin/env perl

use Data::Dumper qw(Dumper);

my $FROM_JSON = qr{

(?&VALUE) (?{ $_ = $^R->[1] })

(?(DEFINE)

(?<OBJECT>
  (?{ [$^R, {}] })
  \{
    (?: (?&KV) # [[$^R, {}], $k, $v]
      (?{ # warn Dumper { obj1 => $^R };
	 [$^R->[0][0], {$^R->[1] => $^R->[2]}] })
      (?: , (?&KV) # [[$^R, {...}], $k, $v]
        (?{ # warn Dumper { obj2 => $^R };
	   [$^R->[0][0], {%{$^R->[0][1]}, $^R->[1] => $^R->[2]}] })
      )*
    )?
  \}
)

(?<KV>
  (?&STRING) # [$^R, "string"]
  : (?&VALUE) # [[$^R, "string"], $value]
  (?{ # warn Dumper { kv => $^R };
     [$^R->[0][0], $^R->[0][1], $^R->[1]] })
)

(?<ARRAY>
  (?{ [$^R, []] })
  \[
    (?: (?&VALUE) (?{ [$^R->[0][0], [$^R->[1]]] })
      (?: , (?&VALUE) (?{ # warn Dumper { atwo => $^R };
			 [$^R->[0][0], [@{$^R->[0][1]}, $^R->[1]]] })
      )*
    )?
  \]
)

(?<VALUE>
  \s*
  (
      (?&STRING)
    |
      (?&NUMBER)
    |
      (?&OBJECT)
    |
      (?&ARRAY)
    |
    true (?{ [$^R, 1] })
  |
    false (?{ [$^R, 0] })
  |
    null (?{ [$^R, undef] })
  )
  \s*
)

(?<STRING>
  (
    "
    (?:
      [^\\"]+
    |
      \\ ["\\/bfnrt]
#    |
#      \\ u [0-9a-fA-f]{4}
    )*
    "
  )

  (?{ [$^R, eval $^N] })
)

(?<NUMBER>
  (
    -?
    (?: 0 | [1-9]\d* )
    (?: \. \d+ )?
    (?: [eE] [-+]? \d+ )?
  )

  (?{ [$^R, eval $^N] })
)

) }xms;

sub from_json {
  local $_ = shift;
  local $^R;
  eval { m{\A$FROM_JSON\z}; } and return $_;
  die $@ if $@;
  return 'no match';
}

while (<>) {
  chomp;
  print Dumper from_json($_);
}



