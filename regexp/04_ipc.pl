#!/usr/bin/env perl
use utf8;
use Modern::Perl;
use Encode::Locale qw(decode_argv);

 if (-t) 
{
    binmode(STDIN, ":encoding(console_in)");
    binmode(STDOUT, ":encoding(console_out)");
    binmode(STDERR, ":encoding(console_out)");
}

use IPC::System::Simple qw(capture);

my $rout = capture('perldoc -l perldoc');