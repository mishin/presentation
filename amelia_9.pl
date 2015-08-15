use v5.18;
$_ = <<'HERE';
Out "Top 'Middle "Bottom" Middle' Out"
HERE

my @matches;

say "Matched!" if m/ 
         (?(DEFINE) 
             (?<QUOTE_MARK> ['"]) 
             (?<NOT_QUOTE_MARK> [^'"])
             (?<QUOTE>
                 (
                      (?<quote>(?&QUOTE_MARK)) 
                      
                      (?: 
                           (?&NOT_QUOTE_MARK)++ 
                           (?&QUOTE)
                      )* 
                      \g{quote} 
           )
          (?{ push @matches, $^N }) 
	     )
	    )
	  (?&QUOTE)
         /x; 
         
