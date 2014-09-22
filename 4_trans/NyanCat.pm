=pod

Nyan Cat TAP Formatter

1. Save this file into your PERL5LIB
2. Run prove with option like following:

$ prove --formatter NyanCat

http://www.mattsears.com/articles/2011/11/16/nyan-cat-rspec-formatter

=cut

package NyanCat;

use utf8;
use strict;
use warnings;
use parent qw(TAP::Formatter::Console);

sub open_test {
    my ($self, $test, $parser) = @_;
    my $session = NyanCat::Session->new( {
        name            => $test,
        formatter       => $self,
        parser          => $parser,
    } );
}

package NyanCat::Session;

use Term::ANSIColor;
use Time::HiRes qw(sleep time);
use parent qw(TAP::Formatter::Console::Session);
use POSIX qw(floor);

my $size = (split /\s+/, `stty size`)[-1];
my $colors = do {
    my $pi_3 = atan2(1, 1) * 4 / 3;
    [
        map {
            my $n = $_ * 1 / 6;
            my $r = floor(3 * sin($n            ) + 3);
            my $g = floor(3 * sin($n + 2 * $pi_3) + 3);
            my $b = floor(3 * sin($n + 4 * $pi_3) + 3);
            36 * $r + 6 * $g + $b + 16;
        }
        (6..((6 * 7) + 1))
    ]
};

my %statistics;
my $code = ' ' x $size;
my $prev = 0;

my $rainbowify = 0;
sub rainbowify ($) {
    my $string = shift;
    $string =~ s{(.)}{
        my $color = $colors->[$rainbowify++ % @$colors];
        sprintf("\e[38;5;%dm%s\e[0m", $color, $1);
    }eg;
    $string;
}

sub cat ($$) {
    my ($eye, $n) = @_;

    ($n % 2 == 0) ?
      [ "_,------,   ",
        "_|  /\\_/\\ ",
        "~|_( $eye .$eye)  ",
        " \"\"  \"\" "
      ]:
      [ "_,------,   ",
        "_|   /\\_/\\",
        "^|__( $eye .$eye) ",
        "  \"\"  \"\"    "
      ];
}

sub result {
    my ($self, $result) = @_;
    if ($result->is_test) {
        my $type = $result->{directive} || $result->{ok};
        $statistics{$type}++;
        $code .= {
            'ok'     => (length($code) % 2 == 0) ? '-' : '_',
            'not ok' => '*',
            'TODO'   => '!',
            'SKIP'   => '=',
        }->{$type};

        print "\e[2J";
        printf "\e[%d;%dH", 0, 0;

        my $length = $size - 30;
        my $x = rainbowify substr($code, -$length);
        my $c = cat('^', length $code);

        print color 'green';
        printf("% 8d: %s%s\n", $statistics{'ok'}     || 0, $x, $c->[0]);
        print color 'red';
        printf("% 8d: %s%s\n", $statistics{'not ok'} || 0, $x, $c->[1]);
        print color 'yellow';
        printf("% 8d: %s%s\n", $statistics{'TODO'}   || 0, $x, $c->[2]);
        print color 'yellow';
        printf("% 8d: %s%s\n", $statistics{'SKIP'}   || 0, $x, $c->[3]);
        print color 'reset';

        my $sleep = time - $prev;
        my $interval = 0.1;
        sleep $interval - $sleep if $sleep < $interval;
        $prev = time;
    }
}

sub close_test {
    my $self   = shift;
    my $parser = $self->parser;
}

1;
__END__
