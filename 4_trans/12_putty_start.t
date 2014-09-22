#!/usr/bin/perl
# from http://www.slideshare.net/takesako/acme-minechan
use 5.010;
use strict;
use warnings;
use utf8;
use Win32::GuiTest qw(:ALL);
system(
    q{"C:\Program Files (x86)\PuTTY\putty.exe" -load "my_server"}
);
sleep(1);