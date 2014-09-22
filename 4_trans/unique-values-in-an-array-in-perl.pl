#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use Data::Dumper qw(Dumper);

#use Smart::Comments;

my $start_time = time;
main();
my $elapsed_time = wdhms( time - $start_time );
my $ret          = print "Time elapsed: $elapsed_time\n";

sub main {

    #read sql and data from source
    my $ref_source_data = import_sql_and_data();
    my $input           = $ref_source_data->{'input.txt'};
### $input

    my @arry_from_txt = do { local $/; "", split /\s+/, $input };
    @arry_from_txt = grep { /\w+/ } @arry_from_txt;
    say Dumper \@arry_from_txt;
    my @unique = grep { state %seen; !$seen{$_}++ } @arry_from_txt;

    #    say Dumper \@unique;
    say "Answer1: @unique";
    my @unique2 = grep { state %seen; !$seen{ uc($_) }++ } @arry_from_txt;
    say "Answer2: @unique2";
}

sub import_sql_and_data {
    print {*STDERR} "Reading DATA ...\n";
    my %contents_of = do { local $/; "", split /_____\[ (\S+) \]_+\n/, <DATA> };

    #    say Dumper \%contents_of;
    for ( values %contents_of ) {
        s/^!=([a-z])/=$1/gxms;
    }
    print {*STDERR} "done\n";
    return \%contents_of;
}

=pod
=item *  C<< import_sql_and_data ()  >>
=item *  my $content=import_sql_and_data () 

Read sql-query and data from source of module
=cut

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

__DATA__

_____[ input.txt ]________________________________________________
foo Bar bar first second
  Foo foo another foo
