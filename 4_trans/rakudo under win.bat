
c:\Users\kshunkov\Documents>mkdir rakudo1

c:\Users\kshunkov\Documents>cd  rakudo1

c:\Users\kshunkov\Documents\rakudo1>git clone git://github.com/rakudo/rakudo.git

Cloning into rakudo...
remote: Counting objects: 51769, done.
remote: Compressing objects: 100% (12356/12356), done.
remote: Total 51769 (delta 39072), reused 51212 (delta 38625)
Receiving objects: 100% (51769/51769), 6.93 MiB | 1.40 MiB/s, done.
Resolving deltas: 100% (39072/39072), done.

c:\Users\kshunkov\Documents\rakudo1>perl Configure.pl --gen-nqp --with-parrot=c:\Parrot-3.9.0\bin\parrot.exe
Can't open perl script "Configure.pl": No such file or directory

c:\Users\kshunkov\Documents\rakudo1>cd rakudo

c:\Users\kshunkov\Documents\rakudo1\rakudo>perl Configure.pl --gen-nqp --with-parrot=c:\Parrot-3.9.0\bin\parrot.exe
"/Parrot-3.9.0/bin/nqp" не является внутренней или внешней
командой, исполняемой программой или пакетным файлом.
Cloning into nqp...
remote: Counting objects: 12466, done.
remote: Compressing objects: 100% (3960/3960), done.
remote: Total 12466 (delta 8553), reused 12161 (delta 8251)
Receiving objects: 100% (12466/12466), 20.33 MiB | 1.89 MiB/s, done.
Resolving deltas: 100% (8553/8553), done.
Note: checking out '2011.10-53-g7e4bb20'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b new_branch_name

HEAD is now at 7e4bb20... forgot nqp::sinh_n
Building NQP ...
C:\Strawberry\perl\bin\perl.exe Configure.pl --with-parrot=/Parrot-3.9.0/bin/par
rot.exe --make-install
Verifying installation ...
Using /Parrot-3.9.0/bin/parrot.exe (version 0).

Creating Makefile ...
Cleaning up ...

Microsoft (R) Program Maintenance Utility Version 10.00.30319.01
Copyright (C) Microsoft Corporation.  All rights reserved.


Microsoft (R) Program Maintenance Utility Version 10.00.30319.01
Copyright (C) Microsoft Corporation.  All rights reserved.

        C:\strawberry\perl\bin\perl.exe \Parrot-3.9.0\lib\parrot\tools\build\pmc
2c.pl --no-lines --dump --include src\pmc --include \Parrot-3.9.0\src\parrot --i
nclude \Parrot-3.9.0\src\parrot\pmc src\pmc\stable.pmc src\pmc\sixmodelobject.pm
c  src\pmc\dispatchersub.pmc  src\pmc\nqpmultisig.pmc src\pmc\nqplexinfo.pmc  sr
c\pmc\nqplexpad.pmc src\pmc\serializationcontext.pmc
        C:\strawberry\perl\bin\perl.exe \Parrot-3.9.0\lib\parrot\tools\build\pmc
2c.pl --no-lines --c --include src\pmc --include \Parrot-3.9.0\src\parrot --incl
ude \Parrot-3.9.0\src\parrot\pmc src\pmc\stable.pmc src\pmc\sixmodelobject.pmc
src\pmc\dispatchersub.pmc  src\pmc\nqpmultisig.pmc src\pmc\nqplexinfo.pmc  src\p
mc\nqplexpad.pmc src\pmc\serializationcontext.pmc
        C:\strawberry\perl\bin\perl.exe \Parrot-3.9.0\lib\parrot\tools\build\pmc
2c.pl --no-lines --library nqp_group --c src\pmc\stable.pmc src\pmc\sixmodelobje
ct.pmc  src\pmc\dispatchersub.pmc  src\pmc\nqpmultisig.pmc src\pmc\nqplexinfo.pm
c  src\pmc\nqplexpad.pmc src\pmc\serializationcontext.pmc
        gcc -c -o nqp_group.o -Isrc\pmc -I\Parrot-3.9.0\include\parrot -I\Parrot
-3.9.0\include\parrot\pmc -DWIN32 -DWINVER=Windows2000  -DHASATTRIBUTE_CONST  -D
HASATTRIBUTE_DEPRECATED  -DHASATTRIBUTE_MALLOC  -DHASATTRIBUTE_NONNULL  -DHASATT
RIBUTE_NORETURN  -DHASATTRIBUTE_PURE  -DHASATTRIBUTE_UNUSED  -DHASATTRIBUTE_WARN
_UNUSED_RESULT  -DHASATTRIBUTE_HOT  -DHASATTRIBUTE_COLD  -DDISABLE_GC_DEBUG=1 -D
NDEBUG -DHAS_GETTEXT -I C:\icu-4.4.2\icu\include    -falign-functions=16 -funit-
at-a-time -maccumulate-outgoing-args -W -Wall -Waggregate-return -Wcast-align -W
cast-qual -Wchar-subscripts -Wcomment -Wdisabled-optimization -Wdiv-by-zero -Wen
dif-labels -Wextra -Wformat -Wformat-extra-args -Wformat-nonliteral -Wformat-sec
urity -Wformat-y2k -Wimplicit -Wimport -Winit-self -Winline -Winvalid-pch -Wlogi
cal-op -Wmissing-braces -Wmissing-field-initializers -Wno-missing-format-attribu
te -Wmissing-include-dirs -Wmultichar -Wpacked -Wparentheses -Wpointer-arith -Wp
ointer-sign -Wreturn-type -Wsequence-point -Wsign-compare -Wstrict-aliasing -Wst
rict-aliasing=2 -Wswitch -Wswitch-default -Wtrigraphs -Wundef -Wno-unused -Wunkn
own-pragmas -Wvariadic-macros -Wwrite-strings -Wc++-compat -Wdeclaration-after-s
tatement -Werror=declaration-after-statement -Wimplicit-function-declaration -Wi
mplicit-int -Wmain -Wmissing-declarations -Wmissing-prototypes -Wnested-externs
-Wnonnull -Wold-style-definition -Wstrict-prototypes  nqp_group.c
cc1.exe: warning: C:\icu-4.4.2\icu\include: No such file or directory
In file included from nqp_group.c:17:
\Parrot-3.9.0\include\parrot/parrot/parrot.h:213:23: error: libintl.h: No such f
ile or directory
NMAKE : fatal error U1077: 'C:\Strawberry\c\bin\gcc.EXE' : return code '0x1'
Stop.
Command failed (status 512): gmake
Command failed (status 512): C:\Strawberry\perl\bin\perl.exe Configure.pl --with
-parrot=/Parrot-3.9.0/bin/parrot.exe --make-install

c:\Users\kshunkov\Documents\rakudo1\rakudo>