#!/usr/bin/perl
#
use 5.10.0;
#
use strict;
use warnings;
#
use Time::Piece;
#
## Read the date from the command line.
my $date = shift;
#
## Parse the date using strptime(), which uses strftime() formats.
my $time = Time::Piece->strptime( $date, "%Y%m%d %H:%M" );
#
## Here it is, parsed but still in GMT.
say $time->datetime;
#
## Get your local time zone offset and add it to the time.
$time += $time->localtime->tzoffset;
#
## And here it is localized.
say $time->datetime;
