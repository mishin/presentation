PS C:\Users\nmishin\Documents\svn\misc\fbs\weekly_load\perl> cpan File::Map
CPAN: CPAN::SQLite loaded ok (v0.199)
Database was generated on Wed, 19 Oct 2011 11:57:42 GMT
Running install for module 'File::Map'
Running make for L/LE/LEONT/File-Map-0.39.tar.gz
CPAN: Digest::SHA loaded ok (v5.62)
CPAN: Compress::Zlib loaded ok (v2.037)
Checksum for C:\Strawberry\cpan\sources\authors\id\L\LE\LEONT\File-Map-0.39.tar.gz ok
CPAN: Archive::Tar loaded ok (v1.78)
CPAN: File::Temp loaded ok (v0.22)
CPAN: Parse::CPAN::Meta loaded ok (v1.4401)
CPAN: CPAN::Meta loaded ok (v2.112150)
CPAN: Module::CoreList loaded ok (v2.49)
CPAN: Time::HiRes loaded ok (v1.9721)

  CPAN.pm: Building L/LE/LEONT/File-Map-0.39.tar.gz

Created MYMETA.yml and MYMETA.json
Creating new 'Build' script for 'File-Map' version '0.39'
Building File-Map
gcc -c -s -O2 -DWIN32 -DHAVE_DES_FCRYPT  -DUSE_SITECUSTOMIZE -DPERL_IMPLICIT_CONTEXT -DPERL_IMPLICIT_SYS -fno-strict-ali
asing -mms-bitfields -DPERL_MSVCRT_READFIX -s -O2 "-DXS_VERSION=\"0.39\"" "-DVERSION=\"0.39\"" -I"C:\Strawberry\perl\lib
\CORE" -I"C:\Strawberry\c\include" -o "lib\File\Map.o" "lib\File\Map.c"
ExtUtils::Mkbootstrap::Mkbootstrap('blib\arch\auto\File\Map\Map.bs')
Generating script 'lib\File\Map.lds'
dlltool --def "lib\File\Map.def" --output-exp "lib\File\Map.exp"
g++ -o "blib\arch\auto\File\Map\Map.dll" -Wl,--base-file,"lib\File\Map.base" -Wl,--image-base,0x290d0000 -mdll -s -L"C:\
Strawberry\perl\lib\CORE" -L"C:\Strawberry\c\lib" "lib\File\Map.lds" "lib\File\Map.exp"
dlltool --def "lib\File\Map.def" --output-exp "lib\File\Map.exp" --base-file "lib\File\Map.base"
g++ -o "blib\arch\auto\File\Map\Map.dll" -Wl,--image-base,0x290d0000 -mdll -s -L"C:\Strawberry\perl\lib\CORE" -L"C:\Stra
wberry\c\lib" "lib\File\Map.lds" "lib\File\Map.exp"
  LEONT/File-Map-0.39.tar.gz
  c:\strawberry\perl\bin\perl.exe ./Build -- OK
CPAN: YAML loaded ok (v0.77)
Running Build test
t/00-compile.t ............ ok
t/10-basics.t ............. ok
t/10-empty.t .............. ok
t/20-errors.t ............. 1/27
#   Failed test 'Can't map STDOUT'
#   at t/20-errors.t line 55.
# expecting: Regexp ((?-xism:^Could not map: Permission denied))
# found: Could not map: Incorrect function. at C:\Strawberry\cpan\build\File-Map-0.39-3bQPY2\blib\lib/File/Map.pm line 8
1, <$self> line 1.
# Looks like you failed 1 test of 27.
t/20-errors.t ............. Dubious, test returned 1 (wstat 256, 0x100)
Failed 1/27 subtests
t/20-protect.t ............ ok
t/20-remap.t .............. skipped: Only works on Linux
t/20-tainting.t ........... ok
t/20-threads.t ............ ok
t/20-unicode.t ............ ok
t/release-kwalitee.t ...... skipped: these tests are for release candidate testing
t/release-pod-coverage.t .. skipped: these tests are for release candidate testing
t/release-pod-syntax.t .... skipped: these tests are for release candidate testing

Test Summary Report
-------------------
t/20-errors.t           (Wstat: 256 Tests: 27 Failed: 1)
  Failed test:  15
  Non-zero exit status: 1
Files=12, Tests=92,  4 wallclock secs ( 0.08 usr +  0.20 sys =  0.28 CPU)
Result: FAIL
Failed 1/12 test programs. 1/92 subtests failed.
  LEONT/File-Map-0.39.tar.gz
  c:\strawberry\perl\bin\perl.exe ./Build test -- NOT OK
//hint// to see the cpan-testers results for installing this module, try:
  reports LEONT/File-Map-0.39.tar.gz
Running Build install
  make test had returned bad status, won't install without force
PS C:\Users\nmishin\Documents\svn\misc\fbs\weekly_load\perl>