set file_src=%1
call ptar -x -f %file_src%
perl -e "if ($ARGV[0]=~ /(.*)([.]tar[.]gz|[.]tgz)$/){print $1}" %file_src% > tmpFile
set /p dir_name= < tmpFile
del tmpFile
echo %dir_name%
cd %dir_name%
IF EXIST Makefile.PL (
perl Makefile.PL
dmake
dmake test
dmake install
) ELSE (
perl Build.PL
Build
Build test
Build install
)
cd ..
