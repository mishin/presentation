#! perl
use v5.10;
use lib 'c:\Temp\Perl\scripts\develop\Datahub-Tools\lib';
use FindBin '$RealBin';
use Datahub::Tools qw/read_file/;
use utf8;
use strict;
use warnings;
use Encode::Locale;
use Text::ASCIITable;

if (-t) {
    binmode( STDIN,  ":encoding(console_in)" );
    binmode( STDOUT, ":encoding(console_out)" );
    binmode( STDERR, ":encoding(console_out)" );
}

my ($file_name) = 'orchestrate_code_body.xml';
my $data = read_file($file_name);

#### STAGE: DWH_REESTRS_DS

=pod
#################################################################
#### STAGE: T199
## Operator
transform
## Operator options
-flag run
-name 'V0S276_audi_05_ChangeCaptureApplyUPP_T199'

## General options
[ident('T199'); jobmon_ident('T199')]
## Inputs
0< [] 'LJ108:L109.v'
## Outputs
0> [] 'T199:INS.v'
1> [] 'T199:UPD.v'
;
=cut

my $operator_rx      = qr{\Q#### STAGE: \E(?<stage_name>\w+)};
my $operator_name_rx = qr{\Q## Operator\E\n(?<operator_name>\w+)\n\#};
my $header_rx = qr{
                  $operator_rx \n
				  $operator_name_rx
                }sx;

my $ORCHESTRATE_BODY_RX = qr{
       (
	   ?<stage_body>
		$header_rx
		.*?
		^;
		)
		}sxm;

# my $inputs_name = defined( $+{inputs_name} ) ? $+{inputs_name} : "";
# my $ORCHESTRATE_CODE_RX2 = qr{
# $header_rx
# }sx;

my $t = Text::ASCIITable->new(
    { headingText => 'Parsing ORCHESTRATE of ' . $file_name } );
$t->setCols( 'Id', 'stage_name', 'operator_name', 'inputs', 'outputs' );

start_parse();

sub start_parse {
    local $/ = '';
    my $i = 1;
    while ( $data =~ m/$ORCHESTRATE_BODY_RX/xsg ) {
        my $ins = process_stage_body( $+{stage_body} );

        my ( $in, $out ) = '';
        if ( ref( $ins->{inputs} ) eq "ARRAY" ) {
            $in = join "\n", @{ $ins->{inputs} };
        }

        if ( ref( $ins->{outputs} ) eq "ARRAY" ) {
            $out = join "\n", @{ $ins->{outputs} };
        }
        $t->addRow( $i, $+{stage_name}, $+{operator_name}, $in, $out );
        $t->addRowLine();

        $i++;
    }
    print $t;
}

sub process_stage_body {
    my ($stage_body) = @_;
    my %outs;
    my $inputs_rx  = qr{## Inputs\n(?<inputs_name>.*?)(?:#|^;$)}sm;
    my $outputs_rx = qr{## Outputs\n(?<outputs_name>.*?)^;$}sm;

    my ( $inputs, $outputs ) = ( '', '' );
    if ( $stage_body =~ $inputs_rx ) {
        $outs{inputs} = get_inout_links( $+{inputs_name} );
    }
    if ( $stage_body =~ $outputs_rx ) {
        $outs{outputs} = get_inout_links( $+{outputs_name} );
    }
    return \%outs;
}

sub get_inout_links {
    my ($body) = @_;
    my @links = ();

    # '[&"psProjectsPath.ProjectFilePath"]DWH_REESTRS_AUDIT_R
    while (
        $body =~ m/'
					 \w+:
					 (?<link_name>\w+)
					 .v
					 |
					 \[.*?\]
					 (?<link_name>\w+.ds)
					 '/xsg
      )
    {
        push @links, $+{link_name};
    }
    return \@links;

}

__DATA__
  
