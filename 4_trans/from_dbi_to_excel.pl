use DBI_to_Excel
  qw(read_DATA get_connect_string say_values_from_db_to_xls from_db_to_xls);

my $data = &read_DATA( join '', <DATA> );
my $dbh = &get_connect_string( 'rwa_owner',
'c:\Users\nmishin\Documents\svn\misc\fbs\weekly_load\perl\FBS-Load\scripts\fbs_load.yml'
);
my $ary_ref = $dbh->selectcol_arrayref( $data->{Get_summit_inst} );

my %param;
@param{ 'conn', 'start_cell', 'type_of_load', 'sth' } =
  ( $dbh, 'A1', 'col', $sth );

for my $location ( @{$ary_ref} ) {
    my $sth = $dbh->prepare( $data->{Data_by_location} );
    $sth->execute($location);

    # for $location ('location') {
        @param{ 'worksheet_name', 'sth' } = ( $location, $sth );
        from_db_to_xls( \%param );
    # }
}

#answer later
#http://stackoverflow.com/questions/11127909/save-sqlite-query-result-in-excel-with-perl

__END__
__DATA__
_____[ Get_summit_inst ]________________________________________________
select distinct location from z_mi_3990_nf
_____[ Data_by_location ]________________________________________________
select * from z_mi_3990_nf where location=?
