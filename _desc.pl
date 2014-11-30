our %desc = (
"PPIx::Regexp::Node" => 
[
"xRe::Node",
"a container",
#~ "PPIx::Regexp::Dumper->new( 'qr{(foo)}' )->print",
],

"PPIx::Regexp::Node::Range" => 
[
"xRe::Node::Range",
"a character range in a character    class",
],

"PPIx::Regexp::Structure" => 
[
"xRe::Structure",
"a structure.",
],

"PPIx::Regexp::Structure::Assertion" => 
[
"xRe::Structure::Assertion",
"a parenthesized assertion ",
"(the grouptype below explains which one)", ##nah## TODO?!?! explain it here
],

"PPIx::Regexp::Structure::BranchReset" => 
[
"xRe::Structure::BranchReset",
"a branch reset group",
],

"PPIx::Regexp::Structure::Capture" => 
[
"xRe::Structure::Capture",
"Represent capture parentheses.",
],

"PPIx::Regexp::Structure::CharClass" => 
[
"xRe::Structure::CharClass",
"a character class",
],

"PPIx::Regexp::Structure::Code" => 
[
"xRe::Structure::Code",
"Represent one of the code structures.",
'WARNING: This extended regular expression feature is considered experimental, and may be changed without notice',
],

    '(?p{ code })' => [
'',
#~ http://perl5.git.perl.org/perl.git/commit/14455d6cc193f1e4316f87b9dbe258db24ceb714
#~ /(?p{})/ changed to /(??{})/, per Larry's suggestion
#~ (?p{}) has been deprecated for a long time.

'warning (?p{}) has been removed Use (??{}) instead. L<http://search.cpan.org/dist/perl/pod/perl5100delta.pod#%28?p{}%29_has_been_removed>',
q{L<http://search.cpan.org/dist/perl/pod/perlre.pod#%28??{_code_}%29|perlre/(??{ code })>},
q{This is a "postponed" regular subexpression. This zero-width assertion executes any embedded Perl code. It always succeeds,  and that its return value, rather than being assigned to $^R, is treated as a pattern, compiled if it's a string (or used as-is if its a qr// object), then matched as if it were inserted instead of this construct.},
],
    '(??{ code })' => [
q{This is a "postponed" regular subexpression. This zero-width assertion executes any embedded Perl code. It always succeeds,  and that its return value, rather than being assigned to $^R, is treated as a pattern, compiled if it's a string (or used as-is if its a qr// object), then matched as if it were inserted instead of this construct.},
q{L<http://search.cpan.org/dist/perl/pod/perlre.pod#%28??{_code_}%29>},
q{L<perlre/(??{ code })>},
],
    '(?{ code })'  => [
'This zero-width assertion executes any embedded Perl code. It always succeeds, and its return value is set as $^R',
'L<http://search.cpan.org/dist/perl/pod/perlre.pod#(?{_code_})>',
'L<perlre/(?{ code })>',
'L<perlvar/$^R>',
],

"PPIx::Regexp::Structure::Main" => 
[
"xRe::Structure::Main",
"a regular expression proper,    or a substitution",
],

"PPIx::Regexp::Structure::Modifier" => 
[
"xRe::Structure::Modifier",
"Represent modifying parentheses",
"group but do not capture; Basic clustering",
],

"PPIx::Regexp::Structure::NamedCapture" => 
[
"xRe::Structure::NamedCapture",
"a named capture",
'L<<< perlre/(?<NAME>pattern) >>>',
'L<perlvar/%+>',
],

"PPIx::Regexp::Structure::Quantifier" => 
[
"xRe::Structure::Quantifier",
"Represent curly bracket    quantifiers",
],

"PPIx::Regexp::Structure::RegexSet" => 
[
"xRe::Structure::RegexSet",
"a regexp character set",
   'L<perlre/(?[ ])>',
   'L<perlrecharclass/Extended Bracketed Character Classes>',
   'L<http://search.cpan.org/dist/perl-5.18.0/pod/perlrecharclass.pod#Extended_Bracketed_Character_Classes>',
   'no warnings "experimental::regex_sets";',
],

"PPIx::Regexp::Structure::Regexp" => 
[
"xRe::Structure::Regexp",
"Represent the top-level regular    expression",
],

"PPIx::Regexp::Structure::Replacement" => 
[
"xRe::Structure::Replacement",
"Represent the replacement in s///",
],

"PPIx::Regexp::Structure::Subexpression" => 
[
"xRe::Structure::Subexpression",
"Represent an independent    subexpression",

## redundant
'(?>pattern)',
'L<perlre/(?>pattern)>',
'It may also be useful in places where the "ratchet" or',
'"grab all you can, and do not give anything back" semantic is desirable.',
],

"PPIx::Regexp::Structure::Switch" => 
[
"xRe::Structure::Switch",
"a switch",
#~ 'L<perlre/(?(condition)yes-pattern|no-pattern)>',
#~ 'L<http://perldoc.perl.org/perlre.html#%28?%28condition%29yes-pattern%7Cno-pattern%29|perlre/(?(condition)yes-pattern|no-pattern)>',
'L<perlre/(?(condition)yes-pattern)>',
'L<http://p3rl.org/perlre#(?(condition)yes-pattern|no-pattern)>',
],

"PPIx::Regexp::Structure::Unknown" => 
[
"xRe::Structure::Unknown",
"Represent an unknown structure. (ERROR!TYPO!NONSENSE!)",
#~ "the following tokens aren't what you wanted",

## TODO be clever like perl?!? TODO ASK or TEST if I can assume this?
#~ $ perl -we " qr{(?(foo)bar|baz|burfle)}smx "
#~ Unknown switch condition (?(fo in regex; marked by <-- HERE in m/(?( <-- HERE foo)bar|baz|burfle)/ at -e line 1.
    
    "ERROR die Unknown switch condition in regex;",
    "for valid conditions see L<perlre/(?(condition)yes-pattern)>",

#~ THIS IS A LIE :) TODO REPORT BUG C<PPIx::Regexp::Structure::Unknown> has no descendants.
],

"PPIx::Regexp::Token::Assertion" => 
[
"xRe::Token::Assertion",
#~ "a simple assertion.",
#~ "a simple assertion (ex: \\A \\Z \\G ...).",
#~ "simple zero-width assertion (ex: \\A \\Z \\G ...).",
"simple zero-width assertion (zero-length, between pos()itions)",
],

"PPIx::Regexp::Token::Backreference" => 
[
"xRe::Token::Backreference",
"a back reference",
'L<perlglossary/backreference>',
#~ TODO REPORT BUG \g10 UNRECOGNIZED AS A REFERENCE misparsed as PPIx::Regexp::Token::Literal
#~ TODO BACKREFERENCE
#~     \k'NAME' 
#~     /(.)(.)(.)(.)(.)(.)(.)(.)(.)\g10/   # \g10 is a backreference 
#~     /(.)(.)(.)(.)(.)(.)(.)(.)(.)\10/    # \10 is octal
#~     /((.)(.)(.)(.)(.)(.)(.)(.)(.))\10/  # \10 is a backreference
#~     /((.)(.)(.)(.)(.)(.)(.)(.)(.))\010/ # \010 is octal
],

"PPIx::Regexp::Token::Backtrack" => 
[
"xRe::Token::Backtrack",
"Represent backtrack control.",
'L<perlre/Special Backtracking Control Verbs>',
'WARNING: These patterns are experimental and subject to change or removal in a future version of Perl.',
'Their usage in production code should be noted to avoid problems during upgrades.',
],

"PPIx::Regexp::Token::CharClass" => 
[
"xRe::Token::CharClass",
"a character class",
],

"PPIx::Regexp::Token::CharClass::POSIX" => 
[
"xRe::Token::CharClass::POSIX",
"a POSIX character    class",
],

"PPIx::Regexp::Token::CharClass::POSIX::Unknown" => 
[
"xRe::Token::CharClass::POSIX::Unknown",
"Represent an unknown or    unsupported POSIX character class",
],

"PPIx::Regexp::Token::CharClass::Simple" => 
[
"xRe::Token::CharClass::Simple",
"This class represents a simple    character class", ## TODO IMPROVE? REMOVE?
],

"PPIx::Regexp::Token::Code" => 
[
"xRe::Token::Code",
"a chunk of Perl embedded in a    regular expression.",
],

"PPIx::Regexp::Token::Comment" => 
[
"xRe::Token::Comment",
#~ "a comment.",
],

"PPIx::Regexp::Token::Condition" => 
[
"xRe::Token::Condition",
"Represent the condition of a switch",
'Checks if a specific capture group (or pattern) has matched something.',
],

"PPIx::Regexp::Token::Control" => 
[
"xRe::Token::Control",
"Case and quote control.",
'L<perlre/\F\l\u\L\U\Q\E>',,

#~ "PPIx::Regexp::Dumper->new( 'qr{\\Ufoo\\E}smx' )->print",
],

"PPIx::Regexp::Token::Delimiter" => 
[
"xRe::Token::Delimiter",
"Represent the delimiters of the regular    expression",
],

"PPIx::Regexp::Token::Greediness" => 
[
"xRe::Token::Greediness",
"a greediness qualifier.",
#~ "PPIx::Regexp::Dumper->new( 'qr{foo*+}smx' )->print",
],

"PPIx::Regexp::Token::GroupType" => 
[
"xRe::Token::GroupType",
"a grouping parenthesis type.",
#~ "PPIx::Regexp::Dumper->new( 'qr{(?i:foo)}smx' )->print",
],

"PPIx::Regexp::Token::GroupType::Assertion" => 
[
"xRe::Token::GroupType::Assertion",
"a look ahead or    look behind assertion",
#~ "PPIx::Regexp::Dumper->new( 'qr{foo(?=bar)}smx' )->print",
],

"PPIx::Regexp::Token::GroupType::BranchReset" => 
[
"xRe::Token::GroupType::BranchReset",
"a branch reset    specifier",
"L<perlre/(?|pattern)>",
"L<perlre/(?E<verbar>pattern)>",
"capture groups are numbered from the same starting point in each alternation branch",
#~ "PPIx::Regexp::Dumper->new( 'qr{(?|(foo)|(bar))}smx' )->print",
],

"PPIx::Regexp::Token::GroupType::Code" => 
[
"xRe::Token::GroupType::Code",
"Represent one of the embedded    code indicators",
],

"PPIx::Regexp::Token::GroupType::Modifier" => 
[
"xRe::Token::GroupType::Modifier",
"Represent the modifiers in a    modifier group.",
#~ "PPIx::Regexp::Dumper->new( 'qr{(?i:foo)}smx' )->print",
],

"PPIx::Regexp::Token::GroupType::NamedCapture" => 
[
"xRe::Token::GroupType::NamedCapture",
#~ "a named capture",
#~ 'L<perlre/(?<NAME>pattern)>',
#~ 'L<<< perlre/(?<NAME>pattern) >>>',
##'L<perlre/(?&NAME)>', ## not this
#~ 'L<perlvar/%+>', ## redundant
#~ "PPIx::Regexp::Dumper->new( 'qr{(?<baz>foo)}smx' )->print",
"",
],

"PPIx::Regexp::Token::GroupType::Subexpression" => 
[
"xRe::Token::GroupType::Subexpression",
"Represent an independent    subexpression marker",
## redundant
#~ '(?>pattern)',
#~ 'It may also be useful in places where the "ratchet" or',
#~ '"grab all you can, and do not give anything back" semantic is desirable.',

#~ "PPIx::Regexp::Dumper->new( 'qr{foo(?>bar)}smx' )->print",
],

"PPIx::Regexp::Token::GroupType::Switch" => 
[
"xRe::Token::GroupType::Switch",
"Represent the introducing    characters for a switch",
#~ "PPIx::Regexp::Dumper->new( 'qr{(?(1)foo|bar)}smx' )->print",


## TODO be clever like perl?!? TODO ASK or TEST if I can assume this?
#~ $ perl -we " qr{(?(foo)bar|baz|burfle)}smx "
#~ Unknown switch condition (?(fo in regex; marked by <-- HERE in m/(?( <-- HERE foo)bar|baz|burfle)/ at -e line 1.
#~     "die Unknown switch condition in regex;",
    "for valid conditions see L<perlre/(?(condition)yes-pattern)>",
],

"PPIx::Regexp::Token::Interpolation" => 
[
"xRe::Token::Interpolation",
"Represent an interpolation in the    PPIx::Regexp package.",
#~ 'It is a variable! whose contents are used as a pattern, subject to \F\l\u\L\U\Q\E',
'It is a variable! subject to \F\l\u\L\U\Q\E',
#~ and L<perlre/Modifiers>',
'L<perlre/\F\l\u\L\U\Q\E>',
#~ 'L<perlre/\Q\U\E\F\u\l\L>',
#~ 'L<perlre/\Q\U\E\L\F\u\l>', #<<<
#~ 'subject to L<perlre/Modifiers>',

#~ "PPIx::Regexp::Dumper->new('qr{\$foo}smx')->print",
],

#~ 2013-08-05-04:22:50
"PPIx::Regexp::Token::Interpolation-Regexp" => ['It is a variable! whose contents are used as a pattern ','subject to L<perlre/Modifiers>'],
"PPIx::Regexp::Token::Interpolation-Substitution" => ['It is a variable! whose contents are used as a REPLACEMENT string'],


"PPIx::Regexp::Token::Literal" => 
[
"xRe::Token::Literal",
"a literal character",
#~ "PPIx::Regexp::Dumper->new( 'qr{foo}smx' )->print",
],

#~ $ perl -Mre=debug -wle " $_ = q{aBaBaBaB}; m{((?i)ab)ab}"
"token_modifier_propagates_right" =>  "These modifiers PROPAGATE to the right for the remainder of the pattern, or the remainder of the enclosing pattern group (if any).  Ex: /((?i)CASeINSeNSITIVeHeRe)CASESENSITIVE/",
"PPIx::Regexp::Token::Modifier" => 
[
"xRe::Token::Modifier",
#~ "Represent (trailing) modifiers.",
#~ "Modifier for one of these operators: match(m//) or substitution (s///) or regexp-constructor (qr//)",
#~ "Represent (trailing) modifiers for match, substitution, regexp constructor",
"Represent 1)embedded pattern-match modifiers or 2)(trailing) modifiers for operators match, substitution, regexp constructor ",
#~ "Represent (trailing) modifiers for m//  s///   qr///", ## 2013-06-20-08:02:53 dontwanna
### TODO qr// needs better name than regex compile
#~ 2013-06-12-03:55:26 Regexp constructor sounds good
#~ "PPIx::Regexp::Dumper->new( 'qr{foo}smx' )->print",
],

"PPIx::Regexp::Token::Operator" => 
[
"xRe::Token::Operator",
"Represent an operator.",
#~ "PPIx::Regexp::Dumper->new( 'qr{foo|bar}smx' )->print",
],

"PPIx::Regexp::Token::Quantifier" => 
[
"xRe::Token::Quantifier",
"Represent an atomic quantifier.",
],

"PPIx::Regexp::Token::Recursion" => 
[
"xRe::Token::Recursion",
"a recursion",
#~ "(?PARNO)",
#~ "L<perlre/(?PARNO)>", ## perlre problematic
"L<perlre/(?PARNO) (?-PARNO) (?+PARNO) (?R) (?0)>", ## perlre problematic
#~ "PPIx::Regexp::Dumper->new( 'qr{(foo(?1)?)}smx' )->print",
],

"PPIx::Regexp::Token::Reference" => 
[
"xRe::Token::Reference",
"a reference to a capture",
#~ "PPIx::Regexp::Dumper->new( 'qr{\\1}smx' )->print",
],

"PPIx::Regexp::Token::Structure" => 
[
"xRe::Token::Structure",
"Represent structural elements.",
#~ 'Represent structural elements. (like "[","]", "{","}" "(",")"  delimiters)', ## m too
#~     ' ',
],

"PPIx::Regexp::Token::Unknown" => 
[
"xRe::Token::Unknown",
"Represent an unknown token (A FAILURE; AN ERROR)",
],

"PPIx::Regexp::Token::Unmatched" => 
[
"xRe::Token::Unmatched",
"Represent an unmatched right bracket (a TYPO!)",
],

"PPIx::Regexp::Token::Whitespace" => 
[
"xRe::Token::Whitespace",
"Represent whitespace",
],


'?u' => [
"according to unicode semantics",
],

'?d' => [
'according to "Depends" or "Dodgy" or "Default" semantics',
],

'?a' => [
'according to ASCII-restrict (or ASCII-safe) semantics',
],

'?aa' => [
'according to stricter-ASCII-restrict (or stricter-ASCII-safe) semantics',
],



  '*' => 'match preceding pattern 0 or more times',
  '+' => 'match preceding pattern 1 or more times',
#~   "PPIx::Regexp::Token::Quantifier".'+' => 'match preceding pattern 1 or more times', ## didn't work, has to do
  '?' => 'match preceding pattern 0 or 1 times; is optional',
  
#~   2013-06-20-02:39:00
    most_possible => '(matching the most amount possible)',
    least_possible => '(matching the least amount possible)',
    only_last_n  => 'WARNING only the LAST repetition of the captured pattern will be stored in %%%%',
## greediness
#~   '+?' => ["and matching (preceding pattern) the least amount possible",'Match shortest string first'],
#~   '++' => ["and give nothing back (ratchet);","modifies preceding quantifier so preceding pattern doesn't backtrack", 'Match longest string and give nothing back'],
  "PPIx::Regexp::Token::Greediness".'?' => ["and matching (preceding pattern) the least amount possible",'Match shortest string first'],
  "PPIx::Regexp::Token::Greediness".'+' => ["and give nothing back (ratchet);","modifies preceding quantifier so preceding pattern doesn't backtrack", 'Match longest string and give nothing back'],


#~ 2013-06-13-02:59:39
  "\\d"  => [
              "\\d Match a decimal digit character.",
              "[0-9]",
              "L<perldebguts/DIGIT>",
            ],
  "\\D"  => [
              "\\D Match a non-decimal-digit character.",
              "L<perldebguts/NDIGIT>",
              'Match not "[0-9]" meaning match "[^0-9]";',
            ],
  "\\Da" => [
              "\\D Match a non-decimal-digit character (/a ASCII-restrict semantics).",
              "L<perldebguts/NDIGITA>",
              'Match not "[0-9]" meaning match "[^0-9]";',
            ],
  "\\da" => [
#~               "\\d Match a decimal digit character.",
              "\\d Match a decimal digit character (/a ASCII-restrict semantics).",
              "Match exactly [0-9]",
              "L<perldebguts/DIGITA>",
            ],
  "\\Dl" => [
              "\\D Match a non-decimal-digit character.",
              "L<perldebguts/NDIGITL>",
            ],
  "\\dl" => [
              "\\d Match a decimal digit character.",
              "L<perldebguts/DIGITL>",
            ],
  "\\du" => [
              "Match a decimal digit character.",
              "matches exactly what \\p{Digit} matches.",
            ],
#~   "\\H"  => "\\H Match a character that isn't horizontal whitespace.",
#~   "\\H"  => "\\H Match a character that is NOT horizontal whitespace.",
#~   "\\h"  => "\\h Match a horizontal whitespace character.",
  "\\H"  => "\\H Match a character that is NOT horizontal whitespace. \\P{HorizSpace} or [^\\N{U+0009}\\N{U+0020}\\N{U+00A0}\\N{U+1680}\\N{U+180E}\\N{U+2000}-\\N{U+200A}\\N{U+202F}\\N{U+205F}\\N{U+3000}]",
  "\\h"  => "\\h Match a horizontal whitespace character. \\p{HorizSpace} or [\\N{U+0009}\\N{U+0020}\\N{U+00A0}\\N{U+1680}\\N{U+180E}\\N{U+2000}-\\N{U+200A}\\N{U+202F}\\N{U+205F}\\N{U+3000}]",
#~   2013-06-14-18:16:35
#~ http://perl5.git.perl.org/perl.git/blob?f=regcomp.c#l9910
  "PPIx::Regexp::Token::Unknown"."\\N" => 'ERROR die \N in a character class must be a named character: \N{...} in regex;',
#~ http://perl5.git.perl.org/perl.git/blob?f=regexec.c#l3673
#~ http://perl5.git.perl.org/perl.git/blob?f=regexec.c#l6688
  "\\N"  => [
#~     "\\N Match a character that isn't a newline (\\n). Experimental.",
    "\\N Match a character that is NOT a newline (\\n). Experimental.",
    'L<perldebguts/REG_ANY>',
   ],
  "\\R"  => [
              "generic newline;",
              "anything considered a linebreak sequence by Unicode;",
              "L<perlrecharclass/Backslash Sequences>",
              "anything that can be considered a newline under Unicode",
              "[\\x{000A}\\x{000C}\\x{000D}\\x{0085}\\x{2028}\\x{2029}]",
#~ http://perl5.git.perl.org/perl.git/blob?f=regcharclass.h
              'LNBREAK: Line Break: \R',
              '\p{VertSpace} and "\x0D\x0A"      # CRLF - Network (Windows) line ending',

            ],
  "\\sa"  => "\\s Match a whitespace character. ASCII-restrict; Match exactly [ \\f\\n\\r\\t] (and in perl5.18 vertical tab chr(11))",
  "\\s"  => "\\s Match a whitespace character.",
  "\\S"  => "\\S Match a non-whitespace character.",
  "\\Sa"  => "\\S Match a non-whitespace character. ASCII-restrict; Match exactly [^ \\f\\n\\r\\t] (and in perl5.18 NOT vertical tab chr(11))",
#~   "\\v"  => "\\v Match a vertical whitespace character.",
  "\\v"  => "\\v Match a vertical whitespace character. \\p{VertSpace}  or  [\\N{U+000A}-\\N{U+000D}\\N{U+0085}\\N{U+2028}-\\N{U+2029}]",
#~   "\\V"  => "\\V Match a character that isn't vertical whitespace.",
#~   "\\V"  => "\\V Match a character that is NOT vertical whitespace.",
  "\\V"  => "\\V Match a character that is NOT vertical whitespace. \\P{VertSpace}  or  [^\\N{U+000A}-\\N{U+000D}\\N{U+0085}\\N{U+2028}-\\N{U+2029}]",
  "\\W"  => [
              "\\W Match a non-\"word\" character.",
              "L<perldebguts/NALNUM>",
              "L<perlrecharclass/\\W>",
              "\\W matches not [a-zA-Z0-9_] meaning [^a-zA-Z0-9_].",
            ],
  "\\Wa" => [
              "\\W Match a non-\"word\" character.",
              "L<perldebguts/NALNUMA>",
              "L<perlrecharclass/\\W>",
              "\\W matches not [a-zA-Z0-9_] meaning [^a-zA-Z0-9_].",
            ],
  "\\Wl" => [
              "\\W Match a non-\"word\" character; according to use locale;",
              "L<perlrecharclass/\\W>",
              "L<perldebguts/NALNUML>",
            ],
  "\\Wu" => [
              "\\W Match a non-\"word\" character; according to unicode semantics",
              "L<perlrecharclass/\\W>",
              "\\W matches exactly what \\P{Word} matches (not \\p{Word}).",
              "L<perldebguts/NALNUMU>",
            ],
  "\\w"  => [
              "\\w Match a \"word\" character.",
              "L<perlrecharclass/\\w>",
              "\\w matches [a-zA-Z0-9_].",
              "L<perldebguts/ALNUM>",
            ],
  "\\wa" => [
              "\\w Match a \"word\" character. (?a:\w)",
              "L<perlrecharclass/\\w>",
              "\\w matches [a-zA-Z0-9_].",
              "L<perldebguts/ALNUMA>",
            ],
  "\\wl" => [
              "\\w Match a \"word\" character; according to use locale; (?l:\w)",
              "L<perlrecharclass/\\w>",
              "L<perldebguts/ALNUML>",
            ],
  "\\wu" => [
              "\\w Match a \"word\" character; according to unicode semantics; (?u:\w)",
              "L<perlrecharclass/\\w>",
              "\\w matches exactly what \\p{Word} matches.",
              "L<perldebguts/ALNUMU>",
            ],

  '.' => 'any character except \n',
#~   '.s' => 'any character (including \n)' . join( ' aka ', '', '[\w\W]', '[\s\S]' , '[\d\D]', '\p{All}' ),
  '.s' => 'any character (including \n)' . join( ' alias ', '', '[\w\W]', '[\s\S]' , '[\d\D]', '\p{All}' ),

#~ 2013-06-13-03:39:54
  '[:alpha:]' => [ 'letters', '\p{PosixAlpha}',],
  '[:alnum:]' => ['letters and digits','\p{PosixAlpha}'],
  '[:ascii:]' => ['all ASCII characters (\000 - \177)', ],
  '[:cntrl:]' => ['control characters (those with ASCII values less than 32)',, '\p{PosixCntrl}', ],
  '[:digit:]' => ['digits (like \d)',, '\p{PosixDigit}', ],
  '[:graph:]' => ['alphanumeric and punctuation characters',, '\p{PosixGraph}', ],
  '[:lower:]' => ['lowercase letters',, '\p{PosixLower}', ],
  '[:print:]' => ['alphanumeric, punctuation, and whitespace characters',, '\p{PosixPrint}', ],
  '[:punct:]' => ['punctuation characters',, '\p{PosixPunct}', ],
  '[:space:]' => ['whitespace characters (like \s)',, '\p{PosixSpace}', ],
  '[:upper:]' => ['uppercase letters',, '\p{PosixUpper}', ],
  '[:word:]' => ['alphanumeric and underscore characters (like \w)',, '\p{PosixWord}', ],
  '[:xdigit:]' => ['hexadecimal digits (a-f, A-F, 0-9)',, '\p{Posix}', ],

      "(*ACCEPT)" => [
        'WARNING: This feature is highly experimental. It is not recommended for production code.',
        "(*ACCEPT) Causes match to succeed at the point of the (*ACCEPT)",
        'L<perlre/(*ACCEPT)>',
      ],
      "(*COMMIT)" => ["(*COMMIT) Causes match failure when backtracked into on failure",'L<perlre/(*COMMIT)>',],
      "(*ACCEPT:NAME)" => ["ERROR die Verb pattern 'ACCEPT' may not have an argument in regex;",],
      "(*COMMIT:NAME)" => ["ERROR die Verb pattern 'COMMIT' may not have an argument in regex;",],
      "(*F:NAME)"      => ["ERROR die Verb pattern 'F' may not have an argument in regex;",],
      "(*FAIL:NAME)"  => ["ERROR die Verb pattern 'FAIL' may not have an argument in regex;",],
      "(*F)"      => ["(*FAIL) Always fails, forcing backtrack", 'L<perlre/(*FAIL) (*F)>', ],
      "(*FAIL)"   => ["(*FAIL) Always fails, forcing backtrack", 'L<perlre/(*FAIL) (*F)>', ],
#~       "(*MARK)"   => ["(*MARK) Name branches of alternation, target for (*SKIP)",'L<perlre/(*MARK) (*MARK:NAME)>',],
      "(*MARK)"        => ["(*MARK) Name branches of alternation, target for (*SKIP)",'L<perlre/(*MARK:NAME) (*:NAME)>',],
      "(*MARK:NAME)"   => ["(*MARK:NAME) Name branches of alternation, target for (*SKIP)",'L<perlre/(*MARK:NAME) (*:NAME)>',],
      "(*PRUNE)"       => ["(*PRUNE) Prevent backtracking past here on failure",'L<perlre/(*PRUNE) (*PRUNE:NAME)>', ],
      "(*PRUNE:NAME)"  => ["(*PRUNE:NAME) Prevent backtracking past here on failure",'L<perlre/(*PRUNE) (*PRUNE:NAME)>', ],
      "(*SKIP)"        => ["(*SKIP) Like (*PRUNE) but also discards match to this point", 'L<perlre/(*SKIP) (*SKIP:NAME)>',],
      "(*SKIP:NAME)"   => ["(*SKIP:NAME) Like (*PRUNE) but also discards match to this point", 'L<perlre/(*SKIP) (*SKIP:NAME)>',],
      "(*THEN)"        => ["(*THEN) Forces next alternation on failure", 'L<perlre/(*THEN) (*THEN:NAME)>',],
      "(*THEN:NAME)"   => ["(*THEN:NAME) Forces next alternation on failure", 'L<perlre/(*THEN) (*THEN:NAME)>',],
#~       "(*UNKNOWN)" => "ERROR warn UNRECOGNIZED VERB (%%%%)",
#~       "(*UNKNOWN:NAME)" => "ERROR warn UNRECOGNIZED VERB:NAME (%%%%:%%%%)",
#~ 2013-08-06-01:47:38
      "(*UNKNOWN)" => "ERROR die Unknown verb pattern '%%%%' in regex;",
      "(*UNKNOWN:NAME)" => "ERROR  die Unknown verb pattern '%%%%:%%%%' in regex;",

  '$' => 'match before an optional \n, and the end of the string', ## todo ANCHOR ANCHOR DESC
  '$m' => 'match before an optional \n, and the end of a "line"',
  '\A' => 'match the beginning of the string',
  '^' => 'match the beginning of the string',
  '^m' => 'match the beginning of a "line"',
  '\z' => 'match the end of the string',
  '\Z' => 'match before an optional \n, and the end of the string',
#~   '\G' => 'match where the last m//g left off',
  '\G' => 'match where the last m//g left off; \G  Match only at pos() (e.g. at the end-of-match position of prior m//g)',
  '\b' => 'match the boundary between a word char (\w) and something that is not a word char (\W); OUTSIDE a "word"',
  '\bl' => 'match the boundary between a word char (\w) and something that is not a word char (\W); according to use locale;; OUTSIDE a "word"',
  '\bu' => 'match the boundary between a word char (\p{Word}) and something that is not a word char (\P{Word}); according to unicode semantics; OUTSIDE a "word"',
  '\ba' => 'match the boundary between a word char (\w) and something that is not a word char (\W); according to ASCII-restrict; OUTSIDE a "word"',
#~ 2013-08-11-19:59:39 #~ TODO #~   touching OUTSIDE a "word"
#~ perlre
#~ \b Match a word boundary
#~ \B Match except at a word boundary
#~ perlrebackslash
#~ \b Word/non-word boundary. (Backspace in []).
#~ \B Not a word/non-word boundary. Not in [].
#~ perlrequick and perlretut
#~ The word anchor \b matches a boundary between a word character and a non-word character \w\W or \W\w :
#~ perlretut
#~ Similarly, the word boundary anchor \b matches wherever a character matching \w is next to a character that doesn't, but it doesn't eat up any characters itself.
#~ \b looks both ahead and behind, to see if the characters on either side differ in their "word-ness".
## perldebguts
#~ /\B/u    \Bu     NBOUNDU Match "" at any word non-boundary using Unicode semantics

#~  
#~   '\B' => 'match the boundary between two word chars (\w) or two non-word chars (\W)',
#~   '\Bl' => 'match the boundary between two word chars (\w) or two non-word chars (\W); according to use locale;',
  '\B' => 'match the boundary between two word chars (\w); INSIDE a "word"',
  '\Bl' => 'match the boundary between two word chars (\w); according to use locale;; INSIDE a "word"',
  '\Bu' => 'match the boundary between two word chars (\\p{Word}); according to unicode semantics; INSIDE a "word"',
  '\Ba' => 'match the boundary between two word chars (\\p{Word}); according to ASCII-restrict; INSIDE a "word"',
#~ 2013-06-14-17:20:08 doesn't affect capture groups
#~ $ perl -Mre=debug -le " $_=q{12345}; m{(.{4}\K)\K(.)}; print $1,$2 "
  "\\K" => [
   'A zero-width positive look-behind assertion.',
   '"(?<=pattern)"    "\\K"',
   'L<perlre/Look-Around Assertions>',
   '"keep" everything matched prior to the \K and do not include it in $& ',
   'match left of \K and discard (not-Keep) from $& ',
  ],

    '?=' => [ '(?=pattern)', 'L<perlre/(?=pattern)>', 'A zero-width positive look-ahead assertion.', 'For example, C</\w+(?=\t)/> matches a word followed by a tab, without including the tab in C<$&>.' ],
    '?<=' => [
        '(?<=pattern)',
        'L<perlre/(?<=pattern)>',
        'C<(?<=pattern)> C<\K>',
        'A zero-width positive look-behind assertion.',
        'For example, C</(?<=\t)\w+/> matches a word that follows a tab, without including the tab in C<$&>.',
        'Works only for fixed-width look-behind.',
    ],
    '?!' => [ '(?!pattern)', 'L<perlre/(?!pattern)>',
        'A zero-width negative look-ahead assertion.',
#~         q{For example C</foo(?!bar)/> matches any occurrence of "foo" that isn't followed by "bar". },
        q{For example C</foo(?!bar)/> matches any occurrence of "foo" that is NOT followed by "bar". },
        'Note however that look-ahead and look-behind are NOT the same thing. ',
        'You cannot use this for look-behind.',
    ],
    '?<!' => [ '(?<!pattern)', 'L<perlre/(?<!pattern)>',

'A zero-width negative look-behind assertion.',
'For example C</(?<!bar)foo/> matches any occurrence of "foo" that does not follow "bar".',
'Works only for fixed-width look-behind.',

    ],
#~     'errn?<!' => 'ERROR die Variable length lookbehind not implemented in regex (** maybe false positive, detection not bulletproof, not hanlde (?i:a) )',
#~     'errn?<=' => 'ERROR die Variable length lookbehind not implemented in regex (** maybe false positive, detection not bulletproof, not hanlde (?i:a) )',
    'errn?<!' => 'ERROR die Variable length lookbehind not implemented in regex; you used variable length alterations like "a|aa" or you used variable-length quantifiers like "*", "+" or "?"',
    'errn?<=' => 'ERROR die Variable length lookbehind not implemented in regex; you used variable length alterations like "a|aa" or you used variable-length quantifiers like "*", "+" or "?"',

#~ 2013-06-13-04:15:45
  # flags

#~ 2013-07-26-16:38:29
#~   'mods.i'  => '/i case-insensitive',
#~   'mods.-i' => '?-i: case-sensitive',
#~   'mods.m'  => '/m with ^ and $ matching start and end of line',
#~   'mods.-m' => '?-m: with ^ and $ matching normally (start and end of string)',
#~   'mods.s'  => '/s with . matching \n',
#~   'mods.-s' => '?-s: with . not matching \n',
#~   'mods.x'  => '/x disregarding whitespace and comments',
#~   'mods.-x' => '?-x: matching whitespace and # normally',
#~   'mods.u'  => '/u sets the character set to Unicode.',

  'mods.i'   => '(?i)  case-insensitive',
  'mods.-i'  => '(?-i) case-sensitive',
  'mods.m'   => '(?m)  with ^ and $ matching start and end of line',
  'mods.-m'  => '(?-m) with ^ and $ matching normally (start and end of string)',
  'mods.s'   => '(?s)  with . matching \n',
  'mods.-s'  => '(?-s) with . not matching \n',
  'mods.x'   => '(?x)  disregarding whitespace and comments',
  'mods.-x'  => '(?-x) matching whitespace and # normally',
  'mods/x'   => '/x    disregarding whitespace and comments',
  'match_semantics.u'   => '(?u)  sets the character set to Unicode.',
#~ http://search.cpan.org/~rjbs/perl-5.18.0/pod/perlre.pod#/a_%28and_/aa%29
  'match_semantics.a' => [ ## match_semantics 
#~     '/a is ASCII-restrict (or ASCII-safe); https://metacpan.org/module/perlre#a-and-aa',
#~     '/a is ASCII-restrict (or ASCII-safe); http://search.cpan.org/dist/perl/pod/perlre.pod#/a_%28and_/aa%29',
    '/a is ASCII-restrict (or ASCII-safe); L<<<http://search.cpan.org/dist/perl/pod/perlre.pod#/a_%28and_/aa%29|/a (and /aa)>>>',
    '/a it causes the sequences \d, \s, \w, and the Posix character classes to match only in the ASCII range.',
    '/a also sets the character set to Unicode, BUT adds several restrictions for ASCII-safe matching.',
  ],
#~   'match_semantics.aa' => '/aa forbids the intermixing of ASCII and non-ASCII; ASCII-restrict-strict ; ASCII-safe-strict;',
#~   'match_semantics.aa' => '/aa forbids the intermixing of ASCII and non-ASCII; ASCII-restrict-insensitive; Prevents this match "k" =~ /N{KELVIN SIGN}/aia',
#~   'match_semantics.aa' => '/aa ASCII-restrict-case-insensitive;  forbids the intermixing of ASCII and non-ASCII; Prevents this match "kk" =~ /\N{KELVIN SIGN}\N{U+212A}/i',
#~ _aa.pl
#~   'match_semantics.aa' => '/aa ASCII-restrict-case-insensitive;  Prevents ASCII-range from matching non-ASCII-range case-insensitively. Prevents this match "kk" =~ /\N{KELVIN SIGN}\N{U+212A}/i;  https://metacpan.org/module/perlre#a-and-aa',
#~   'match_semantics.aa' => '/aa ASCII-restrict-case-insensitive;  Prevents ASCII-range from matching non-ASCII-range case-insensitively. Prevents this match "kk" =~ /\N{KELVIN SIGN}\N{U+212A}/i;  http://search.cpan.org/dist/perl/pod/perlre.pod#/a_%28and_/aa%29',
  'match_semantics.aa' => '/aa ASCII-restrict-case-insensitive;  Prevents ASCII-range from matching non-ASCII-range case-insensitively. Prevents this match "kk" =~ /\N{KELVIN SIGN}\N{U+212A}/i;  L<<<http://search.cpan.org/dist/perl/pod/perlre.pod#/a_%28and_/aa%29|/a (and /aa)>>>',
#~   because CORE::fc("\N{KELVIN SIGN}\N{U+212A}") eq "\F\N{KELVIN SIGN}\N{U+212A}\Q" eq "kk"
#~ http://search.cpan.org/~rjbs/perl-5.18.0/pod/perlre.pod#/d
  'match_semantics.^' => '(?^) is (?d) is "Depends" or "Dodgy" or "Default"; L<perlunicode/The "Unicode Bug">;',
  'match_semantics.d' => [
    '(?d) is "Depends" or "Dodgy" or "Default"; L<perlunicode/The "Unicode Bug">;',
    '(?d) is the old, problematic, pre-5.14 Default character set behavior. Its only use is to force that old behavior.',
   ],
   'match_semantics.l' => "/l sets the character set to current locale. See L<perllocale>",
   'match_semantics.u' => "/u sets the character set to Unicode.",
   'mods/l' => [ "/l WARNING NOT RECOMMENDED instead use locale; ", ],
   'mods/u' => [ "/u WARNING NOT RECOMMENDED instead use feature 'unicode_strings'", ],
   'mods.o' => [ "ERROR warn Useless (?o) - use /o modifier in regex;  /o  Compile pattern only once.", ],
   'mods/o' => [ "/o  Compile pattern only once.", ],
   'mods.p' => [ '(?p)  Preserve the string matched such that ${^PREMATCH}, ${^MATCH}, and ${^POSTMATCH} are available for use after matching. GLOBAL!TRICKY!(RT#117135)',],
   'mods/p' => [ '/p    Preserve the string matched such that ${^PREMATCH}, ${^MATCH}, and ${^POSTMATCH} are available for use after matching. GLOBAL!TRICKY!(RT#117135)',],
#~ Note also that the p modifier is special in that its presence anywhere in a pattern has a global effect.
   'mods.-a' => [ 'ERROR die Regexp modifier "a" may not appear after the "-" in regex;', ],

#~ 2013-08-12-01:50:18
#~ untrippable 
#~ TODO REPORT BUG? SHOULD BE RECOGNIZED AS  Token::Modifier/GroupType::Modifier
#~ 'qr{(?-^)(?-^:u}', ## #~ xRe::Structure::Capture #~ /1/C1/C58/C0 ; xRe::Token::Unknown
#~    'mods.-^' => [ 'ERROR die Regexp modifier "^" aka "d" may not appear after the "-" in regex;', ],
   'mods.-d' => [ 'ERROR die Regexp modifier "d" may not appear after the "-" in regex;', ],
   'mods.-l' => [ 'ERROR die Regexp modifier "l" may not appear after the "-" in regex;', ],
   'mods.-u' => [ 'ERROR die Regexp modifier "u" may not appear after the "-" in regex;', ],
   'mods.-p' => [ 'THINKO warn Useless use of (?-p) in regex;', ],
   'mods.-p' => [ 'THINKO warn Useless use of (?-p) in regex; You cant turn (?p) off; (?p) is global', ],

#~ evaln
   'mods/s/e'     => '(/e)  Evaluate the right side as an expression.',
   'mods/s/ee'    => '(/ee) Evaluate the right side as a string then eval the result (maybe %%%% times). WARNING DANGEROUS L<perlfunc/eval>',
   'mods/s/r'     => '(/r)  Return substitution and leave the original string untouched; not modify $foo in $foo =~ s///r',

#~ 2013-07-28-20:13:01
  'mods/i'   => '(/i)  case-insensitive',
#~ untrippable #~   'mods/-i'  => '(/-i) case-sensitive',
  'mods/m'   => '(/m)  with ^ and $ matching start and end of line',
#~ untrippable #~   'mods/-m'  => '(/-m) with ^ and $ matching normally (start and end of string)',
  'mods/s'   => '(/s)  with . matching \n',
  
## 2013-07-26-02:44:01
#~    'mods.twice'     => 'ERROR die Regexp modifier "%%%%" may not appear twice in regex;',
   'mods.nottwice'     => 'ERROR die Regexp modifier "%%%%" may not appear twice in regex;',
   'mods.twicemax'  => 'ERROR die Regexp modifier "%%%%" may appear a maximum of twice in regex;',
   'mods.exclusive' => 'ERROR die Regexp modifiers "%%%%" and "%%%%" are mutually exclusive',
#~    'mods.unknown' =>   'ERROR UNKNOWN MODIFIER "%%%%" (?%%%%)',
   'mods.unknown' =>   'ERROR UNKNOWN MODIFIER "%%%%" die Sequence (?%%%%...) not recognized in regex;',
   'mods/unknown' =>   'ERROR UNKNOWN MODIFIER "%%%%" die Having no space between pattern and following word is deprecated',
#~     2013-07-26-03:31:02
#~    'mods/g' => [ "/g  Match globally, i.e., find all occurrences.", ],
   'mods/g' => [ "/g  Match globally, i.e., find all occurrences.", 'in list context (@matches=m//g) return all matches; in scalar context($count=m//g) return number of matches' ],
   'mods/c' => [ "/c  Do not reset search position on a failed match when /g is in effect.", ],
    
    
#~   '|' => ['OR ; Alternation (outside character class)'],
#~   '|' => ['OR ; Alternation (outside character class); match_left OR match_right'],
  '|' => ['OR ; Alternation ; match_left OR match_right'],

#~ 2013-06-14-00:39:34
    'parsing_failures' => [
"# ERROR WARNING PARSING FAILURE, EXPLANATIONS UNREAL ie IMAGINED ie WRONG ",
"# WARNING PARSING FAILURE, EXPLANATIONS UNREAL ",
"# WARNING PARSING FAILURE, EXPLANATIONS IMAGINED ",
"# WARNING PARSING FAILURE, EXPLANATIONS UNRELIABLE ",
"# WARNING PARSING FAILURE, EXPLANATIONS WRONG ",
"# ",
    ],
    'matches_as_follows' => 'matches as follows:',
    'the_regex' => 'The regular expression ',
    'm_pat_at_add' => 'match the preceding pattern at address=',
#~ $ perl -Mre=debug -we " qr{*}" ## never used because its Token::Unknown
    'quant_f_not' => 'IMPOSSIBLE ERROR die Quantifier follows nothing in regex;',
    'm_recur_ata' => 'MATCH RECURSION at address=',
    'f_e_r_n_exit' => "FATAL ERROR die Reference to nonexistent group in regex;",
    'n_exist_group' => "FATAL ERROR die Reference to nonexistent group in regex;",

#~ 2013-06-14-04:23:22

    "(DEFINE)" => [
        "L<perlre/(DEFINE)>",
        'define subpatterns which will be executed only by the recursion mechanism',
        'It is recommended that you put DEFINE block at the end of the pattern,',
        'and that you name any subpatterns defined within it.',
        'the yes-pattern is never directly executed, and no no-pattern is allowed',
        'Similar in spirit to (?{0}) but more efficient.',
    ],
    '(DEFINE)pointless' => 'WARNING a (DEFINE) section without (?<NAMEd>patterns) is pointless; an empty (DEFINE) section is pointless',
    
#~ 2013-06-14-04:58:49

    'regexset.!' =>  'complement (everything NOT in following set)',
    'regexset.&' =>  'intersection',
    'regexset.+' =>  'union',
    'regexset.|' =>  "another name for '+', hence means union",
    'regexset.-' =>  "subtraction (matched by left operand (above), excluding right operand (below))",
    'regexset.^' =>  [
        "symmetric difference (the union minus the intersection);",
        "like exclusive or;",
        "set of code points that are matched by either, but not both, of the operands.",
    ],
#~     2013-08-12-01:20:21 dupes
#~     'PPIx::Regexp::Structure::RegexSet!' =>  'complement (everything NOT in following set)',
#~     'PPIx::Regexp::Structure::RegexSet&' =>  'intersection',
#~     'PPIx::Regexp::Structure::RegexSet+' =>  'union',
#~     'PPIx::Regexp::Structure::RegexSet|' =>  "another name for '+', hence means union",
#~     'PPIx::Regexp::Structure::RegexSet-' =>  "subtraction (matched by left operand (above), excluding right operand (below))",
#~     'PPIx::Regexp::Structure::RegexSet^' =>  [
#~         "symmetric difference (the union minus the intersection);",
#~         "like exclusive or;",
#~         "set of code points that are matched by either, but not both, of the operands.",
#~     ],
   
  "PPIx::Regexp::Structure::CharClass".'^' => "Character class inversion (all characters except the following)",
  "PPIx::Regexp::Node::Range".'-' => "'-' is character range operator (a-z means all characters from a to z)",
#~   '-' => "Character range (inside character class)", ## 2013-06-20-07:17:11
  
#~ 2013-06-14-06:07:00
#~     '{n}'        => ['Match exactly n times', 'L<perlre/Quantifiers>', ],
#~     '{n,}'       => ['Match at least n times', 'L<perlre/Quantifiers>', ],
#~     '{n,m}'      => ['Match at least n but not more than m times', 'L<perlre/Quantifiers>', ],
#~ 2013-06-14-06:24:37
#~     '{n}'        => 'Match exactly n times',
#~     '{n,}'       => 'Match at least n times', 
#~     '{n,m}'      => 'Match at least n but not more than m times',
#~ 2013-08-03-17:05:44
    '{n}'        => '{n}   Match exactly (%%%%) times',
    '{n,}'       => '{n,}  Match at least (%%%%) times', 
    '{n,m}'      => '{n,m} Match at least (%%%%) but not more than (%%%%) times',
    '{,m}'       => 'ERROR:P', ## \Q{,m}\E
    '(n)'        => [ 'Checks if the numbered capturing group has matched something.', "L<perlre/(1) (2) ...>", ],
    '(<NAME>)'   => ['Checks if a group with the given name has matched something.', "L<perlre/(<NAME>) ('NAME')>", ],
#~     "('NAME')"   => 'Checks if a group with the given name has matched something.',
    "(R)"        => [
        "Checks if the expression has been evaluated inside of recursion.",
        "L<perlre/(R)>",
    ],
    "(Rn)"       => ["Checks if the expression has been evaluated while executing directly inside of the n-th capture group.",'L<perlre/(R1) (R2) ...>'],
    "(R&NAME)"   => [
        "L<perlre/(R&NAME)>",
      "Similar to (R1) , this predicate checks to see if we're executing directly inside of the leftmost group with a given name ",
      '(this is the same logic used by (?&NAME) to disambiguate).',
      'It does not check the full stack, but only the name of the innermost active recursion.',
    ],
    "posix_inside"   => "ERROR warn POSIX syntax [: :] belongs inside character classes in regex; like this [[:word:]]", ## [::][:unknown:]
    "\\C"   => ['Single octet, even under UTF-8.  Not in [].','L<perldebguts/CANY>',],
    
#~ 2013-06-14-19:04:04
        '\l' => ['Lowercase next character.  Not in [].', "L<perlfunc/lcfirst>",, ],
        '\u' => ['Uppercase next character.  Not in [].', "L<perlfunc/ucfirst>" ],
        '\L' => ['Lowercase till \E.  Not in [].', "L<perlfunc/lc>", ],
        '\U' => ['Uppercase till \E.  Not in [].', "L<perlfunc/uc>", ],
        '\Q' => ['quotemeta till \E.  Not in [].', 'Quote (disable) pattern metacharacters till \E.', 'L<perlfunc/quotemeta>', ],
        '\E' => ['Turn off \Q, \L and \U processing.  Not in [].', '', ],
        '\F' => ['Foldcase till \E.  Not in [].', '', ],
#~ 2013-06-14-20:55:08
#~ m{\a[\b]\e
  '\a' => q('\a' (alarm)),
  "\b" => q('\b' (backspace)), ## NOT '\b'
  '\e' => q('\e' (escape)),
  '\f' => q('\f' (form feed)),
  '\n' => q('\n' (newline)),
  '\r' => q('\r' (carriage return)),
  '\t' => q('\t' (tab)),
#~   '\X' => q{Unicode "eXtended grapheme cluster"; leter and diacritic mark;  Not in [].},
  '\X' => q{Unicode "eXtended grapheme cluster"; leter and diacritic mark;  Multiple code points that add up to a single visual character. L<perldebguts/CLUMP>},

#~ 2013-06-16-02:57:43
'check_prefix' => 'Checks to see if the following has matched. ',
mnext_nth_capture => "MATCH the NEXT nth (%%%%) capture group from this position ",
mprev_nth_capture => "MATCH the PREVIOUS nth (%%%%) capture group from this position ",
#~ match_the_capture => 'MATCH THE (%%%%) capture ; MATCH "\\%%%%" aka (in replacement) "$%%%%" ',
match_the_capture => 'MATCH THE (%%%%) capture ; MATCH "\\%%%%" alias (in replacement) "$%%%%" ',
#~ check_the_capture => 'Checks to see if the following has matched.  (%%%%) capture ; MATCH "\\%%%%" aka (in replacement) "$%%%%" ',
#~ check_the_capture => 'Checks to see if the (%%%%) capture has matched; The backreference "\\%%%%" aka (in replacement) "$%%%%" ',
check_the_capture => 'Checks to see if the (%%%%) capture has matched; The backreference "\\%%%%" alias (in replacement) "$%%%%" ',

#~ cnext_nth_capture => "Checks to see if the following has matched. The NEXT nth (%%%%) capture group from this position ",
#~ cprev_nth_capture => "Checks to see if the following has matched. The PREVIOUS nth (%%%%) capture group from this position ",


cnext_nth_capture => "Checks to see if the NEXT nth (%%%%) capture group from this position has matched.",
cprev_nth_capture => "Checks to see if the PREVIOUS nth (%%%%) capture group from this position has matched.",
#~ 'cm_recur_ata'    => 'Checks to see if the following has matched RECURSION at address=%%%%',
'cm_recur_ata'    => 'Checks to see if we are executing directly inside the capture at address=%%%%',
#~ 2013-06-16-04:06:54
#~ check_n_capture   => 'Checks to see if the following has matched. "\g{%%%%}" aka  "(?&%%%%)" aka "(?P>%%%%)"',
#~ check_n_capture   => 'Checks to see if the following capture has matched: "\g{%%%%}" aka  "(?&%%%%)" aka "(?P>%%%%)"',
#~ check_n_capture   => 'Checks to see if we are executing directly inside the capture "\g{%%%%}" aka  "(?&%%%%)" aka "(?P>%%%%)"',
check_n_capture   => 'Checks to see if we are executing directly inside the capture "\g{%%%%}" alias  "(?&%%%%)" alias "(?P>%%%%)"',
'\P'    => ['L<perlrecharclass/Unicode Properties>','TODO warn REPORT BUG for PPIx::Regexp; \PP is \P{Prop} ; for example \PN is \P{Number}; ' ],
'\p'    => ['L<perlrecharclass/Unicode Properties>','TODO warn REPORT BUG for PPIx::Regexp; \pP is \p{Prop} ; for example \pN is \p{Number}; ' ],
'eo_grouping' => 'end of grouping for %%%%',
'dodgy-u-name' => '(/d) dodgy forced to (/u) unicode semantics because \N{} found in pattern',
'dodgy-u-prop' => '(/d) dodgy forced to (/u) unicode semantics because \p{} found in pattern',
'dodgy-u-255'  => '(/d) dodgy forced to (/u) unicode semantics because code point above 255 found in pattern',
#~ 'dodgy-u-rset' => '(/d) dodgy forced to (/u) unicode semantics because L<perlre/(?[ ])> found in pattern',
'dodgy-u-rset' => '(/d) dodgy forced to (/u) unicode semantics because (?[ ]) found in pattern',
); ## our %desc
#~ die scalar %desc; ## 201/512 ## 2013-08-11-18:43:53

