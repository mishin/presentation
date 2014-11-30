#!/usr/bin/perl --
use utf8;
use strict;
use warnings;
use PPI;
use PPIx::Regexp;
use Wx 0.86 qw(  );
use Wx::AUI;

Main( @ARGV );
exit( 0 );

sub Main {
    my( @files ) = @_;
    
    @files or @files = ( \"#!/usr/bin/perl --\nuse strict;\nuse warnings;\nuse utf8;\nprint q{\nud hello is o\x{283}\x{283}\x{1DD}\x{265}\nud o\x{283}\x{283}\x{1DD}\x{265} is hello\n}, 4 + 2 , \"\\n\";;;;\n\nqr{a\\s(\\d+)f}i;;\n\ns{a\\s(\\d+)f}{\$1}i;;\n\nm{a\\s(\\d+)f}i;;\n\ns{\n    hd_defect-\n    (\n        ([^\\.]+\$)\n        |\n        (?:\n            ([^\\.]+)\n            .\n            (.+\$)\n        )\n    )\n}{\n    \$3\n    ? uc(\"\$2-\$3\")\n    : uc \$1\n}sex;;;\n\n\nprint qx{echo echo}, \"\\n\";;;;\n\nmy \$scalar = 42;\nmy %hash;\nmy \@array;\n\nprint <<'SINGLE';\nsingle quoted\nSINGLE\n\nprint <<\"DOUBLE\";\ndouble quoted\nDOUBLE\n\nprint <<DOUBLE;\ndouble quoted\nDOUBLE\n\nprint <<`BACKTICK`;\necho backticks quoted\nBACKTICK\n\n=head1 HI\n\n=cut\n\n__END__\n\nthere\n\n=head1 YO\n\n=cut\n\n",,,, );;;;;
    
    my $app = Wx::SimpleApp->new ;
    for my $file ( @files ){
        my $frame = MyPP->new;
        $app->SetTopWindow( $frame );
        $frame->CenterOnScreen;
#~         $frame->Maximize(1);
        $frame->Show( 1 );
        $frame->readFile( $file );
        $app->MainLoop();
        $frame->pperspective();
    }
}

package MyPP;

