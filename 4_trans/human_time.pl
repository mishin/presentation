#convert time to human view
sub wdhms {
    my ( $weeks, $days, $hours, $minutes, $seconds, $sign, $res ) =
      qw/0 0 0 0 0/;

    use constant M_IN_HOUR => 60;
    use constant H_IN_DAY  => 24;
    use constant D_IN_WEEK => 7;

    my $EMPTY = q{};
    my $SPACE = q{ };
    my $COMMA = q{,};
    my $QUOTE = q{'};
    my $PLUS  = q{+};
    my $DASH  = q{-};

    $seconds = shift;
    $sign    = $seconds == abs $seconds ? $EMPTY : $DASH;
    $seconds = abs $seconds;

    if ($seconds) {
        ( $seconds, $minutes ) =
          ( $seconds % M_IN_HOUR, int( $seconds / M_IN_HOUR ) );
    }

    if ($minutes) {
        ( $minutes, $hours ) =
          ( $minutes % M_IN_HOUR, int( $minutes / M_IN_HOUR ) );
    }
    if ($hours) {
        ( $hours, $days ) = ( $hours % H_IN_DAY, int( $hours / H_IN_DAY ) );
    }
    if ($days) {
        ( $days, $weeks ) = ( $days % D_IN_WEEK, int( $days / D_IN_WEEK ) );
    }

    if ($weeks)   { $res .= sprintf '%dw ', $weeks }
    if ($days)    { $res .= sprintf '%dd ', $days }
    if ($hours)   { $res .= sprintf '%dh ', $hours }
    if ($minutes) { $res .= sprintf '%dm ', $minutes }
    $res .= sprintf '%ds ', $seconds;

    return $sign . $res;
}