use Modern::Perl;

use File::Slurp qw(read_file write_file);
use Data::Dumper qw(Dumper);
my $filename = 'short_example.dsx';

my $data           = read_file($filename);
my $header_and_job = split_by_header_and_job($data);
my $header_fields  = split_fields_by_new_line( $header_and_job->{header} );
say Dumper $header_fields;

sub split_by_header_and_job {
    my $data = shift;
    local $/ = '';    # Paragraph mode
    my %header_and_job = ();
    my @fields         = ();

    #@fields = (
    $data =~ /
(?<header>
BEGIN[ ]HEADER
.*?
END[ ]HEADER
)
.*?
(?<job>
BEGIN[ ]DSJOB
.*?
END[ ]DSJOB )
/xsg
      ;
    %header_and_job = %+;
    return \%header_and_job;
}

sub split_fields_by_new_line {
    my ($curr_record)     = @_;
    my %fields_and_values = ();
    my @fields            = ();
    while (
        $curr_record =~ m/
        (?<name>\w+)[ ]"(?<value>.*?)(?<!\\)"|
        ((?<name>\w+)[ ]\Q=+=+=+=\E
        (?<value>.*?)
        \Q=+=+=+=\E)
        /xsg
      )
    {
        my $name       = $+{name};
        my $value      = $+{value};
        my %hash_value = ();
        push @fields, \%hash_value;
    }
    return \@fields;
}