use base qw/ Wx::Frame /;
sub new {
    my($class, @rest ) = @_;
    @rest or @rest = (
        undef, -1, "ppiwx / wxPPI / wxppixregexp ",
        [ -1,  -1 ],
        [ 555, 555 ],
        Wx::wxDEFAULT_FRAME_STYLE() | Wx::wxTAB_TRAVERSAL()
    );
    
    my $frame   = $class->SUPER::new( @rest );


    $frame->{auim} = Wx::AuiManager->new();
    $frame->{auim}->SetManagedWindow( $frame );
    
    my $Left = Wx::Panel->new( $frame, -1 );
    $Left->SetSizer( Wx::BoxSizer->new( Wx::wxHORIZONTAL() ) );
    my $codetext = MakeScintilla( $Left );
    
    $Left->GetSizer->Add( $codetext, 1, Wx::wxEXPAND(), );
    
    my $newLeft = Wx::Panel->new( $frame, -1 );
    my $newRight = Wx::Panel->new( $frame, -1, [ -1, 100 ] );
    $newLeft->SetSizer( Wx::BoxSizer->new( Wx::wxHORIZONTAL() ) );
    $newRight->SetSizer( Wx::BoxSizer->new( Wx::wxHORIZONTAL() ) );

    my $codetree = Wx::TreeCtrl->new(
        $newLeft, -1,
        [ -1, -1 ],
        [ -1, -1 ],
        Wx::wxTR_SINGLE() | Wx::wxTR_DEFAULT_STYLE()
    );
    
    $codetree->SetIndent(0);

    my $treetext = MakeScintilla( $newRight );

    $newLeft->GetSizer->Add( $codetree, 1, Wx::wxEXPAND(), );
    $newRight->GetSizer->Add( $treetext, 1, Wx::wxEXPAND(), );
    $frame->{codetext}    = $codetext;
    $frame->{codetree}    = $codetree;
    $frame->{treetext}    = $treetext;
    
    
    $codetext->SetModEventMask( Wx::wxSTC_MOD_INSERTTEXT() | Wx::wxSTC_MOD_DELETETEXT() );
    Wx::Event::EVT_STC_CHANGE( $frame, $codetext, \&on_build_tree );
    Wx::Event::EVT_TREE_SEL_CHANGED( $frame, $codetree, \&on_item_sel );

    
    
    $frame->{auim}->AddPane( $newLeft, Wx::AuiPaneInfo->new->Name("aui_codetree")->Caption("ppi dom(click here)")->Center->Movable->Resizable->Dockable->MinSize( 240,100 )->Left->Floatable->PinButton->CloseButton(0) );
    $frame->{auim}->AddPane( $Left, Wx::AuiPaneInfo->new->Name("aui_codetext")->Caption("input(paste here)")->Center->Movable->Resizable->Dockable->MinSize( 100,250 )->Center->Floatable->PinButton->CloseButton(0) );
    $frame->{auim}->AddPane( $newRight, Wx::AuiPaneInfo->new->Name("aui_treetext")->Caption("ppi node")->Center->Movable->Resizable->Dockable->MinSize( 50, 50 )->Center->Floatable->PinButton->CloseButton(0) );
    $frame->{auim}->Update();
    0 and $frame->{auim}->LoadPerspective(q{layout2| name=aui_codetree; caption=ppi dom(click here); state=16779260; dir=4; layer=0; row=0; pos=0; prop=100000; bestw=240; besth=100; minw=240; minh=100; maxw=-1; maxh=-1; floatx=-1; floaty=-1; floatw=-1; floath=-1| name=aui_codetext; caption=input(paste here); state=16779260; dir=5; layer=0; row=0; pos=0; prop=100000; bestw=100; besth=250; minw=100; minh=250; maxw=-1; maxh=-1; floatx=-1; floaty=-1; floatw=-1; floath=-1| name=aui_treetext; caption=ppi node; state=16779260; dir=5; layer=0; row=0; pos=1; prop=100000; bestw=50; besth=50; minw=50; minh=50; maxw=-1; maxh=-1; floatx=-1; floaty=-1; floatw=-1; floath=-1| dock_size(4,0,0)=242| dock_size(5,0,0)=102|});
    0 and $frame->{auim}->LoadPerspective(q{layout2| name=aui_codetree; caption=ppi dom(click here); state=16781308; dir=1; layer=0; row=1; pos=0; prop=100000; bestw=240; besth=100; minw=240; minh=100; maxw=-1; maxh=-1; floatx=250; floaty=518; floatw=400; floath=493| name=aui_codetext; caption=input(paste here); state=16781308; dir=1; layer=0; row=1; pos=1; prop=100000; bestw=100; besth=250; minw=100; minh=250; maxw=-1; maxh=-1; floatx=7; floaty=290; floatw=400; floath=493| name=aui_treetext; caption=ppi node; state=16781308; dir=5; layer=0; row=0; pos=0; prop=100000; bestw=50; besth=50; minw=50; minh=50; maxw=-1; maxh=-1; floatx=-1; floaty=-1; floatw=-1; floath=-1| dock_size(5,0,0)=102| dock_size(1,0,1)=574|});
    0 and $frame->{auim}->LoadPerspective(q{layout2| name=aui_codetree; ppi dom(click here); state=16779260; dir=2; layer=0; row=1; pos=0; prop=100000; bestw=240; besth=100; minw=240; minh=100; maxw=-1; maxh=-1; floatx=8; floaty=17; floatw=400; floath=493| name=aui_codetext; caption=input(paste here); state=16779260; dir=5; layer=0; row=0; pos=0; prop=145048; bestw=100; besth=250; minw=100; minh=250; maxw=-1; maxh=-1; floatx=-1; floaty=-1; floatw=-1; floath=-1| name=aui_treetext; caption=ppi node; state=16779260; dir=3; layer=0; row=1; pos=0; prop=54952; bestw=50; besth=50; minw=50; minh=50; maxw=-1; maxh=-1; floatx=66; floaty=66; floatw=400; floath=493| dock_size(5,0,0)=102| dock_size(2,0,1)=360| dock_size(3,0,1)=133|});
    0 and $frame->{auim}->LoadPerspective(q{});
    $frame->{init_perspective} = $frame->{auim}->SavePerspective;
    $codetree->SetFocus;
    
    return $frame;
}

sub DESTROY { 
    my($frame) = @_;
    $frame->{auim}->UnInit();
    undef %{$frame};
    return;
}

sub pperspective {
    my($frame) = @_;
    my $i = $frame->{init_perspective};
    my $p = $frame->{auim}->SavePerspective;
    return if $i eq $p;
    $p =~ s{([\;\|])}{$1\n}g;
    print $p;
}


