use utf8;
use Encode::Locale;
use IO::Interactive qw(is_interactive);

use Dancer ':syntax';
use Data::Printer colored => 1;

sub prepare_encoding_console {
    if ( is_interactive() ) {
        binmode( STDIN,  ":encoding(console_in)" );
        binmode( STDOUT, ":encoding(console_out)" );
        binmode( STDERR, ":encoding(console_out)" );
    }
}

prepare_encoding_console();

my $aa = { a => 'b', c => 'д' };    # тут русская буква
p $aa;
my $jj = to_json($aa);
p $jj;
my $test = utf8::is_utf8($jj);       # returns 1
p $test;
my $bb = from_json($jj);
p $bb;
