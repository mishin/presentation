        $curr_record =~ m/
   (?(DEFINE)
   	        (?<values>(?<name>\w+)[ ]?&quote(?<value>.*?)?&quote)
	        (?<quote> (?&short_quote) | (?&long_quote) )   	        
	        (?<short_quote> ["] )
	        (?<long_quote> \Q=+=+=+=\E )
	    )
	    (?<values>(?<name>\w+)[ ]?&quote(?<value>.*?)?&quote)


        
        (?<name>\w+)[ ]"(?<value>.*?)(?<!\\)"|
        ((?<name>\w+)[ ]\Q=+=+=+=\E
        (?<value>.*?)
        \Q=+=+=+=\E)
