#!/usr/bin/perl --
use strict;
use warnings;
use utf8;
use Data::Dump qw/ dd pp /;
use charnames (); ## for ord
use HTML::Entities();
use Unicode::UCD();


use Getopt::Long();
use PPI::Document;
use PPIx::Regexp::Dumper;

use vars qw/ $opt_pmshortcut $opt_coverage /;


use utf8;
use Modern::Perl;
use Encode::Locale qw(decode_argv);

 if (-t)
{
    binmode(STDIN, ":encoding(console_in)");
	binmode(STDOUT, ":encoding(console_out)");
	binmode(STDERR, ":encoding(console_out)");
}

Encode::Locale::decode_argv();

unless( caller ){
    Main( @ARGV );
    exit( 0 );
}

sub Main { goto &MainXplain }
sub MainXplain {
    my %opt;
    Getopt::Long::GetOptionsFromArray(
      \@_,
      \%opt,
      q{text|t!},
      q{html!},
      q{dumper|ddr!},
      q{dumpee|dde!},
      q{help|h!},
      q{perlmonks|pmshortcut|pm|p!},
      q{coverage|c!},
    );

    $opt{help} and return print Usage();
    @_         or  return print Usage();

    $opt{text} or $opt{html}=1;

    $opt{coverage} and $opt_coverage=1;

    unshift @_, \%opt;
    goto &Mexplain;
}

sub Usage {
    "
Usage:
    $0
    $0 --help
    $0 --html qr/\\d\\w/u
    $0 --text qr/\\d\\w/u
    $0  \\d\\w  qr/\\d\\w/u s/\\d\\w/rand/gex m/\\d\\w/aax ...

# --html is default
# bare pattern becomes qr//
# remember to quote args according to your shell rules

"
}

sub Mexplain {
    my $args = shift;
    local $opt_pmshortcut = $$args{perlmonks};
    for my $restr ( @_ ){
        my $pdoc = PPI::Document->new( \$restr );
        my @res  = map { PPIx::Regexp->new( $_ ) } @{
            $pdoc->find(
                sub {
                    return 1 if ref($_[1]) =~ m{
PPI::Token::QuoteLike::Regexp
| PPI::Token::Regexp::Match
| PPI::Token::Regexp::Substitute
                    }ix;
                },
            )
            || []
        };
        @res or @res = PPIx::Regexp->new( "qr{$restr}" );
        for my $re ( @res ){
            if( $$args{html} ){
                darnhtml( $re->xplain );
            } else {
                darntext( $re->xplain );
            }
            $$args{dumper} and dd( $re );
            $$args{dumpee} and dd( $re->xplain );
        }
        undef @res; undef $pdoc;
    }
}


sub darntext {
    my( $ref  ) = @_;
    my @lols;
    if( ref $ref eq 'HASH' ){
        my $start = $ref->{start};
        my $con   = $ref->{start_con};
        my $hr    = $ref->{start_hr};
        my $depth = $ref->{depth} || 0;
        my $dent  = '  ' x $depth;
        $_ = "# $dent   $_" for grep { defined $_ } @$start;
        $_ = "$dent    $_" for grep { defined $_ } $con;
        my $conhr = [  grep { defined $_ } $con, $hr ];
        my $chits = $ref->{chits};
        @lols = ( $start, $conhr, $chits );

    } else {
        @lols = $ref;
    }
    for my $lol ( @lols ){
        for my $l ( @$lol ){
            if( ref $l ){
                darntext( $l );
            } else {
                print "$l\n";
            }
        }
    }
    return;
}



sub darnhtml{
    print "<!DOCTYPE html><html><head><title> title </title></head><body>\n";;;
#~ <base href="http://perlmonks.com/">
    &darnhtmltable;
print "</body></html>\n";
}

sub darnhtmltable {
    my( $ref  ) = @_;
    my $depth = 0;
    my @lols;
    if( ref $ref eq 'HASH' ){
        my $start = $ref->{start};
        my $con   = $ref->{start_con};
        my $hr    = $ref->{start_hr};
        $depth    = $ref->{depth} || 0;
        darn_table( $depth, $con, $start , $hr );
        @lols = $ref->{chits};

    } else {
        @lols = $ref;
    }
    for my $lol ( @lols ){
        for my $l ( @$lol ){
            if( ref $l ){
                darnhtmltable( $l );
            } else {
                darn_table( $depth, " ", [$l] );
            }
        }
    }
    return;
}


