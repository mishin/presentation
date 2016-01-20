# you can write to stdout for debugging purposes, e.g.
# print "this is a debug message\n";
use List::Util qw(max);
use Test::More tests => 5;

sub solution {
    my ($N) = @_;

    # write your code in Perl 5.18
    my $binary_number = sprintf "%b", $N;

    # print "\$binary_number: $binary_number\n";
    my $counter     = 0;
    my $max_counter = 0;

    # my $ret_counter   = 0;
    my $lenght_string = length $binary_number;
    my $start_gap     = '0';
    for ( my $i = 0 ; $i < $lenght_string ; $i++ ) {
        my $char      = substr( $binary_number, $i,     1 );
        my $prev_char = substr( $binary_number, $i - 1, 1 );
        my $next_char = substr( $binary_number, $i + 1, 1 );
        
        if ( $char eq '0' && ( $prev_char eq '1' || $counter > 0 ) ) {
            $counter++;
            if ( $next_char eq '1' ) {
                $max_counter = max( $max_counter, $counter );
            }
        }
        else {
            $counter = 0;
        }
    }
    return $max_counter;
}


# $ARGV[0]
is( solution(6),    0, "0 zero gap for 6" );
is( solution(1),    0, "0 zero gap for 1" );
is( solution(2),    0, "0 zero gap for 2" );
is( solution(1024), 0, "0 zero gap for 1024" );
is( solution(1041), 5, "5 zero gap for 1041" );
