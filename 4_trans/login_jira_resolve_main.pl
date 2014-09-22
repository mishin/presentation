use Modern::Perl;
use charnames ':full';
binmode( STDOUT, ":utf8" );
use HTML::Strip;
use WWW::Mechanize::Firefox;
use File::Slurp;
use File::Basename;
use Try::Tiny;
use English qw(-no_match_vars);
use Carp;

#21543 .. 21549,
for my $jira_num ( 21467 .. 21477 ) {
    load_jira($jira_num);
}

# 21539 .. 21549 #71
# 21467 .. 21477 #70

sub load_jira {
    my $jira = shift;
    my $url  = 'http://jira.gto.intranet.db.com:2020/jira/browse/FRWA-' . $jira;
    my ($firemech) = WWW::Mechanize::Firefox->new( tab => 'current', );
    my %is_download = ();

    try {
        $firemech->get($url);

        # die "foo";
    }
    catch {
        warn "caught error: $_";    # not $@
        given ($_) {
            fill_page($firemech) when /Authorization Required/;

            # say 'String has letters'  when /[a-zA-Z]/;
            default { say "Another arror" }
        }

        # when Authorization Required
    };

    die "Cannot connect to $url\n" if !$firemech->success();

    print "I'm connected!\n";

    my ($retries) = 2;
    while ( $retries--
        and !$firemech->is_visible( xpath => '//*[@id="action_id_5"]' ) )
    {
        sleep 1;
    }
    die "Timeout" unless $retries;

    my ($content) = $firemech->content();

    if ( $firemech->is_visible( xpath => '//*[@id="action_id_5"]' ) ) {
        print "action_id_5 shown!\n";
        $firemech->click(
            { xpath => '//*[@id="action_id_5"]', synchronize => 0 } );

        print "1 click issue-workflow-transition-submit shown!\n";

        ($retries) = 10;
        while (
            $retries--
            and !$firemech->is_visible(
                xpath => '//*[@id="issue-workflow-transition-submit"]'
            )
          )
        {
            sleep 1;
        }
        die "Timeout" unless $retries;
        print "2 show issue-workflow-transition-submit shown!\n";

        $firemech->click_button( id => 'issue-workflow-transition-submit' );
        print "3 issue FRWA-$jira resolved!\n";
    }
    else {
        print "action_id_5 not shown, skip !\n";
    }
}

