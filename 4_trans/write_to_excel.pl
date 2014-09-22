use DBI;
use Smart::Comments;
use Toolkit;
use Excel::Writer::XLSX;    # Step 0

my $data = &read_DATA();
### $data

my $dbh = &get_connect_string();

# $dbh
# my $statement = $data->{Get_summit_inst};
my $ary_ref = $dbh->selectcol_arrayref( $data->{Get_summit_inst} );
### $ary_ref

# Data_by_location
for my $location (@$ary_ref) {
    say $location;
    my $workbook =
      Excel::Writer::XLSX->new( $location . '_location.xlsx' );    # Step 1
    my $worksheet = $workbook->add_worksheet($location);           # Foglio2
    $worksheet->write( 'A1', 'trade' );
    $worksheet->write( 'B1', 'version' );
    $worksheet->write( 'C1', 'type' );

    # Step 3

# my $ref_location =      # $dbh->selectrow_array( $data->{Data_by_location}, {}, $location );
    my $sth = $dbh->prepare( $data->{Data_by_location} );
    $sth->execute($location);
    my $num = 1;
    while ( my @row = $sth->fetchrow_array ) {
        # print "@row[0..2]\n";
        $num++;
        $worksheet->write( 'A' . $num, $row[0] );
        $worksheet->write( 'B' . $num, $row[1] );
        $worksheet->write( 'C' . $num, $row[2] );

    }

    # my  @calc_value = $sth->fetchrow_array();

    # my $a=\@calc_value;
    # $a
    # my $ary_ref = $dbh->selectcol_arrayref( $statement, {} );

}

sub get_connect_string {

    my $conf = YAML::Tiny::LoadFile(
'c:\Users\nmishin\Documents\svn\misc\fbs\weekly_load\perl\FBS-Load\scripts\fbs_load.yml'
    ) or croak "Couldn't open YAML::Tiny->errstr: $OS_ERROR";

    # my $config_name = 'fbs_load.yml';
    my $user     = $conf->{rwa_owner_un};
    my $password = $conf->{rwa_owner_pw};

    my $prod_database_tns = $conf->{prod_database_tns};
    my $driver            = $conf->{driver};

 #return " sqlsh -d DBI:$driver:$prod_database_tns -u $user -p $password -i < ";
    my $connections;
    my $MAX_TRIES = 1;
  TRY:
    for my $try ( 1 .. $MAX_TRIES )
    {    ### Connecting to server $prod_database_tns under user $user... done
        $connections =
          DBI->connect( 'dbi:' . $driver . ':' . $prod_database_tns,
            $user, $password );
        last TRY if $connections;
    }
    croak "Can't contact server ($prod_database_tns)"
      if not $connections;
    return $connections;
}

sub read_DATA {
    print {*STDERR} "Reading sql query...\n";
    my %contents_of = do { local $/; "", split /_____\[ (\S+) \]_+\n/, <DATA> };
    for ( values %contents_of ) {
        s/^!=([a-z])/=$1/gxms;
    }
    print {*STDERR} "done\n";
    return \%contents_of;
}

__DATA__
_____[ Get_summit_inst ]________________________________________________
select distinct location from z_mi_3990
_____[ Data_by_location ]________________________________________________
select * from z_mi_3990 where location=?