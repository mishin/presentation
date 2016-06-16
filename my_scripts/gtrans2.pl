#!/usr/bin/env perl
# By: Jeremiah LaRocco, Nikolay Mishin (refactoring)
# Use translate.google.com to translate between languages.
# Sample run:
#gtrans.pl --from en --to ru --text "This is a test"

use Modern::Perl;
use LWP::UserAgent;

use Getopt::Long;
use Pod::Usage;

use open ':locale';

my $man  = 0;
my $help = 0;
my $from = 'en';
my $to   = 'ru';
my $text = 'yapc';

GetOptions(
    'help|?' => \$help,
    'man'    => \$man,
    'from=s' => \$from,
    'to=s'   => \$to,
    'text=s' => \$text
) or pod2usage( -verbose => 2 );

pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

&main;
exit;

sub main {
    translate_text( $from, $to, $text );
}

sub translate_text {
    my ( $from, $to, $words ) = @_;

    my $url =
        'http://translate.google.com/translate_t?langpair='
      . $from . '|'
      . $to
      . '&text=' . '+'
      . $words;
    my $ua = LWP::UserAgent->new;
    $ua->agent('');
    my $res = $ua->get($url);
    die $res->status_line if $res->is_error;
    my $html = $res->decoded_content;

    my @matches =
      $html =~ m{onmouseout="this.style.backgroundColor='#fff'">(.*?)</span>}g;

    foreach my $translated_string (@matches) {
        say $translated_string;
    }
}

__END__

=head1 NAME

gtrans.pl - Translate using  translate.google.com

=head1 SYNOPSIS

gtrans.pl --from en --to ru --text "This is a test"
gtrans.pl [options] [text to translate ...]

Options:
-help brief help message
-man full documentation
-from from language
-to to language
-text text to translate

=head1 OPTIONS

=over 2

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

B<This program> will read the given input "text" and translate it to 
 selected language using translate.google.com.

=head1 AUTHOR


Jeremiah LaRocco, Nikolay Mishin(mi@ya.ru) (refactoring)


=cut
