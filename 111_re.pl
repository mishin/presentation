use v5.10;    
my @captures = "a" =~ /
            (.)                  # Первый захват
            (?(DEFINE)
	    (?<EXAMPLE> 1 )  # Второй захват
	    )/x;
											     say scalar @captures;

