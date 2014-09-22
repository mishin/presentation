my ( $t1, $t2, $t3, ) = ( '1', '2', '3' );
my @in_proc = ( $t1, $t2, $t3, );
my $rez = proc( \@in_proc );

sub proc {
    my ( $t1, $t2, $t3, ) = @{ $_[0] };
    my $r = $t1 + $t2 + $t3;
    return \$r;
}
