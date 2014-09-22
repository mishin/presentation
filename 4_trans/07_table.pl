
##############################################################################
#      $URL: mishin.narod.ru $
#     $Date: 2011-02-17 20:53:20 +0300 (Mon, 14 Feb 2011) $
#   $Author: mishin nikolay $
# $Revision: 1.02 $
#   $Source: table.pl $
#   $Description: read data from jira table $
##############################################################################

package Table;

#use 5.006;

use strict;
use warnings;

#use Smart::Comments;

use File::Slurp qw( :std );
use Data::Dumper;
use HTML::TableExtract;
use English;
use Carp;
use Getopt::Long;
use List::Util qw(max min);

#use File::Basename;
use 5.01;

our $VERSION = '0.01';
my $EMPTY = q{};

my $file = $EMPTY;
my $result = GetOptions( 'file|f=s' => \$file );

process_chunk_file( $EMPTY, $file );

#
# New subroutine "process_chunk_file" extracted - Mon Oct 10 21:15:50 2011.
#
sub process_chunk_file {
    my $EMPTY = shift;
    my $file  = shift;

    my $jira_number     = $file;
    my $RGX_JIRA_NUMBER = qr{\w+-(\d+)[.].*}smo;
    $jira_number =~ s/$RGX_JIRA_NUMBER/$1/sm;

    #read_file( $file2compare, chomp => 1 );
    my $t           = read_file($file);
    my @ar          = @{$t};
    my $html_string = join $EMPTY, @ar;
    my $ref_chunk   = parse_chunk_table($html_string);
### $ref_chunk

    return;
}

#
# New subroutine "parse_chunk_table" extracted - Mon Oct 10 21:20:12 2011.
#
sub parse_chunk_table {
    my $html_string = shift;

    my $te =
      HTML::TableExtract->new( attribs => { class => 'confluenceTable' } );
    $te->parse($html_string);

    # Examine all matching tables
    my %chunk = ();
    foreach my $ts ( $te->tables ) {
        my $check_tables = 0;

        #print Dumper ($ts->rows);
        foreach my $row ( $ts->rows ) {

            #        print Dumper ($$row[0]);
            if ( $$row[0] eq 'chunk_revision_sk' ) {
                $check_tables = 1;
            }
            if ( ( $$row[0] ne 'chunk_revision_sk' ) & ( $check_tables eq 1 ) )
            {
                $chunk{ $$row[0] }++;
            }
        }
    }

    return \%chunk;
}

1;
