perl -MIO::All -E"say$_->name.q{ }.$_->getlines for sort {$a->size<=>$b->size}grep{/lre/}io->dir((`perldoc -l perl`=~/(.+?)[\w.]+$/))->all"


# `perldoc -l perl`=~/(.+?)[\w.]+$/;$p=$1;
 ($hours, $minutes, $second) = ($time =~ /(\d\d):(\d\d):(\d\d)/);

perl -e "print(`perldoc -l perl`=~/(.+?)[\w.]+$/)"
perl -e "($p)=(`perldoc -l perl`=~/(.+?)[\w.]+$/);print $p"
;$p=$1;


perl -MIO::All -E"say$_->name.$_->getlines for sort {$a->size<=>$b->size}grep{/lre/}io->dir(`perldoc -l perl`=~/(.+?)[\w.]+$/r)->all" #error

perl -MIO::All -E"`perldoc -l perl`=~/(.+?)[\w.]+$/;$p=$1;say$_->name.$_->getlines for sort {$a->size<=>$b->size}grep{/lre/}io->dir($p)->all"

perl -MIO::All -E"`perldoc -l perl`=~/(.+?)\\[\w.]+$/;say$_->name.q{ }.$_->getlines for sort {$a->size<=>$b->size} grep{/perlre/}io->dir($1)->all"


perl -e "$a=`perldoc -l perl`=~/(.+?)\\[\w.]+$/r;" ##error!!
perl  -MIO::All -E"`perldoc -l perl`=~/(.+?)\\[\w.]+$/;say$_->name.q{ }.$_->getlines for sort {$a->size<=>$b->size} grep{/perlre/}io->dir($1)->all"
#error

perl  -MIO::All -E"`perldoc -l perl`=~/(.+?)\\[\w.]+$/;$p=$1;say$_->name.q{ }.$_->getlines for sort {$a->size<=>$b->size} grep{/perlre/}io->dir($p)->all"
perl  -MIO::All -E"`perldoc -l perl`=~/(.+?)\\[\w.]+$/;$pp=$1;say$_->name.q{ }.$_->getlines for sort {$a->size<=>$b->size} grep{/perlre/}io->dir($pp)->all"

perl -e "`perldoc -l perl`=~/(.+?)(?{ print 1 }) \\[\w.]+$/;$pp=$1"
perl -e "`perldoc -l perl`=~/(.+?)\\[\w.]+$/;$pp=$1"
cd C:\Dwimperl\perl\lib\pods
perl -MIO::All -E"say$_->name.q{ }.$_->getlines for sort {$a->size<=>$b->size} grep{/perlre/}io->dir('.')->all"

perl -e "`perldoc -l perl`=~/(.+?)\\[\w.]+$/;`cd $1`"
perl -e "`perldoc -l perl`=~/(.+?)\\[\w.]+$/;$ENV{podpath}=$1"
perl -e "`perldoc -l perl`=~/(.+?)\\[\w.]+$/;print $1"

http://www.thinkplexx.com/learn/howto/dos/bat/assign-command-output-to-variable-in-dos-bat-cmd-shell
cmd > tmpFile
set /p myvar= < tmpFile
del tmpFile

perl -e "`perldoc -l perl`=~/(.+?)\\[\w.]+$/;print $1"|cd
perl -E "$a=`perldoc -l perldoc`;$a=~/(.+?)\\[\w.]+$/;say $1"
perl -E "`perldoc -l perl`=~/(.+?)\\[\w.]+$/;say $1"
perl -E "`perldoc -l perl`=~/(.+?)\\[\w.]+$/;say $1"

perl -E "$a=`perldoc -l perldoc`;$a =~ s/[\w.]+$//;say $a"
perl -E "$a=`perldoc -l perldoc`;$a=~/([\w\\:]+)[\w.]+$/;say $1"
perl -E "$a=`perldoc -l perldoc`;$a=~/(.+?)\\[\w.]+$/;say $1"
perl -E "$a=`perldoc -l perldoc`;say $a =~ s/[\w.]+$//;say $a"

perl -MIO::All -E'say$_->name.q{ }.$_->getlines for sort {$a->size<=>$b->size} grep{/perlre/}io->dir(".")->all'

c:\Users\TOSH\Documents\GitHub\p2ru\tools>perl -M"IPC::System::Simple qw(capture)" -E "say capture(q{perldoc -l perldoc})"
c:\Dwimperl\perl\bin\perldoc.bat 

perl -M"IPC::System::Simple qw(capture)" -e
 my $rout = capture('perl golf.pl');
 
 use Modern::Perl;
use File::Spec::Functions qw(catdir splitdir);
use DDP;
my $cmd = q{perldoc -l perldoc};
use IPC::Open3;
my @pod_path        = splitdir( run_shell($cmd) );
my @pod_path_splice = @pod_path[ 0 .. $#pod_path - 1 ];
my $pod_path        = catdir(@pod_path_splice);
say $pod_path;



c:\Users\TOSH\Documents\GitHub\p2ru\tools\pod_path.pl 