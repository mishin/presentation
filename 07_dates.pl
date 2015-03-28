
#Here's an example, using DateTime and its strptime format module.
use Modern::Perl;
use DateTime;
use DateTime::Format::Strptime;

my $dt = DateTime->new(
    year       => 2015,
    month      => 02,
    day        => 07,
    hour       => 16,
    minute     => 12,
    second     => 47,
    nanosecond => 500000000,
    time_zone  => 'Europe/Moscow',
);

#+50
my $formatter =
  DateTime::Format::Strptime->new( pattern => '%a %b %d %H:%M %Y %z' );

$dt->set_formatter($formatter);
for ( 1 .. 50 ) {
    say $dt->_stringify();
    $dt->add( days => 1 );
}

=cut
my $val = "20090103 12:00";

my $format = new DateTime::Format::Strptime(
    pattern   => '%Y%m%d %H:%M',
    time_zone => 'Europe/Moscow',
);

my $date = $format->parse_datetime($val);

#Sat Jan 10 14:00 2015 +0300
print $date->strftime("%a %b %d %H:%M %Y %z") . "\n";

#$date->set_time_zone("Europe/Moscow");

#print $date->strftime("%Y%m%d %H:%M %z") . "\n";


#$perl dates . pl 20090103 12 : 00 UTC 20090103 07 : 00 EST

#  If you had wanted to parse localtime, here's how you'd do it : )

  use DateTime;

my @time = (localtime);

my $date = DateTime->new(
      year      => $time[5] + 1900,
      month     => $time[4] + 1,
      day       => $time[3],
      hour      => $time[2],
      minute    => $time[1],
      second    => $time[0],
      time_zone => "America/New_York"
  );

print $date->strftime("%F %r %Z") . "\n";

$date->set_time_zone("Europe/Prague");

print $date->strftime("%F %r %Z") . "\n";

shareeditflag

  edited Jan 5 '09 at 9:44

											
										answered Jan 4 ' 09 at 22 : 20 Vinko Vrsalovic 131 k29244306
=pod
