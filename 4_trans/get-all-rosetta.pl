use v6;

my $OUTPUT_DIR = 'output';
mkdir $OUTPUT_DIR;

my $table-of-contents = qx[wget -q -O- http://rosettacode.org/wiki/Category:Perl_6];

my $interested = False;
for $table-of-contents.lines {
    $interested = True  if /'pages are in this category, out of'/;
    $interested = False if /'</table>'/;

    if $interested && /'<li><a href="/wiki/' (.*?) '" title="' .*? '">' (.*?) '<' / {
        my $article_name = $0;
        my $name = $1.lc;

        $name.=subst(' ', '_', :g);
        $name.=subst('+', '_plus_', :g);
        $name.=subst('/', '__', :g);
        $name.=subst(/'('|')'/, '', :g);
        $name.=subst(q['], '', :g);
        $name.=subst('_-_', '_', :g);
        $name.=subst('_-', '-', :g);
        $name.=subst('&quot;', '', :g);
        $name.=subst('brain****', 'brainfuck', :g);
        $name.=subst('$', 'USD', :g);
        $name.=subst(',', '', :g);
        die "Unknown characters in $name"
            unless $name ~~ /^ [\w | '-']+ $/;

        my $url = "http://rosettacode.org/mw/index.php?title=$article_name\\&action=edit";
        my $article = qqx[wget -q -O- $url];

        my $PERL6_PREFIX = '&lt;lang perl6>';
        my $PERL6_SUFFIX = '&lt;/lang>';

        my $capturing = False;
        my $content = "";
        my $file_index = 1;
        for $article.lines {
            $capturing = True if /$PERL6_PREFIX/;
            if $capturing {
                $content ~= $_;
            }
            if $capturing && /$PERL6_SUFFIX/ {
                $capturing = False;
                $content.=subst($PERL6_PREFIX, '');
                $content.=subst($PERL6_SUFFIX, '');
                given open "$OUTPUT_DIR/$name-{$file_index++}", :w {
                    .say: $content;
                    .close;
                }
                $content = "";
            }
        }
    }
}
