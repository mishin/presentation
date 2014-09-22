use strict;
use warnings;
use utf8;

use Win32::GuiTest qw/:ALL/;
use Time::HiRes qw/sleep/;

UnicodeSemantics(1);

my $setupexe = "d:/tmp/cygwin/setup.exe";
my $nextbutton_title = "次へ";
my $finishbutton_title = "完了";
my $sleepsec = 0.2;

system(qq{cmd.exe /c "start $setupexe"});

my $w = WaitWindow('^Cygwin Setup$', 30) or die "window not found!";

my $nextbutton = WaitWindowLike($w, $nextbutton_title);
my $nextbutton_id = GetWindowID($nextbutton);

my $finishbutton = WaitWindowLike($w, $finishbutton_title);
my $finishbutton_id = GetWindowID($finishbutton);

while (1) {
  if ( IsWindowEnabled($nextbutton) ) {
    PushChildButton($w, $nextbutton_id);
    next;
  }

  if ( IsWindowVisible($finishbutton) ) {
    PushChildButton($w, $finishbutton_id);
    last;
  }
}
continue { sleep $sleepsec; }