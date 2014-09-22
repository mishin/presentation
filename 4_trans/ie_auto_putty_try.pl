#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';

use Const::Fast;
use Win32::GuiTest qw( SetForegroundWindow SendMessage FindWindowLike );
use Win32::OLE;
$Win32::OLE::Warn = 3;

const my %SC => (
    MAXIMIZE    => 0xF030,
    RESTORE     => 0xF120,
    MINIMIZE    => 0xF020,
    IDM_COPYALL    => 0x0170,  #https://gist.github.com/3610622 
);

const my $WM_SYSCOMMAND       => 0x0112;
const my $READYSTATE_COMPLETE => 4;

my @windows = FindWindowLike( 0, "PuTTY", "" );
say $windows[0];
my $hwnd = $windows[0];

SetForegroundWindow $hwnd;


for my $cmd (qw(MAXIMIZE RESTORE MINIMIZE RESTORE IDM_COPYALL)) {
    SendMessage( $hwnd, $WM_SYSCOMMAND, $SC{$cmd}, 0 );
    sleep 1;
}
