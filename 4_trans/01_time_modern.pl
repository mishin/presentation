use Modern::Perl;
use Test::More;
use 5.010;
use Regexp::Common 'RE_num_ALL';
use Smart::Comments;
use Carp ;
#use Carp qw(cluck);

my %time_check = (
    10            => '10s ',
    100           => '1m 40s ',
    10_000        => '2h 46m 40s ',
    60            => '1m ',
    -60           => '-1m ',
    3_600         => '1h ',
    300_000       => '3d 11h 20m ',
    30_000_000    => '49w 4d 5h 20m ',
    300_000_000   => '9y 28w 5h 20m ',
    3_000_000_000 => '95y 20w 2d 5h 20m ',
);

my ( %times_of, %part_of, %time_pair );
for my $sec ( sort { $a <=> $b } keys %time_check ) {
    is( show_human_time($sec), $time_check{$sec},
        "$sec: |$time_check{$sec}| time the same" );
}


use Test::Exception;
# Check that the stringified exception matches given regex
throws_ok { show_human_time('a') } qr/Usage: show_human_time/, 'wrong input caught okay';
# test the errors
#eval { show_human_time('a'); };
#my $error_message='Usage: show_human_time';#($seconds), $seconds must be integer at 01_time_modern.pl';
#print $@;
#like( $@, qr/Usage: show_human_time/, "Filed type of parameter" );
#is( show_human_time('a'), 'err','test error');

done_testing();

sub show_human_time {
    my $seconds = shift;
    die  'Usage: show_human_time($seconds), $seconds must be integer'
      if ( $seconds !~ $RE{num}{int} );
    my ( $sign, $time );
    if ( $seconds =~ $RE{num}{int}{-keep} ) {
        $times_of{seconds} = $3;
        $sign = $2;
    }

    my @full_times = qw/seconds minutes hours days weeks years/;
    my @low_times  = @full_times[ 0 .. $#full_times - 1 ];
    @part_of{@low_times} = qw/60 60 24 7 52/;
    my @big_times = @full_times[ 1 .. $#full_times ];
    @time_pair{@low_times} = @big_times;    #slice of hash!!!

    map { _get_part_of($_) } @low_times;
    $time = join '', map { _format_time($_) } reverse @full_times;

    return $sign.$time;
}

sub _format_time {
    my $time_name = shift;
    my $part      = $times_of{$time_name};
    my $format    = substr( $time_name, 0, 1 );
    given ($part) {
        when (0) { return ''; }
        default {
            return sprintf '%d' . $format . ' ', $part;
        }
    }
}

sub _get_part_of {
    my $chunk   = shift;
    my $measure = $times_of{$chunk};
    my $part_of = $part_of{$chunk};
    given ($measure) {
        when (undef) { return 0; }
        default {
            $times_of{$chunk} = $measure % $part_of;
            $times_of{ $time_pair{$chunk} } = int( $measure / $part_of );
        }
    }
    return 1;
}
