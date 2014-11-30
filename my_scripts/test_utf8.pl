use Modern::Perl;
use POSIX qw(locale_h);
my $old_locale = setlocale(LC_CTYPE);
say $old_locale;