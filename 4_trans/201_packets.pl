#!/usr/bin/perl -w
#use re 'debug';
my $record = "RX packets:1473352 errors:28 dropped:0 overruns:0 frame:0";
if ( $record =~ /(RX)(.*)/ ) {
    print "1=$1,2=$2\n";
}
if ( $record =~ /(RX)(.*)(packets)(.*)/ ) {
    print "1 = $1, 2 = $2, 3 = $3, 4 = $4\n";
}
###result
#1=RX,2= packets:1473352 errors:28 dropped:0 overruns:0 frame:0
#1 = RX, 2 =  , 3 = packets, 4 = :1473352 errors:28 dropped:0 overruns:0 frame:0
