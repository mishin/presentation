package Padre::Plugin::My;

use 5.008;
use strict;
use warnings;
use utf8;
use Padre::Constant ();
use Padre::Plugin   ();
use Padre::Wx       ();
use Data::Dumper;
use IPC::Open3 'open3';
use Carp;
use English qw(-no_match_vars);
use File::Slurp;

our $VERSION = '0.84';

#our @ISA     = 'Padre::Plugin';
use base 'Padre::Plugin';

#^@ISA used instead of "use base"

#####################################################################
# Padre::Plugin Methods

sub padre_interfaces {
    return (
        'Padre::Plugin'   => 0.66,
        'Padre::Constant' => 0.66,
    );
}

sub plugin_name {
    return 'My Plugin';
}

sub menu_plugins_simple {
    my $self = shift;
    return $self->plugin_name => [
        'About' => sub { $self->show_about },

        '&Replace_slash'      => sub { $self->replace_slash },
        'Replace_start_digit' => sub { $self->replace_start_digit },
        "Run_perlcritic_from_activeperl\tCtrl-Alt-F3" =>
          sub { $self->run_perlcritic_from_activeperl },
        'Template_of_module' => sub { $self->template_of_module },

        "Jira_link\tCtrl-Alt-F5"     => sub { $self->jira_link2 },
        "Replace_Space\tCtrl-Alt-F6" => sub { $self->seplace_space },
        "Word_to_sql"                => sub { $self->word_to_sql },
        "Template_of_replace"        => sub { $self->template_of_replace },
        "Execute_selection_in_Oracle\tCtrl-Alt-F7" =>
          sub { $self->execute_selection_in_oracle },

        'Date_time' => sub { $self->date_time },

        # 'A Sub-Menu...' => [
        #     'Sub-Menu Entry' => sub { $self->yet_another_method },
        # ],
    ];
}

#####################################################################
# Custom Methods

sub show_about {
    my $self = shift;

    # Locate this plugin
    my $path = File::Spec->catfile( Padre::Constant::CONFIG_DIR,
        qw{ plugins Padre Plugin My.pm } );

    # Generate the About dialog
    my $about = Wx::AboutDialogInfo->new;
    $about->SetName('My Plug-in');
    $about->SetDescription( <<"END_MESSAGE" );
The philosophy behind Padre is that every Perl programmer
should be able to easily modify and improve their own editor.

To help you get started, we've provided you with your own plug-in.

It is located in your configuration directory at:
$path
Open it with with Padre and you'll see an explanation on how to add items.
END_MESSAGE

    # Show the About dialog
    Wx::AboutBox($about);

    return;
}

sub replace_slash {
    my $self = shift;
    my $main = $self->main;

    my $doc  = Padre::Current->document;
    my $text = $doc->text_get();
    $text =~ s#\\#/#g;
    $doc->text_set($text);

    return;
}

sub replace_start_digit {
    my $self = shift;
    my $main = $self->main;

    my $doc  = Padre::Current->document;
    my $text = $doc->text_get();
    $text =~ s/^\s*[0-9]//mg;

#$text =~ s/FRWA-(\d+)/[FRWA-$1|http://jira.gto.intranet.db.com:2020/jira/browse/FRWA-$1]/mg;
    $doc->text_set($text);

    return;
}

sub change_text {
    my $self         = shift;
    my $replace_text = shift;
    my $main         = $self->main;
    my $doc          = Padre::Current->document;
    my $text         = $doc->text_get();

    my @all_text_lines = split "\n", $text;
    my $out_line = "";

    #change every line in text
    for my $current_line (@all_text_lines) {
        $out_line .= &$replace_text($current_line);
    }

    $doc->text_set($out_line);
    return;
}

# my $func_ref = sub {
# my $get = shift;
# my $new_txt =      s#([A-Z]+-\d+)#[$1\|http://jira.gto.intranet.db.com:2020/jira/browse/$1]#;
# return $new_txt;
# };

