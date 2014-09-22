
c:\Users\kshunkov\Documents\perl6>cd rakudo

c:\Users\kshunkov\Documents\perl6\rakudo>perl Configure.pl --gen-parrot
Системе не удается найти указанный путь.
Cloning into nqp...
remote: Counting objects: 12466, done.
remote: Compressing objects: 100% (3960/3960), done.
remote: Total 12466 (delta 8553), reused 12161 (delta 8251)
Receiving objects: 100% (12466/12466), 20.33 MiB | 2.04 MiB/s, done.
Resolving deltas: 100% (8553/8553), done.
Note: checking out '2011.10-53-g7e4bb20'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b new_branch_name

HEAD is now at 7e4bb20... forgot nqp::sinh_n
Системе не удается найти указанный путь.
Cloning into parrot...
remote: Counting objects: 385790, done.
remote: Compressing objects: 100% (86936/86936), done.
remote: Total 385790 (delta 288979), reused 385301 (delta 288537)
Receiving objects: 100% (385790/385790), 91.28 MiB | 1.24 MiB/s, done.
Resolving deltas: 100% (288979/288979), done.
Note: checking out 'RELEASE_3_9_0-51-g65e6ab7'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b new_branch_name

HEAD is now at 65e6ab7... don't store value of strstart in ByteBuffer, get it in
 each usage - issue 182

Configuring Parrot ...
C:\Strawberry\perl\bin\perl.exe Configure.pl --optimize --prefix=c:/Users/kshunk
ov/Documents/perl6/rakudo/install
Parrot Version 3.9.0 Configure 2.0
Copyright (C) 2001-2011, Parrot Foundation.

Hello, I'm Configure. My job is to poke and prod your system to figure out
how to build Parrot. The process is completely automated, unless you passed in
the `--ask' flag on the command line, in which case I'll prompt you for a few
pieces of info.

Since you're running this program, you obviously have Perl 5--I'll be pulling
some defaults from its configuration.

init::manifest -      Check MANIFEST.....................................done.
init::defaults -      Set Configure's default values.....................done.
init::install -       Set up installation paths..........................done.
init::hints -         Load platform and local hints files................done.
inter::progs -        Determine what C compiler and linker to use........done.
inter::make -         Is make installed...................................yes.
inter::lex -          Is lex installed................................skipped.
inter::yacc -         Is yacc installed...............................skipped.
auto::gcc -           Is your C compiler actually gcc................yes, 4.4.
auto::glibc -         Is GNU libc installed................................no.
auto::backtrace -     Does libc have the backtrace* functions..............no.
auto::msvc -          Is your C compiler actually Visual C++..........skipped.
auto::attributes -    Detect compiler attributes.........................done.
auto::warnings -      Detect supported compiler warnings.................done.
auto::arch -          Determine CPU architecture and OS..................done.
auto::cpu -           Generate CPU specific stuff........................done.
init::optimize -      Enable optimization.................................yes.
inter::shlibs -       Determine flags for building shared libraries......done.
inter::libparrot -    Should parrot link against a shared library.........yes.
inter::types -        What types should Parrot use.......................done.
auto::ops -           Which opcode files should be compiled in...........done.
auto::pmc -           Which pmc files should be compiled in..............done.
auto::headers -       Probe for C headers................................done.
auto::sizes -         Determine some sizes...............................done.
auto::byteorder -     Compute native byteorder for wordsize.....little-endian.
auto::va_ptr -        Test the type of va_ptr...
step auto::va_ptr died during execution: Unknown va_ptr type at config/auto/va_p
tr.pm line 41.

 at Configure.pl line 76

auto::format -        What formats should be used for sprintf............done.
auto::isreg -         Does your C library have a working S_ISREG..........yes.
auto::llvm -          Is minimum version of LLVM installed.................no.
auto::inline -        Does your compiler support inline...................yes.
auto::gc -            Determine allocator to use..........................gms.
auto::memalign -      Does your C library support memalign.................no.
auto::signal -        Determine some signal stuff........................done.
auto::socklen_t -     Determine whether there is socklen_t.................no.
auto::stat -          Detect stat type..................................posix.
auto::neg_0 -         Determine whether negative zero can be printed......yes.
auto::env -           Does your C library have setenv / unsetenv.....unsetenv.
auto::timespec -      Does your system has timespec.......................yes.
auto::infnan -        Is standard C Inf/NaN handling present..............yes.
auto::thread -        Does your system has thread.........................yes.
auto::gmp -           Does your platform support GMP......................yes.
auto::readline -      Does your platform support readline..................no.
auto::pcre -          Does your platform support pcre......................no.
auto::opengl -        Does your platform support OpenGL....................no.
auto::zlib -          Does your platform support zlib.....................yes.
auto::gettext -       Does your configuration include gettext............done.
auto::snprintf -      Test snprintf......................................done.
auto::perldoc -       Is perldoc installed................................yes.
auto::coverage -      Are coverage analysis tools installed...............yes.
auto::pod2man -       Is pod2man installed................................yes.
auto::ctags -         Is (exuberant) ctags installed.......................no.
auto::revision -      Determine Parrot's revision...........................1.
auto::icu -           Is ICU installed..........................no icu-config.
auto::libffi -        Is libffi installed..................................no.
auto::ipv6 -          Determine IPV6 capabilities.........................yes.
auto::platform -      Generate a list of platform object files...........done.
gen::config_h -       Generate C headers...Use of uninitialized value $va_result
 in concatenation (.) or string at (eval 113) line 53, <$in> line 8.
Use of uninitialized value in string eq at (eval 113) line 57, <$in> line 8.
Use of uninitialized value in string eq at (eval 113) line 63, <$in> line 8.
..............................done.
gen::core_pmcs -      Generate core pmc list.............................done.
gen::opengl -         Generating OpenGL bindings......................skipped.
gen::makefiles -      Generate makefiles and other build files...........done.
gen::config_pm -      Record configuration data for later retrieval......done.
During configuration the following steps failed:
    26:  auto::va_ptr
You should diagnose and fix these errors before calling 'gmake'
Command failed (status 256): C:\Strawberry\perl\bin\perl.exe Configure.pl --opti
mize --prefix=c:/Users/kshunkov/Documents/perl6/rakudo/install

c:\Users\kshunkov\Documents\perl6\rakudo>