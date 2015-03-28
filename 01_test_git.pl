use Modern::Perl;
use Git::Repository;
my $url='https://github.com/mishin/perldoc-ru.git';
my $dir='/home/mishin/github/test_repo';
#Git::Repository->run( clone => $url => $dir );
my $r = Git::Repository->new( work_tree => $dir );

$r->run( add => '.' );
$r->run( commit => '-m', 'my commit message' );


#git commit --amend --date="Sat Jan 10 14:00 2015 +0300"
my $date = 'Fri Jul 26 19:34:15 2013 +0200';
my $cmd = $r->command( commit => "--amend", "--date=$date" );
#http://www.dagolden.com/index.php/998/how-to-script-git-with-perl-and-gitwrapper/
#
#
#http://blogs.perl.org/users/preaction/2012/10/chicagopm-report---scripting-git-with-perl.html
#
#https://metacpan.org/pod/release/BOOK/Git-Repository-1.311/lib/Git/Repository/Tutorial.pod
#
#http://habrahabr.ru/post/201922/
#
#http://stackoverflow.com/questions/5188320/how-can-i-get-a-list-of-git-branches-ordered-by-most-recent-commit
#https://git.wiki.kernel.org/index.php/ExampleScripts


