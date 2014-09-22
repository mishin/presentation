my %test_values_of = (
    '0'        => '1',
    '1'        => '1',
    '4349678L' => '9',
    '4347946L' => '9',
    '791517N'  => '9'
);
use Smart::Comments;
my $n = 0;
while ( my ( $key, $value ) = each(%test_values_of) ) {
    $n++;
    print '#' x 20, "\n";
### $n
### $key
### $value

    for $op ( '&', '&&', 'and' ) {
### $op
        test_op( $key, $value, $n, $op );
    }
}

sub test_op {
    my ( $sysid, $ver, $n, $op ) = @_;
    my $rez = eval( '$sysid ' . $op . ' $ver' );
    if ($rez) {
        print 'done';
    }
    else {
        print 'no';
    }
    print '[' . $rez . "]\n";
}
