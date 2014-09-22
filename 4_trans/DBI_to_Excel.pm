package DBI_to_Excel;

use DBI;
use Modern::Perl;
use English qw( -no_match_vars ) ;  # Avoids regex performance penalty
use Carp;
use YAML::Tiny;
use File::Slurp;

# use Smart::Comments;
# use Toolkit;
use Excel::Writer::XLSX;    # Step 0

our ( @ISA, $VERSION, @EXPORT_OK );

BEGIN {
    $VERSION = '0.0.1';
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT_OK =
      qw(read_DATA get_connect_string say_values_from_db_to_xls from_db_to_xls );
	  
}


sub from_db_to_xls {
    my $ref_param = shift;
	my %param=%{$ref_param};
    my ( $dbh, $sth, $where, $workbook_name, $type ) =
      @param{ 'conn', 'sth', 'start_cell', 'worksheet_name', 'type_of_load' };

    my $workbook =
      Excel::Writer::XLSX->new( $workbook_name . '.xlsx' );    # Step 1
    my $worksheet = $workbook->add_worksheet($workbook_name);  # Foglio2

    # my $sth = $dbh->prepare($data->{$workbook_name});
    # $sth->execute();

    my @name = @{ $sth->{NAME} };
    my @type = @{ $sth->{TYPE} };
    push my @out_array, \@name;

    my ( @data, $i );
    $sth->bind_columns( {}, \( @data[ 0 .. $#name ] ) );

    while ( $sth->fetch ) {
        $i = 0;
        my @curr = map { $dbh->quote( $_, $type[ $i++ ] ) } @data;
        push @out_array, \@curr;

    }
    my $out = \@out_array;

    given ($type) {
        when (/row/) { $worksheet->write_row( $where, \@out_array ); }
        when (/col/) { $worksheet->write_col( $where, \@out_array ); }
        default { ; }
    }
}

	  
sub say_values_from_db_to_xls {
    my $ref_param = shift;
	my %param=%{$ref_param};
    my ( $dbh, $data, $where, $workbook_name, $type ) =
      @param{ 'conn', 'data', 'start_cell', 'worksheet_name', 'type_of_load' };

    my $workbook =
      Excel::Writer::XLSX->new( $workbook_name . '.xlsx' );    # Step 1
    my $worksheet = $workbook->add_worksheet($workbook_name);  # Foglio2

    my $sth = $dbh->prepare($data->{$workbook_name});
    $sth->execute();

    my @name = @{ $sth->{NAME} };
    my @type = @{ $sth->{TYPE} };
    push my @out_array, \@name;

    my ( @data, $i );
    $sth->bind_columns( {}, \( @data[ 0 .. $#name ] ) );

    while ( $sth->fetch ) {
        $i = 0;
        my @curr = map { $dbh->quote( $_, $type[ $i++ ] ) } @data;
        push @out_array, \@curr;

    }
    my $out = \@out_array;

    given ($type) {
        when (/row/) { $worksheet->write_row( $where, \@out_array ); }
        when (/col/) { $worksheet->write_col( $where, \@out_array ); }
        default { ; }
    }
}

sub get_connect_string {
    my $user_init = shift;
    my $conf_path = shift;
    my $conf      = YAML::Tiny::LoadFile($conf_path)
      or croak "Couldn't open YAML::Tiny->errstr: $OS_ERROR";

    # my $config_name = 'fbs_load.yml';
    my $user     = $conf->{ $user_init . '_un' };
    my $password = $conf->{ $user_init . '_pw' };

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

    # my ($file) = @_;
    my $string = shift;    #read_file($file);
    print {*STDERR} "Reading sql query...\n";

  # my %contents_of = do { local $/; "", split /_____\[ (\S+) \]_+\n/, <DATA> };
    my %contents_of =
      do { local $/; "", split /_____\[ (\S+) \]_+\n/, $string };
    for ( values %contents_of ) {
        s/^!=([a-z])/=$1/gxms;
    }
    print {*STDERR} "done\n";
    return \%contents_of;
}
