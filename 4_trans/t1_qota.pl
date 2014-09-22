use Modern::Perl;
my $substring = 'quick.*?fox';
my $quoted_substring = quotemeta($substring);
say $quoted_substring;
