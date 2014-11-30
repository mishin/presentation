use IO::File;
use File::Slurp;

#use re 'debug';
#use Smart::Comments;
use English qw(-no_match_vars);
use Data::Dumper 'Dumper';
use Benchmark qw/cmpthese timethese/;
my $cnt      = 30;
my $testfile = 'test.xml';
make_test_xml( $cnt, $testfile );
my $testfile2 = 'test2.xml';
make_test_xml( $cnt, $testfile2 );

my $index1=sub{return _generate_index( $_[0], $_[1] );};
my $index2=sub{return _generate_index2($_[0], $_[1] );};
# my $doubler = sub { return 2 * $_[0]; };
# #Then later in my program I would call that routine as:
# my $doubled = &$doubler(5);  # $doubled is now 10
# say $doubled;

my $r = timethese(
    -3,
    {
        test  => sub { my $ko = invoke( $testfile,  $index1, 0 ) },
        test2 => sub { my $ko = invoke( $testfile2, $index2, 0 ) }
    }
);
cmpthese $r;

sub invoke {
    my $filename = shift;
    my $index_proc =shift;
    my $verbose  = shift;
    my $idx_file = $filename . q{.idx};
    _clear_file($idx_file);
    my $cnt_of_idx;
    my $fh = IO::File->new( $filename, 'r' )
      or die "Couldn't open $filename for read and write: $ERRNO\n";
    $cnt_of_idx = &$index_proc( $fh, $idx_file );
    $fh->close();

    print
"index with $index_func for file $filename with $cnt_of_idx row created ok\n"
      if $verbose;
    return 1;
}

sub _clear_file {
    my $file = shift;
    if ( -f $file ) {
        unlink($file);
    }
    return 1;
}

sub _generate_index {
    my ( $fh, $idx_file ) = @_;
    my ( $tag_value, @index_table, $index_row, $end );
    my $start_tag  = '<?xml version="1.0" encoding="UTF-8"?>';
    my $tag        = 'Account';
    my $tag_string = "\<$tag\>([A-Za-z0-9]+)\<\/$tag\>";
    my $RGX_TAG    = qr/$tag_string/ims;
    my $RGX_START  = qr/\Q$start_tag\E/ims;
    my $count_xml  = 1;
    my $start      = 1;
    while ( my $line = <$fh> ) {

        if ( $line =~ /$RGX_TAG/ ) {
            $tag_value = $1;
        }
        if ( $line =~ /$RGX_START/ ) {

            $end = $INPUT_LINE_NUMBER - 1;
            $index_row = join ',', $start, $end, $tag_value;
            if ( $count_xml > 1 ) {
                push @index_table, $index_row . "\n";
            }
            $start = $INPUT_LINE_NUMBER;
            $count_xml++;
        }
    }
    $index_row = join ',', $start, $INPUT_LINE_NUMBER, $tag_value;
    push @index_table, $index_row;
    write_file( $idx_file, \@index_table );
    return scalar @index_table;
}

sub _generate_index2 {
    my ( $fh, $idx_file ) = @_;
    my ( $tag_value, @index_table, $index_row, $end );
    my $start_tag  = '<?xml version="1.0" encoding="UTF-8"?>';
    my $tag        = 'Account';
    my $RGX_START  = qr/\Q$start_tag\E/ims;
    my $tag_string = "<$tag>(\w+)</$tag>";
    my $RGX_TAG    = qr/$tag_string/ims;
    my $count_xml  = 1;
    my $start      = 1;
    while ( my $line = <$fh> ) {

        if ( $line =~ /\<Account\>(\w+)\<\/Account\>/ ) {
            $tag_value = $1;
        }
        if ( $line =~ /\Q$start_tag\E/ims ) {

            $end = $INPUT_LINE_NUMBER - 1;
            $index_row = join ',', $start, $end, $tag_value;
            if ( $count_xml > 1 ) {
                push @index_table, $index_row . "\n";
            }
            $start = $INPUT_LINE_NUMBER;
            $count_xml++;
        }
    }
    $index_row = join ',', $start, $INPUT_LINE_NUMBER, $tag_value;
    push @index_table, $index_row;
    write_file( $idx_file, \@index_table );
    return scalar @index_table;
}

sub make_test_xml {
    my $max  = shift;
    my $file = shift;
    my @data = ();
    my $chunk;
    for my $Account_id ( 1 .. $max ) {
        $chunk = <<"END_XML";
<?xml version="1.0" encoding="UTF-8"?>
<RECORD>
  <Account>${Account_id}2550004455</Account>
  <message-size xmlns="">01</message-size>
  <message-size1 xmlns="">04</message-size>
  <message-size2 xmlns="">05</message-size>
  <message-size3 xmlns="">05</message-size>
</RECORD>

END_XML

        push @data, $chunk;
    }

    write_file( $file, \@data );
    return 1;
}