sub enent {
    my $ret = HTML::Entities::encode_entities( $_[0] );
    $ret =~ s{\[}{&#91;}g;
    $ret =~ s{\]}{&#93;}g;
    $ret =~ s{\|}{&#124;}g;
    return $ret;
}
sub darn_table {
    my( $depth, $con, $desc, $hr ) = @_;
    defined $con or $con= '   ';
    print "<table>\n";
#~     print "<table border=1>\n";
    print "<tr>";
    print "<td><pre>", '  ' x ($depth+3) , enent($con),"</pre></td>\n";
    print '<td>', '&nbsp;' x ($depth+3) , "</td>\n";
    print "<td>";
#~     shift @$desc;;; ### ditch address= TODO make it { address => '' }
#~     shift @$desc;;; ### ditch token xRE:: TODO makeit { token => [ '','', ] }

    my( @three ) = splice @$desc, 0, 3; ## make it a tooltip?!??!??!?
#~     unshift @$desc, '# '.join ' ; ', @three;
    unshift @$desc, 3==@three ? ( '# '.join ' ; ', @three ) : ( @three );

## TO?DO? http://www.thecssninja.com/css/css-tree-menu# Pure CSS collapsible tree menu | The CSS Ninja - All things CSS, JavaScript & HTML
    local$_; for(@$desc){
        if( m{\sat\saddress=\s*(\S+)} ){
            $_ = sprintf q{<a href="#%s">%s</a>}, enent("$1"), enent($_);
        } elsif( m{\baddress=\s*(\S+)} ){
            $_ = sprintf q{<a name="%s">%s</a>}, enent("$1"), enent($_);
#~             $_ = sprintf q{<a name="%s"></a>}, enent("$1"), ;
#~         } elsif( m{L<(.*)>} ){
#~         } elsif( m{L<{1,3}(.*)>{1,3}} ){
#~         } elsif( m{L<+\b(.*)\b>+} ){
#~         } elsif( m{L<++(.*?)>+} ){
#~         } elsif( m{L(?:<<<|<)(.*?)(?:>>>|>)}x ){
        } elsif( m{L(?:<<<|<)(.*[^>])(?:>>>|>)}x ){
            my $odoc = $1;
            $odoc =~ s/^\s+|\s+$//g;
            my $doc = enent($odoc);
#~             $doc =~ s{^(.+?)/(.+)$}{$1#$2};
            if( my( $one, $frag ) = $doc =~ m{^(.+?)/(.+)$} ){
                $frag =~ s/\s/-/g;
                $frag =~ s{\[}{%5b}g;
                $frag =~ s{\]}{%5d}g;
                $frag =~ s{\|}{%7c}g;
                $doc = "$one#$frag";
            }
#~             my $href = "http://perlmonks.com/?node=doc://$doc";
#~             $href = enent($odoc) if $odoc =~ m{^http://}i;
#~             $_ = qq{<a href="$href">}.enent($_).'</a>';
#~

            my $href = "http://perlmonks.com/?node=doc://$doc";
            if( $odoc =~ m{^http://}i ){
                my( $oleft, $oright ) = split /\|/, $odoc;
#~                 $href = enent($odoc) ;
                $href = enent($oleft) ;
                $_ = qq{<a href="$href">}.enent($_).'</a>';
            } else {
                if( $opt_pmshortcut ){
                    $_ = "[doc://$doc|".enent($_)."]";
                } else {
                    my $href = "http://perlmonks.com/?node=doc://$doc";
                    $href = enent($odoc) if $odoc =~ m{^http://}i;
                    $_ = qq{<a href="$href">}.enent($_).'</a>';
                }
            }

#~         } elsif( m{^\s*.*?(?:\bdie\b|\bwarn)}i ){
#~             $_ = '<b>'.enent($_).'</b>';
        } else {
            $_ = enent($_);
        }
        $_ = "<b>$_</b>" if /\bdie\b|\bwarn/i;
    }
    if( @$desc>1 and $desc->[1] !~ /^#/ ){ $_="# $_" for @$desc; }

    $con and $con=~/\x22,\s*$/ and push @$desc, '#<b>'.enent($con).'</b>';
    $hr and push @$desc, $hr;
    print map { "$_<br>\n" } @$desc;
    print "</td></tr></table>\n";
}

#~ package PPIx::Regexp::Element; ## dumb
sub PPIx::Regexp::Element::xplain_desc {
    goto &PPIx::Regexp::Node::xplain_desc
}
#~ package PPIx::Regexp::Node; ## dumb
#~ 2013-07-23-05:37:02 dumb for umlclass.bat
{ package PPIx::Regexp::Element;     package PPIx::Regexp::Node;     package PPIx::Regexp::Structure::Capture;     package PPIx::Regexp::Structure::CharClass;     package PPIx::Regexp::Structure::Code;     package PPIx::Regexp::Structure::Modifier;     package PPIx::Regexp::Structure::Quantifier;     package PPIx::Regexp::Structure::Replacement;     package PPIx::Regexp::Structure;     package PPIx::Regexp::Token::Backreference;     package PPIx::Regexp::Token::Backtrack;     package PPIx::Regexp::Token::CharClass::POSIX;     package PPIx::Regexp::Token::CharClass::Simple;     package PPIx::Regexp::Token::Code;     package PPIx::Regexp::Token::Comment;     package PPIx::Regexp::Token::Condition;     package PPIx::Regexp::Token::Delimiter;     package PPIx::Regexp::Token::Greediness;     package PPIx::Regexp::Token::GroupType::Modifier;     package PPIx::Regexp::Token::GroupType::Switch;     package PPIx::Regexp::Token::Interpolation;     package PPIx::Regexp::Token::Literal;     package PPIx::Regexp::Token::Modifier;     package PPIx::Regexp::Token::Operator;     package PPIx::Regexp::Token::Quantifier;     package PPIx::Regexp::Token::Recursion;     package PPIx::Regexp::Token::Structure;     package PPIx::Regexp::Token::Unknown;     package PPIx::Regexp::Token::Whitespace;     package PPIx::Regexp::Token;     package PPIx::Regexp; package main; }

our %desc; BEGIN { require '_desc.pl'; }
sub PPIx::Regexp::Node::xplain_desc {
    my @ret = &PPIx::Regexp::Node::xplain_desc_real;
#~     @ret and warn "# @_ => ",pp(\@ret), "\n";
    if( @ret ){  ## successfull descriptions, stuff we actually used
        my $self = shift;
#~         warn "# $self\n", pp( \@_ ), " => ", pp(\@ret), ",\n\n";
        $opt_coverage and warn "# $self\n", pp( \@_ ), " => ", pp(\@ret), ",\n\n";
    }
    return wantarray ? @ret : join('', @ret );
}
sub PPIx::Regexp::Node::xplain_desc_real {
#~ sub PPIx::Regexp::Node::xplain_desc {
#~     warn "@_\n"; ## grogelinginadequate
    my( $self, $key , @repos ) = @_;
    %desc or require '_desc.pl';

    if( my $ret = $desc{ $key }  ){
        if( ref $ret ){
            return @$ret;
        } else {
            my $ix = 0; ## yick
            @repos and $ret =~ s/%%%%/my$r=$repos[$ix++]; defined $r?$r:'%%%%'/ge;;
            return $ret;
        }
    }
    return;
}

sub PPIx::Regexp::Element::xplain_start {
    goto &PPIx::Regexp::Node::xplain_start
}
sub PPIx::Regexp::Node::xplain_start {
    my( $self, %args ) = @_;
    my $depth = $args{depth} || 0;
    my @ret;

    push @ret, 'address='. $self->address;
    push @ret, $self->xplain_desc( ref $self );;
    push @ret, $self->xplain_perl_version;;
#~     push @ret, 'address='. $self->address;

    if( defined( my $ord = eval { $self->ordinal } ) ){
#~         my $unicode10 = Unicode::UCD::charinfo( $ord )->{unicode10} ;
        my $unicode10 = unicode10( $ord );
#~         $unicode10  or warn pp( {crapola => Unicode::UCD::charinfo( $ord ) } ); ## 2013-08-18-04:12:49
        push @ret,
#~             join ' aka ',
            join ' alias ',
                "ordinal= ord( chr( $ord ) )",
                sprintf('\\N{U+%04.4X}', $ord ),
                sprintf('\%03o', $ord ),
                ( $unicode10  ? $unicode10 : () ),
                chr( $ord ),
            ;;;;;;;;;
    }


    if( not $args{no_mods} ){
        if( $self->xmods_susceptible ){
            push @ret, xplain_modifiers( $self );
        }

        push @ret, 'is_case_sensitive' if eval { $self->is_case_sensitive };
    }


    my $con       = eval { $self->{content} };
    my $xmods     = eval { $self->xmods };
    my $semantics = eval { $$xmods{match_semantics} };

#~ msixpodualgcer
    my @cons      = grep { $$xmods{$_} } qw{ m s i x p o d u a l g c e r };
    if( $con and not $args{no_con_desc} ){
        @cons = map {  $con.$_ } grep { defined $_ } @cons, $semantics, '';;
#~         push @cons, ref($self).$con; ## TODO REFUDGE
#~         warn pp { con => $con, semantics => $semantics, cons => \@cons };
#~ 2013-08-11-19:51:28
#~         warn "\n\n", pp( [ qw/FUDGE REFUDGE /, con => $con, semantics => $semantics, cons => \@cons ],[]),"\n\n";
        my @desc;
        for my $con ( @cons ){
            @desc = $self->xplain_desc( $con );;;
            if( @desc ){
                last;
            }
        }
        @desc and push @ret, @desc;
    }
    return \@ret;
}

sub PPIx::Regexp::Element::address { goto &PPIx::Regexp::Node::address }
our $__rootaddr = 0;
sub PPIx::Regexp::Node::address {
    my( $self, %args ) = @_;
    my $addr = $$self{_xaddr} || '';
    return $addr if $addr;

    my @pops =  $self;
    my $prev = $self;
    while( $prev = $prev->parent ){
        unshift @pops, $prev;
    }
    my $root = shift @pops;
    my $rootaddr = eval { $root->{__rootaddr}||=++$__rootaddr } ;
    $rootaddr  ||= sprintf(' 0+%x',$root);
#~     return join '',
    $addr = join '',
        '/'.$rootaddr,
        ( map {
            my ( $method, $inx ) = $_->_my_inx();
            $method = uc$1 if $method =~ m{^(.)};
            "/$method$inx";
        } @pops ), ' ';
#~     $$self{_xaddr}=$addr;
    return $addr;
}


sub PPIx::Regexp::xplain {
    my( $self, %args ) = @_;
    $self->{xfailures}=0;
    $self->xmods_propagate;
    my $depth = $args{depth} || 0;
    my @ret;
    my $ret = { depth => $depth, start => [@ret], chits => \@ret };
    undef @ret;

    for my $child ( eval { $self->children } ){
        if( eval{ $child->children } ){ #$haskids
            push @ret, $child->xplain( %args, depth => $depth + 3 );
        } else {
            push @ret, $child->xplain( %args, depth => $depth + 2 ); ## GRRRRRR
        }
    }


    { ## the_ter_rible xfailures

        my @ter = (
            "my \$regstr = join '', ",
        );;;

        my $source = $self->source  ;
        my $sourceref = ref $source ;
        $sourceref = '' if not defined $sourceref;
        $source = '' if not defined $source;

        if( $source ){
            my $rr = $self->xplain_desc("the_regex");
            if( $sourceref ){
                $rr .= "($sourceref)";
                my $con = $source->content;
                $con or $con = $self->content;;
                $con or $con = "";
                $con or die dd $self;
                $source = $con;
            }
            $rr .=":\n\n";
            $rr .= $source;
            $rr .="\n\n" . $self->xplain_desc("matches_as_follows")."\n";
            $rr =~ s{^}{# }gm;
            push @ter, split /\n/, $rr;
        }

    #~     if( my $fail = eval { $self->failures } ){
        if( my $totalfail = eval { $self->failures + $self->{xfailures} } ){
            push @ter, pp( $self );
    #~         push @ret,"# failures=$fail";
            my $fail = eval { $self->failures } ||0;
            my $xfail = eval { $self->{xfailures} } ||0;
            push @ter,"# failures=$totalfail == fail($fail) + xfail($xfail)";
            push @ter, $self->xplain_desc("parsing_failures");

        }

        push @ter, join '', "#r: ", join ' / ', grep { defined $_ } ref( $self ), $sourceref;
        push @ter, join '', "#r= ",Data::Dump::quote( $self->content );
        push @ter, '#  ';
        unshift @{ $$ret{start} }, @ter;
    }
    if( my(@why) = xdodgy_unicode_override( $self ) ){
        push @{$ret[-1]{start}}, map { $self->xplain_desc($_) } @why; ## yick
    }
    push @ret, { depth => $depth, start => [";;;;;;;;;;\n\n"], };
    return $ret;;
} ## end of sub PPIx::Regexp::xplain

sub PPIx::Regexp::Node::parent_modifiers {
    my( $self ) = @_;
    my $root = $self->root;
    my $kid  = $root->last_element;
    return eval { $kid->modifiers };
}

sub PPIx::Regexp::Element::root {
    my( $self ) = @_;
    my $root = $self;
    while( my $newp = $root->_parent ){
        $root = $newp ;
    }
    return $root;
}


sub PPIx::Regexp::Element::xplain_perl_version {
    my( $self ) = @_;
    my @ret;
    if( my $val = eval { $self->perl_version_introduced } ){
#~         if ( $val ne '5.000' ){
        if ( $val > 5.006 ){ ## otherwise its waaay too much :)
            push @ret, "perl_version_introduced=$val";
        }
    }
    if( my $val = eval { $self->perl_version_removed } ){
        push @ret, "warning perl_version_removed =$val";
    }
    return @ret;
}

sub PPIx::Regexp::Structure::Replacement::xplain {
#~     push @_ , ( in_replacement => 1, hr_length => 6 );
    push @_ , ( in_replacement => 1, );
    goto &PPIx::Regexp::Structure::xplain;; ## cause it deletes start_con
}


sub PPIx::Regexp::Structure::xplain {
#~     push @_, ( hr_length => 6 );
    my $ret = &PPIx::Regexp::Node::xplain;
    delete $ret->{start_con};
#~     $$ret{start_hr} = join '', "# ", '-' x  6 ;
    $$ret{start_hr} = join '', "# ", '-' x  ( 2 * $$ret{depth} ) ;
    return $ret;
}

sub PPIx::Regexp::Structure::Quantifier::xn_comma_m { ## n_comma_m {n,m}
    my( $self ) = @_;
    my( $n, $comma, $m ) = map { eval { $_->{content} } } $self->children;
    my @ncm = ('n',',','m'); # {n,m}
    defined $n or $ncm[0]='';
    defined $comma or $ncm[1]='';
    defined $m or $ncm[2]='';
    return $n, $comma, $m , @ncm;
}
sub PPIx::Regexp::Structure::Quantifier::xplain {
    my( $self ) = @_;
    push @_, ( no_con_desc => 1 ); #jic
    my $ret = &PPIx::Regexp::Token::Quantifier::xplain;
    my( $n, $comma, $m , @ncm ) = $self->xn_comma_m;

    push @{$$ret{start}},
        $self->xplain_desc( join('', '{',@ncm,'}'), 'n', 'm' ),
        $self->xplain_desc( join('', '{',@ncm,'}'), $n, $m ),
        'L<perlre/Quantifiers>',
    ;;;;;;;

    return $ret;
}

sub PPIx::Regexp::Token::Quantifier::xplain {
    my( $self, %args ) = @_;
    my $ret   = $self->PPIx::Regexp::Node::xplain( %args, no_elements => 1 );
    my $pp = $self->preceding_pattern_address;;
    my $ns = $self->next_sibling;
    my $nsc = eval { $ns->{content} };
    my $nsgreedy = eval { $ns->isa("PPIx::Regexp::Token::Greediness") };
    if( not($nsgreedy) or ( $nsgreedy and $nsc ne '?') ){
        push @{$$ret{start}}, $self->xplain_desc('most_possible');
    }elsif( $nsc eq '?'){
        push @{$$ret{start}}, $self->xplain_desc('least_possible');
    }

    my $ps = $self->previous_sibling;
    if( eval { $ps->isa("PPIx::Regexp::Structure::Capture") } ){
        my $number   = eval { $ps->number } ;
        my $name     = eval { $ps->name };
        my $only     = "";
        $number and $only .= qq{"\$$number"};
        $name   and $only .= qq{ or "\$+{$name}"};;
        push @{$$ret{start}}, $self->xplain_desc('only_last_n', $only );
    }
    push @{$$ret{start}},
        $pp ?  $self->xplain_desc( 'm_pat_at_add' ) . $pp
            :  $self->xplain_desc( 'quant_f_not' ) ;;;

#~     $$ret{start_hr} = join '', "# ", '-' x  ( 2 * $$ret{depth} ) ;
#~     $nsgreedy or $$ret{start_hr} = join '', "# ", '-' x  ( 2 * $$ret{depth} ) ;
    $$ret{start_hr} = $nsgreedy  ? '' : join '', "# ", '-' x  ( 2 * $$ret{depth} ) ;
    $ret;
}




sub PPIx::Regexp::Token::Greediness::xplain {
    my( $self, %args ) = @_;
    $args{no_con_desc}=1;
    my $ret   = $self->PPIx::Regexp::Node::xplain( %args );
    push @{$$ret{start}},  $self->xplain_desc( ref($self).$self->{content} ); ## grr
    push @{$$ret{start}},  $self->xplain_desc( 'm_pat_at_add' ) . $self->preceding_pattern_address;
    $ret;
}

sub PPIx::Regexp::Element::preceding_pattern_address {
    my( $self, %args ) = @_;
#~     return eval { $self->previous_sibling->address }; ## its always this isn't it? TODO figure it out
    ## bug, for greediness previous_sibling is quantifier, so go again
    my $ps = $self->previous_sibling;
    if( $ps->isa('PPIx::Regexp::Token::Quantifier' ) ){
        $ps = $ps->previous_sibling;
    }
    return eval { $ps->address };
}

sub PPIx::Regexp::Structure::Code::xplain {
    my( $self, %args ) = @_;
    $args{no_elements}=1;
    my $ret = $self->PPIx::Regexp::Node::xplain( %args );
    my $type = $self->type->content; ## PPIx::Regexp::Token::GroupType::Code
    my $key = "(${type}{ code })";
    push @{$$ret{start}},  $self->xplain_desc( $key );
    return $ret;
}


sub PPIx::Regexp::Token::Structure::xplain {
    push @_, ( no_elements => 1 , no_mods => 1, fudgeme => 0, );
    goto &PPIx::Regexp::Node::xplain;
}

sub PPIx::Regexp::Token::Code::xplain {
    my( $self, %args ) = @_;
    $args{no_elements} = 1 if $self->ancestor_isa('PPIx::Regexp::Structure::Replacement');
    return $self->PPIx::Regexp::Node::xplain( %args );
}

#~ 2013-06-14-05:22:25
#~ TO??DO?? unicharproptoregexrange-unicode-regex-range-character-class-ucd.pl
sub PPIx::Regexp::Token::CharClass::Simple::xplain {
    my( $self , %args ) = @_;
    $args{no_mods}=1;
    my $ret = $self->PPIx::Regexp::Node::xplain( %args );
    if( my $con = eval{$self->{content}} ){
        if( $con =~ /^\\[pP]\{/ ){
            push @{$$ret{start}}, "L<perluniprops/$con>";;; ## autogenerated
        } else {
            push @{$$ret{start}}, "L<perlrecharclass/$con>";;;
            push @{$$ret{start}}, "L<perlrebackslash/$con>";;;
        }
        push @{$$ret{start}}, xplain_modifiers( $self, { GONERS => [qw/ i /] } );
    }

    $$ret{start_hr} = join '', "# ", '-' x  ( 2 * $$ret{depth} ) ;
    return $ret;
}

sub PPIx::Regexp::Token::CharClass::POSIX::xplain {
    push @_, ( no_con_desc => 0 );
    goto &PPIx::Regexp::Token::CharClass::Simple::xplain;
}

sub PPIx::Regexp::Structure::CharClass::xplain {
    my( $self ) = @_;
    push @_, ( no_con_desc => 1 );
    my $ret = &PPIx::Regexp::Structure::xplain;
    if( $self->children > 1 ){
        my $colons = join '', map { $_->content } $self->schild(0), $self->schild(-1) ;
        if( $colons eq '::'){
    #~     if( $colons eq '::' and $self->children > 1 ){
            push @{$$ret{start}}, $self->xplain_desc('posix_inside');
        }
    }
    return $ret;
}

sub PPIx::Regexp::Token::Interpolation::xplain {
#~     goto &PPIx::Regexp::Token::xplain ## start_content
    my( $self ) = @_;
    my $ret = &PPIx::Regexp::Token::xplain;
    my $key = $self->ancestor_isa('PPIx::Regexp::Structure::Replacement')
              ? 'PPIx::Regexp::Token::Interpolation-Substitution'
              : 'PPIx::Regexp::Token::Interpolation-Regexp' ;
    push @{$$ret{start}}, $self->xplain_desc( $key );
    return $ret;
}
sub PPIx::Regexp::Token::Literal::xplain { goto &PPIx::Regexp::Token::xplain; }
sub PPIx::Regexp::Token::xplain {
    my( $self, %args ) = @_;
    my $ret   = $self->PPIx::Regexp::Node::xplain( %args, no_elements => 1, no_mods => 0, );
    my $con   = $self->{content};

    if( $con =~ m{\\g\d+} ){
        push @{$$ret{start}}, (
            "TODO warn REPORT BUG \\g10 UNRECOGNIZED AS A PPIx::Regexp::Token::Backreference  misparsed as PPIx::Regexp::Token::Literal (\\g10 is not \\10, can't be treated as octal)",
            $self->xplain_desc('n_exist_group')
        );
    }
    {   no warnings 'uninitialized';

        if( $self->ancestor_isa('PPIx::Regexp::Structure::CharClass') and $con =~ m{^\\\d+$} and eval { $self->next_sibling->{content} eq '-' } ){
            push @{$$ret{start}}, 'ERROR warn TODO REPORTBUG octals NOT PARSED AS PPIx::Regexp::Node::Range';
        }
    }
    return $ret;
}

sub PPIx::Regexp::Token::Recursion::xplain {
#~     my( $self )  = @_;
#~     my $ret      = &PPIx::Regexp::Node::xplain;

    my( $self , %args ) = @_;
##  guessing ## $ perl -le " warn int m{(lc(?i:(?1)|end)+)}smx for qw/ lcend lclcend lclcEND lcLCend  /"
#~ $ perl -e " print int m{(lc(?i:(?1)|end)+)}smx for qw/ lcend lclcend lclcEND lcLCend  /"
#~ 1110
    $args{no_mods}=1;
    my $ret      = $self->PPIx::Regexp::Node::xplain( %args );
    my $absolute = eval { $self->absolute } ;
    my $number   = eval { $self->number } ;

    if( $number ){
        my $padd = eval{ $self->find_recursion_number( $absolute )->address };
        if(  my ( $direction ) = $number =~ /^([\-\+])/ ){
            my $desckey = $direction eq '+' ? 'mnext_nth_capture' : 'mprev_nth_capture';
            push @{$$ret{start}}, $self->xplain_desc( $desckey, $number );
        }
        $absolute and push @{$$ret{start}}, $self->xplain_desc('match_the_capture', ($absolute) x 3 );
        if( $padd ){
            push @{$$ret{start}}, $self->xplain_desc('m_recur_ata').$padd;
        } else {
            push @{$$ret{start}}, $self->xplain_desc('n_exist_group')
        }
    }

    if( my $name = eval { $self->name } ){
        push @{$$ret{start}}, 'name='.$name.join(' alias ','', '"(?&'.$name.')"', '"(?P>'.$name.')"' );
        my $padd = eval{ $self->find_recursion_number( $name )->address };
        if( $padd ){
            push @{$$ret{start}}, $self->xplain_desc('m_recur_ata').$padd;
        } else {
            push @{$$ret{start}}, $self->xplain_desc('n_exist_group')
        }
    }

    return $ret;
}

sub PPIx::Regexp::Token::Backreference::xplain {
    my( $self )  = @_;
    push @_, ( no_mods =>  0 ); ## susceptible except /x
    my $ret      = &PPIx::Regexp::Node::xplain;
    my $absolute = eval { $self->absolute } ;
    my $number   = eval { $self->number } ;

    if( $number ){
        my $padd = eval{ $self->find_recursion_number( $absolute )->address };
        if(  my ( $direction ) = $number =~ /^([\-\+])/ ){
            my $desckey = $direction eq '+' ? 'mnext_nth_capture' : 'mprev_nth_capture';
            push @{$$ret{start}}, $self->xplain_desc( $desckey, $number );
        }
        $absolute and push @{$$ret{start}}, $self->xplain_desc('match_the_capture', ($absolute) x 3 );
        if( $padd ){
            push @{$$ret{start}}, $self->xplain_desc('m_recur_ata').$padd;
        } else {
            push @{$$ret{start}}, $self->xplain_desc('n_exist_group');;
        }
    }

    if( my $name = eval { $self->name } ){
        push @{$$ret{start}}, 'L<perlre/(?P=NAME)>';
#~         push @{$$ret{start}}, 'L<perldebguts/NREF>'; ## TODO?? NREFF? NREFFL? NREFFU? NREFFA? unlinkable
        push @{$$ret{start}}, 'MATCH  "\\g{'.$name.'}"'.join(' alias ','', '"\\k<'.$name.'>"', '"(?&'.$name.')"', '"(?P>'.$name.')"' );

        if( my $capture = $self->find_recursion_number( $name ) ){
            push @{$$ret{start}}, $self->xplain_desc('m_recur_ata').$capture ->address;
        } else {
            push @{$$ret{start}}, $self->xplain_desc('n_exist_group');
        }
    }

    return $ret;
}

sub PPIx::Regexp::Token::Condition::xplain {
#~     push @_, ( no_con_desc => 0 ); ## want it, its not no doubling
#~     my( $self )  = @_;
#~     my $ret      = &PPIx::Regexp::Node::xplain;
    my( $self , %args ) = @_;
    $args{no_mods}=1; ## 2013-08-05-04:38:50
    delete $args{no_con_desc}; ## 2013-08-11-19:19:21
    my $ret      = $self->PPIx::Regexp::Node::xplain( %args );
    my $absolute = eval { $self->absolute } ;
    my $number   = eval { $self->number } ;
    my $name     = eval { $self->name } ;
    my $con      = eval { $self->content } ;
    my $check_prefix = $self->xplain_desc('check_prefix');

    if( my( $left, $right) = $con =~ m{
^
\(
    ( # $1
        <
    |
        '
    |
        R\&?
    )? ## first alteration is optional
    ( # $2
        [^\)]*
    )
\)
}x ){
        my $gotr = defined $left ? ( $left =~ /^R/ ) : 0 ;
        my $desc = join '',
            ( $gotr ? $left : () ),
            ( $number ? 'n' : () ),
            ( $name ? 'NAME' : () ),
        ;;;;;;;;;;;;;

        if($name and not $gotr) {
            $desc = "(<$desc>)" ;
        } else {
            $desc = "($desc)";
        }
        push @{$$ret{start}}, $self->xplain_desc( $desc );
    }

    if( $number ){
        my $padd = eval{ $self->find_recursion_number( $absolute )->address };
#~ 2013-08-11-20:40:29 apparently this will never happen because (?(1)) is legal but (?(-1)) is not legal
        if(  my ( $direction ) = $number =~ /^([\-\+])/ ){
            my $desckey = $direction eq '+' ? 'cnext_nth_capture' : 'cprev_nth_capture';
            push @{$$ret{start}}, $self->xplain_desc( $desckey, $number );
        }
        $absolute and push @{$$ret{start}}, $self->xplain_desc('check_the_capture', ($absolute) x 3 );
        if( $padd ){
            push @{$$ret{start}}, $self->xplain_desc('cm_recur_ata', $padd );
        } else {
            push @{$$ret{start}}, $self->xplain_desc('n_exist_group')
        }
    }

    if( $name ){
        push @{$$ret{start}}, 'L<perlre/(?(condition)yes-pattern)>';
#~         push @{$$ret{start}}, $check_prefix.'"\\g{'.$name.'}"'.join(' aka ','', '"(?&'.$name.')"', '"(?P>'.$name.')"' );
        push @{$$ret{start}}, $self->xplain_desc('check_n_capture', ($name) x 3 );

        if( my $capture = $self->find_recursion_number( $name ) ){
            push @{$$ret{start}}, $self->xplain_desc('cm_recur_ata', $capture ->address );
        } else {
            push @{$$ret{start}}, $self->xplain_desc('n_exist_group');
        }
    }
    if( $con eq '(DEFINE)'){
## grr #~ Can't locate object method "find" via package "PPIx::Regexp::Token::Condition"
#~         if( not $self->find(sub{ return 1 if $_[0]->isa('PPIx::Regexp::Structure::NamedCapture'); return 0; }, ) ){
#~         if( not $self->find_first(sub{ return 1 if $_[0]->isa('PPIx::Regexp::Structure::NamedCapture'); return 0; }, ) ){
### belongs in parent?
        if( not $self->parent->find_first(sub{ return 1 if $_[0]->isa('PPIx::Regexp::Structure::NamedCapture'); return 0; }, ) ){
            push @{$$ret{start}}, $self->xplain_desc('(DEFINE)pointless');
        }
    }
    return $ret;
} ## end of fudgy sub PPIx::Regexp::Token::Condition::xplain


sub PPIx::Regexp::Element::find_recursion_number  {
    goto &PPIx::Regexp::Node::find_recursion_number
}

sub PPIx::Regexp::Node::find_recursion_number {
    my( $self, $n ) = @_;

    $self->root->find_first( sub {
        my $type = $_[1]->isa('PPIx::Regexp::Structure::NamedCapture')
                || $_[1]->isa('PPIx::Regexp::Structure::Capture')
                || $_[1]->isa('PPIx::Regexp::Token::GroupType::NamedCapture')
        ;;;
        if( $type ){
            if( my $number =  eval{$_[1]->number} ){
                return 1 if $number eq $n ;## found a good one
            }
            if( my $name =  eval{$_[1]->name} ){
                return 1 if $name eq $n ;## found a good one
            }
        }
        return 0; ## keep searching
    }, );
}

sub PPIx::Regexp::Structure::Capture::xplain {
    my( $self )  = @_;
    my $ret      = &PPIx::Regexp::Node::xplain;
    my $number   = eval { $self->number } ;
    my $name     = eval { $self->name };
    $name   and $name = 'name='.$name.join(' alias ','', '"\\g{'.$name.'}"', '"\\k<'.$name.'>"', '"(?&'.$name.')"', '"(?P>'.$name.')"' , qq{"\$+{$name}"} );;
    $number and $number = 'number='.$number.' alias "$'.$number.'" or "\\'.$number.'"';
    $number and push @{$$ret{start}}, $number ;
    $name   and push @{$$ret{start}}, $name;
    delete $ret->{start_con};
    $$ret{start_hr} = join '', "# ", '-' x  ( 2 * $$ret{depth} ) ;

## the fudgyness goes on
    $number and push @{$ret->{chits}[-1]{start}}, $self->xplain_desc('eo_grouping', $number );
    $name   and push @{$ret->{chits}[-1]{start}}, $self->xplain_desc('eo_grouping', $name );
    return $ret;
}

sub PPIx::Regexp::Element::xplain { goto &PPIx::Regexp::Node::xplain }
sub PPIx::Regexp::Node::xplain {
    my( $self, %args ) = @_;
    my $depth = $args{depth} || 0;
    my $start = $self->xplain_start( %args );

    my @chits;
    my $ret = { depth => $depth, start => $start , chits => \@chits };
    $$ret{start_hr} = join '', "# ", '-' x  ( $args{hr_length} ||  66 );
    $$ret{start_con} = Data::Dump::pp( $self->content ).',';

    if( $args{no_elements} ){
        delete $$ret{chits};
        return $ret;
    }

    for my $start ( eval { $self->start } ){
        push @chits, $start->xplain( %args, depth => $depth );
    }

    for my $type ( eval { $self->type } ){
        if( my @exp = $type->xplain( %args, depth => $depth + 1 ) ){
            push @chits, @exp;
        }
    }

    for my $child ( eval { $self->children } ){
        if( eval{ $child->children } ){ #$haskids
            push @chits, $child->xplain( %args, depth => $depth + 3 );
        } else {
            push @chits, $child->xplain( %args, depth => $depth + 2 );
        }
    }

    for my $finish ( eval { $self->finish } ){
        push @chits, $finish->xplain( %args, depth => $depth );
    }

    if( not @$ret{chits} ){
        delete $$ret{chits};
    }

    return $ret;

} ## end of sub PPIx::Regexp::Node::xplain


sub PPIx::Regexp::Structure::Modifier::xplain {
    push @_, no_mods => 1;
    goto &PPIx::Regexp::Structure::xplain
}

sub PPIx::Regexp::Token::GroupType::Modifier::xplain {
    my( $self , %args )  = @_;
    my $ret      = $self->PPIx::Regexp::Node::xplain( %args, no_elements => 1 , no_mods => 0 );
    if( my @mods = eval {  $self->modifiers } ){ ## yick
        my %mods = @mods; %mods and push@{$$ret{start}}, join(' ', 'mods(', map { " $_ = $mods{$_} "} keys%mods ).')';;
        my @exp = xplain_modifiers( $self );
        @exp and push @{$$ret{start}}, @exp;
    }
    ##fudgy
    return $ret;
}

sub PPIx::Regexp::Token::Modifier::xplain {
    my( $self , %args ) = @_;
    delete $args{no_mods};
    my $ret   = $self->PPIx::Regexp::Node::xplain( %args );
    push @{$$ret{start}}, xplain_modifiers( $self );
    my $con = eval{ $self->{content}};
    if( length $con and $self != $self->root->modifier  and $con =~ m{^\(.+\)$}sm ){
        push @{$$ret{start}}, $self->xplain_desc( "token_modifier_propagates_right" );; ## 2013-07-30-03:02:24 TODO MORE RET KEYS
    }
    $ret;
}


sub PPIx::Regexp::Token::Operator::xplain {
    my( $self , %args ) = @_;
    $args{no_elements} = 1;
    $args{no_mods} = 1;
    $args{no_con_desc} = 1;
    my $ret   = $self->PPIx::Regexp::Node::xplain( %args );
    my @desc;
    if( @desc = eval { $self->xplain_desc( ref($self->parent). $self->{content} ) } )
    {
        push @{$$ret{start}},  @desc ;
        my $refpc = ref($self->parent). $self->{content};
        my ( $method, $inx ) = $self->_my_inx();

        if( $refpc eq "PPIx::Regexp::Structure::CharClass".'^' and $method ne 'type' ){
            push @{$$ret{start}},  "ERROR warn TODO REPORT BUG THIS IS LITERAL ^ NOT NEGATION";
        }
        if( $refpc eq "PPIx::Regexp::Structure::CharClass".'^'
            and $method eq 'type'
            and eval { $self->parent->child( 0 )->content eq ']' }
        ){
            push @{$$ret{start}},  "ERROR warn TODO REPORT BUG A LONE ^ IN A CHARCLASS IS A IS LITERAL ^ NOT NEGATION";
        }
    } elsif( $self->ancestor_isa('PPIx::Regexp::Structure::RegexSet') and @desc = eval { $self->xplain_desc( 'regexset.'.$self->{content} ) } )
    {
        push @{$$ret{start}}, @desc ;
    } elsif( @desc = eval { $self->xplain_desc( $self->{content} ) } )
    {
        push @{$$ret{start}}, @desc ;
    }

    return $ret;
}

sub PPIx::Regexp::Element::ancestor_isa {
    my( $self, $type ) = @_;
    my $root = $self;
    while( my $newp = $root->_parent ){
        return 1 if $type eq ref $newp;
        $root = $newp ;
    }
    return 0;
}


sub PPIx::Regexp::Token::Backtrack::xplain {
    my( $self ) = @_;
    push @_, ( no_con_desc => 1 ); ## no doubling
    my $ret   = &PPIx::Regexp::Node::xplain;
    my( $con ) = $ret->{start_con} =~ m{ \( ( [^\)]+ ) \) }x;
    my( $verb, $arg ) = split /\:/, $con;
    if( $verb and $arg ){
        if( my @desc = $self->xplain_desc( "($verb:NAME)" ) ){
            push @{$$ret{start}}, @desc;
        } else {
            push @{$$ret{start}}, $self->xplain_desc( "(*UNKNOWN:NAME)", $verb, $arg ) ;
        }
    }
    if( $verb ){
        if( my @desc = $self->xplain_desc( "($verb)" ) ){
            push @{$$ret{start}}, @desc;
        } else {
            push @{$$ret{start}}, $self->xplain_desc( "(*UNKNOWN)", $verb ) ;
        }
    }
    $ret;
}


sub PPIx::Regexp::Token::Unknown::xplain {
    my( $self ) = @_;
    my $ret = &PPIx::Regexp::Node::xplain;
    push @{$$ret{start}},  $self->xplain_desc( ref($self).$self->{content} ); ## grr
    if( '?' eq $self->{content}  ){
        push @{$$ret{start}},  $self->xplain_desc( 'quant_f_not' ); ## meh
    }
    return $ret;
}

sub PPIx::Regexp::Token::GroupType::Switch::xplain {
    push @_, ( no_con_desc => 1 ); ## no doubling
    goto &PPIx::Regexp::Node::xplain;
}
sub PPIx::Regexp::Token::Delimiter::xplain {
    push @_, ( no_con_desc => 1 ); ## s\\\sex  \ with parent modifiers becomes \s
    goto &PPIx::Regexp::Node::xplain;
}

#~ $ perl -Mre=debug -wle " qr/[a-z]/i"
#~ $ perl lolabe.pl -t -ddr " qr/[a-z]/i"
#~ $ perl lolabe.pl -t " qr/[a-z]/i"

sub unicode10 {
    my $it = Unicode::UCD::charinfo( $_[0] );
    my $uc10 = $it->{unicode10} || $it->{name};
    return $uc10;
}

sub PPIx::Regexp::Node::Range::xplain {
#~     my( $self ) = @_;
#~     my $ret = &PPIx::Regexp::Node::xplain;
    my( $self , %args ) = @_;
    $args{no_elements} = 1; ## doesn't interfere with wxPPI
    my $ret = $self->PPIx::Regexp::Node::xplain( %args );
    my( $left, $right ) = map{ $self->schild($_)->ordinal } 0 , -1;
#~     push @{$$ret{start}},  sprintf("code points %d to %d", $left, $right );
    push @{$$ret{start}},  sprintf("code points ord(chr( %d )) to ord(chr( %d ))", $left, $right );
#~     push @{$$ret{start}},  sprintf("code points \\%03o  to \\%03o", $left, $right );
#~     push @{$$ret{start}},  sprintf("code points '\\N{U+%04.4X}' to '\\N{U+%04.4X}'", $left, $right );
    push @{$$ret{start}},  sprintf('code points "\N{U+%04.4X}" to "\N{U+%04.4X}"', $left, $right );
    $left = unicode10( $left );
    $right = unicode10( $right );
    if( $left and $right ){
        push @{$$ret{start}},  sprintf('characters "%s" to "%s"', $left, $right );
    }
    $ret;
}

#~ sub PPIx::Regexp::Token::Comment::xplain { goto &PPIx::Regexp::Token::Whitespace::xplain }
sub PPIx::Regexp::Token::Comment::xplain {
    my( $self, %args ) = @_;
    $args{no_con_desc}=1;
    my $ret   = $self->PPIx::Regexp::Token::xplain( %args );
}
sub PPIx::Regexp::Token::Whitespace::xplain {
#~     return Data::Dump::pp( $_[0]->content ).','; ## content
    return { start_con => Data::Dump::pp( $_[0]->content ).',' }; ## content
}


sub PPIx::Regexp::Element::xmods { goto &PPIx::Regexp::Node::xmods }
sub PPIx::Regexp::Node::xmods {
    my $xmods = $_[0]->{xmods};
    return $xmods
            ? wantarray
              ? %{ $xmods }
              : $xmods
            : ();
}


sub PPIx::Regexp::Element::xmods_susceptible  { goto &PPIx::Regexp::Node::xmods_susceptible  }
sub PPIx::Regexp::Node::xmods_susceptible  {
    use List::Util();
    return List::Util::first {
        $_[0]->isa($_)
    } qw/   PPIx::Regexp::Token::Literal
            PPIx::Regexp::Token::Reference
            PPIx::Regexp::Token::CharClass
            PPIx::Regexp::Token::Interpolation
            PPIx::Regexp::Token::Assertion
        /
    ;;;;
}


#~ 2013-07-26-03:43:03
#~     sub PPIx::Regexp::is_qr         { goto &PPIx::Regexp::is_compile                         }
#~     sub PPIx::Regexp::is_compile    { return !! $_[0]->root->child( 0 )->content eq 'qr'     }
#~     sub PPIx::Regexp::is_substitute { return !! $_[0]->root->replacement                     }
#~     sub PPIx::Regexp::is_match      { return !( $_[0]->is_substitute && $_[0]->is_compile )  }
#~     #~ is_compile    { eval { $_[0]->root->source->isa('PPI::Token::QuoteLike::Regexp')  } }
#~     #~ is_match      { eval { $_[0]->root->source->isa('PPI::Token::Regexp::Match')      } }
#~     #~ is_substitute { eval { $_[0]->root->source->isa('PPI::Token::Regexp::Substitute') } }



#~ sub PPIx::Regexp::is_compile    { return !! $_[0]->child( 0 )->content eq 'qr'           }
sub PPIx::Regexp::is_compile    { return !! $_[0]->type->content eq 'qr'                 }
sub PPIx::Regexp::is_substitute { return !! $_[0]->replacement                           }
sub PPIx::Regexp::is_match      { return !( $_[0]->is_substitute && $_[0]->is_compile )  }
#~ sub PPIx::Regexp::xtype         {
#~     return $_[0]->is_substitute
#~            ? 's'
#~            : $_[0]->is_compile
#~              ? 'qr'
#~              : 'm'
#~     ;;;;;;;;
#~ }
sub PPIx::Regexp::xtype {
    return
        $_[0]->is_substitute ? 's'
      : $_[0]->is_compile    ? 'qr'
      :                        'm';
}


#~ 2013-07-28-16:31:40
#~     (?see-n) would return
#~     my( $modorder, $modcount ) = [ qw/ s e e n / ], { s => 1 , e => 2, n => 0 }
#~
#~     if( exists $modcount->{e} and  my $count = $modcount->{e} ){
#~         ## we saw it, and it was on this many times
#~     }
#~
#~
sub PPIx::Regexp::Token::Modifier::xmods_explode {
    my $notroot = int eval { $_[0] != $_[0]->root->modifier };
    my $con = $_[0]->{content};
    my @mods;
    my %mods;
    $con =~ s{
^
(?:
    \Q(?\E
    |
    \Q?\E
)
|
(?:
     \Q:\E
    |\Q)\E
    |\Q:)\E
) $
    }{}gx;

    my( $onners, $offers ) = ( split( '-', $con ), '','' );

    my @onners = $onners =~ m/(.)/g;
    my @offers = $offers =~ m/(.)/g;

    $mods{$_}++ for @onners;
#~     delete @mods{@offers} ; ## OFFERS TRUMP ONNERS
    $mods{$_}=0 for @offers ; ## OFFERS TRUMP ONNERS

    @mods = ( @onners, @offers );

    if( $notroot ){
        if( my @goners = grep { exists $mods{ $_ } }  '?', ':', '(', ')', ){ ## JIC
            delete @mods{ @goners } ;
            $_[0]->root->{xfailures}+=int@goners ; ## GRR
        }
    }

    if( ( my @two = grep { $mods{$_} } qw/ a d l u / ) > 1 ){
        $_[0]->root->{xfailures}+=int@two; ## GRR
    }

    return \@mods, \%mods;
}

### walks tree, can->modifiers
sub PPIx::Regexp::xmods_propagate {
    my( $node , $depth, $xmods ) = @_;
    $depth ||= 0;
    $xmods ||= {};
    if( $node->isa('PPIx::Regexp') ){
        my($arraymods, $hashmods ) = $node->modifier->xmods_explode;
        %{$xmods} = %{$hashmods};
        $node->root->{xmods} = {%{$xmods}}; ## markit
        delete $xmods->{o}; ## do not propagate
        PPIx::Regexp::xmods_propagate( $node->regular_expression, 0, $xmods );
    } else {
        my @kids = eval { $node->elements };
        if( not @kids ){
            @kids = map { eval { $node->$_ } } qw{ start type children finish };
        }
        for my $kid ( @kids ){
            if( $kid->can('modifiers') ){
                my( $arraymods, $hashmods ) = $kid->xmods_explode;
                my %newmods = $kid->xmerge_mods( $xmods, $hashmods );
                if( $kid->isa( 'PPIx::Regexp::Token::GroupType::Modifier' ) ){
                    $xmods = \%newmods; ### propagate to children (?i:)
                } else { ## propagate to siblings (?i)
                    %{$xmods} = $kid->xmerge_mods( $xmods, $hashmods );
                }
#~                 if( my $p = delete $xmods->{p} ){ ## TODO NOT WORKING
#~                     $node->root->{xmods}{p} = $p; ## cause (?p)/p is global, propagates UP
#~                 }
            }

            if( $kid->xmods_susceptible ){
                delete $xmods->{o}; ## do not propagate, mods.o, error but not UNKNOWN , grrr
                $kid->{xmods}={%{$xmods}};
            }

            PPIx::Regexp::xmods_propagate( $kid , $depth + 1, $xmods );
        }
    }
    return;
}

###
sub PPIx::Regexp::Element::xmerge_mods {
    my( $self , $old, $new ) = @_;
    my %mods = %$old;

    while( my( $mod, $on ) = each %$new ){
        if( $on ){
            $mods{$mod} = $on;
        } else {
#~             $mods{$mod} = !!0; #off
            $mods{$mod} = 0; #off
        }
    }
    if( my $ms = $mods{match_semantics} ){
        $mods{ $ms } ||= 1;
    }
    ### ^ a d l u p match_semantics proper merging propagation
    ### if new ones, nuke existing ones
    if( my @mss = grep { $new->{ $_ } } qw/ ^ a d l u / ){
        delete @mods{ qw/ ^ a d l u / };
        for my $ms ( @mss ){
            if( my $msv = $new->{ $ms } ){ ## and propagate new one (cause ONE)
                $mods{ $ms } = $msv;
#~                 $mods{ match_semantics } = $ms;
                $mods{ match_semantics } = $ms eq '^' ? 'd' : $ms;
                last;
            }
        }
    }
    return wantarray ? %mods : \%mods;
}

## for ->can('modifiers') explodes {content} and explains all options, even the mistakes
## for non-can-modifiers explains xmods, but not UNKNOWNS (mistakes without descriptions)
## increments xfailures (grr)
sub xplain_modifiers {
    my( $self , $OPTS ) = @_;
    undef $OPTS if not ref $OPTS;

    my @ret;
    my $can_modifiers = $self->can('modifiers');
    my $specialEEE = 0;

    my %seen;
    my %mods = eval { $self->xmods };
    my @mods = keys %mods;

    if( !%mods and $can_modifiers  ){
        my( $arraymods, $hashmods ) = $self->xmods_explode;
        @mods = @$arraymods;
        %mods = %$hashmods;
    }

#~                             (?adlupimsx-imsx)    <<< perlre
#~                             (?^alupimsx)         <<< perlre
#~                            (?^msixp..ual)        <<< perlre
#~                             (?msixp.dual-imsx)   <<< perlre
#~                     qr/STRING/msixpodual         <<< perlop
#~                     m/PATTERN/msixpodualgc       <<< perlop
#~                     m?PATTERN?msixpodualgc       <<< perlop
#~         s/PATTERN/REPLACEMENT/msixpodualgcer     <<< perlop
    my @prefix = ( 'mods.', 'match_semantics.' ); ## for inline, for (?adlupimsx-imsx)
    if(  $self == eval { $self->root->modifier } ){
        if( $self->root->is_substitute ){
            @prefix = ( 'mods/s/', 'mods/',  'match_semantics.' , ); # s///eee
            $specialEEE ++;
        } else {
            @prefix = ( 'mods/',  'match_semantics.', ); ## m//x qr//x
        }
    } else {
#~         delete @mods{qw/ p /}; ## (?p) is global like /p is global in 5.16, so JIC don't propagate this past root
#~ 2013-07-30-03:13:33 mistake is mistake, propagate it, don't explain it except in PPIx::Regexp::Token::Modifier
    }


    delete $mods{match_semantics}; ## not used by xplain_modifiers


    if( grep { $self->isa($_) } qw/ PPIx::Regexp::Token::Literal PPIx::Regexp::Token::CharClass / ){
        delete @mods{qw/ p m s x /};
        ## LITERALS are susceptible to  ^ a d l u  for case-insensitivity BUT NOT p m s x
    }

#~     if( grep { $self->isa($_) } qw/ PPIx::Regexp::Token::CharClass::Simple / ){
#~         delete @mods{qw/ i /}; ## \d \w aren't susceptible to case , never case sensitive
#~     }
#~         \p{Latin} is susceptible, grrr
#~         \p{Latin} is  perl_version_introduced=5.006001
#~         BUT \p{Latin} currently doesn't get called modifiers

#~ 2013-07-22-03:29:41 GUESSING!!!!
    if( grep { $self->isa($_) } qw/ PPIx::Regexp::Token::Recursion / ){
#~         delete @mods{qw/ p match_semantics /};
#~ 2013-08-03-16:40:48
#~ $ perl -e " print int m{(lc(?i:(?1)|end)+)}smx for qw/ lcend lclcend lclcEND lcLCend  /"
#~ 1110
        undef %mods;
    }

#~     2013-08-03-16:43:40
## susceptible to /i , not /x, cause its a string-literal not a pattern
#~         $ perl -e " print int m{(lc)(?i:\1)} for qw/ lclc lcLC / "
#~ 11
### might interact somehow with a/aa that needs explaining
    if( grep { $self->isa( $_ ) } qw/ PPIx::Regexp::Token::Backreference / ){
        delete @mods{qw[ x m s p a d l u ]};
    }

    delete @mods{ eval{ @{ $OPTS->{GONERS} } } }; ###### m/\w/i
    @mods = grep { exists $mods{$_ } } @mods;


### THE LEGITIMATE DOUBLES (/aa, /ee)
    if( my $count = $mods{a} ){
        if( $count > 1 ){
            push @ret, $self->xplain_desc("match_semantics.aa" ); ## TODO more
        }
    }

    if( $specialEEE and $can_modifiers and  $mods{e} and 1 != ( my $count = $mods{e} ) ){
        push @ret, $self->xplain_desc( 'mods/s/ee', $count-1 );
    }


MODSLOOP:
    for my $mod ( @mods ){
        my $count = $mods{ $mod }  ;
        my $sufix = $count ? $mod : '-'.$mod;
        next if not defined $count; ## exists $mods{ $mod } ## cause /(?-x:i)/x
        for my $prefix( @prefix ){
            next MODSLOOP if $seen{$mod};
            if( my @desc = $self->xplain_desc( "$prefix$sufix" ) ){
                push @ret, @desc;
                $seen{$mod}++;
                next MODSLOOP;
            }
        }

        if( $can_modifiers and !exists$seen{$mod}  ){
            $self->root->{xfailures} ++;
            push @ret, $self->xplain_desc( "$prefix[-2]unknown", $sufix, $sufix ); ## ICK!!!
        }
    } ## end MODSLOOP

    if( $can_modifiers ){
        for my $twice ( qw/ d l u / ){
            if( exists $mods{$twice} and $mods{$twice} > 1 ){
                push @ret, $self->xplain_desc("mods.nottwice", $twice ); ## perlbug ## $ perl -e " m/(?ad)/ "
            }
        }

        if( $mods{a}  ){
            if(  $mods{a} > 2 or int( grep { exists $mods{$_} } qw/ d l u / ) ){
                push @ret, $self->xplain_desc("mods.twicemax", "a" ); ## $ perl -e " m/(?aaa)/ "
            }
        }

        if( ( my @two = grep { $mods{$_} } qw/ a d l u / ) > 1 ){
            $self->root->{xfailures}++; ## YUCK
            while( @two > 1 ){
                push @ret, $self->xplain_desc("mods.exclusive", @two[0,1] );
                splice @two, 1,1;
            }
        }
    }

    return @ret;
} ## end of sub xplain_modifiers


#~ 2013-08-03-16:59:33
#~ todo sub ... xis_variable      determines if fixed width pattern or variable
#~ todo sub ... xlength           ditches structure/modifiers to return length of literals and charclasses
#~ todo sub ... xsets             nodes/groups literals seperated by operators
#~ todo sub ... xis_fixed_width   determines if fixed width
#~ todo sub ... xis_variable_width
#~ todo sub ... quantized
#~ todo sub ... quantified  group quantified nodes, establish children/finish quantifier relationship,
#~                          no extra indentation levels, no address changes???
#~ todo         PPIx::Regexp::Structure::Quantized
#~ todo         PPIx::Regexp::Structure::String (2+ literal tokens)
#~ todo         PPIx::Regexp::Structure::Literals (2+ literal tokens)

#~ 2013-08-05-01:31:56 false positive on /(?<!a|(i:a))/
#~ 2013-08-11-03:08:48 false positive no more
sub PPIx::Regexp::Node::xis_fixed_width {
    my( $self ) = @_;
    my $is_variable = 0;
#~     $is_variable++ if  $self->find_first( sub { return 1 if $_[1]->isa('PPIx::Regexp::Token::Quantifier') ; }, );
    my $problems = $self->find( sub {
            return 1 if grep { $_[1]->isa( $_ ) } qw/
                    PPIx::Regexp::Token::Quantifier
                    PPIx::Regexp::Structure::Quantifier
                    PPIx::Regexp::Token::Reference
                /;
            return 0;
        },
    );
    $problems ||= [];
    for my $prob ( @$problems ){
        if( $prob->can('xn_comma_m') ){
            my( $n, $comma, $m , @ncm ) = $prob->xn_comma_m;
            if( $n != $m ){
                $is_variable++;
            }
        } else {
            $is_variable++;
        }
    }

    $is_variable and return ! $is_variable; ## SAVE SOME WORK

#~ perl lolabe.pl  -t -ddr " m/(?<!a|aa)E/" >2
#~ perl lolabe.pl  -t -ddr " m/(?<!a?)E/" >2
#~ perl lolabe.pl  -t -ddr " m/(?<!a{2,3})E/" >2
#~ perl lolabe.pl  -t -ddr " m/(?<!a|aa)E/; m/(?<!a?)E/; m/(?<!a{2,3})E/; m/(?<=a|(?i:a)|a)/" >2
#~ perl lolabe.pl  -t -ddr " m/(?<=a|(?i:a)|a)/" >2
#~ perl lolabe.pl  -t -ddr " m/\d++\d{1,2}(?<=a|(?i:a)|a)/" >2
#~ perl lolabe.pl  -t -ddr " m/(?<!a|(?-i:(?i:a)))(?<=a|(?i:a))/" >2
#~ 2013-08-11-02:29:24
#~ variable PPIx::Regexp::Token::Reference #~ $ perl -Mre=debug -wle "m/(.)(?<=a|\1)/"
#~ 2013-08-11-02:44:30 2013-08-11-03:04:35 gah incremental
#~ perl lolabe.pl  -t -ddr " m/(?<!a|(?-i:(?i:a)))(?<=a|(?i:a))/" >2
#~ 2013-08-11-03:19:56
#~ typo #~ perl lolabe.pl  -t -ddr " m/(?<!a|(?-i:(?i:(?[a]))))(?<=a|(?i:a))/" >2
#~      #~ perl lolabe.pl  -t -ddr " m/(?<!a|(?-i:(?i:(?[[a]]))))(?<=a|(?i:a))/" >2
#~      #~ perl lolabe.pl  -t -ddr " m/(?<!a|(?-i:(?i:(?[\w]))))(?<=a|(?i:a))/" >2
#~      #~ perl lolabe.pl  -t -ddr " m/(?<!aa|(?[[a]])(?-i:(?i:(?[\w]))))(?<=a|(?i:a))/" >2
#~ 2013-08-11-03:40:23
#~      #~ perl lolabe.pl  -t -ddr " m/(?<!aaa|\w(?[[a]])(?-i:(?i:(?[\w]))))(?<=a|(?i:a))/" >2
    my @lengths = ( 0 );
#~     for my $kid ( $self->elements ){
    for my $kid ( $self->children ){
        if( $kid->isa('PPIx::Regexp::Token::Operator') ){ ## assume alteration
            push @lengths, 0;
        } else {
#~             $lengths[-1] += length( $kid->content );
            $lengths[-1] += length( $kid->content ) - xstf_length( $kid );
#~                 my $lc = length( $kid->content ) ;
#~                 my $xc = xstf_length( $kid );
#~                 $kid->{xlc}=$lc;
#~                 $kid->{xxc}=$xc;
#~                 $lengths[-1] +=  $lc - $xc;
#~                 warn pp { damn =>scalar( $kid->content), lc => $lc , xc => $xc } ;
#~             warn pp( my $c = $kid->content  );
#~             $lengths[-1] += length( $c );
        }
    }
    $self->{xxls}=[@lengths];
#~     warn pp\@lengths;
    while( @lengths > 1 ){
        if( $lengths[-1] != $lengths[-2] ){
            $is_variable++;
        }
        pop @lengths;
    }

## grr, too many tokens can_be_quantified
#~ PPIx::Regexp::Token::Structure can_be_quantified even though its structural
#~ PPIx::Regexp::Token::Operator can_be_quantified even though its an OPERATOR
    return ! $is_variable;
}

sub PPIx::Regexp::Structure::Assertion::xplain {
    my( $self, %args ) = @_;
    delete $args{no_elements};
    my $ret = $self->PPIx::Regexp::Structure::xplain( %args );
    if( not $self->xis_fixed_width ){
        push @{$$ret{start}},  $self->xplain_desc('errn'.$self->type->content);
    }
    return $ret;
}

#~ dodgy , force unicode if: 1) string is utf8 2) pattern is utf8 3) pattern mentions codepoint above 255 4)pat uses unicode name \N{} 5)pat uses unicode property \p{} 6) pat uses RegexSet (?[ ])
#~ force unicode semantics if
#~     #~ 1   the target string is encoded in UTF-8; or
#~     #~ 2   the pattern is encoded in UTF-8; or
#~     #~ 3   the pattern explicitly mentions a code point that is above 255 (say by \x{100} ); or
#~     #~ 4   the pattern uses a Unicode name (\N{...} ); or
#~     #~ 5   the pattern uses a Unicode property (\p{...} ); or
#~     #~ 6   the pattern uses (?[ ])
sub xdodgy_unicode_override {
    my( $self ) = @_;
#~ perl lolabe.pl -t -ddr "m/\pN\p{N}\x{100}\N{Kelvin}/d" >2
    my $unicode = 0;
    my %why;
    $self->find( sub {
#~         $unicode += grep { $_[1]->isa( $_ ) } qw/ PPIx::Regexp::Structure::RegexSet / ;
        if( $_[1]->isa('PPIx::Regexp::Structure::RegexSet') ){
            $unicode++;
            $why{'dodgy-u-rset'}++;
        }elsif( $_[1]->isa('PPIx::Regexp::Token::Literal') ){
            my $ord = $_[1]->ordinal;
#~             if( not defined $ord or $ord > 255 or ( $_[1]->{content} =~ m{^\\[pPN]} ) ){
            if( defined $ord and $ord > 255 ){
                $unicode++;
#~                 push @why, 'dodgy-u-255';
                $why{'dodgy-u-255'}++;
            }elsif( $_[1]->{content} =~ m{^\\[pP]}  ){
                $unicode++;
                $why{'dodgy-u-prop'}++;
            }elsif( $_[1]->{content} =~ m{^\\[N]}  ){
                $why{'dodgy-u-name'}++;
                $unicode++;
            }
        }elsif( $_[1]->isa('PPIx::Regexp::Token::CharClass::Simple') ){
            if( my $con = eval{$self->{content}} ){
                if( $con =~ /^\\[pP]\{/ ){
                    $why{'dodgy-u-prop'}++;
                    $unicode++;
                }
            }
        }
        return 0;
    } );
    ## pattern encoded in UTF-8 check
#~     return $unicode ;
    return keys %why;
}
1;

sub PPIx::Regexp::Token::GroupType::NamedCapture::xplain {
    my( $self, %args ) = @_;
    return {
        depth => $args{depth},
        start => [
            'address='. $self->address,
            $self->xplain_desc( ref $self),
        ],
        start_con => Data::Dump::pp( $self->content ).',',
        start_hr => join '', "# ", '-' x  ( $args{hr_length} ||  66 ),
    };
}



#~ 2013-08-11-01:50:27
#~ PPIx::Regexp::Token::Structure
#~ PPIx::Regexp::Token::GroupType
#~ sub is_start  { $_[0]->address =~ m{/[S]\d+$}i }
#~ sub is_type   { $_[0]->address =~ m{/[T]\d+$}i }
#~ sub is_finish { $_[0]->address =~ m{/[F]\d+$}i }
#~ 2013-08-11-01:57:59
## cant use Find because of PPIx::Regexp::Structure::Quantifier \d{2,3} 2,3 are contents
## and don't want to think about that
#~ 2013-08-11-02:11:54
#~ stf PPIx::Regexp::Structure::Assertion
#~ stf PPIx::Regexp::Structure::BranchReset
#~ stf PPIx::Regexp::Structure::Capture
#~ C #~ stf+operators PPIx::Regexp::Structure::CharClass
#~ c PPIx::Regexp::Structure::Code
#~ 0E PPIx::Regexp::Structure::Main
#~ stf PPIx::Regexp::Structure::Modifier
#~ c #~ stf PPIx::Regexp::Structure::Quantifier
#~ stf PPIx::Regexp::Structure::Subexpression
#~ stf PPIx::Regexp::Structure::Switch
#~ stf PPIx::Regexp::Structure::Unknown
#~ 2013-08-11-03:18:57
#~ c0 PPIx::Regexp::Structure::RegexSet
##
#~ sspm PPIx::Regexp::Structure::Assertion PPIx::Regexp::Structure::BranchReset PPIx::Regexp::Structure::Capture PPIx::Regexp::Structure::CharClass PPIx::Regexp::Structure::Code PPIx::Regexp::Structure::Main PPIx::Regexp::Structure::Modifier PPIx::Regexp::Structure::Quantifier PPIx::Regexp::Structure::Subexpression PPIx::Regexp::Structure::Switch PPIx::Regexp::Structure::Unknown
##
#~ 2013-08-11-02:32:41
##
#~ s length of start
#~ t length of type
#~ f length of finish
#~ c length of content
#~ 0 length 0
#~ Q length is VARIABLE (ITS A QUANTIFIER)
#~ E error (shouldn't encounter this)
##
#~ first letter is length to be removed to be subtracted to obtain real-literal-fixed-width-length
#~ second letter is length to be added to obtain real-literal-fixed-width-length
#~ E is an error means its not fixed-width or its impossible situation so forget it
##
#~ c0 PPIx::Regexp::Token::Assertion
#~ c0 PPIx::Regexp::Token::Backtrack
#~ cQ PPIx::Regexp::Token::CharClass
#~ cE PPIx::Regexp::Token::Code
#~ c0 PPIx::Regexp::Token::Comment
#~ c0 PPIx::Regexp::Token::Control
#~ cEQ PPIx::Regexp::Token::Greediness
#~ c0 PPIx::Regexp::Token::GroupType
#~ c1 PPIx::Regexp::Token::Literal
#~ cE PPIx::Regexp::Token::Modifier
#~ c0 PPIx::Regexp::Token::Operator
#~ cE PPIx::Regexp::Token::Quantifier
#~ cE PPIx::Regexp::Token::Reference
#~ c0 PPIx::Regexp::Token::Structure
#~ c0 PPIx::Regexp::Token::Unknown
#~ cE PPIx::Regexp::Token::Unmatched
#~ c0 PPIx::Regexp::Token::Whitespace
#~ 2013-08-11-03:42:02
#~ c1 PPIx::Regexp::Token::CharClass::Simple
##
#~ sspm PPIx::Regexp::Token::Assertion PPIx::Regexp::Token::Backtrack PPIx::Regexp::Token::CharClass PPIx::Regexp::Token::Code PPIx::Regexp::Token::Comment PPIx::Regexp::Token::Control PPIx::Regexp::Token::Greediness PPIx::Regexp::Token::GroupType PPIx::Regexp::Token::Literal PPIx::Regexp::Token::Modifier PPIx::Regexp::Token::Operator PPIx::Regexp::Token::Quantifier PPIx::Regexp::Token::Reference PPIx::Regexp::Token::Structure PPIx::Regexp::Token::Unknown PPIx::Regexp::Token::Unmatched PPIx::Regexp::Token::Whitespace
#~ 2013-08-11-02:39:11
#~ length of structural elements to be removed
#~ to be subtracted from length of content
#~ to obtain real-literal-fixed-width-length
sub xstf_length {
    my( $node , $depth ) = @_;
    $depth ||= 0;
    my $length = 0;
    my @kids = eval { $node->elements };

    if( not @kids ){
        @kids = map { eval { $node->$_ } } qw{ start type children finish };
    }

    my $count_content = grep {
        !! $node->isa($_)
    } qw'
        PPIx::Regexp::Structure::CharClass
        PPIx::Regexp::Structure::Code
        PPIx::Regexp::Structure::Quantifier
        PPIx::Regexp::Structure::RegexSet
        ';;;;

    my $count_once = grep {
        !! $node->isa($_)
    } qw'
        PPIx::Regexp::Structure::CharClass
        PPIx::Regexp::Structure::RegexSet
        PPIx::Regexp::Token::CharClass
        PPIx::Regexp::Token::Literal
        ';;;;

    if( $count_once and not @kids  and not $count_content ){ ## ICK! \w has length 2 but quantifies as 1
        return length( $node->content )-1; ## \x{} has length > 2 but quantifies as 1
    }
    if( $count_content ){
        return $length + length( $node->content ) - $count_once; ## cause charclasses/regexsets quantify as 1
    }

    for my $kid ( @kids ){
        if( $kid->address =~ m{/[STF]\d+\s$}i ){
            $length += length $kid->content;
#~         } elsif( $kid->children ) { ## inadequate
        } elsif( $kid->isa('PPIx::Regexp::Structure') ) { ## should be stf type
            $length += xstf_length( $kid, $depth+1 );
        }
    }

    return $length;
} ## end of sub xstf_length
#~ self-fulfilling enlightenment or gratifying ignorance.
 
