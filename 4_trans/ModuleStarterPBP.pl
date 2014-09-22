PS C:\Users\nmishin\Documents\svn\misc\fbs\weekly_load\perl\FBS-Load> .\Build.bat
Building FBS-Load
PS C:\Users\nmishin\Documents\svn\misc\fbs\weekly_load\perl\FBS-Load> .\Build.bat  test
t\00.load.t .......
t\00.load.t ....... 1/1 #   Failed test 'use FBS::Load;'
#   at t\00.load.t line 4.
#     Tried to use 'FBS::Load'.
#     Error:  Global symbol "%EXPORT" requires explicit package name at C:\Users\nmishin\Documents\svn\misc\fbs\weekly_l
oad\perl\FBS-Load\blib\lib/FBS/Load.pm line 13.
# Global symbol "%EXPORT_TAGS" requires explicit package name at C:\Users\nmishin\Documents\svn\misc\fbs\weekly_load\per
l\FBS-Load\blib\lib/FBS/Load.pm line 13.
# Global symbol "%EXPORT_TAGS" requires explicit package name at C:\Users\nmishin\Documents\svn\misc\fbs\weekly_load\per
l\FBS-Load\blib\lib/FBS/Load.pm line 13.
# BEGIN not safe after errors--compilation aborted at C:\Users\nmishin\Documents\svn\misc\fbs\weekly_load\perl\FBS-Load\
blib\lib/FBS/Load.pm line 13.
# Compilation failed in require at (eval 4) line 2.
# BEGIN failed--compilation aborted at (eval 4) line 2.
Use of uninitialized value $FBS::Load::VERSION in concatenation (.) or string at t\00.load.t line 7.
# Testing FBS::Load
# Looks like you failed 1 test of 1.
t\00.load.t ....... Dubious, test returned 1 (wstat 256, 0x100)
Failed 1/1 subtests
t\perlcritic.t .... ok
t\pod-coverage.t .. ok
t\pod.t ........... ok

Test Summary Report
-------------------
t\00.load.t     (Wstat: 256 Tests: 1 Failed: 1)
  Failed test:  1
  Non-zero exit status: 1
Files=4, Tests=4,  3 wallclock secs ( 0.01 usr +  0.11 sys =  0.13 CPU)
Result: FAIL
Failed 1/4 test programs. 1/4 subtests failed.
PS C:\Users\nmishin\Documents\svn\misc\fbs\weekly_load\perl\FBS-Load> .\Build.bat  test