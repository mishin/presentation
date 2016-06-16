sub split_fields_by_new_line {
my ($curr_record) = @_;
my %fields_and_values = ();
while (
$curr_record =~ m/
(?<name>\w+)[ ]"(?<value>.*?)(?<!\\)"|
((?<name2>\w+)[ ]\Q=+=+=+=\E
(?<value2>.*?)
\Q=+=+=+=\E)
/xsg
)
{
my ($value, $name) = ('', '');
if (defined $+{name}) {
$name = $+{name};
$value = $+{value};
}
elsif (defined $+{name2}) {
$name = $+{name2};
$value = $+{value2};
}
$fields_and_values{$name} = $value;
}
return \%fields_and_values;
}
