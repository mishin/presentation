# VOODOO LINE-NOISE
my ( $C, $M, $P, $N, $S );
END { print "1..$C\n$M"; print "\nfailed: $N\n" if $N }

sub ok {
    $C++;
    $M .= ( $_[0] || !@_ )
      ? "ok $C\n"
      : (
        $N++,
        "not ok $C ("
          . ( ( caller 1 )[1] || ( caller 0 )[1] ) . ":"
          . ( ( caller 1 )[2] || ( caller 0 )[2] ) . ")\n"
      );
}
sub try { $P = qr/^$_[0]$/ }

sub fail {
    my ( $S, @M ) = @_;
    my $C = 0;
    unshift @M, $S;
    print "wanted\t[", join( '][', @M ), "]\n";
    print "got\t[", join( '][', $S =~ $P ), "]\n";
}

sub pass {
    my ( $S, @M ) = @_;
    my $C = 0;
    unshift @M, $S;
    foreach ( $S =~ $P ) {
        ++$C and next
          if ( shift() eq $_ );
        ok(0) && return;
    }
    ok( $C > 0 );
}