sub jira_link2 {
    my $self = shift;

    my $ref_replace_text = sub {
        my $in_text = shift;
        $in_text =~
s{([A-Z]+-\d+)\s+}{[$1\|http://jira.gto.intranet.db.com:2020/jira/browse/$1]};
        return $in_text;
    };

    change_text( $self, $ref_replace_text );
    return;
}

sub selace_space {
    my $self = shift;

    my $ref_replace_text = sub {
        my $in_text = shift;

        ###Change this text
        $in_text =~ s{(\w+)\s+(\w+)\s+(\w+)}{$1,$2,$3};

        return $in_text;
    };

    change_text( $self, $ref_replace_text );
    return;
}

sub word_to_sql {
    my $self = shift;

    #Mon Sep 19 20:42:12 2011
    #C:\Users\nmishin\AppData\Local\Perl\Padre\plugins\Padre\Plugin\My.pm
    #11619

    my $ref_replace_text = sub {
        my $in_text = shift;

        ###Change this text
        $in_text =~ s{(\w+)}{'$1',};

        return $in_text;
    };

    change_text( $self, $ref_replace_text );
    return;
}

sub jira_link {
    my $self = shift;
    my $main = $self->main;
    my $doc  = Padre::Current->document;
    my $text = $doc->text_get();

    $text =~
s#([A-Z]+-\d+)[^|]{1}#[$1\|http://jira.gto.intranet.db.com:2020/jira/browse/$1]#;
    $doc->text_set($text);
    return;
}

sub date_time {
    my $self = shift;
    my $main = $self->main;
    my $doc  = Padre::Current->document;
    my $text = $doc->text_get();
    my ( $sec, $min, $hour, $day, $month, $yr19, @rest ) = localtime(time);
    my $dt = sprintf qq{%04d-%02d-%02d %02d:%02d:%02d mishin}, $yr19 + 1900,
      ++$month, $day, $hour, $min, $sec;
    $text =~ s#Date\#time#$dt#;
    $doc->text_set($text);
    return;
}

sub template_of_replace {
    my $self = shift;
    my $main = $self->main;

    my $doc      = Padre::Current->document;
    my $text     = $doc->text_get();
    my $template = <<'END_MESSAGE';
sub word_to_sql {
    my $self = shift;

    my $ref_replace_text = sub {
        my $in_text = shift;
        
        ###Change this text
        $in_text =~ s{(\w+)}{'$1',};
        
        
        return $in_text;
    };

    change_text( $self, $ref_replace_text );
    return;
}
END_MESSAGE

    my $editor = Padre::Current->editor;
    $editor->ReplaceSelection('');
    my $pos = $editor->GetCurrentPos;
    $editor->InsertText( $pos, $template );
    return;
}

sub execute_selection_in_oracle {
    my $main = shift;

    # Tidy the current selected text
    my $current = $main->current;
    my $text    = $current->text;

    # Generate the About dialog
    #my $about = Wx::AboutDialogInfo->new;
    #$about->SetName('Show_selection');

    use File::Temp qw/ tempfile tempdir /;

    #$fh = tempfile();
    #my ( $fh, $out_file ) = tempfile();
    my ( undef, $out_file ) = tempfile(
        'tmp_sql_XXXXXX',
        OPEN   => 0,
        UNLINK => 0,
        DIR    => 'c:/Users/nmishin/Documents/git/cygwin',
        SUFFIX => '.dat',
    );

    my ( undef, $log_file ) = tempfile(
        'tmp_log_XXXXXX',
        OPEN   => 0,
        UNLINK => 0,
        DIR    => 'c:/Users/nmishin/Documents/git/cygwin',
        SUFFIX => '.dat',
    );

    my ( undef, $query_file ) = tempfile(
        'tmp_qry_XXXXXX',
        OPEN   => 0,
        UNLINK => 0,
        DIR    => 'c:/Users/nmishin/Documents/git/cygwin',
        SUFFIX => '.dat',
    );

    #my $out_file = get_temp_filename();
    if ( $text !~ m/;/xms ) { $text .= ';' }

    #print "file:$filename\n";
    my $sqlsqh_command = <<"END_SQLSQH_COMMAND";
set multiline on;
ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY HH24:MI';
ALTER SESSION SET CURRENT_SCHEMA = RWA_OWNER;
set log-mode box;
log commands $log_file;
log queries $query_file;
$text
no log;
exit;    
END_SQLSQH_COMMAND

    my $main_object = $main->main;
    $main_object->message($sqlsqh_command);

    open my $out, '>', $out_file
      or croak "Couldn't open '$out_file': $OS_ERROR";
    print {$out} $sqlsqh_command
      or croak "Couldn't write '$out_file': $OS_ERROR";
    close $out or croak "Couldn't close '$out_file': $OS_ERROR";

#c:\cygwin\cygwin_here.bat sqlsh  -d DBI:Oracle:FRFCLOP1.DE.DB.COM -u mishnik -p quux7AiK -i < c:\Users\nmishin\Documents\svn\misc\chunk_status\sqlsh_command.sqlsh

    my $exec_shell =
q{c:\cygwin\cygwin_here.bat sqlsh  -d DBI:Oracle:FRFCLOP1.DE.DB.COM -u mishnik -p quux7AiK -i < }
      . $out_file;

    $main_object->message($exec_shell);
    my $cmd_file = 'c:/Users/nmishin/Documents/git/cygwin/sqlsh_command.bat';
    open my $cmd_out, '>', $cmd_file
      or croak "Couldn't open '$cmd_file': $OS_ERROR";
    print {$cmd_out} $exec_shell
      or croak "Couldn't write '$cmd_file': $OS_ERROR";
    close $cmd_out or croak "Couldn't close '$cmd_file': $OS_ERROR";

    #    $main->message($exec_shell);

    my $a = run_shell($exec_shell);

    my $sql_result = $text . "\n" . read_file($query_file);

    my $editor = Padre::Current->editor;
    $editor->ReplaceSelection('');
    my $pos = $editor->GetCurrentPos;
    $editor->InsertText( $pos, $sql_result );
    return;

}

sub run_sql {
    my $self = shift;
    my $main = $self->main;
    my $doc  = Padre::Current->document;

    my $filename = $doc->filename;

#c:\cygwin\cygwin_here.bat sqlsh  -d DBI:Oracle:FRFCLOP1.DE.DB.COM -u mishnik -p quux7AiK -i < c:\Users\nmishin\Documents\svn\misc\chunk_status\sqlsh_command.sqlsh
#C:\cygwin\Cygwin.bat
#C:\Users\nmishin>c:\cygwin\bin\perl.exe c:\cygwin\bin\perldoc DBD::Oracle
#sqlsh -d DBI:Oracle:FRFCLOP1.DE.DB.COM -u mishnik -p quux7AiK -i < /cygdrive/c/Users/nmishin/Documents/svn/misc/chunk_status/sqlsh_command.sqlsh
#  c: \cygwin \bin \perl . exe
    my $exec_shell =
q{C:\Perl\bin\wperl.exe -x "C:\Perl\bin\perlcritic-gui" c:\Users\nmishin\Documents\git\perlcritic\perlcritic_profile.perlcriticrc }
      . $filename
      . q{ --run};
    $main->message($exec_shell);

    my $a = run_shell($exec_shell);
    return;
}

sub template_of_module {
    my $self = shift;
    my $main = $self->main;

    my $doc = Padre::Current->document;

    my $template = <<"END_MESSAGE";
=head1 NAME

<Module::Name> - <One-line description of module's purpose>

=head1 VERSION

The initial template usually just has:

This documentation refers to <Module::Name> version 0.0.1.

=head1 SYNOPSIS

   use <Module::Name>;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.

=head1 DESCRIPTION

A full description of the module and its features.

May include numerous subsections (i.e., =head2, =head3, etc.).

=head1 SUBROUTINES/METHODS

A separate section listing the public components of the module's interface.

These normally consist of either subroutines that may be exported, or methods
that may be called on objects belonging to the classes that the module
provides.

Name the section accordingly.

In an object-oriented module, this section should begin with a sentence (of the
form "An object of this class represents ...") to give the reader a high-level
context to help them understand the methods that are subsequently described.

=head1 DIAGNOSTICS

A list of every error and warning message that the module can generate (even
the ones that will "never happen"), with a full explanation of each problem,
one or more likely causes, and any suggested remedies.

=head1 CONFIGURATION AND ENVIRONMENT

A full explanation of any configuration system(s) used by the module, including
the names and locations of any configuration files, and the meaning of any
environment variables or properties that can be set. These descriptions must
also include details of any configuration language used.

=head1 DEPENDENCIES

A list of all of the other modules that this module relies upon, including any
restrictions on versions, and an indication of whether these required modules
are part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.

=head1 INCOMPATIBILITIES

A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for system
or program resources, or due to internal limitations of Perl (for example, many
modules that use source code filters are mutually incompatible).

=head1 BUGS AND LIMITATIONS

A list of known problems with the module, together with some indication of
whether they are likely to be fixed in an upcoming release.

Also, a list of restrictions on the features the module does provide: data types
that cannot be handled, performance issues and the circumstances in which they
may arise, practical limitations on the size of data sets, special cases that
are not (yet) handled, etc.

The initial template usually just has:

There are no known bugs in this module.

Please report problems to <Maintainer name(s)> (<contact address>)

Patches are welcome.

=head1 AUTHOR

<Author name(s)>  (<contact address>)

=head1 LICENSE AND COPYRIGHT

Copyright (c) <year> <copyright holder> (<contact address>).
All rights reserved.

followed by whatever license you wish to release it under.

For Perl code that is often just:

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
END_MESSAGE

    $doc->text_set($template);

    return;
}

#C:\Perl\bin\wperl.exe -x "C:\Perl\bin\perlcritic-gui" c:\Users\kshunkov\Documents\perl\python\get_trade\get_trade.pl

sub run_perlcritic_from_activeperl {
    my $self = shift;
    my $main = $self->main;
    my $doc  = Padre::Current->document;

    my $filename = $doc->filename;

    my $exec_shell =
q{C:\Perl\bin\wperl.exe -x "C:\Perl\bin\perlcritic-gui" c:\Users\nmishin\Documents\git\perlcritic\perlcritic_profile.perlcriticrc }
      . $filename
      . q{ --run};
    $main->message($exec_shell);

    my $a = run_shell($exec_shell);
    return;
}

sub run_shell {
    my ($cmd) = @_;
    my @args  = ();
    my $EMPTY = q{};
    my $ret   = undef;
    my ( $HIS_IN, $HIS_OUT, $HIS_ERR ) = ( $EMPTY, $EMPTY, $EMPTY );
    my $childpid = open3( $HIS_IN, $HIS_OUT, $HIS_ERR, $cmd, @args );
    $ret = print {$HIS_IN} "stuff\n";
    close $HIS_IN or croak "unable to close: $HIS_IN $ERRNO";
    ;    # Give end of file to kid.

    if ($HIS_OUT) {
        my @outlines = <$HIS_OUT>;    # Read till EOF.
        $ret = print " STDOUT:\n", @outlines, "\n";
    }
    if ($HIS_ERR) {
        my @errlines = <$HIS_ERR>;    # XXX: block potential if massive
        $ret = print " STDERR:\n", @errlines, "\n";
    }
    close $HIS_OUT or croak "unable to close: $HIS_OUT $ERRNO";

    #close $HIS_ERR or croak "unable to close: $HIS_ERR $ERRNO";#bad..todo
    waitpid $childpid, 0;
    if ($CHILD_ERROR) {
        $ret = print "That child exited with wait status of $CHILD_ERROR\n";
    }
    return 1;
}

sub other_method {
    my $self = shift;
    my $main = $self->main;

    $main->message( 'Hi from My Plugin', 'Other method' );

# my $name = $main->prompt('What is your name?', 'Title', 'UNIQUE_KEY_TO_REMEMBER');
# $main->message( "Hello $name", 'Welcome' );

    # my $doc   = Padre::Current->document;
    # my $text  = $doc->text_get;
    # my $count = length($text);
    # my $filename = $doc->filename;
    # $main->message( "Filename: $filename\nCount: $count", 'Current file' );

    # my $doc   = Padre::Current->document;
    # my $text  = $doc->text_get();
    # $text     =~ s/[ \t]+$//m;
    # $doc->text_set( $text );

    return;
}

1;

__END__

=pod

=head1 NAME

Padre::Plugin::My - My personal plug-in

=head1 DESCRIPTION

This is your personal plug-in. Update it to fit your needs. And if it
does interesting stuff, please consider sharing it on C<CPAN>!

=head1 COPYRIGHT & LICENSE

Currently it's copyrighted © 2008-2010 by The Padre development team as
listed in Padre.pm... But update it and it will become copyrighted © You
C<< <mi@ya.ru> >>! How exciting! :-)

=cut

# Copyright 2008-2011 The Padre development team as listed in Padre.pm.
# LICENSE
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl 5 itself.