sub on_build_tree {
    my( $frame, $e ) = @_;
    
    my $codetext = $frame->{codetext} || die;
    my $codetextpos = $codetext->GetCurrentPos;
    my $tree = $frame->{codetree} || die;
    my $treetext = $frame->{treetext} || die;
    my $rawtext = $codetext->GetValue;
    
    my $focus = Wx::Window::FindFocus() || $tree;
    
    $_->Disable for $codetext, $tree, $treetext;
    $tree->Unselect;
    $tree->DeleteAllItems;
    
    
## need to keep PPI::Document alive, TreeItemData appears to use weaken
    $frame->{ppidocument} = 
    my $document = PPI::Document->new( \$rawtext );
    TreeAdd( $tree, $document->document );
    
    $tree->ExpandAll;
    $treetext->SetValue("");
    $_->Enable for $tree, $treetext, $codetext;
    $focus and $focus->SetFocus; ### important
    $focus and $codetext->GotoPos( $codetextpos ); ### important
    return;
}

sub PPI::Element::reff { my $ref = ref $_[0]; $ref =~ s/^PPI:://; $ref }
sub PPIx::Regexp::Element::reff { my $ref = ref $_[0]; $ref =~ s/^PPIx::Regexp::/xRe::/; $ref }

sub Wx::StyledTextCtrl::SelectRowColLen {
    my( $self, $row, $col, $len ) = @_;
    $self->SetSelectionMode( Wx::wxSTC_SEL_STREAM() );
    $self->GotoLine( $row );
    my $cpos = $self->GetCurrentPos ;
    $self->GotoPos( $cpos + $col );
    $cpos = $self->GetCurrentPos ;
    $self->GotoPos( $cpos + $len  );
    $self->SetSelection( $cpos , $cpos + $len );
}



sub Wx::StyledTextCtrl::SelectRowColLenStartEnd {
    my( $self, $row, $col, $len , $start, $end ) = @_;
    my $canmultiple = eval { $self->SetMultipleSelection( 1 ); 1 };
    eval { $self->ClearSelections( ); };
    $self->GotoLine( $row );
    my $cpos = $self->GetCurrentPos ;
    $self->GotoPos( $cpos + $col );
    $cpos = $self->GetCurrentPos ;
    $self->GotoPos( $cpos + $len  );
    my $orig_pos = $self->GetCurrentPos;
    my $start_pos = $self->PositionFromLine( $start );;
    my $end_pos = $self->PositionFromLine( $end );
    
    $self->SetSelection( $cpos , $cpos + $len );
    return if not $canmultiple ;
    $self->AddSelection( $start_pos  , $end_pos );
}

sub on_item_sel {
    my( $frame, $e ) = @_;
    my $focus = Wx::Window::FindFocus() ;
    
    my $treetext = $frame->{treetext}                  || die;
    my $codetext = $frame->{codetext}                  || die;
    my $tree = $frame->{codetree}                  || die;
    
    
    my $curr_item = $tree->GetSelection ;
    
    my $data = $tree->GetItemData( $curr_item ) || return;
    
    my $dataobj = $data = $data->GetData;
    my $col = $data->column_number - 1 ;
    my $row = $data->line_number - 1 ;
    my $lengthdata = 0;
    

    if( $data->isa( 'PPI::Token::HereDoc' ) ){
#~         warn pp($dataobj);
        my $ndd = "$data";
        $lengthdata = length $ndd;
        $data = join '', $ndd, "\n", $data->heredoc, $data->terminator;
        $data = '#'.$dataobj->overload::StrVal."\n".$data;

        eval { $codetext->SetMultipleSelection( 1 ); };
        $codetext->SelectRowColLenStartEnd( $row, $col, $lengthdata, $dataobj->here_line_range );
        $treetext->SetValue( $data );
        return ;
    } else {
        ### ick
        my $data = $data->can( 'serialize' )
                  ? $data->serialize
                  : $data->can('content')
                    ? $data->content
                    : $data ;
        $lengthdata = length $data;
        
#~         warn "the data is $data of length $lengthdata at row $row and col $col";
        
        $data = '#'.$dataobj->overload::StrVal."\n".$data;
        
        eval { $codetext->SetMultipleSelection( 0 ); };
        $codetext->SelectRowColLen( $row, $col, $lengthdata );
#~         $treetext->SetValue( $data );
#~         2013-07-18-20:20:53 no caching of this yet
#~ 2013-07-18-20:29:16
#~ 2013-07-18-20:39:31 weird, eval hides the failure I guess, nope, ITS THE GIANT large regex
#~ right, on token whitespace, naturally :)
        BEGIN { require 'ppixregexplain.pl'; }
#~         my $xplain = eval { $dataobj->can('xplain') } ? MainXplain( $dataobj ) : ();
#~         $xplain and $data = "$data\n__END__\n$xplain" ;
        if( my $xplain = eval { $dataobj->xplain } ){
            my $str ="";
            open my($virtual), '>:raw', \$str or die "IMPOSSIBLE $! $^E";
            use SelectSaver;
            my $saver = SelectSaver->new( $virtual );
            local $@="";
            eval { darntext( $xplain ); }; ## this is halfarsed, darntext doesn't deal with partials
#~             darntext( $xplain ); 
#~             $data .= "\n\n__END__\n\n$str\n";
            my $err = "$@" || "";
            $err =~ s/^/#/gm;
#~             $data = "$str\n\n$err\n\n$data";
            $data = "$str\n\n$err\n__END__\n$data";
        }
        $treetext->SetValue( $data );
#~         $treetext->GotoLine( -1 ); ## no work
#~         $treetext->GotoLine( 1000000 ); ## works but FEH! documented as "could be first or last"
        $treetext->GotoPos( length $data );
        
        return;
    }
    
}

sub TreeAdd {
    my( $t, $d, $root ) = @_;

    if( not $root ) {
        $root = $t->AddRoot( $d->reff, -1, -1, Wx::TreeItemData->new( $d ) );
    }
    my @chids = eval { $d->start };
    if( @chids ){
        @chids = ( @chids, eval { $d->type } );
    }
    @chids = ( @chids, eval { $d->children }, eval { $d->finish } );
    for my $kid ( @chids ) {
        my $ref_kid = ref($kid);
        if( eval { scalar $kid->children; } ) {
            my $newid = Wx::TreeItemData->new( $kid );
            my $item = eval { $t->AppendItem( $root, $kid->reff, -1, -1, $newid ) };
            $item or do {
                warn "failed to append kid(
$kid
)
to root(
@{[ $root->overload::StrVal ]} = $root
)
with newid(
$newid
)
because GRR $@ ";
                next;
            };
            TreeAdd( $t, $kid, $item );
            if( $kid->isa('PPI::Statement::Include') ){
                $t->SetItemTextColour( $item, Wx::Colour->new( '#00007F' ));
                $t->SetItemBold( $item, 1 );
            }elsif( $ref_kid =~ /Data|End/  ){
                $t->SetItemTextColour( $item, Wx::Colour->new( '#600000' ));
                $t->SetItemBackgroundColour( $item, Wx::Colour->new( '#FFF0D8' ));
            }
        } else {
            my $newid = Wx::TreeItemData->new( $kid );
            my $item = eval { $t->AppendItem( $root, $kid->reff, -1, -1, $newid ) };
            $item or do {
                warn "failed to append kid($kid) to root($root) with newid($newid) because GRR $@ ";
                next;
            };
            if( $kid->isa('PPI::Token::HereDoc' ) ){
                my $heredoc = "$kid";
                my $fore = "";
                my $back = "";
                my $bold = 0;
                if( $heredoc =~ /'/ )   { $fore="#7F007F"; $back="#feeffe"; $bold = 0; }
                elsif( $heredoc =~ /`/ ){ $fore="#FFFF00"; $back="#A08080"; $bold = 1; }
                else                    { $fore="#7F007F"; $back="#feeffe"; $bold = 1; }
                $t->SetItemTextColour( $item, Wx::Colour->new( $fore ));
                $t->SetItemBackgroundColour( $item, Wx::Colour->new( $back ));
                $t->SetItemBold( $item, $bold );
            }elsif( $ref_kid =~ /PPI::Token::QuoteLike::Command/ ){
                $t->SetItemTextColour( $item, Wx::Colour->new( '#FFFF00'));
                $t->SetItemBackgroundColour( $item, Wx::Colour->new( '#A08080'));
            }elsif( $ref_kid =~ /PPI::Token::Quote/ ){
                $t->SetItemTextColour( $item, Wx::Colour->new( '#7F007F'));
                if( $ref_kid eq 'PPI::Token::QuoteLike::Regexp'){                    
                    my $regex = xPPIx_Regexp_linecol_onize( $kid, $kid->line_number, $kid->column_number );
                    my $newid = Wx::TreeItemData->new( $regex );
                    my $regexitem = eval { $t->AppendItem( $item, $regex->reff, -1, -1, $newid ) };
                    TreeAdd( $t, $regex, $regexitem  );
                }
            }elsif( ref $kid eq 'PPI::Token::Pod' ){
                $t->SetItemTextColour( $item, Wx::Colour->new( '#004000' ));
                $t->SetItemBackgroundColour( $item, Wx::Colour->new( '#C0FFC0' ));
            }elsif( ref $kid eq 'PPI::Token::Separator' ){
                $t->SetItemBackgroundColour( $item, Wx::Colour->new( '#FFF0D8' ));
            }elsif( ref $kid eq 'PPI::Token::Regexp::Substitute' ){
                $t->SetItemBackgroundColour( $item, Wx::Colour->new( '#F0E080' ));
                my $regex = xPPIx_Regexp_linecol_onize( $kid, $kid->line_number, $kid->column_number );
                my $newid = Wx::TreeItemData->new( $regex );
                my $regexitem = eval { $t->AppendItem( $item, $regex->reff, -1, -1, $newid ) };
                TreeAdd( $t, $regex, $regexitem  );
            }elsif( ref $kid eq 'PPI::Token::Regexp::Match' ){
                $t->SetItemBackgroundColour( $item, Wx::Colour->new( '#A0FFA0' ));
                
                my $regex = xPPIx_Regexp_linecol_onize( $kid, $kid->line_number, $kid->column_number );
                my $newid = Wx::TreeItemData->new( $regex );
                my $regexitem = eval { $t->AppendItem( $item, $regex->reff, -1, -1, $newid ) };
                TreeAdd( $t, $regex, $regexitem  );
            }elsif( ref $kid eq 'PPI::Token::Word' ){
                $t->SetItemTextColour( $item, Wx::Colour->new( '#00007F' ));
                $t->SetItemBold( $item, 1 );
            }elsif( ref $kid eq 'PPI::Token::Comment' ){
                $t->SetItemTextColour( $item, Wx::Colour->new( '#007F00' ));
            }elsif( ref $kid eq 'PPI::Token::Number' ){
                $t->SetItemTextColour( $item, Wx::Colour->new( '#007F7F' ));
            }elsif( $ref_kid =~ /Operator|Structure/  ){
                $t->SetItemBold( $item, 1 );
            }elsif( $ref_kid =~ /PPI::Token::Magic|PPI::Token::Symbol/ ){
                my $symbol_type = $kid->symbol_type;
                my $back = '#FFE0E0' ;
                if( $symbol_type eq '@' ){    $back ='#FFFFE0'}
                elsif( $symbol_type eq '%' ){ $back ='#FFE0FF'}
                elsif( $symbol_type eq '*' ){ $back ='#E0E0E0'}
                $t->SetItemBackgroundColour( $item, Wx::Colour->new( $back ));
            }
        }
    }
    return $root;
}


sub MakeScintilla {
    my( $newRight ) = @_;
    my $treetext = Wx::StyledTextCtrl->new(
        $newRight, -1,
        [ -1, -1 ],
        [ -1, -1 ],
        Wx::wxTE_PROCESS_ENTER() | Wx::wxTE_MULTILINE() | &Wx::wxTE_NOHIDESEL
    );
    
    $treetext->SetCodePage(65001);
    $treetext->SetLexerLanguage( 'perl' );
    eval {
        my $font = Wx::Font->new(
            10,
            Wx::wxTELETYPE(),
            Wx::wxNORMAL(),
            Wx::wxNORMAL(),
            0,
            "DejaVu Sans Mono",
## fontmapper doesn'te detect its a UTF8 font,
## so it throws up a fontchooser dialog, known bug
#~             Wx::wxFONTENCODING_UTF8(),
        );
        $treetext->SetFont( $font );
        $treetext->StyleSetFont( Wx::wxSTC_STYLE_DEFAULT(), $font );
    };



    $treetext->StyleClearAll();
    $treetext->SetLexer( Wx::wxSTC_LEX_PERL() );
    $treetext->SetSelectionMode( Wx::wxSTC_SEL_LINES() );
    $treetext->StyleSetSpec( 0,"fore:#808080,font:DejaVu Sans Mono,size:11" ); # White space
    $treetext->StyleSetSpec( 1,"fore:#FFFF00,back:#FF0000" ); # Error
    $treetext->StyleSetSpec( 2,"fore:#007F00,font:DejaVu Sans Mono,size:11" ); # Comment
    $treetext->StyleSetSpec( 3,"fore:#004000,back:#E0FFE0,font:DejaVu Sans Mono,size:11,eolfilled" ); # POD: = at beginning of line
    $treetext->StyleSetSpec( 4,"fore:#007F7F" ); # Number
    $treetext->StyleSetSpec( 5,"fore:#00007F,bold" ); # Keyword
    $treetext->StyleSetSpec( 6,"fore:#7F007F,font:DejaVu Sans Mono,size:11" ); # Double quoted string
    $treetext->StyleSetSpec( 7,"fore:#7F007F,font:DejaVu Sans Mono,size:11" ); # Single quoted string
    $treetext->StyleSetSpec( 8,"back:#FF0000," ); # Symbols / Punctuation. Currently not used by LexPerl.
    $treetext->StyleSetSpec( 9,"back:#FF0000," ); # Preprocessor. Currently not used by LexPerl.
    $treetext->StyleSetSpec( 10,"fore:#000000,bold" ); # Operators
    $treetext->StyleSetSpec( 11,"fore:#000000" ); # Identifiers (functions, etc.)
    $treetext->StyleSetSpec( 12,"fore:#000000,back:#FFE0E0" ); # Scalars: $var
    $treetext->StyleSetSpec( 13,"fore:#000000,back:#FFFFE0" ); # Array: @var
    $treetext->StyleSetSpec( 14,"fore:#000000,back:#FFE0FF" ); # Hash: %var
    $treetext->StyleSetSpec( 15,"fore:#000000,back:#E0E0E0" ); # Symbol table: *var
    $treetext->StyleSetSpec( 17,"fore:#000000,back:#A0FFA0" ); # Regex: /re/ or m{re}
    $treetext->StyleSetSpec( 18,"fore:#000000,back:#F0E080" ); # Substitution: s/re/ore/
    $treetext->StyleSetSpec( 19,"fore:#FFFF00,back:#8080A0" ); # Long Quote (qq, qr, qw, qx) -- obsolete: replaced by qq, qx, qr, qw
    $treetext->StyleSetSpec( 20,"fore:#FFFF00,back:#A08080" ); # Back Ticks
    $treetext->StyleSetSpec( 21,"fore:#600000,back:#FFF0D8,eolfilled" ); # Data Section: __DATA__ or __END__ at beginning of line
    $treetext->StyleSetSpec( 22,"fore:#000000,back:#feeffe" ); # Here-doc (delimiter)
    $treetext->StyleSetSpec( 23,"fore:#7F007F,back:#feeffe,eolfilled,notbold" ); # Here-doc (single quoted, q)
    $treetext->StyleSetSpec( 24,"fore:#7F007F,back:#feeffe,eolfilled,bold" ); # Here-doc (double quoted, qq)
    $treetext->StyleSetSpec( 25,"fore:#FFFF00,back:#A08080,eolfilled,bold" ); # Here-doc (back ticks, qx)
    $treetext->StyleSetSpec( 26,"fore:#7F007F,font:DejaVu Sans Mono,size:11,notbold" ); # Single quoted string, generic
    $treetext->StyleSetSpec( 27,"fore:#7F007F,font:DejaVu Sans Mono,size:11" ); # qq = Double quoted string
    $treetext->StyleSetSpec( 28,"fore:#FFFF00,back:#A08080" ); # qx = Back ticks
    $treetext->StyleSetSpec( 29,"fore:#000000,back:#A0FFA0" ); # qr = Regex
    $treetext->StyleSetSpec( 30,"fore:#000000,back:#FFFFE0" ); # qw = Array
    $treetext->StyleSetSpec( 31,"fore:#004000,back:#C0FFC0,font:DejaVu Sans Mono,size:11,eolfilled" ); # POD: verbatim paragraphs
    $treetext->StyleSetSpec( 40,"fore:#000000,bold,italics" ); # subroutine prototype
    $treetext->StyleSetSpec( 41,"fore:#C000C0,bold" ); # format identifier
    $treetext->StyleSetSpec( 42,"fore:#C000C0,back:#FFF0FF,eolfilled" ); # format body

    $treetext->SetMarginType(0, Wx::wxSTC_MARGIN_NUMBER() );
    $treetext->SetMarginWidth(0,50);
    $treetext->SetMarginWidth(1,0);
    
    
#~ perl.properties
    $treetext->SetKeyWords( 0, join ' ' , qw{NULL __FILE__ __LINE__ __PACKAGE__ __DATA__ __END__ AUTOLOAD BEGIN CORE DESTROY END EQ GE GT INIT LE LT NE CHECK abs accept alarm and atan2 bind binmode bless caller chdir chmod chomp chop chown chr chroot close closedir cmp connect continue cos crypt dbmclose dbmopen defined delete die do dump each else elsif endgrent endhostent endnetent endprotoent endpwent endservent eof eq eval exec exists exit exp fcntl fileno flock for foreach fork format formline ge getc getgrent getgrgid getgrnam gethostbyaddr gethostbyname gethostent getlogin getnetbyaddr getnetbyname getnetent getpeername getpgrp getppid getpriority getprotobyname getprotobynumber getprotoent getpwent getpwnam getpwuid getservbyname getservbyport getservent getsockname getsockopt glob gmtime goto grep gt hex if index int ioctl join keys kill last lc lcfirst le length link listen local localtime lock log lstat lt map mkdir msgctl msgget msgrcv msgsnd my ne next no not oct open opendir or ord our pack package pipe pop pos print printf prototype push quotemeta qu rand read readdir readline readlink readpipe recv redo ref rename require reset return reverse rewinddir rindex rmdir scalar seek seekdir select semctl semget semop send setgrent sethostent setnetent setpgrp setpriority setprotoent setpwent setservent setsockopt shift shmctl shmget shmread shmwrite shutdown sin sleep socket socketpair sort splice split sprintf sqrt srand stat study sub substr symlink syscall sysopen sysread sysseek system syswrite tell telldir tie tied time times truncate uc ucfirst umask undef unless unlink unpack unshift untie until use utime values vec wait waitpid wantarray warn while write xor given when default say state UNITCHECK});
    $treetext->EnsureCaretVisible;
    return $treetext;
}


sub SelectTreeAtLine {
    my( $tree, $line, $child ) = @_;
    $child ||= $tree->GetRootItem;
    if( $tree->GetChildrenCount( $child ) ){
        my( $item, $cookie ) = $tree->GetFirstChild(  $child );
        while(1){        
            my $data = $tree->GetItemData( $item ) || die;
            my $dataobj = $data->GetData;
            my $col = $dataobj->column_number - 1 ;
            my $row = $dataobj->line_number - 1 ;
            if( $row == $line ){
                $tree->SelectItem( $tree->GetItemParent( $item ), 1 ); ## oy
                return 1;
            }
            ( $item, $cookie ) = $tree->GetNextChild(  $child, $cookie );
            if( $tree->GetChildrenCount( $item )  ){
                last if SelectTreeAtLine( $tree, $line, $item );
            }
            last if not $item->IsOk;
        }
    }
}

sub readFile {
    my( $frame, $file ) = @_;
    open my($fh),'<', $file or die "$!\n$^E\n ";
    binmode $fh, ':encoding(UTF-8)';
    local $/;
    my $thesourcecode = readline $fh;
    close $fh;
    $thesourcecode =~ s/\x{FEFF}//g; ## nuke bom
    $frame->{codetext}->SetValue( $thesourcecode );
}



sub Wx::StyledTextCtrl::SetValue { shift->SetText( @_ ); }
sub Wx::StyledTextCtrl::GetValue { shift->GetText( @_ ); }


BEGIN {
    if( not eval { require Wx::STC; 1 } )
    {
        require Wx::Scintilla;
        @Wx::StyledTextCtrl::ISA = 'Wx::Scintilla::TextCtrl';
    }
}


sub PPI::Statement::serialize {
    my( $ppis ) = @_;
    my $ret = "$ppis";
    my $heredoc = "";
    for my $kid( $ppis->tokens ){
        if( $kid->isa( 'PPI::Token::HereDoc' )  ){
            $heredoc .= join '', $kid->heredoc, $kid->{_terminator_line};
        }
    }
    if ( $heredoc ){
        $ret .= "\n$heredoc";
    }
    return $ret;
}

sub PPI::Token::HereDoc::here_line_range { ## column_number / line_number for ->heredoc
    my( $ppih ) = @_;
    my $here_line_range = $ppih->{_here_line_range} ||= [];
    
    return @$here_line_range if @$here_line_range ;
    
    my $parent = $ppih->parent;
    my $ret = "$ppih";
    my $heredoc = "";
    my $line_range = my $line_range_start = $parent->line_number;
    my $line_range_end = $parent->line_number;
    for my $kid( $parent->tokens ){
        if( $kid->isa( 'PPI::Token::HereDoc' )  ){
            $kid == $ppih and $line_range_start = $line_range;
            $line_range++ for $kid->heredoc, $kid->terminator;
            $kid == $ppih and $line_range_end = $line_range;
        }
    }
    push @$here_line_range, $line_range_start, $line_range_end ;
    return ( $line_range_start, $line_range_end );
}

sub PPIx::Regexp::Element::line_number {
    my( $e ) = @_;
    my $oldparent = $e;
    my $line = eval { $oldparent->{__line_number} };
    
    return $line if defined $line;
    
    my $ix = 0;
    while( my $newparent = eval { $oldparent->_parent } ){
        $oldparent = $newparent;
        $line = eval { $newparent->{__line_number} };
        last if defined $line;
        $ix++;
        last if $ix > 1024;
    }
    
    return $line;
}


sub PPIx::Regexp::Element::column_number {
    my( $e ) = @_;
    my $oldparent = $e;
    my $column = eval { $oldparent->{__column_number} };
    
    return $column if defined $column;
    
    my $ix = 0;
    while( my $newparent = eval { $oldparent->_parent } ){
        $oldparent = $newparent;
        $column = eval { $newparent->{__line_number} };
        return $column if defined $column ;
        $ix++;
        last if $ix > 1024;
    }
    return $column ;
}




sub xPPIx_Regexp_linecol_onize {
    my( $re , $line, $col ) = @_;
    
    if( not ref $re  or  ref($re) =~ m{^(?: PPI::Token::QuoteLike::Regexp | PPI::Token::Regexp::Match | PPI::Token::Regexp::Substitute )$}xs ){
        $re = PPIx::Regexp->new( $re )
            or Carp::croak( "Aww FUDGE ". PPIx::Regexp->errstr() );
    }
    
    $line ||= 1;
    $col  ||= 1;
    $re->{__line_number}   ||= $line ;
    $re->{__column_number} ||= $col  ;
    
    my $ref = ref $re;
    
    for my $start ( eval { $re->start } ){
        xPPIx_Regexp_linecol_onize( $start, $line, $col );
        $col += length $start->content;
    }
    
    if( eval { $re->start } ){
        for my $type ( eval { $re->type } ){
            xPPIx_Regexp_linecol_onize( $type, $line, $col );
            $col += length $type->content;
        }
    }
    
    
    for my $kid( eval { $re->children } ){
        my $rref = ref $kid;
        my $haskids = eval { scalar $kid->children } ;
        
        if( $rref =~ m{^PPIx::Regexp::Token} or not $haskids ){
            ## don't print PPIx::Regexp::Structure::Regexp
            ## don't print PPIx::Regexp::Structure::Replacement
            ## print its start/type/children/finish instead (they add up to parent)
            xPPIx_Regexp_linecol_onize( $kid, $line, $col );
            $col += length $kid->content;
        }
        if( $haskids ){
            xPPIx_Regexp_linecol_onize( $kid, $line, $col );
            $col += length $kid->content;
        }
    }
    
    
    for my $finish ( eval { $re->finish } ){
        xPPIx_Regexp_linecol_onize( $finish, $line, $col );
        $col += length $finish->content;
    }
    
    return $re;
}

__END__


=head1 NAME

ppiwx - wxppi, display L<PPI> DOM in Wx::TreeCtrl, now with color

=head1 USAGE

    ppiwx utf8file.pl anotherutf8file.pl ...

=head1 EXPECTS

expects UTF-8 files, so whateveryou need to do :) 

    iconv -f UTF-16 -t UTF-8 < in > out 
    piconv -f UTF-16LE -t UTF-8 < in > out

=head1 PREREQUISITED

=head1 DEPENDENCIES

=head1 KNOWN TO WORK WITH

    AutoLoader             5.71
    Carp                   1.17
    Clone                  0.31
    Digest::MD5            2.51
    Digest::base           1.16
    DynaLoader             1.10
    Encode                 2.43
    Encode::Alias          2.14
    Encode::Config         2.05
    Encode::Encoding       2.05
    Exporter             5.64_01
    IO::String             1.08
    List::MoreUtils        0.32
    List::Util             1.23
    PPI                   1.215
    PPIx::Regexp          0.034
    PPI::Util             1.215
    Params::Util           1.04
    PerlIO                 1.06
    PerlIO::encoding       0.12
    PerlIO::scalar         0.08
    Scalar::Util           1.23
    Symbol                 1.07
    Tie::Handle             4.2
    Tie::StdHandle          4.2
    Wx                   0.9902
    Wx::AUI                0.01
    Wx::STC                0.01
    Wx::Wx_Exp                 
    XSLoader               0.15
    attributes             0.12
    base                   2.15
    bytes                  1.04
    constant               1.21
    overload               1.10
    utf8                   1.08
    vars                   1.01
    warnings               1.09
    warnings::register     1.01

=head1 AUTHOR

Anonymous Monk

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<http://ali.as/>
L<PPI>
L<Wx>
L<http://www.wxperl.it/>
L<http://wiki.wxperl.it/>
L<http://wiki.wxwidgets.org/>
L<http://forums.wxwidgets.org/>
L<http://docs.wxwidgets.org/>
L<http://www.scintilla.org/>
L<http://perl.org/>

=cut


