#!/usr/bin/env perl
use v5.10;

my ( $init_start, $init_end ) = @ARGV;
step_by_n( $init_start, $init_end );

sub step_by_n {
    my ( $start, $end ) = @_;
    say "start step_by_n($start,$end)";
    for my $k ( $start .. $end ) {
        if ( $k < $end ) {
            say "from step_by_n($start,$end): $k";
            step_by_n( $k + 1, $end );
        }

        #fork();
    }
}

#sleep 60*60*24;

