use Modern::Perl;
use File::Slurp qw( :edit );

my $date=shift or die qq{Usage: $0 "date in dddd.mm.yy format"\n};
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
say qq{git commit -m "my $n commit message" --date="$date_git"};