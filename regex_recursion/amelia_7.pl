use v5.18;
$_ = <<'HERE';
Out "Top 'Middle "Bottom" Middle' Out"
HERE


say "Matched [$+{said}]!" if m/ 
         (?(DEFINE) 
             (?<QUOTE> ['"]) 
             (?<NOT_QUOTE> [^'"]) 
         ) 
         (?<said> 
         (?<quote>(?&QUOTE))
                 (?: 
                    (?&NOT_QUOTE)++ 
                    | 
                    (?R) 
                 )* 
          \g{quote} 
         ) 
         (?{ say "Inside regex: $+{said}" }) 
         /x; 
         
