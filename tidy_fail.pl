my $src_fields = 'push_to_usa';
    print $src_fields. "\n";
for my $country (qw(ru by en)) {
    my $trg_field = $src_fields =~ s/usa/$country/r;
    print $trg_field. "\n";
}
