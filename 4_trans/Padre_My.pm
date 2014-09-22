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
use File::Temp qw/ tempfile tempdir /;
use YAML::Tiny;
use File::Basename;

our $VERSION = '0.91';

#our @ISA     = 'Padre::Plugin';
use base 'Padre::Plugin';

#read start parameter to connect oracle database!!
my $yaml = get_user_param(); #Global hash with parameters

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
		'About' => sub { $self->show_about('ZZZ') },

		'&Replace_slash'      => sub { $self->replace_slash },
		'Replace_start_digit' => sub { $self->replace_start_digit },
		"Run_perlcritic_from_activeperl\tCtrl-Alt-F3" =>
			sub { $self->run_perlcritic_from_activeperl },

		#'Template_of_module' => sub { $self->template_of_module },
		'Get_trades'                 => sub { $self->get_trades },
		"Jira_link\tCtrl-Alt-F5"     => sub { $self->jira_link },
		"Replace_Space\tCtrl-Alt-F6" => sub { $self->replace_space },
		"Word_to_sql"                => sub { $self->word_to_sql },
		"Template_of_replace"        => sub { $self->template_of_replace },

		"Mi_prod\tCtrl-Alt-F7" => sub {
			$self->execute_oracle_sql( get_connect_string('mishnik') );
		},
		"FBS_EXEC_prod\tCtrl-Alt-F8" => sub {
			$self->execute_oracle_sql( get_connect_string('fbs_exec') );
		},
		"Rwa_fcat_owner_prod\tCtrl-Alt-F9" => sub {
			$self->execute_oracle_sql( get_connect_string('rwa_fcat_owner') );
		},
		"Qv_fbs_ro\tCtrl-Alt-F10" => sub {
			$self->execute_oracle_sql( get_connect_string('qv_fbs_ro') );
		},
		"Rwa_inf_owner\tCtrl-Alt-F11" => sub {
			$self->execute_oracle_sql( get_connect_string('rwa_inf_owner') );
		},
		"Make_jira_code\tCtrl-Alt-F12" => sub {
			$self->make_jira_code;
		},

		'Date_time' => sub { $self->date_time },

		# 'A Sub-Menu...' => [
		#     'Sub-Menu Entry' => sub { $self->yet_another_method },
		# ],
	];
}

sub get_connect_string {
	my $init_user         = shift;
	my $user              = $yaml->{ $init_user . '_un' };
	my $password          = $yaml->{ $init_user . '_pw' };
	my $prod_database_tns = $yaml->{prod_database_tns};
	my $driver            = $yaml->{driver};

	return " sqlsh -d DBI:$driver:$prod_database_tns -u $user -p $password -i < ";
}

sub get_user_param {
	my $path = File::Spec->catfile( Padre::Constant::CONFIG_DIR,
		qw{  plugins Padre Plugin My.pm  }
	);
	my $orig_path = dirname($path);
	$orig_path =~ s#\\#/#g;
	my $my_yml_file = $orig_path . q{/My.yml};

	# Open the config
	my $yaml = YAML::Tiny::LoadFile($my_yml_file);
	return $yaml;
}

#####################################################################
# Custom Methods

sub show_about {
	my $self      = shift;
	my $test_text = shift;

	my $path = File::Spec->catfile( Padre::Constant::CONFIG_DIR,
		qw{  plugins Padre Plugin My.pm  }
	);

	#my $document = Padre::Current->document;
	my $editor      = Padre::Current->editor;
	my $editor_dump = Dumper($editor);

	# Generate the About dialog
	my $about = Wx::AboutDialogInfo->new;
	$about->SetName('My Plug-in');
	$about->SetDescription( <<"END_MESSAGE" );
The philosophy behind Padre is that every Perl programmer
should be able to easily modify and improve their own editor.

To help you get started, we've provided you with your own plug-in.

It is located in your configuration directory at:
$path

$test_text

$editor_dump

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
	my $main         = shift;
	my $replace_text = shift;

	#my $main         = shift;

	# Tidy the current selected text
	my $current = $main->current;
	my $text    = $current->text;

	# my $main         = $self->main;
	# my $doc          = Padre::Current->document;
	# my $text         = $doc->text_get();

	my @all_text_lines = split "\n", $text;
	my $out_line = "";

	#change every line in text
	for my $current_line (@all_text_lines) {
		$out_line .= &$replace_text($current_line);
	}

	my $editor = Padre::Current->editor;
	$editor->ReplaceSelection('');
	my $pos = $editor->GetCurrentPos;
	$editor->InsertText( $pos, $out_line );
	return;

	#$doc->text_set($out_line);
	#return;
}


