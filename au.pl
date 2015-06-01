use 5.010;
use Acme::CPANAuthors;

# use Data::Printer;
my $authors = Acme::CPANAuthors->new('Russian');
my @ids = $authors->id;
my %distros;

for (@ids) {
	$distros{$_} = $authors->distributions($_);
}

foreach $value ( sort { $distros{$b} <=> $distros{$a} } keys %distros )
{
	say "$value $distros{$value}";
}
