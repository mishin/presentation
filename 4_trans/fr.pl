 use locale;
    use POSIX qw(locale_h); # Imports setlocale() and the LC_ constants.
    #      setlocale(LC_NUMERIC, "fr_FR") or die "Pardon";
          printf "%g\n", 1.23; # If the "fr_FR" succeeded, probably shows 1,23.


	    use locale;
	       use POSIX qw(locale_h strtod);
	          setlocale(LC_NUMERIC, "de_DE") or die "Entschuldigung";
		     my $x = strtod("2,34") + 5;
		        print $x, "\n"; # Probably shows 7,34.
