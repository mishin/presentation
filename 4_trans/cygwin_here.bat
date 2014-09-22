@echo off
REM --- cygwin_here.bat ------------------------------------------------------
REM function: Start Cygwin in current directory
REM args:     - 1..9

REM Setting `CHERE_INVOKING' prevents /etc/profile from issuing `cd $HOME'
set CHERE_INVOKING=1
C:\cygwin\bin\bash --login -i %1 %2 %3 %4 %5 %6 %7 %8 %9
