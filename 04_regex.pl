    "1000\t2000" =~ m(0\t2);      # matches
    "cat"      =~ /\143\x61\x74/; # matches in ASCII, but a weird way to spell cat
#perl -MYAPE::Regex::Explain -e "print YAPE::Regex::Explain->new(qr/0\t2/)->explain();"
#perl -MYAPE::Regex::Explain -e "print YAPE::Regex::Explain->new(qr/\143\x61\x74/)->explain();"