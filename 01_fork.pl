use v5.10;

my ( $init_start, $init_end )=@ARGV;
step_by_n( $init_start, $init_end );

sub step_by_n {
    my ( $start, $end ) = @_;
#        if ( $start > $end ) {
#		exit;
#        }
    say "start step_by_n($start,$end)";
    for my $k ( $start .. $end ) {
        say "from step_by_n($start,$end): $k";
            step_by_n( $k + 1, $end );

        #fork();
    }
}

#perl 01_fork.pl 1 25|grep from|wc -l
#33554431

#sleep 60*60*24;
#my $n = 25;
#my $sum = ( $n * ( $n + 1 ) ) / 2;
#printf "%s \n", $sum;

