use YAPE::Regex::Explain;
print YAPE::Regex::Explain->new(qr/\Q[abc]\E\d+/)->explain();