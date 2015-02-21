use strict; use warnings;

use Marpa::R2;
use MarpaX::Repa::Lexer;
use MarpaX::Repa::Actions;

use Regexp::Common qw /delimited/;

my $grammar = Marpa::R2::Grammar->new( {
    action_object => 'MarpaX::Repa::Actions',
    default_action => 'do_scalar_or_list',
    start         => 'config',
    rules         => [
        { lhs => 'config', rhs => [qw(BEGIN list END)] },
        { lhs => 'list', rhs => [qw/item/], separator => 'EOL', min => 1 },
        { lhs => 'item', rhs => [qw/WS? name WS quoted/] },
        { lhs => 'WS?', rhs => [] },
        { lhs => 'WS?', rhs => ['WS'], action => 'do_ignore' },
    ],
});
$grammar->precompute;

my $recognizer = Marpa::R2::Recognizer->new( { grammar => $grammar } );
my $lexer = MarpaX::Repa::Lexer->new(
    tokens => {
        name          => { match => qr{\b(?!END|BEGIN)\w+\b}, store => 'scalar' },
        'quoted'      => {
            match => qr[$RE{delimited}{-delim=>qq{\"}}],
            store => sub {
                ${$_[1]} =~ s/^"//;
                ${$_[1]} =~ s/"$//;
                ${$_[1]} =~ s/\\([\\"])/$1/g;
                return $_[1];
            },
        },
        BEGIN => { match => qr{BEGIN\s+(\w+)}, store => sub { ${$_[1]} =~ s/^BEGIN\s+//; return $_[1] } },
        END => { match => qr{END\s+(\w+)}, store => sub { ${$_[1]} =~ s/^END\s+//; return $_[1] } },
        EOL => { match => qr{\r*\n}, store => 'undef' },
        WS => { match => qr{\s+}, store => 'undef' },

    },
    debug => 1,
);

use Data::Dumper;
print Dumper( $lexer->recognize( $recognizer => \*DATA )->value );

__DATA__
BEGIN DSSUBRECORD
   Name "$APT_DBNAME"
   Prompt "DB2 Database"
   Default "BANKDATA"
   HelpTxt "Default DB2 database to use"
   ParamType "0"
   ParamLength "0"
   ParamScale "0"
END DSSUBRECORD

