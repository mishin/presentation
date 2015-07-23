use Data::Dumper;
use Sort::Maker;
my @array_of_hash = (
    {name => 'Moscow'},
    {name => 'Amsterdam'},
    {name => 'Bonn'},
    {name => 'New York'},
    {name => 'Vladivostok'}
);

# Make a Schwartzian Transform sorter
my $sorter1 = make_sorter(
    'ST',
    name   => 'townSorter',
    string => {code => '$_->{name}',}
);

# sort
my @sorted_array_of_hash = townSorter(@array_of_hash);
print Dumper \@sorted_array_of_hash;


my @sorted_array_of_hash2 =  sort { $a->{name} cmp $b->{name} } @array_of_hash;

print Dumper \@sorted_array_of_hash2;