sub jira_link {
	my $self = shift;

	my $ref_replace_text = sub {
		my $in_text = shift;
		$in_text =~ s{([A-Z]+-\d+)\s+}{[$1\|http://jira.gto.intranet.db.com:2020/jira/browse/$1] };
		return $in_text;
	};

	change_text( $self, $ref_replace_text );
	return;
}

sub replace_space {
	my $self = shift;

	my $ref_replace_text = sub {
		my $in_text = shift;

		###Change this text
		#| 1000637L       | 29                | SWOPT      |
		#$in_text =~ s{\|\s+(\w+)\s+\|\s+(\w+)\s*\|\s*(\w+)\s*\|\s*}{$1,$2,$3\n};
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

sub make_jira_code {
	my $main    = shift;
	my $current = $main->current;
	my $text    = $current->text;

	my $jira_code = '{code}' . "\n" . $text . "\n" . '{code}';
	insert_into_selection($jira_code);
	return;
}




sub check_file {
	my $file_name = shift;
	if ( !-e $file_name ) {
		die "\$file_name=$file_name not exists on system";
	}
}

sub message {
	my $main        = shift;
	my $echo_string = shift;
	my $main_object = $main->main;
	$main_object->message($echo_string);
}

#
# Create commands for interactive mode sqlsh - Fri Sep 30 20:46:13 2011.
#
sub get_sqlsqh_cmd {
	my $sql_result_file = shift;
	my $sql_query       = shift;

	#Commands for exec in sqlsh
	my $sqlsqh_command = <<"END_SQLSQH_COMMAND";
set multiline on;
ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY HH24:MI';
ALTER SESSION SET CURRENT_SCHEMA = $yaml->{current_schema};
set log-mode box;
log queries $sql_result_file;
$sql_query
no log;
exit;    
END_SQLSQH_COMMAND

	return $sqlsqh_command;
}

sub execute_oracle_sql {
	my $main           = shift;
	my $connect_string = shift;

	my $current   = $main->current;
	my $sql_query = $current->text;

	my $sql_cmd_file    = get_tmp_file( 'sql', '.sql' );
	my $sql_result_file = get_tmp_file( 'rez', '.dat' );

	#add ; in the finish of sql query if ; not exists
	if ( $sql_query !~ m/;/xms ) { $sql_query .= ';' }
	my $sqlsqh_cmd = get_sqlsqh_cmd( $sql_result_file, $sql_query );

	#Write and exec sql command in cygwin
	file_write( $sql_cmd_file, $sqlsqh_cmd );
	my $exec_shell = $yaml->{cygwin_run} . $connect_string . $sql_cmd_file;
	file_write( $yaml->{cmd_file}, $exec_shell );

	#	$main->message( $yaml->{cygwin_run} );
	my $a = run_shell( $yaml->{cmd_file} );

	#sleep(2);
	my $ready_rows = make_wiki_header($sql_result_file) or carp("cannot open $sql_result_file");
	my $sql_result = $sql_query . "\n" . time_now() . "\n" . $ready_rows;
	insert_into_selection($sql_result);
	return;
}

sub time_now {
	return scalar localtime;
}

#
# Insert result text into current selection - Fri Sep 30 20:54:06 2011.
#
sub insert_into_selection {
	my $text_to_insert = shift;
	my $editor         = Padre::Current->editor;
	$editor->ReplaceSelection('');
	my $pos = $editor->GetCurrentPos;
	$editor->InsertText( $pos, $text_to_insert );
	return;
}

sub file_write {
	my ( $file, $message ) = @_;
	open my $fh, q{>}, "$file" or croak "unable to open:$file $ERRNO";
	my $ret = print {$fh} $message;
	close $fh or croak "unable to close: $file $ERRNO";
	return 1;
}

#refactoring
# New subroutine "get_tmp_file" extracted - Fri Sep 30 07:12:03 2011.
#
sub get_tmp_file {

	my $suffix_for_log         = shift;
	my $extention_for_log      = shift;
	my $tmp_file_name_template = 'tmp_' . $suffix_for_log . '_XXXXXX';
	my ( undef, $out_file ) = tempfile(
		$tmp_file_name_template,
		OPEN   => 0,
		UNLINK => 0,
		DIR    => $yaml->{tmp_dir},
		SUFFIX => $extention_for_log,
	);

	return $out_file;
}

#m/(\w+)\s*\(v[.](\d+)\)/imx
#N291176N (v.44), N291177N (v.47), C828906M (v.13), C826196M (v.19)
sub get_trades {
	my $self = shift;

	my $ref_replace_text = sub {
		my $in_text = shift;

		###Change this text
		my @out_text = split /,/, $in_text;

		# bad !!! my $RGX_TRADE = /(\w+)\s*\(v[.](\d+)\)/imx; #.*(([0-9]{2}-Jan|Feb|Mar)|(01-Apr))-2011.*[.]xml$/;
		my $RGX_TRADE = qr/(\w+)\s*\(v[.](\d+)\)/smo;
		my $out_text;
		my $tr;
		my @ch_ar = ();
		for my $line (@out_text) {
			if ( $line =~ m/$RGX_TRADE/sm ) {
				push @ch_ar, $1 . ',' . $2;
			}
		}
		$out_text = join "\n", @ch_ar;

		#$in_text =~ s{(\w+)}{'$1',};


		return $out_text;
	};

	change_text( $self, $ref_replace_text );
	return;
}

sub make_wiki_header {
	my ($query_file) = @_;
	my @sql_rezult_rows = read_file($query_file); # or croak("cannot read $query_file")
	my @filtered_lines = grep { !/[+][-]{4}/ } @sql_rezult_rows;

	#my @header_lines = split /[ ]*[|][ ]*/, $filtered_lines[0];
	my @header_lines = split /[|]/, $filtered_lines[0];
	my $in = join '||', @header_lines;
	chop($in);
	chop($in);
	$filtered_lines[0] = $in . "\n";
	my $ret_lines = join '', @filtered_lines;
	return $ret_lines; #\@filtered_lines;
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
	#$main->message($exec_shell);

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
	; # Give end of file to kid.

	if ($HIS_OUT) {
		my @outlines = <$HIS_OUT>; # Read till EOF.
		$ret = print " STDOUT:\n", @outlines, "\n";
	}
	if ($HIS_ERR) {
		my @errlines = <$HIS_ERR>; # XXX: block potential if massive
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