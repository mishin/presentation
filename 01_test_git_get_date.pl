use Modern::Perl;
use File::Slurp qw( :edit );

my $date=shift or die qq{Usage: $0 "date in dddd.mm.yy format"\n};
# use Date::Parse;

# my $date = "Tue, 11 Feb 2014 11:01:57 +0100 (CET)";
# my $time = str2time($date);
 
# my ($ss,$mm,$hh,$day,$month,$year,$zone) = strptime($date);
my ($year, $month, $day) = ($date =~ /(\d{4})[.](\d{2})[.](\d{2})/);
use DateTime;
use DateTime::Format::Strptime;

my $dt = DateTime->new(
    year       => $year,
    month      => $month,
    day        => $day,
    hour       => 16,
    minute     => 12,
    second     => 47,
    nanosecond => 0,
    time_zone  => 'Europe/Moscow',
);

#'Fri Jul 26 19:34:15 2013 +0200';
my $formatter =
  DateTime::Format::Strptime->new( pattern => '%a %b %d %H:%M %Y %z' );

$dt->set_formatter($formatter);
my $date_git = $dt->_stringify();
my $n = 1;
say qq{commit -m "my $n commit message" --date="$date_git"};



# for ( 1 .. 50 ) {

    # #inplace edit
    # edit_file { s/__NUMBER\d+__/__NUMBER${n}__/ }
    # $dir . '/pod2-ru/POD2-RU/scripts/get_pod_one_liners.md';
    # say "iteration №${n}";
    # say 'edit ok';
    # $r->run( add => '.' );
    # say 'add ok';
    # my $date = $dt->_stringify();
    # $r->run( commit => '-m', "my $n commit message", "--date=$date" );
    # say 'commit ok';
    # $dt->add( days => 1 );
    # $n++;
# }

#git remote set-url origin git@github.com:mishin/perldoc-ru.git
#git commit --amend --date="Sat Jan 10 14:00 2015 +0300"
#my $cmd = $r->command( commit => "--amend", "--date=$date");#, { fatal => 1 }
#say 'amend ok';
#my @errput = $cmd->stderr->getlines();
#say "ERROR: @errput";
#$cmd->close;

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

