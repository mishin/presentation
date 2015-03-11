 →  milla-tutorial$ sp_ch () {(cat $1|aspell --lang=ru-yo list|aspell --lang=en list); };sp_ch lib/POD2/RU/perlretut.pod
  { (cat $1|aspell --lang=ru-yo list|aspell --lang=en list); }


sp_ch () {(cat $1|aspell --lang=ru-yo list|aspell --lang=en list); };sp_ch lib/POD2/RU/perlretut.pod

 perl -M"File::Slurp qw(edit_file)" -e "edit_file { s/=item (\d+)/=item C<$1>/g } 'lib/POD2/RU/perlretut.pod' "


perl -pi.bak -e 's/=item (\d+)/=item C<$1>/g' lib/POD2/RU/perlretut.pod 

┌─[mishin@mishin-Satellite-T230]─(~/github/milla2/POD2-RU) [20:41]
└─ →  milla-tutorial$ milla release
[@Milla/NameFromDirectory] guessing your distribution name is POD2-RU
[DZ] beginning to build POD2-RU
[DZ] guessing dist's main_module is lib/POD2/RU.pm
[@Milla/LicenseFromModule] guessing from lib/POD2/RU.pm, License is Software::License::Perl_5
[@Milla/LicenseFromModule] Copyright 2015- Nikolay Mishin <mi@ya.ru>
[@Milla/VersionFromModule] dist version 0.01 (from lib/POD2/RU.pm)
Next release version?  [0.01]: 5.18.0.1.16
[@Milla/ReversionOnRelease] Bumping $VERSION in lib/POD2/RU.pm to 5.18.0.1.16
[@Milla/ExtraTests] rewriting release test xt/release/pod-syntax.t
[@Milla/Prereqs::FromCPANfile] Parsing 'cpanfile' to extract prereqs
[DZ] writing POD2-RU in POD2-RU-5.18.0.1.16
[@Milla/CopyFilesFromBuild] Copied POD2-RU-5.18.0.1.16/META.json to ./META.json
[@Milla/CopyFilesFromBuild] Copied POD2-RU-5.18.0.1.16/LICENSE to ./LICENSE
[@Milla/CopyFilesFromBuild] Copied POD2-RU-5.18.0.1.16/Build.PL to ./Build.PL
[@Milla/ReadmeAnyFromPod] overriding README.md in root
[DZ] building archive with Archive::Tar::Wrapper
[DZ] writing archive to POD2-RU-5.18.0.1.16.tar.gz
[@Milla/Git::Check] branch master is in a clean state
[@Milla/CheckChangesHasContent] Checking Changes
[@Milla/CheckChangesHasContent] Changes OK
[@Milla/TestRelease] Extracting /home/mishin/github/milla2/POD2-RU/POD2-RU-5.18.0.1.16.tar.gz to .build/g4GyES6iQa
Creating new 'Build' script for 'POD2-RU' version '5.18.0.1.16'
cp lib/POD2/RU/perlintro.pod blib/lib/POD2/RU/perlintro.pod
cp lib/POD2/RU/perl.pod blib/lib/POD2/RU/perl.pod
cp lib/POD2/RU/perlstyle.pod blib/lib/POD2/RU/perlstyle.pod
cp lib/POD2/RU/perlrebackslash.pod blib/lib/POD2/RU/perlrebackslash.pod
cp lib/POD2/RU/perlretut.pod blib/lib/POD2/RU/perlretut.pod
cp lib/POD2/RU.pm blib/lib/POD2/RU.pm
cp lib/POD2/RU/perlcheat.pod blib/lib/POD2/RU/perlcheat.pod
cp lib/POD2/RU/perlreapi.pod blib/lib/POD2/RU/perlreapi.pod
cp lib/POD2/RU/perlunicode.pod blib/lib/POD2/RU/perlunicode.pod
cp lib/POD2/RU/perlpragma.pod blib/lib/POD2/RU/perlpragma.pod
cp lib/POD2/RU/perlrecharclass.pod blib/lib/POD2/RU/perlrecharclass.pod
cp lib/POD2/RU/perlsecret.pod blib/lib/POD2/RU/perlsecret.pod
cp lib/POD2/RU/a2p.pod blib/lib/POD2/RU/a2p.pod
cp lib/POD2/RU/perlnewmod.pod blib/lib/POD2/RU/perlnewmod.pod
cp lib/POD2/RU/perlrun.pod blib/lib/POD2/RU/perlrun.pod
cp lib/POD2/RU/perlbook.pod blib/lib/POD2/RU/perlbook.pod
cp lib/POD2/RU/perlreguts.pod blib/lib/POD2/RU/perlreguts.pod
cp lib/POD2/RU/perlre.pod blib/lib/POD2/RU/perlre.pod
cp lib/POD2/RU/perlreref.pod blib/lib/POD2/RU/perlreref.pod
cp lib/POD2/RU/perlrequick.pod blib/lib/POD2/RU/perlrequick.pod
cp lib/POD2/RU/perldoc.pod blib/lib/POD2/RU/perldoc.pod
t/00base.t .............. ok   
t/basic.t ............... ok   
t/release-pod-syntax.t .. ok     
All tests successful.
Files=3, Tests=24,  2 wallclock secs ( 0.08 usr  0.01 sys +  1.80 cusr  0.03 csys =  1.92 CPU)
Result: PASS
[@Milla/TestRelease] all's well; removing .build/g4GyES6iQa
[@Milla/ConfirmRelease] *** Preparing to release POD2-RU-5.18.0.1.16.tar.gz with @Milla/UploadToCPAN ***
Do you want to continue the release process? [Y/n]: Y
[@Milla/UploadToCPAN] registering upload with PAUSE web server
[@Milla/UploadToCPAN] POSTing upload for POD2-RU-5.18.0.1.16.tar.gz to https://pause.perl.org/pause/authenquery
[@Milla/UploadToCPAN] PAUSE add message sent ok [200]
[@Milla/CopyFilesFromRelease] Copied POD2-RU-5.18.0.1.16/lib/POD2/RU.pm to lib/POD2/RU.pm
[@Milla/Git::Commit] Committed Changes lib/POD2/RU.pm META.json
[@Milla/Git::Tag] Tagged 5.18.0.1.16
[@Milla/Git::Push] pushing to origin
fatal: The current branch master has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin master

┌─[mishin@mishin-Satellite-T230]─(~/github/milla2/POD2-RU) [20:42]
└─ →  milla-tutorial$ 


# ABSTRACT: Translate Perl documentation to Russian language
