use 5.14.0;
use PPI;

use Smart::Comments;
my $file_name = shift or die "Usage: $0 file_4_transform\n";
my $doc = PPI::Document->new($file_name);

my @comments = ();
my @statament = ();
$doc->find(
    sub {
        my ( $root, $node ) = @_;
        if ( $node->isa('PPI::Token::Comment')) {
            push @comments, $node;
        }
        if ( $node->isa('PPI::Statement')) {
            push @statament, $node;
        }
    }
);
#$module->prune( 'PPI::Token::Comment' );
## @comments
## @statament
say join "",@comments;
say join "",@statament;
