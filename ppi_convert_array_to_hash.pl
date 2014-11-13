use 5.14.0;
use PPI;
use Smart::Comments;
use DDP;
my $doc = PPI::Document->new('arr_snip_4.pl');

my $hash_name = '';
my @variables = ();
$doc->find(
    sub {
        my ( $root, $node ) = @_;
        if ( $node->isa('PPI::Token::Symbol') && $node->symbol_type eq '$' ) {
            push @variables, substr( $node, 1 );
        }
        if ( $node->isa('PPI::Token::Symbol') && $node->symbol_type eq '@' ) {
            $hash_name = substr( $node, 1 );
        }
    }
);

# my @names_of_var = ();
# for my $var (@variables) {
# push @names_of_var, "'$var'";
# }
# my $left_side = join ',', @names_of_var;

my $left_side = join ',', map { "'$_'" } @variables;

# my @self_of_var = ();
# for my $var (@variables) {
# push @self_of_var, "\$$var";
# }
# my $right_side = join ',', @self_of_var;

my $right_side = join ',', map { "\$$_" } @variables;

my $full_text = <<"end_line";
my %${hash_name}=();
\@${hash_name}{
        ${left_side}
      }
      = (
        ${right_side}
      );
end_line

print $full_text; 
