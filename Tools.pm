#!/usr/bin/perl
package Dsx_parse::Tools;
use v5.14;
use utf8;
use warnings;
use strict;
use Carp;
use DBI;
use Encode::Locale;
use Data::Dumper;
use Tie::IxHash;
use Spreadsheet::WriteExcel;
use Text::ASCIITable;
use POSIX qw(strftime);
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use File::Slurp;
use Data::Printer {
    output         => 'stdout',
    hash_separator => ': ',
    return_value   => 'pass',
};
use Data::TreeDumper;
use Hash::Merge qw( merge );

#use Smart::Comments;

#-------------------------------------------------------------------
# package setup data
#-------------------------------------------------------------------

#$Data::TreeDumper::Useascii = 0 ;
#$Data::TreeDumper::Maxdepth = 2 ;
# $Data::TreeDumper::Displaycallerlocation=1;

use version; our $VERSION = qv('0.0.1');
use Sub::Exporter -setup => {
    exports => [
        qw/
          invoke_orchestrate_code
          conDB
          read_DATA
          get_job_name
          read_file
          enc_terminal
          parse_orchestrate_body
          reformat_links
          show_dsx_content
          /
    ],
};

sub enc_terminal {
    if (-t) {
        binmode( STDIN,  ":encoding(console_in)" );
        binmode( STDOUT, ":encoding(console_out)" );
        binmode( STDERR, ":encoding(console_out)" );
    }
}

#
# New subroutine "process_parameters_properties" extracted - Thu Oct 30 15:25:16 2014.
#
sub process_parameters_properties {
    my ( $parameter_set_body, $PARAMETER_RX ) = @_;
    while ( $parameter_set_body =~ m/$PARAMETER_RX/g ) {
        print "\nFound Parameter Name: $+{parameter_name}\n";
        print "Found ParameterPrompt: "
          . from_dsx_2_utf( $+{parameter_prompt} ) . " \n";
        print "Found ParameterHelpText: "
          . from_dsx_2_utf( $+{parameter_help_text} ) . " \n"
          if defined $+{parameter_help_text};
        print "Found DefaultValue: "
          . double_slash_2_slash( $+{default_value} ) . " \n"
          if defined $+{default_value};
        print "Found ParamType: " . decode_param_type( $+{param_type} ) . " \n";
    }
}

#
# New subroutine "process_orchestrate_code_properties" extracted - Thu Oct 30 15:25:16 2014.
# my $ORCHESTRATE_CODE_RX =qr#STAGE: (?<stage_name>\w+).*?Operator\n(?<operator_name>\w)\n.*?source 0 '{(<?source_body>.*?)\n}'#s;
sub process_orchestrate_code_properties {
    my ( $orchestrate_code_body, $ORCHESTRATE_CODE_RX ) = @_;
    my $fields;
    my @stage_and_fields    = ();
    my $ORCHESTRATE_BODY_RX = make_regexp();
    while ( $orchestrate_code_body =~ m/$ORCHESTRATE_BODY_RX/g ) {

        my %stage_and_fields = ();
        say "Found Orchestrate StageName: $+{stage_name}";
        say "Found Orchestrate OperatorName: $+{operator_name}";
        $stage_and_fields{stage_name}    = $+{stage_name};
        $stage_and_fields{operator_name} = $+{operator_name};
        if ( defined $+{stage_body} ) {

            # print "Found Orchestrate SourceBody: $+{source_body}\n";
            $fields = process_orchestrate_body( $+{stage_body} );
            $stage_and_fields{fields} = $fields;

            # print DumpTree($fields, 'fields');
        }

# my $ORCHESTRATE_CODE_RX =
# qr{STAGE: (?<stage_name>\w+).*?Operator\n(?<operator_name>\w+)(.*?\-source 0 \'\{(?<source_body>.*?)\n\}\'|.*?)(\#\# Inputs\n0\< \[.*?\] '(?<inputs_name>.*?)'|.*?)(\#\# Outputs\n0\> \[.*?\] '(?<outputs_name>.*?)'|.*?)}s;
        if ( defined $+{inputs_name} ) {
            $stage_and_fields{inputs_name} = $+{inputs_name};
        }
        if ( defined $+{outputs_name} ) {
            $stage_and_fields{outputs_name} = $+{outputs_name};
        }
        push @stage_and_fields, \%stage_and_fields;
    }
    return \@stage_and_fields;    #\%stage_and_fields;
}

#
# New subroutine "process_orchestrate_code_properties" extracted - Thu Oct 30 15:25:16 2014.
# my $ORCHESTRATE_CODE_RX =qr#STAGE: (?<stage_name>\w+).*?Operator\n(?<operator_name>\w)\n.*?source 0 '{(<?source_body>.*?)\n}'#s;

=pod
DSSQLType={WRH_IDAT=1, PREV_WRH_IDAT=1, ALERT_FLG=4, UPP_IDAT=9},
DSSQLPrecision={WRH_IDAT=10, PREV_WRH_IDAT=10, ALERT_FLG=4, UPP_IDAT=10},
DSSchema=\\'record
(
WRH_IDAT\\:string\\[10\\]\\;
PREV_WRH_IDAT\\:string\\[10\\]\\;
ALERT_FLG\\:int32\\;
UPP_IDAT\\:nullable date\\;
)\\'
=cut	

sub process_orchestrate_body {
    my ($orchestrate_code_body) = @_;
    my $ORCHESTRATE_ELEMENTS_RX =
qr#DSSQLType=\{(?<sql_type>.*?)\}.*?DSSQLPrecision=\{(?<sql_precision>.*?)\}.*?DSSchema=.*?\((?<sql_schema>.*?)\)#s;
    my $fields;
    while ( $orchestrate_code_body =~ m/$ORCHESTRATE_ELEMENTS_RX/g ) {

        # print "\nInput Fields:\n";
        # say $+{sql_type};
        # say $+{sql_precision};
        $fields =
          process_orchestrate_sql_type( $+{sql_type}, $+{sql_precision} );
    }
    return $fields;
}

=pod

          if ($@)
        {
	            print "Error [$@] occured!";

            say "DEBUG_keys1:";
			print DumpTree( %hash,   '%hash' );
            print DumpTree( $sql_type,   'sql_type' );
			print DumpTree( $sql_precision,   '%sql_precision' );
            say "END_DEBUG_keys1:";

        }
=cut		

sub process_orchestrate_sql_type {
    my ( $sql_type, $sql_precision ) = @_;
    my $prec_hash = process_orchestrate_sql_precision($sql_precision);
    tie my %hash, 'Tie::IxHash';

    # my @types=split /\s*,\s*/, $sql_type;
    # print DumpTree(\@types,'types');
    %hash = map { split /=/, $_ } ( split /\s*,\s*/, $sql_type );
    my @fields = ();
    for my $key ( keys %hash ) {
        my %hash_datatypes = ();

        # print $key. ": "
        # . decode_sql_type($hash{$key}) . "("
        # . $prec_hash->{$key} . ")\n";

        # say 'DEBUG_$key:'.$key;
        # say 'DEBUG_$hash{$key}:'.$hash{$key};

=pod
CTNUMDOG: VUse of uninitialized value in concatenation (.) or string at Dsx_parse/Tools.pm line 166.
Use of uninitialized value in concatenation (.) or string at Dsx_parse/Tools.pm line 170.
arChar(20)
=cut		  

        $hash_datatypes{field_name} = $key;
        $hash_datatypes{sql_type} =
          decode_sql_type( $hash{$key} ) . "(" . $prec_hash->{$key} . ")";

        push @fields, \%hash_datatypes;
    }
    return \@fields;
}

sub process_orchestrate_sql_precision {
    my $sql_precision = shift;
    my %hash = map { split /=/, $_ } ( split /, /, $sql_precision );
    return \%hash;
}

sub decode_sql_type {
    my $code = shift;
    my %param_type;
    @param_type{ 1, 4, 9, 12, 3, 5, 6, 10 } = (
        'Char',    'Integer',  'Date',    'VarChar',
        'Decimal', 'SmallInt', 'Unnown6', 'Time'
    );
    return $param_type{$code};
}

# Found field_type 1
# Found field_type 10
# Found field_type 12
# Found field_type 3
# Found field_type 4
# Found field_type 5
# Found field_type 9
#
# New subroutine "process_parameters" extracted - Thu Oct 30 15:01:56 2014.
#
sub process_parameters {
    my ( $parameter_sets_body, $COMPILE_PARAM_RX_REF ) = @_;

    #my ( $PARAMETER_RX, $PARAMETER_SET_RX ) = @{$COMPILE_PARAM_RX_REF};
    while (
        $parameter_sets_body =~ m/$COMPILE_PARAM_RX_REF->{PARAMETER_SET_RX}/g )
    {
        print "\n\nFound ParameterSet Name: $+{parameter_set}\n";
        print "Found ParameterSet Desc: "
          . from_dsx_2_utf( $+{parameter_set_desc} ) . " \n";
        process_parameters_properties( $+{parameter_set_body},
            $COMPILE_PARAM_RX_REF->{PARAMETER_RX} );
        my @group_param_val = split( /\\\\\\V/, $+{param_values} );
        for my $group_param (@group_param_val) {
            my @param_val =
              split( /\\S/, double_slash_2_slash($group_param) );
            print "\nFound ParameterSet Values: "
              . join( "\n", @param_val ) . " \n";
        }
    }
}

# $transformer_stage_prop = process_transformer_stage_properties( $stage_body, $CONNECT_PROPERTIES_RX );

=pod
// define our input/output link names
inputname 0 L202;
outputname 0 INS;
outputname 1 UPD;
$TRANSFORMER_STAGE_PROPERTIES_RX
=cut

#
# New subroutine "process_transformer_stage_properties" extracted - Thu Oct 30 15:08:33 2014.
#
sub process_transformer_stage_properties {
    my ($stage_body) = @_;

# my $CONNECT_PROPERTIES_RX =
#qr{BEGIN DSSUBRECORD.*?Name "XMLProperties".*?<Database .*?\Q![CDATA[\E(?<database_name>#.*?#)\Q]]\E.*?<Username .*?\Q![CDATA[\E(?<user_name>#.*?#)\Q]]\E.*?<SelectStatement .*?\Q![CDATA[\E(?<select_statement>.*?)\Q]]\E}s;
    my $TRANSFORMER_STAGE_PROPERTIES_RX =
qr{(?<in_out_param>define our input/output link names\n(\w+ \d+ \w+;\n)+\n)}s;
    my %stage_prop  = ();
    my @input_name  = ();
    my @output_name = ();
    while ( $stage_body =~ m/$TRANSFORMER_STAGE_PROPERTIES_RX/g ) {
        if ( defined $+{in_out_param} ) {
            print "Found in_out_param:" . $+{in_out_param};
            my $in_out_param = $+{in_out_param};
            while ( $in_out_param =~
m/((inputname \d+ (?<input_name>\w+);\n)|(outputname \d+ (?<output_name>\w+);\n))/g
              )
            {
                if ( defined $+{input_name} ) {
                    print "Found input_name:" . $+{input_name} . " \n";
                    push @input_name, $+{input_name};
                }
                if ( defined $+{output_name} ) {
                    print "Found output_name:" . $+{output_name} . " \n";
                    push @output_name, $+{output_name};
                }
            }
            $stage_prop{InputName}  = \@input_name;
            $stage_prop{OutputName} = \@output_name;
        }
    }
    return \%stage_prop;
}

#
# New subroutine "process_connect_properties" extracted - Thu Oct 30 15:08:33 2014.
#
sub process_connect_properties {
    my ( $stage_body, $CONNECT_PROPERTIES_RX ) = @_;
    my %connect_prop = ();
    while ( $stage_body =~ m/$CONNECT_PROPERTIES_RX/g ) {
        if ( defined $+{database_name} ) {
            print "Found DatabaseName: " . $+{database_name} . " \n";
            $connect_prop{DatabaseName} = $+{database_name};
            print "Found UserName: " . $+{user_name} . " \n";
            $connect_prop{UserName} = $+{user_name};
            print "Found SelectStatement: "
              . from_dsx_2_utf( $+{select_statement} ) . " \n";
            $connect_prop{SelectStatement} =
              from_dsx_2_utf( $+{select_statement} );
        }
    }
    return \%connect_prop;
}

#
# New subroutine "process_stage_activity" extracted - Wed Nov 12 18:02:01 2014.
#
sub process_stage_activity {
    my $job_body = shift;
    my @activity = ();
    my $ACTIVITY_REGEX =
qr{\Q**************************************************\E\nL\$V0S(?<activity_number>\d{3})\$START:\n\Q***\E Activity "(?<activity_name>\w+)": Initialize job\n jb\$V0S\g{activity_number} = "(?<job_name>\w+)"(:\'\.\':\("(?<invocation_id>\w+)"\)|)}s;
    while ( $job_body =~ m/$ACTIVITY_REGEX/g ) {
        my %activity = ();
        print "\n\nFound Activity Name: $+{activity_name}";
        print "\nFound Activity Number: $+{activity_number}";
        print "\nFound Activity job_name: $+{job_name}";
        if ( defined $+{invocation_id} ) {
            print "\nFound Activity invocation_id: $+{invocation_id}";
            $activity{invocation_id} = $+{invocation_id};
        }
        $activity{activity_name}   = $+{activity_name};
        $activity{activity_number} = $+{activity_number};
        $activity{job_name}        = $+{job_name};
        push @activity, \%activity;
    }
    return \@activity;
}

#
# New subroutine "process_stage_stages" extracted - Wed Nov 12 18:05:51 2014.
#
sub process_stage_stages {
    my $JOB_STAGE_RX          = shift;
    my $CONNECT_PROPERTIES_RX = shift;
    my $JOB_STAGE_TYPE_RX     = shift;
    my $job_body              = shift;
    my @stages                = ();
    while ( $job_body =~ m/$JOB_STAGE_RX/g ) {
        my @fields_and_types = ();
        my %stage            = ();
        $stage{OLEType}   = $+{ole_type};
        $stage{StageName} = $+{stage_name};

        #p $stage{StageName};
        print "\nFound StageName: " . $+{stage_name} . " \n";
        print "\nFound OLEType " . $+{ole_type} . " \n";
        my $stage_body = $+{stage_body};
        my $FIELD_RECORD_RX =
qr{(?<field_body>BEGIN DSSUBRECORD\s+Name "(?<field_name>\w+)"\s+SqlType "(?<field_type>\w+)".*?Precision "(?<prec_value>\w+)".*?Scale "(?<scale>\d+)".*?Nullable "(?<nullable>\d+).*?KeyPosition "(?<keyposition>\d+).*?(.*?ParsedDerivation "(?<parsed_deriv>.*?)(?<!\\)"|.*?).*?(SourceColumn "(?<source_column>.*?)"|.*?).*?END DSSUBRECORD)}s;

=pod
.*?(.*?Nullable "(?<nullable>.*?).*?(.*?KeyPosition "(?<keyposition>.*?)
      BEGIN DSSUBRECORD
         Name "POREPDATE"
         Description "<none>"
         SqlType "9"
         Precision "10"
         Scale "0"
         Nullable "0"
         KeyPosition "1"
=cut		  

 # write_file('out_stages/'.$+{stage_name}.'_'.$+{ole_type}.'.dsx',$stage_body);
        while ( $stage_body =~ m/$FIELD_RECORD_RX/g ) {

            # p $+;
            #$+{stage_name} out_stages $stage_body
            my %hash_datatypes = ();
            print "\nFound field_name: " . $+{field_name} . " \n";
            print "Found field_type " . $+{field_type} . " \n";
            print "Found prec_value: " . $+{prec_value} . " \n";
            if ( defined $+{parsed_deriv} ) {
                print "Found parsed_deriv: " . $+{parsed_deriv} . " \n";
                $hash_datatypes{parsed_deriv} = $+{parsed_deriv};
            }
            if ( defined $+{source_column} ) {
                print "Found source_column: " . $+{source_column} . " \n";
                $hash_datatypes{source_column} = $+{source_column};
            }
            $hash_datatypes{field_name} = $+{field_name};
            print "Found field_name: " . $hash_datatypes{field_name} . " \n";
            $hash_datatypes{sql_type} =
              decode_sql_type( $+{field_type} ) . "(" . $+{prec_value} . ")";
            print "Found sql_type: " . $hash_datatypes{sql_type} . " \n";

            $hash_datatypes{nullable} = $+{nullable};
            print "Found nullable: " . $hash_datatypes{nullable} . " \n";

            $hash_datatypes{keyposition} = $+{keyposition};
            print "Found keyposition: " . $hash_datatypes{keyposition} . " \n";

            $hash_datatypes{scale} = $+{scale};
            print "Found scale: " . $hash_datatypes{scale} . " \n";

            #p %hash_datatypes;
            push @fields_and_types, \%hash_datatypes;
        }
        $stage{fields_and_types} = \@fields_and_types;
        my ( $connect_prop, $transformer_stage_prop ) = ( '', '' );
        if ( $stage_body =~ m/$JOB_STAGE_TYPE_RX/g ) {
            $stage{StageType} = $+{stage_type};
            print "Found StageType: " . $+{stage_type} . " \n";
            if ( defined $stage{StageType} ) {
                if ( $stage{StageType} eq 'DB2ConnectorPX' ) {
                    $connect_prop = process_connect_properties( $stage_body,
                        $CONNECT_PROPERTIES_RX );
                    $stage{connect_prop} = $connect_prop;
                }
                $transformer_stage_prop =
                  process_transformer_stage_properties($stage_body);
                $stage{transformer_stage_prop} = $transformer_stage_prop;
            }
        }
        push @stages, \%stage;
    }
    return \@stages;
}

#
# New subroutine "process_stage" extracted - Thu Oct 30 14:52:44 2014.
#
sub process_stage {
    my ( $job_body, $COMPILE_RX_REF ) = @_;

    # print DumpTree($job_body,     'job_body');
    # print DumpTree($COMPILE_RX_REF,     'COMPILE_RX_REF');
    my %job_prop;
    while ( $job_body =~ m/$COMPILE_RX_REF->{JOB_DESC_RX}/g ) {

        $job_prop{JobName} = from_dsx_2_utf( $+{job_name} );

        if ( defined( $+{job_description} ) ) {
            $job_prop{JobDesc} = from_dsx_2_utf( $+{job_description} );
        }
    }
    my @fields_all = ();
    my $fields;
    my $only_links;
    if ( $job_body =~ $COMPILE_RX_REF->{ORCHESTRATE_CODE_FULL_RX} ) {

  # say 'We_are_in_the_ORCHESTRATE_CODE_FULL_RX_ZZZ'
  # . $COMPILE_RX_REF
  # ->{ORCHESTRATE_CODE_RX}; #сюда приходим, уже хорошо
  # say 'We_are_in_the_orchestrate_code_body: '
  # . $+{orchestrate_code_body}; #сюда приходим, уже хорошо
        $fields =
          process_orchestrate_code_properties( $+{orchestrate_code_body},
            $COMPILE_RX_REF->{ORCHESTRATE_CODE_RX} );
        my $parsed_dsx = parse_orchestrate_body( $+{orchestrate_code_body} );

        # print "\nDebug_orig\n\n";
        # p $parsed_dsx;
        $only_links = reformat_links($parsed_dsx);

        #show_dsx_content( $parsed_dsx, $file_name );
    }
    my @identlist = ();
    my $job_identlist_value;
    while ( $job_body =~ m/$COMPILE_RX_REF->{IDENTLIST_RX}/g ) {
        $job_identlist_value = $+{job_identlist_value};
    }
    while ( $job_body =~ m/$COMPILE_RX_REF->{CPARAMETERS_RX}/g ) {
        process_parameters_properties( $+{job_parameters},
            $COMPILE_RX_REF->{PARAMETER_RX} );
    }
    my @job_annotation_texts = ();
    while ( $job_body =~ m/$COMPILE_RX_REF->{JOB_ANNOTATION_TEXT_RX}/g ) {
        if ( defined $+{annotation_text} ) {
            push @job_annotation_texts, from_dsx_2_utf( $+{annotation_text} );
        }
    }
    my $ref_stages = process_stage_stages(
        $COMPILE_RX_REF->{JOB_STAGE_RX},
        $COMPILE_RX_REF->{CONNECT_PROPERTIES_RX},
        $COMPILE_RX_REF->{JOB_STAGE_TYPE_RX}, $job_body
    );
    my $ref_activity = process_stage_activity($job_body);
    @job_prop{
        'fields_all', 'IdentList',            'Activity',
        'StagesInfo', 'job_annotation_texts', 'only_links'
      }
      = (
        $fields, $job_identlist_value, $ref_activity, $ref_stages,
        \@job_annotation_texts, $only_links
      );

    # $job_prop{fields_all} = $fields;
    # $job_prop{IdentList} = $job_identlist_value;
    # $job_prop{Activity} = $ref_activity;
    # $job_prop{StagesInfo} = $ref_stages;
    # $job_prop{job_annotation_texts} = \@job_annotation_texts;
    return \%job_prop;
}

sub invoke_orchestrate_code {
    my ($file_name) = @_;
    my $data = read_file($file_name);
    my $ORCHESTRATE_CODE_FULL_RX =
      qr{OrchestrateCode \Q=+=+=+=\E(?<orchestrate_code_body>.*?)\Q=+=+=+=\E}s;
    my $orchestrate_code_body = '';
    if ( $data =~ $ORCHESTRATE_CODE_FULL_RX ) {
        $orchestrate_code_body = $+{orchestrate_code_body};
    }
    return $orchestrate_code_body;
}

sub get_job_name {
    my ($file_name) = @_;
    my $data = read_file($file_name);
    my $ORCHESTRATE_CODE_FULL_RX =
      qr{OrchestrateCode \Q=+=+=+=\E(?<orchestrate_code_body>.*?)\Q=+=+=+=\E}s;
    my $stage_operator =
      qr{STAGE:\s* (?<stage_name>\w+).*?Operator\n(?<operator_name>\w+)};
    my $outputs     = qr{## Outputs.*?'(?<outputs_name>.*?)'};
    my $inputs      = qr{## Inputs.*? '(?<inputs_name>.*?)'};
    my $source_body = qr{-source 0 '{(?<source_body>.*?)\n}'};
    my $ORCHESTRATE_CODE_RX =
qr%($stage_operator(.*?$source_body.*?$outputs)|($stage_operator.*?($inputs)?.*?($outputs)?))%s;
    my $IDENTLIST_RX =
qr{BEGIN DSSUBRECORD.*?Name "IdentList".*?Value "(?<job_identlist_value>.*?)(?<!\\)".*?END DSSUBRECORD}s;
    my $CPARAMETERS_RX =
qr{(?<job_parameters>Parameters "CParameters".*?BEGIN DSSUBRECORD.*ParamScale.*?END DSSUBRECORD)}s;
    my $PARAMETER_RX =
qr{(?<parameter>BEGIN DSSUBRECORD.*?Name "(?<parameter_name>.*?)(?<!\\)".*?Prompt "(?<parameter_prompt>.*?)(?<!\\)"(.*?Default "(?<default_value>.*?)".*?HelpTxt "(?<parameter_help_text>.*?)(?<!\\)".*?|.*?)ParamType "(?<param_type>\d+)".*?END DSSUBRECORD)}s;
    my $PARAMETER_SETS_RX =
      qr{(?<parameter_sets_body>BEGIN DSPARAMETERSETS.*?END DSPARAMETERSETS)}s;
    my $PARAMETER_SET_RX =
qr{(?<parameter_set_body>BEGIN DSRECORD.*?Identifier "(?<parameter_set>\w+)".*?OLEType "CParameterSet".*?ShortDesc "(?<parameter_set_desc>.*?)(?<!\\)".*?ParamValues "(?<param_values>.*?)".*?END DSRECORD)}s;
    my $JOB_RX = qr{(?<job_body>BEGIN DSJOB.*?END DSJOB)}s;
    my $JOB_DESC_RX =
qr{BEGIN DSRECORD.*?OLEType "CJobDefn".*?Name "(?<job_name>\w+)".*?(Description "(?<job_description>.*?)(?<!\\)")?}s;
    my $JOB_ANNOTATION_TEXT_RX =
qr{BEGIN DSRECORD.*?OLEType "CAnnotation".*?AnnotationText "(?<annotation_text>.*?)(?<!\\)"}s;
    my $ole_type =
qr{OLEType "(?<ole_type>CCustomStage|CTransformerStage|CTrxOutput|CTrxInput|CCustomOutput|CCustomInput)"};
    my $name       = qr{Name "(?<stage_name>\w+)"};
    my $stage_type = qr{(StageType "(?<stage_type>\w+)")};
    my $JOB_STAGE_RX =
      qr{(?<stage_body>BEGIN DSRECORD.*?$ole_type.*?$name.*?END DSRECORD)}s;
    my $JOB_STAGE_TYPE_RX =
qr{(?<stage_body>BEGIN DSRECORD.*?$ole_type.*?$name.*?$stage_type.*?END DSRECORD)}s;
    my $CONNECT_PROPERTIES_RX =
qr{BEGIN DSSUBRECORD.*?Name "XMLProperties".*?<Database .*?\Q![CDATA[\E(?<database_name>#.*?#)\Q]]\E.*?<Username .*?\Q![CDATA[\E(?<user_name>#.*?#)\Q]]\E.*?<SelectStatement .*?\Q![CDATA[\E(?<select_statement>.*?)\Q]]\E}s;
    my $JOB_HEADER_RX = qr{BEGIN HEADER(?<job_header>.*?)END HEADER}s;
    my %COMPILE_RX    = ();
    @COMPILE_RX{
        'CPARAMETERS_RX',         'JOB_DESC_RX',
        'JOB_ANNOTATION_TEXT_RX', 'JOB_STAGE_RX',
        'CONNECT_PROPERTIES_RX',  'PARAMETER_RX',
        'IDENTLIST_RX',           'ORCHESTRATE_CODE_FULL_RX',
        'ORCHESTRATE_CODE_RX',    'JOB_STAGE_TYPE_RX'
      }
      = (
        $CPARAMETERS_RX,         $JOB_DESC_RX,
        $JOB_ANNOTATION_TEXT_RX, $JOB_STAGE_RX,
        $CONNECT_PROPERTIES_RX,  $PARAMETER_RX,
        $IDENTLIST_RX,           $ORCHESTRATE_CODE_FULL_RX,
        $ORCHESTRATE_CODE_RX,    $JOB_STAGE_TYPE_RX
      );
    my %COMPILE_PARAM_RX = ();
    @COMPILE_PARAM_RX{ 'PARAMETER_RX', 'PARAMETER_SET_RX' } =
      ( $PARAMETER_RX, $PARAMETER_SET_RX );
    my ( $head_prop, $job_prop );
    my @jobs_properties;
    {
        local $/ = '';    # Paragraph mode
        while ( $data =~ m/$JOB_HEADER_RX/g ) {
            say '';

            $head_prop = process_job_header( $+{job_header} );
        }
        while ( $data =~ m/$JOB_RX/g ) {
            say 'We_are_in_the_JOB_RX2';

            # say $+{job_body};
            $job_prop = process_stage( $+{job_body}, \%COMPILE_RX );
            push @jobs_properties, $job_prop;
        }

        #p $job_prop;
        while ( $data =~ m/$PARAMETER_SETS_RX/g ) {
            say 'We_are_in_the_PARAMETER_SETS_RX3';
            process_parameters( $+{parameter_sets_body}, \%COMPILE_PARAM_RX );
        }
    }
    my @prop_4_excel = ( $head_prop, \@jobs_properties );
    make_revision_history( \@prop_4_excel, $file_name );
}

sub process_job_header {
    my ($job_header) = @_;

=pod
BEGIN HEADER
CharacterSet "CP1251"
ExportingTool "IBM InfoSphere DataStage Export"
ToolVersion "8"
ServerName "PROD-ETL"
ToolInstanceID "AUDIT"
MDISVersion "1.0"
Date "2014-10-29"
Time "14.09.57"
ServerVersion "8.7" ИЛИ    ServerVersion "8.1"
         и похоже регекспы разные
		 хотя это нужно уточнить,
		 пока оставляем одинаковые модули,
		 хотя и была идея раздвоить
		 Dsx_parse_8_7\Tools.pm 
		 Dsx_parse_8_1\Tools.pm 
END HEADER
=cut	

    my %head_prop;
    my $JOB_HEADER_ELEMENTS_RX =
qr{ServerName "(?<server_name>.*?)(?<!\\)".*?ToolInstanceID "(?<project_name>.*?)(?<!\\)".*?ServerVersion "(?<server_version>.*?)(?<!\\)"}s;
    while ( $job_header =~ m/$JOB_HEADER_ELEMENTS_RX/g ) {
        print "Found ServerName: " . $+{server_name} . " \n";
        $head_prop{ServerName} = $+{server_name};
        print "Found ProjectName: " . $+{project_name} . " \n";
        $head_prop{ProjectName} = $+{project_name};
        print "Found ServerVersion: " . $+{server_version} . " \n";
        $head_prop{ServerVersion} = $+{server_version};
    }
    return \%head_prop;
}

sub decode_param_type {
    my $code = shift;
    my %param_type;
    @param_type{ 0, 1, 2, 3, 4, 5, 6, 7, 13 } = (
        'String',   'Encrypted', 'Integer', 'Float',
        'Pathname', 'Lists',     'Date',    'Time',
        'Parameter Set'
    );
    return $param_type{$code};
}

sub from_dsx_2_utf {
    my $string = shift;
    $string =~ s#\Q\(A)\E#\n#g;
    $string =~ s#\Q\(9)\E#\t#g;
    $string =~ s#\\([^(])#$1#g;
    $string =~ s#\\\((...)\)#chr(hex$1)#gsme;
    return $string;
}

sub double_slash_2_slash {
    my $string = shift;
    $string =~ s#\\\\#\\#g;
    return $string;
}

sub get_job_desc {
    my ($file_name) = @_;
    my $data = read_file($file_name);
    my @sample = ( $data =~ m[BEGIN DSJOB\n\s+Identifier "(\w+)"]sg );
    print "Job in $file_name:\n";
    print join "\n", @sample;

    # write_file($file_name.".patched",$data);
}

#
# New subroutine "set_excel_properties" extracted - Wed Nov 5 09:44:48 2014.
#
sub set_excel_properties {
    my $workbook = shift;
    $workbook->set_properties(
        title    => 'Mapping for Reengineering',
        subject  => 'Generated from Datastage',
        author   => 'Nikolay Mishin',
        manager  => '',
        company  => '',
        category => 'mapping',
        keywords => 'mapping, perl, automation',
        comments => 'Автосгенерированный Excel файл',

        # status => 'В Работе',
    );
}

#
# New subroutine "set_excel_formats" extracted - Wed Nov 5 09:47:05 2014.
#
sub set_excel_formats {
    my $workbook = shift;

    # Add a Format
    my $heading = $workbook->add_format(
        align    => 'left',
        bold     => 1,
        border   => 2,
        bg_color => 'silver'
    );

    # size => 20,
    my $rows_fmt = $workbook->add_format( align => 'left', border => 1 );

    # $rows_fmt->set_text_wrap();
    my $date_fmt = $workbook->add_format(
        align      => 'left',
        border     => 1,
        num_format => 'mm.dd.yyyy'
    );
    my $num_fmt = $workbook->add_format(
        align      => 'left',
        border     => 1,
        num_format => '0.0'
    );
    my $url_format = $workbook->add_format(
        color     => 'blue',
        underline => 1,
    );
    my $sql_fmt = $workbook->add_format();
    $sql_fmt->set_text_wrap();
    $sql_fmt->set_size(8);
    $sql_fmt->set_font('Arial Narrow');
    $sql_fmt->set_align('bottom');
    $workbook->set_custom_color( 40, 141, 180, 226 );
    my $map_fmt = $workbook->add_format(
        bold     => 1,
        border   => 2,
        bg_color => 40,
    );
    my %formats;
    @formats{
        'date_fmt',   'heading', 'num_fmt', 'rows_fmt',
        'url_format', 'sql_fmt', 'map_fmt'
      }
      = (
        $date_fmt,   $heading, $num_fmt, $rows_fmt,
        $url_format, $sql_fmt, $map_fmt
      );

#my @formats=( $date_fmt, $heading, $num_fmt, $rows_fmt, $url_format,$sql_fmt,$map_fmt );
    return \%formats;
}

#
# New subroutine "add_write_handler_autofit" extracted - Wed Nov 5 09:49:47 2014.
#
sub add_write_handler_autofit {
    my $sheet = shift;
###############################################################################
   #
   # Add a handler to store the width of the longest string written to a column.
   # We use the stored width to simulate an autofit of the column widths.
   #
   # You should do this for every worksheet you want to autofit.
   #
    $sheet->add_write_handler( qr[\w], \&store_string_widths );
}

#
# New subroutine "fill_excel_header" extracted - Wed Nov 5 09:54:20 2014.
#
sub fill_excel_header {
    my $ref_formats      = shift;
    my $revision_history = shift;
    my $head_prop        = shift;
    my $date             = strftime "%d.%m.%Y", localtime;
    $revision_history->write( 0, 0, "Date",        $ref_formats->{heading} );
    $revision_history->write( 0, 1, "Version",     $ref_formats->{heading} );
    $revision_history->write( 0, 2, "Description", $ref_formats->{heading} );
    $revision_history->write( 0, 3, "Author",      $ref_formats->{heading} );
    $revision_history->write( 1, 0, $date,         $ref_formats->{date_fmt} );
    $revision_history->write( 1, 1, "1.0",         $ref_formats->{num_fmt} );
    $revision_history->write(
        1, 2,
        "Initial version",
        $ref_formats->{rows_fmt}
    );
    $revision_history->write(
        1, 3,
        "Мишин Н.А.",
        $ref_formats->{rows_fmt}
    );
    $revision_history->write( 0, 5, "Project", $ref_formats->{heading} );
    $revision_history->write( 0, 6, "Server",  $ref_formats->{heading} );
    $revision_history->write(
        1, 5,
        $head_prop->{ProjectName},
        $ref_formats->{rows_fmt}
    );
    $revision_history->write(
        1, 6,
        $head_prop->{ServerName},
        $ref_formats->{rows_fmt}
    );
    $revision_history->write( 4, 5, "Id",          $ref_formats->{heading} );
    $revision_history->write( 4, 6, "Parent_id",   $ref_formats->{heading} );
    $revision_history->write( 4, 7, "Sequence",    $ref_formats->{heading} );
    $revision_history->write( 4, 8, "Description", $ref_formats->{heading} );
}

#
# New subroutine "fill_excel_name_stages" extracted - Wed Nov 5 16:08:24 2014.
#
sub fill_excel_name_stages {
    my $ref_formats = shift;
    my $curr_job    = shift;
    my $stages      = shift;
    my $j           = shift;
    $curr_job->write( 5, 3, "StageName", $ref_formats->{heading} );
    $curr_job->write( 6, 3, "StageType", $ref_formats->{heading} );
    my $col = 0;
    for my $stage_element ( @{$stages} ) {
        $curr_job->write(
            5, 4 + $col,
            $stage_element->{StageName},
            $ref_formats->{rows_fmt}
        );
        $curr_job->write(
            6, 4 + $col,
            $stage_element->{StageType},
            $ref_formats->{rows_fmt}
        );
        $col++;
    }
    return 6;
}

# $curr_job->write( $j + 8, $col_map + 4,
# "Expression/Decode", $map_fmt );
#$j, $col,
#
# New subroutine "fill_excel_job_annotation_text" extracted - Wed Nov 5 16:10:45 2014.
#
sub fill_excel_job_annotation_text {
    my $ref_formats              = shift;
    my $curr_job                 = shift;
    my $ref_job_annotation_texts = shift;
    my $j                        = shift;
    $curr_job->write( 'E' . ( 6 + $j ),
        "JobAnnotationText", $ref_formats->{heading} );
    for my $annotation_text ( @{$ref_job_annotation_texts} ) {
        $curr_job->write( 'E' . ( 6 + ++$j ),
            $annotation_text, $ref_formats->{rows_fmt} );
    }
    return $j;
}

#
# New subroutine "header_for_fill_excel_stage_info" extracted - Wed Nov 12 16:40:08 2014.
#
sub header_for_fill_excel_stage_info {
    my $curr_job    = shift;
    my $ref_formats = shift;
    my $col         = shift;
    my $j           = shift;
    $curr_job->write( $j,     $col, "StageName", $ref_formats->{heading} );
    $curr_job->write( $j + 1, $col, "StageType", $ref_formats->{heading} );
    $curr_job->write( $j + 2, $col, "OLEType",   $ref_formats->{heading} );
    $curr_job->write( $j + 3, $col, "DatabaseName/Input",
        $ref_formats->{heading} );
    $curr_job->write( $j + 4, $col, "UserName/Output",
        $ref_formats->{heading} );
    $curr_job->write( $j + 5, $col, "SQL", $ref_formats->{heading} );
    return 1;
}

#
# New subroutine "fill_excel_ai_connector" extracted - Wed Nov 12 16:45:26 2014.
#
sub fill_excel_ai_connector {
    my $curr_job    = shift;
    my $ref_formats = shift;
    my $col         = shift;
    my $j           = shift;
    my $stage       = shift;
### $stage
    if ( defined $stage->{StageType}
        && $stage->{StageType} eq 'DB2ConnectorPX' )
    {
        my $connect_prop = $stage->{connect_prop};
        $curr_job->write(
            $j + 3, $col,
            $connect_prop->{DatabaseName},
            $ref_formats->{rows_fmt}
        );
        $curr_job->write(
            $j + 4, $col,
            $connect_prop->{UserName},
            $ref_formats->{rows_fmt}
        );
        $curr_job->write(
            $j + 5, $col,
            $connect_prop->{SelectStatement},
            $ref_formats->{sql_fmt}
        );
    }
    return 1;
}

#
# New subroutine "fill_excel_ai_input_name" extracted - Wed Nov 12 16:53:26 2014.
#
sub fill_excel_ai_input_name {
    my $col         = shift;
    my $stage_prop  = shift;
    my $max         = shift;
    my $col_map     = shift;
    my $curr_job    = shift;
    my $stages      = shift;
    my $ref_formats = shift;
    my $j           = shift;

    if ( defined $stage_prop->{InputName} ) {
        my @input_name = @{ $stage_prop->{InputName} };
        $curr_job->write( $j + 7, $col_map + 2,
            "@input_name", $ref_formats->{heading} );
        $curr_job->write( $j + 3, $col, "@input_name",
            $ref_formats->{rows_fmt} );
        for my $in_name (@input_name) {
            for my $loc_stage ( @{$stages} ) {
                if ( $loc_stage->{StageName} eq $in_name ) {
                    my $r = 1;
                    for my $single_field ( @{ $loc_stage->{fields_and_types} } )
                    {
                        $curr_job->write(
                            $j + 8 + $r,
                            $col_map + 2,
                            $single_field->{field_name},
                            $ref_formats->{rows_fmt}
                        );
                        $curr_job->write(
                            $j + 8 + $r,
                            $col_map + 3,
                            $single_field->{sql_type},
                            $ref_formats->{rows_fmt}
                        );

                        # my $null =
                        # ($single_field->{nullable} == 0)
                        # ? 'ДА'
                        # : 'НЕТ';

                        # $curr_job->write(
                        # $j + 8 + $r,
                        # $col_map + 4,
                        # $null, $ref_formats->{rows_fmt}
                        # );
                        # my $key =
                        # ($single_field->{keyposition} == 1)
                        # ? 'ДА'
                        # : 'НЕТ';
                        # $curr_job->write(
                        # $j + 8 + $r,
                        # $col_map + 5,
                        # $key, $ref_formats->{rows_fmt}
                        # );

                        $r++;
                        $max = max_q( $max, $r );
                    }
                }
            }
        }
    }
    return $max;
}

#
# New subroutine "fill_excel_ai_output_name" extracted - Wed Nov 12 16:55:49 2014.
#
sub fill_excel_ai_output_name {
    my $col         = shift;
    my $stage_prop  = shift;
    my $max         = shift;
    my $col_map     = shift;
    my $curr_job    = shift;
    my $stages      = shift;
    my $ref_formats = shift;
    my $j           = shift;

    if ( defined $stage_prop->{OutputName} ) {
        my @output_name = @{ $stage_prop->{OutputName} };
        $curr_job->write( $j + 7, $col_map, "@output_name",
            $ref_formats->{heading} );
        $curr_job->write( $j + 4, $col, "@output_name",
            $ref_formats->{rows_fmt} );
        for my $out_name (@output_name) {
            for my $loc_stage ( @{$stages} ) {
                if ( $loc_stage->{StageName} eq $out_name ) {
                    my $q = 1;
                    for my $single_field ( @{ $loc_stage->{fields_and_types} } )
                    {
                        $curr_job->write(
                            $j + 8 + $q,
                            $col_map,
                            $single_field->{field_name},
                            $ref_formats->{rows_fmt}
                        );
                        $curr_job->write(
                            $j + 8 + $q,
                            $col_map + 1,
                            $single_field->{sql_type},
                            $ref_formats->{rows_fmt}
                        );

                        # my $null =
                        # ($single_field->{nullable} == 0)
                        # ? 'ДА'
                        # : 'НЕТ';

                        # $curr_job->write(
                        # $j + 8 + $q,
                        # $col_map + 2,
                        # $null, $ref_formats->{rows_fmt}
                        # );
                        # my $key =
                        # ($single_field->{keyposition} == 1)
                        # ? 'ДА'
                        # : 'НЕТ';
                        # $curr_job->write(
                        # $j + 8 + $q,
                        # $col_map + 3,
                        # $key, $ref_formats->{rows_fmt}
                        # );

                        $q++;
                        $max = max_q( $max, $q );
                    }
                }
            }
        }
    }
    return $max;
}

#
# New subroutine "fill_excel_ai_increment_col_map" extracted - Wed Nov 12 17:02:44 2014.
#
sub fill_excel_ai_increment_col_map {
    my $col_map    = shift;
    my $stage_prop = shift;
    if (   defined $stage_prop->{InputName}
        || defined $stage_prop->{OutputName} )
    {

        # $col_map = $col_map + 6;
        $col_map = $col_map + 10;
    }
    return $col_map;
}

#
# New subroutine "fill_excel_stage_info" extracted - Wed Nov 5 16:12:45 2014.
#
sub fill_excel_stage_info {
    my ( $ref_formats, $curr_job, $col, $stages, $j ) = @_;
    $j = $j + 7;
    header_for_fill_excel_stage_info( $curr_job, $ref_formats, $col, $j );
    my $max     = 0;
    my $col_map = $col;
    for my $stage ( @{$stages} ) {

        #my $cnt=0;
        #if ( defined $stage->{StageType} && $stage->{StageType} ne '' ) {
        $col++;
        $curr_job->write( $j, $col, $stage->{StageName},
            $ref_formats->{rows_fmt} );
        $curr_job->write( $j + 2, $col, $stage->{OLEType},
            $ref_formats->{rows_fmt} );

        # $cnt++;
        $curr_job->write( $j + 1, $col, $stage->{StageType},
            $ref_formats->{rows_fmt} );
        fill_excel_ai_connector( $curr_job, $ref_formats, $col, $j, $stage );
        my $stage_prop = $stage->{transformer_stage_prop};
        fill_excel_ai_header_mapping( $col_map, $curr_job, $ref_formats,
            $stage_prop, $stage, $j );
        $max = fill_excel_ai_input_name( $col, $stage_prop, $max, $col_map,
            $curr_job, $stages, $ref_formats, $j );

        # $col_map=$col_map+2;
        $max = fill_excel_ai_output_name( $col, $stage_prop, $max, $col_map,
            $curr_job, $stages, $ref_formats, $j );
        $col_map = fill_excel_ai_increment_col_map( $col_map, $stage_prop );

        # }
        # print "\nDEbug\nStageType_cnt=$cnt\nDEbug\n";
    }
    $j = $j + $max + 4;
    return $j;
}

#
# New subroutine "fill_excel_stage_fields" extracted - Wed Nov 5 16:12:45 2014.
#
sub fill_excel_stage_fields {
    my $ref_formats = shift;
    my $curr_job    = shift;
    my $col         = shift;
    my $stages      = shift;
    my $j           = shift;
    $curr_job->write( $j + 6, $col, "table_name",    $ref_formats->{heading} );
    $curr_job->write( $j + 7, $col, "operator_name", $ref_formats->{heading} );
    my $max = 0;

    for my $fields_all_element ( @{$stages} ) {
        $col++;
        $curr_job->write(
            $j + 6, $col,
            $fields_all_element->{StageName},
            $ref_formats->{rows_fmt}
        );
        $curr_job->write(
            $j + 7, $col,
            $fields_all_element->{OLEType},
            $ref_formats->{rows_fmt}
        );
        $curr_job->write( $j + 9, $col, "Field_Name", $ref_formats->{heading} );
        $curr_job->write( $j + 9, $col + 1, "Field_Type",
            $ref_formats->{heading} );
        $curr_job->write( $j + 9, $col + 2, "ParsedDerivation",
            $ref_formats->{heading} );
        $curr_job->write( $j + 9, $col + 3, "SourceColumn",
            $ref_formats->{heading} );
        my $q = 1;

        for my $single_field ( @{ $fields_all_element->{fields_and_types} } ) {
            $curr_job->write(
                $j + 9 + $q,
                $col,
                $single_field->{field_name},
                $ref_formats->{rows_fmt}
            );
            $curr_job->write(
                $j + 9 + $q,
                $col + 1,
                $single_field->{sql_type},
                $ref_formats->{rows_fmt}
            );
            $curr_job->write(
                $j + 9 + $q,
                $col + 2,
                $single_field->{parsed_deriv},
                $ref_formats->{rows_fmt}
            );
            $curr_job->write(
                $j + 9 + $q,
                $col + 3,
                $single_field->{source_column},
                $ref_formats->{rows_fmt}
            );
            $q++;
        }
        $col = $col + 4;
        $max = max_q( $max, $q );
    }
    $j = $j + 4 + $max;
    return $j;
}

#
# New subroutine "fill_excel_only_links" extracted - Wed Nov 5 16:12:45 2014.
#
sub fill_excel_only_links {
    my ( $all, $col, $j ) = @_;
    my ( $links, $ref_stages_with_types, $ref_formats, $curr_job, $job_pop ) = (
        $all->{job_pop}->{only_links}->{only_stages_and_links},
        $all->{job_pop}->{only_links}->{stages_with_types},
        $all->{ref_formats},
        $all->{curr_job},
        $all->{job_pop}
    );
    my $only_links = $job_pop->{only_links};
    pexcel_head( $j + 6, $col, $all, 'link_name' );
    pexcel_head( $j + 7, $col, $all, 'trans_name' );
    pexcel_head( $j + 8, $col, $all, 'operator_name' );
    my $max = 0;
    for my $stage ( @{ $only_links->{only_links} } ) {
        $col++;
        pexcel_row( $j + 6, $col, $all, $stage->{link_name} );
        pexcel_row( $j + 7, $col, $all, $stage->{trans_name} );
        pexcel_row( $j + 8, $col, $all, $stage->{operator_name} );
        pexcel_head( $j + 9, $col,     $all, 'field_name' );
        pexcel_head( $j + 9, $col + 1, $all, 'field_type' );
        pexcel_head( $j + 9, $col + 2, $all, 'not_nullable' );
        pexcel_head( $j + 9, $col + 3, $all, 'link_keep_fields' );
        my $q = pexcel_table_fields( $j + 9, $col, $all, $stage->{params} );
        my $g =
          pexcel_table( $j + 9, $col + 3, $all, $stage->{link_keep_fields} );
        $col = $col + 4;
        $max = max( $max, $g, $q );
    }
    $j = $j + 4 + $max;
    return $j;
}

sub pexcel_head {
    my ( $j, $col, $job_and_formats, $name ) = @_;
    $job_and_formats->{curr_job}
      ->write( $j, $col, $name, $job_and_formats->{ref_formats}->{heading} );
}

sub pexcel_row {
    my ( $j, $col, $job_and_formats, $name ) = @_;
    $job_and_formats->{curr_job}
      ->write( $j, $col, $name, $job_and_formats->{ref_formats}->{rows_fmt} );
}

sub pexcel_table {
    my ( $j, $col, $all, $ref_array ) = @_;
    my $q = 1;
    for my $single_field ( @{$ref_array} ) {
        pexcel_row( $j + $q, $col, $all, $single_field );
        $q++;
    }
    return $q;
}

sub pexcel_table_fields {
    my ( $j, $col, $all, $ref_array ) = @_;
    my $q = 1;
    for my $single_field ( @{$ref_array} ) {
        pexcel_row( $j + $q, $col,     $all, $single_field->{field_name} );
        pexcel_row( $j + $q, $col + 1, $all, $single_field->{field_type} );
        pexcel_row( $j + $q, $col + 2, $all, $single_field->{is_null} );
        $q++;
    }
    return $q;
}

sub pexcel_table_links {
    my ( $j, $col, $all, $stage, $suffix ) = @_;
    pexcel_head( $j, $col, $all, $suffix );
    my $q = 1;
    for my $single_field ( @{ $stage->{$suffix} } ) {
        pexcel_row( $j + $q, $col, $all, $single_field );
        $q++;
    }
    $j = $j + $q;

    # $j = show_stage_prop(
    my $max = show_stage_prop(
        $j, $col, $all, $stage->{$suffix},
        $all->{job_pop}->{only_links}->{stages_with_types},
        '_' . $suffix
    );

    # return $j;
    return $max;
}

sub show_stage_prop {
    my ( $j, $col, $all, $input_links, $ref_stages_with_types, $suffix ) = @_;
    my $max = 0;
    for my $link_name ( @{$input_links} ) {
        my $lname = $link_name . $suffix;    #'_input_links';
        pexcel_head( $j + 2, $col,     $all, 'field_name' );
        pexcel_head( $j + 2, $col + 1, $all, 'field_type' );
        pexcel_head( $j + 2, $col + 2, $all, 'not_nullable' );
        pexcel_head( $j + 2, $col + 3, $all, 'link_keep_fields' );
        my $g =
          pexcel_table_fields( $j + 2, $col, $all,
            $ref_stages_with_types->{$lname}->{params} );
        my $q =
          pexcel_table( $j + 2, $col + 3, $all,
            $ref_stages_with_types->{$lname}->{link_keep_fields} );
        $max = max( $max, $g, $q );
    }
    $col = $col + 4;
    $j   = $j;         # + 4 + $max;

    # return $j;
    return $max;
}

#
# New subroutine "fill_excel_stages_and_links" extracted - Wed Nov 5 16:12:45 2014.
#
sub fill_excel_stages_and_links {
    my ( $all, $col, $j, $direction ) = @_;

    my $links = $all->{job_pop}->{only_links}->{only_stages_and_links};
    my @start_stages = ( 'copy', 'pxbridge' );
    my %start_stages_of = map { $_ => 1 } @start_stages;
    my $max             = 0;
    my $orig_col        = $col;

    # print DumpTree($all, 'all_fields');

#сюда кладем те стадии, которые уже выводились в excel
# my %painted = ();
# my $save_col=0;

=pod
26 итого массив из 26 ячеек
на самом деле их и того меньше
в одну сторону
start-5
в другую 
end -3
итого, всего 8 дорожек
26*8 - 208 элементов во всех дорожках

каждый элемент из которого
нужно запомнить как путь,
например,
0-й элемент
будет как хэш, где
number_in_road=0
если он первый
stage_name=MART_UREP_WRH_DS
и потом просто пройдемся по этому отсортированному хэшу
и выведем все стейджи
    #Нужно просто сделать дерево для каждого линка,а потом вывести его          

#проверяем, что стейдж входит в список тех, которые выводятся первыми ('copy', 'pxbridge') и инпут=0
#число входящих линков
        print DumpTree( $stage->{stage_name},   '$stage->{stage_name}' );
        print DumpTree( $stage->{input_links},  '$stage->{input_links}' );
        print DumpTree( $stage->{output_links}, '$stage->{output_links}' );

=cut

    my $links_type = ( $direction eq 'start' ) ? 'input_links' : 'output_links';

    #итак создаем нашу структуру
    my @roads = ();

    my %start_stages_name = ();
    my %a_few_stages      = ();
    my $num_stages        = 0;
    my $cnt_stages        = 0 + @{$links};

    #    say "number of links: $cnt_stages";
    #хэш стейджей с объектами
    my %stages_body;
    for my $stage ( @{$links} ) {
        my $is_dataset = 'no';

        #кладем
        $stages_body{ $stage->{stage_name} } = $stage;

#рахъясняющая переменная, не удалять, а то быдет плохо читаться код
        my $cnt_links = 0 + @{ $stage->{$links_type} };
        if ( $cnt_links == 1
            && substr( ${ $stage->{$links_type} }[0], -2 ) eq 'ds' )
        {
            $is_dataset = 'yes';
        }

#также, если стейдж типа ds или это источник в виде базы данных 'pxbridge'
#у которого нет входящих линков для 1-го и выходящих для последнего
#точки приземления! (Андрей Бабуров)
        if ( ( $start_stages_of{ $stage->{operator_name} } && $cnt_links == 0 )
            || ( $is_dataset eq 'yes' ) )
        {

            #высота текущей стадии, стейджа
            my $curr_j = $j + $max;

         #находим все начальные линки,их имена!!!
            $a_few_stages{ $stage->{stage_name} }++;

            # $start_stages_name{$stage->{stage_name}}->{stage} = $stage;

            # print DumpTree($links, '$links_$links');

# #дальше правее должны пойти те стейджы (стадии, шаги, этапы по-русски)
# #у которых $input_links входит в @$output_links
# my $ref_next_stages = get_next_stage_for_link($links, $stage, $direction);
# ($max, $col) =  fill_excel_inout_links($all, $orig_col, $j + $max, $stage);

            $max = max( $max, 5 );
            $j = $j + $max + 10;

# my ($max, $col) =fill_excel_next_stage($col, $curr_j, $max, $links, $all, $stage,   $direction);
# my ($max, $col) =fill_excel_next_stage_no_recurtion($col, $curr_j, $max, $links, $all, $stage,   $direction);
            $j = $curr_j + $max;    # + 100;

            my %road_map = ();

            # print DumpTree( $stage, '$stage_find_links_type' );
            $road_map{number_in_road}  = 0;
            $road_map{stage_name}      = $stage->{stage_name};
            $road_map{last_stage}      = $stage->{stage_name};
            $road_map{last_links}      = $stage->{$links_type};
            $road_map{last_links_type} = $links_type;
            $road_map{orig_stage}      = $stage;
            push @roads, \%road_map;

        }

        my %link_collection = ();
        for my $direction ( 'start', 'end' ) {
            my $assoc_stages =
              get_next_stage_for_link( $links, $stage, $direction );
            $link_collection{$direction} = $assoc_stages;

            #       if ( $stage->{stage_name} eq 'J01' ) {
            #           p $assoc_stages;
            #           print DumpTree( $assoc_stages, 'assoc_stages' );
            #      }

         # $start_stages_name{$stage->{stage_name}}->{$direction}=$assoc_stages;
        }
        $start_stages_name{ $stage->{stage_name} } = \%link_collection;

        #say $stage->{stage_name} . ' cnt: ' . ++$num_stages;

    }

    # print DumpTree(\%start_stages_name, '@start_stages_name');

    # p %start_stages_name;

    #число стейджей всего:
    my $cnt_ctages = 0 + @{$links};

    #say "number of stages: $cnt_ctages";

#$cnt_ctages - это максимальное число вертикальных уровней или столбцов!!!

    #строим нушу цепочку без рекурсии!!
    #
    enc_terminal();
    my %lines = ();
    foreach my $few_stage ( sort keys %a_few_stages ) {
        $lines{$few_stage}++;
        my @elements   = ();
        my @levels     = ();
        my %in_already = ();
        for ( my $i = 0 ; $i < $cnt_ctages ; $i++ ) {
            my %stages_in_level    = ();
            my %collect_stages     = ();
            my $ref_collect_stages = \%collect_stages;

            #print "$i\n";
            if ( $i == 0 ) {
                $collect_stages{$few_stage} = 1;
                $in_already{$few_stage}++;
                push @levels, \%collect_stages;

         #say "Первый элемент: @{[ sort keys %collect_stages ]}\n";
                my $ref_0_stages =
                  get_next_stage_in_hash( $few_stage, \%start_stages_name,
                    $direction );
                push @levels, $ref_0_stages;
                foreach my $stg ( keys %{$ref_0_stages} ) {
                    $in_already{$stg}++;
                }

        #say "Второй элемент: @{[ sort keys %{$ref_0_stages} ]}\n";
            }
            elsif ( $i > 1 ) {
                my $prev_stages = $levels[ $i - 1 ];
                foreach my $prev_stage ( sort keys %{$prev_stages} ) {
                    my $ref_stages =
                      get_next_stage_in_hash( $prev_stage, \%start_stages_name,
                        $direction );
                    $ref_collect_stages =
                      merge( $ref_collect_stages, $ref_stages );   #$ref_stages;

                }
                my %hash_for_check = %{$ref_collect_stages};

#проверяем получившийся хэш на стейджи, которые уже были
                foreach my $stg2 ( keys %hash_for_check ) {
                    if ( defined $in_already{$stg2} ) {
                        delete $hash_for_check{$stg2};
                    }

                }

                $ref_collect_stages = \%hash_for_check;
                if ( !keys %{$ref_collect_stages} ) {
                    last;
                }
                push @levels, $ref_collect_stages;    #\%collect_stages;
                foreach my $stg3 ( keys %{$ref_collect_stages} ) {
                    $in_already{$stg3}++;
                }

#               say "Третий элемент: @{[ sort keys %{$ref_collect_stages} ]}\n";
            }
        }
        $lines{$few_stage} = \@levels;
    }

    # my %var_4_show = ();
    # @var_4_show{ 'j', 'col', 'all', 'orig_col', 'max', 'lines',
    # 'stages_body' } =
    # ( $j, $col, $all, $orig_col, $max, \%lines, \%stages_body );
    # ( $max, $col ) = fill_road_to_excel( \%var_4_show );

    print DumpTree( \%lines, '%lines' );

    $j = $j + 4 + $max;
    return $j;
}

#
# New subroutine "fill_road_to_excel" extracted - Sun Nov 30 22:30:25 2014.
#
sub fill_road_to_excel {
    my ($var_4_show) = @_;
    my ( $max, $col );
    foreach my $road ( keys %{ $var_4_show->{lines} } ) {

        foreach my $draw_stage ( @{ $var_4_show->{lines}->{$road} } ) {

            my $stage = $var_4_show->{stages_body}{$draw_stage};
            ( $max, $col ) = fill_excel_inout_links(
                $var_4_show->{all}, $var_4_show->{orig_col},
                $var_4_show->{max}, $var_4_show->{stage}
            );

        }
    }

    return ( $max, $col );
}

sub get_next_stage_in_hash {
    my ( $prev_stage, $ref_start_stages_name, $direction ) = @_;

#enc_terminal();
#say 'Для начала выясним, что у нас за переменные:';
#say 'Будем считать, что в хэше несколько стейджей,тогда пройдем по ним всем!!!:';
#say 'Предыдущий стейдж :' . $prev_stage;
    my $ref_link_array    = $ref_start_stages_name->{$prev_stage}->{$direction};
    my %stage_collections = ();
    for my $link ( @{$ref_link_array} ) {

        #       say $link->{stage_name};
        $stage_collections{ $link->{stage_name} }++;
    }
    return \%stage_collections;
}

sub add_stage_to_road {
    my ( $ref_road, $stage_2_road ) = @_;

    #my @road_and_next=();
    for my $road ( @{$ref_road} ) {

# print DumpTree($ref_road,     'ref_road');
#my %road_stage=();
#my $next_stages=get_next_stage_for_link( $links, $road->{orig_stage}, $direction );
#$road_stage{road}=$road;
#$road_stage{next}=$next_stages;
#push @road_and_next,\%road_stage;
#find_current_road_and_add_next_stage($road,$next_stages);
# $road->{stage_name};
# test if curr_stage eq next_stage for main_stage
    }

    #
    print DumpTree( $ref_road,     'ref_road' );
    print DumpTree( $stage_2_road, 'stage_2_road' );
    return $ref_road;

}

# print DumpTree( $stage,           'for_stage' );
# print DumpTree( $ref_next_stages, 'ref_next_stages' );
# print DumpTree( $direction, 'direction' );

#
# New subroutine "fill_excel_next_stage" extracted - Fri Nov 21 11:19:14 2014.
#
sub fill_excel_next_stage_no_recurtion {
    my ( $col, $curr_j, $max, $links, $all, $stage, $direction ) = @_;

    # print DumpTree($links, '$links_$links');

# #дальше правее должны пойти те стейджы (стадии, шаги, этапы по-русски)
# #у которых $input_links входит в @$output_links
# my $ref_next_stages = get_next_stage_for_link($links, $stage, $direction);

#выводим следующие по порядку стадии справа
# for my $next_stage (@{$ref_next_stages}) {
# ($max, $col) =
# fill_excel_inout_links($all, $col, $curr_j, $next_stage);
# $col++;
# my $ref_next_stages2 =
# get_next_stage_for_link($links, $next_stage, $direction);
# my $orig_col = $col;
# for my $next_stage2 (@{$ref_next_stages2}) {
# ($max, $col) =
# fill_excel_inout_links($all, $orig_col, $curr_j, $next_stage2);

    # # $painted->{$stage->{stage_name}}++;
    # my $ref_next_stages3 =
    # get_next_stage_for_link($links, $next_stage2, $direction);

# #($max, $col, $curr_j) =          fill_excel_next_stage2($col, $curr_j, $max, $links,   $next_stage2, $all, $ref_next_stages3, $direction);
# }
# $max = max($max, 5);
# $curr_j = $curr_j + $max + 10;
# }
    return ( $max, $col );
}

#
# New subroutine "fill_excel_next_stage" extracted - Fri Nov 21 11:19:14 2014.
#
sub fill_excel_next_stage {
    my ( $col, $curr_j, $max, $links, $all, $stage, $direction ) = @_;

    print DumpTree( $links, '$links_$links' );

#дальше правее должны пойти те стейджы (стадии, шаги, этапы по-русски)
#у которых $input_links входит в @$output_links
    my $ref_next_stages = get_next_stage_for_link( $links, $stage, $direction );

#выводим следующие по порядку стадии справа
    for my $next_stage ( @{$ref_next_stages} ) {
        ( $max, $col ) =
          fill_excel_inout_links( $all, $col, $curr_j, $next_stage );
        $col++;
        my $ref_next_stages2 =
          get_next_stage_for_link( $links, $next_stage, $direction );
        my $orig_col = $col;
        for my $next_stage2 ( @{$ref_next_stages2} ) {
            ( $max, $col ) =
              fill_excel_inout_links( $all, $orig_col, $curr_j, $next_stage2 );

            # $painted->{$stage->{stage_name}}++;
            my $ref_next_stages3 =
              get_next_stage_for_link( $links, $next_stage2, $direction );

#($max, $col, $curr_j) =          fill_excel_next_stage2($col, $curr_j, $max, $links,   $next_stage2, $all, $ref_next_stages3, $direction);
        }
        $max = max( $max, 5 );
        $curr_j = $curr_j + $max + 10;
    }
    return ( $max, $col );
}

#
# New subroutine "fill_excel_next_stage2" extracted - Fri Nov 21 13:46:53 2014.
#
sub fill_excel_next_stage2 {
    my ( $col, $curr_j, $max, $links, $next_stage2, $all, $ref_next_stages3,
        $direction )
      = @_;
    my $orig_col2 = $col;
    for my $next_stage3 ( @{$ref_next_stages3} ) {

        ( $max, $col ) =
          fill_excel_inout_links( $all, $orig_col2, $curr_j, $next_stage3 );
        my $ref_next_stages4 =
          get_next_stage_for_link( $links, $next_stage3, $direction );
        for my $next_stage4 ( @{$ref_next_stages4} ) {

            ( $max, $col ) =
              fill_excel_inout_links( $all, $orig_col2, $curr_j, $next_stage3 );
            my $ref_next_stages4 =
              get_next_stage_for_link( $links, $next_stage3, $direction );
            my $cnt_of_next_stages = 0 + @{$ref_next_stages4};
            if ( $cnt_of_next_stages > 0 ) {

                ( $max, $col, $curr_j ) =
                  fill_excel_next_stage2( $col, $curr_j, $max, $links,
                    $next_stage3, $all, $ref_next_stages4, $direction );
            }
        }
        $max = max( $max, 5 );
        $curr_j = $curr_j + $max + 10;
    }
    return ( $max, $col, $curr_j );
}
#
# New subroutine "get_next_stage_for_link" extracted - Thu Nov 21 10:27:27 2014.
#
sub get_next_stage_for_link {
    my ( $links, $stage, $direction ) = @_;

    # input_links output_links
    # @{$stage->{$suffix}}
    my ( $out_suffix, $in_suffix ) = ( '', '' );
    if ( $direction eq 'start' ) {
        $out_suffix = 'output_links';
        $in_suffix  = 'input_links';
    }
    elsif ( $direction eq 'end' ) {
        $out_suffix = 'input_links';
        $in_suffix  = 'output_links';
    }

  #массив стадий, которые идут сразу за нашей
    my @next_stages = ();

    #    state $i ;    #         = 0;
    #    say "get_next_stage_for_link" . ++$i;

    #     print DumpTree( $links,           '$links' );

#Выводим все выходные линки из текущей стадии
    for my $out_link_name ( @{ $stage->{$out_suffix} } ) {

        # say "\nDebug_bug_bug\n\n";
        # say $out_link_name;
        #идем по всем стадиям
        for my $loc_stage ( @{$links} ) {

#ищем входные линки совпадающие с нашим выходным
            for my $in_link_name ( @{ $loc_stage->{$in_suffix} } ) {
                if ( $out_link_name eq $in_link_name ) {

# say "\nЛинки совпали, ура!!!\n\n";
# say "$out_link_name in $stage->{stage_name} eq $in_link_name in $loc_stage->{stage_name}";
                    push @next_stages, $loc_stage;
                }
            }
        }
    }

    #считаем число стадий
    # my $cnt_of_next_stages=0+@next_stages;
    #возвращаем ссылку на массив стадий

    return \@next_stages;
}

#sub fill_excel_next_stage2 {}
#
# New subroutine "get_body_of_stage" extracted - Thu Nov 21 10:27:27 2014.
#
sub get_body_of_stage {
    my ( $links, $stage_name ) = @_;
    my $stage_body;

    #идем по всем стадиям
    for my $loc_stage ( @{$links} ) {
        if ( $loc_stage->{stage_name} eq $stage_name ) {
            $stage_body = $loc_stage;
        }

    }

    return $stage_body;
}

#
# New subroutine "fill_excel_inout_links" extracted - Thu Nov 20 15:27:27 2014.
#
sub fill_excel_inout_links {
    my ( $all, $col, $j, $stage ) = @_;
    my ( $col_max, $loc_max ) = ( 0, 0, 0 );
    pexcel_head( $j + 6, $col, $all, 'stage_name' );
    pexcel_row( $j + 6, $col + 1, $all, $stage->{stage_name} );
    pexcel_head( $j + 7, $col, $all, 'operator_name' );
    pexcel_row( $j + 7, $col + 1, $all, $stage->{operator_name} );
    my @start_stages = ( 'copy', 'pxbridge' );
    my %start_stages_of = map { $_ => 1 } @start_stages;

    for my $link (qw/input_links output_links/) {

        # print "\n\n\nDEbug\n\n";
        # say 0 + @{ $stage->{$link} };
        # p $link;
        # p $stage;

        #если число линков больше нуля
        if ( 0 + @{ $stage->{$link} } > 0 ) {
            $loc_max = pexcel_table_links( $j + 9, $col, $all, $stage, $link );
            $col_max = max( $col_max, $loc_max );

            # $col = $col + 5;
            $col = $col + 4;
        }

        #}
    }
    return ( $col_max, $col );    #,$j);
}

#
# New subroutine "fill_excel_ai_header_mapping" extracted - Wed Nov 12 16:48:49 2014.
#
sub fill_excel_ai_header_mapping {
    my $col_map     = shift;
    my $curr_job    = shift;
    my $ref_formats = shift;
    my $stage_prop  = shift;
    my $stage       = shift;
    my $j           = shift;
    if (   defined $stage_prop->{InputName}
        || defined $stage_prop->{OutputName} )
    {
        $curr_job->write(
            $j + 6, $col_map,
            "Mapping for " . $stage->{StageName},
            $ref_formats->{heading}
        );
        $curr_job->write(
            $j + 8, $col_map,
            "Target Column",
            $ref_formats->{map_fmt}
        );
        $curr_job->write( $j + 8, $col_map + 1,
            "Datatype", $ref_formats->{map_fmt} );

        # $curr_job->write($j + 8, $col_map + 2,
        # "nullable", $ref_formats->{map_fmt});
        # $curr_job->write($j + 8, $col_map + 3,
        # "keyposition", $ref_formats->{map_fmt});
        $curr_job->write(
            $j + 8,
            $col_map + 2,
            "Source Column",
            $ref_formats->{map_fmt}
        );
        $curr_job->write( $j + 3, $col_map + 5,
            "Datatype", $ref_formats->{map_fmt} );

        # $curr_job->write($j + 8, $col_map + 6,
        # "nullable", $ref_formats->{map_fmt});
        # $curr_job->write($j + 8, $col_map + 7,
        # "keyposition", $ref_formats->{map_fmt});
    }
    return 1;
}

#
# New subroutine "fill_excel_activity_info" extracted - Wed Nov 5 16:14:26 2014.
#
sub fill_excel_activity_info {
    my $ref_formats = shift;
    my $curr_job    = shift;
    my $col         = shift;
    my $activity    = shift;
    my $j           = shift;
    $col = 3;
    $curr_job->write( $j + 6, $col, "activity_name", $ref_formats->{heading} );
    $curr_job->write( $j + 7, $col, "job_name",      $ref_formats->{heading} );
    $curr_job->write( $j + 8, $col, "invocation_id", $ref_formats->{heading} );
    $curr_job->write( $j + 9, $col, "activity_number",
        $ref_formats->{heading} );

    for my $activity_element ( @{$activity} ) {
        $col++;
        $curr_job->write(
            $j + 6, $col,
            $activity_element->{activity_name},
            $ref_formats->{rows_fmt}
        );
        $curr_job->write(
            $j + 7, $col,
            $activity_element->{job_name},
            $ref_formats->{rows_fmt}
        );
        $curr_job->write(
            $j + 8, $col,
            $activity_element->{invocation_id},
            $ref_formats->{rows_fmt}
        );
        $curr_job->write(
            $j + 9, $col,
            $activity_element->{activity_number},
            $ref_formats->{rows_fmt}
        );
    }
    return $j;
}

#
# New subroutine "fill_excel_fields_all" extracted - Wed Nov 5 16:14:26 2014.
#
sub fill_excel_fields_all {
    my $ref_formats = shift;
    my $curr_job    = shift;
    my $col         = shift;
    my $fields_all  = shift;
    my $j           = shift;
    $col = 3;
    if ( defined $fields_all && @{$fields_all} > 1 ) {
        $curr_job->write( $j + 6, $col, "table_name", $ref_formats->{heading} );
        $curr_job->write( $j + 7, $col, "operator_name",
            $ref_formats->{heading} );
        $curr_job->write( $j + 8, $col, "inputs_name",
            $ref_formats->{heading} );
        $curr_job->write( $j + 9, $col, "outputs_name",
            $ref_formats->{heading} );

        # if ( defined $+{inputs_name} ) {
        # $stage_and_fields{inputs_name} = $+{inputs_name};
        # }
        # if ( defined $+{outputs_name} ) {
        # $stage_and_fields{outputs_name} = $+{outputs_name};
        # }
        my $max_q = 0;
        for my $fields_all_element ( @{$fields_all} ) {
            $col++;
            $curr_job->write(
                $j + 6, $col,
                $fields_all_element->{stage_name},
                $ref_formats->{rows_fmt}
            );
            $curr_job->write(
                $j + 7, $col,
                $fields_all_element->{operator_name},
                $ref_formats->{rows_fmt}
            );
            $curr_job->write(
                $j + 8, $col,
                $fields_all_element->{inputs_name},
                $ref_formats->{rows_fmt}
            );
            $curr_job->write(
                $j + 9, $col,
                $fields_all_element->{outputs_name},
                $ref_formats->{rows_fmt}
            );
            $curr_job->write( $j + 11, $col, "field_name",
                $ref_formats->{heading} );
            $curr_job->write( $j + 11, $col + 1, "field_type",
                $ref_formats->{heading} );

            $curr_job->write( $j + 11, $col + 2, "nullable",
                $ref_formats->{heading} );
            $curr_job->write( $j + 11, $col + 3, "keyposition",
                $ref_formats->{heading} );
            my $q = 1;

            for my $single_field ( @{ $fields_all_element->{fields} } ) {
                $curr_job->write(
                    $j + 11 + $q,
                    $col,
                    $single_field->{field_name},
                    $ref_formats->{rows_fmt}
                );
                $curr_job->write(
                    $j + 11 + $q,
                    $col + 1,
                    $single_field->{sql_type},
                    $ref_formats->{rows_fmt}
                );

                $curr_job->write(
                    $j + 11 + $q,
                    $col + 2,
                    $single_field->{nullable},
                    $ref_formats->{rows_fmt}
                );

                $curr_job->write(
                    $j + 11 + $q,
                    $col + 3,
                    $single_field->{keyposition},
                    $ref_formats->{rows_fmt}
                );
                $q++;
                $max_q = max_q( $max_q, $q );
            }
            $col = $col + 4;
        }
        $j = $j + 11 + $max_q;
    }
    return $j;
}

sub max_q {
    my ( $max_q, $q ) = @_;
    if ( $q > $max_q ) {
        $max_q = $q;
    }
    return $max_q;
}

# $j = fill_excel_fields_all( $rows_fmt, $curr_job, $col, $fields_all,
# $heading, $j );
#
# New subroutine "fill_excel_ident_list" extracted - Wed Nov 5 16:14:26 2014.
#
sub fill_excel_ident_list {
    my $ref_formats = shift;
    my $curr_job    = shift;
    my $col         = shift;
    my $ident_list  = shift;
    my $j           = shift;
    $col = 3;
    $curr_job->write( $j + 6, $col, "IdentListValue", $ref_formats->{heading} );

    #for my $ident_list_element ( @{$ident_list} ) {
    $col++;
    $curr_job->write( $j + 6, $col, $ident_list, $ref_formats->{rows_fmt} );

    #}
    return $j;
}

#
# New subroutine "fill_excel_stages" extracted - Wed Nov 5 11:13:56 2014.
#
sub fill_excel_stages {

    # my ($ref_formats, $curr_job, $job_pop) = @_;
    my ( $job_and_formats, $direction ) = @_;

# @job_and_formats{'ref_formats', 'curr_job', 'job_pop'}=($ref_formats, $curr_job, $job_pop);
# fill_excel_stages($ref_formats, $curr_job, $job_pop);
# fill_excel_stages(\%job_and_formats);
    my $stages   = $job_and_formats->{job_pop}->{StagesInfo};
    my $activity = $job_and_formats->{job_pop}->{Activity};
    my $ref_job_annotation_texts =
      $job_and_formats->{job_pop}->{job_annotation_texts};
    my $ident_list = $job_and_formats->{job_pop}->{IdentList};
    my $fields_all = $job_and_formats->{job_pop}->{fields_all};

    # print DumpTree($fields_all, 'fields_all');
    # print DumpTree($stages,     'stages');

    my ( $ref_formats, $curr_job, $job_pop ) = (
        $job_and_formats->{ref_formats},
        $job_and_formats->{curr_job},
        $job_and_formats->{job_pop}
    );

    # my $only_links = $job_pop->{only_links};
    #print "\nDebug_only\n\n";
    #p $only_links;
    my $j   = 1;
    my $col = 3;

    # $j = fill_excel_name_stages($ref_formats, $curr_job, $stages, $j);
    $j = fill_excel_job_annotation_text( $ref_formats, $curr_job,
        $ref_job_annotation_texts, $j );

    #$j = fill_excel_stage_info($ref_formats, $curr_job, $col, $stages, $j);
    $j =
      fill_excel_activity_info( $ref_formats, $curr_job, $col, $activity, $j );
    $j =
      fill_excel_ident_list( $ref_formats, $curr_job, $col, $ident_list, $j );
    $j =
      fill_excel_fields_all( $ref_formats, $curr_job, $col, $fields_all, $j );

    #$j = fill_excel_stage_fields($ref_formats, $curr_job, $col, $stages, $j);

# $j = fill_excel_only_links($ref_formats, $curr_job, $col, $job_pop, $j);
# $j = fill_excel_only_links($job_and_formats, $col, $j);
# $j = fill_excel_stages_and_links($ref_formats, $curr_job, $col, $job_pop, $j);
# $j =      fill_excel_stages_and_links($job_and_formats, $col, $j + 4, $direction);
    $j = fill_excel_stages_and_links( $job_and_formats, $col, $j, $direction );
}

sub fill_rev_history {
    my ( $revision_history, $job_pop, $ref_formats, $workbook, $i, $num ) = @_;
    $revision_history->write( 5 + $i, 5, $i,  $ref_formats->{rows_fmt} );
    $revision_history->write( 5 + $i, 6, "0", $ref_formats->{rows_fmt} );
    $revision_history->write_url(
        5 + $i, 7,
        'internal:' . substr( $job_pop->{JobName}, -28 ) . '_' . $num . '!A2',
        $ref_formats->{url_format},
        $job_pop->{JobName}
    );
    $revision_history->write( 5 + $i, 8, $job_pop->{JobDesc},
        $ref_formats->{rows_fmt} );
}

#
# New subroutine "fill_excel_body" extracted - Wed Nov 5 09:58:42 2014.
#
sub fill_excel_body {
    my $ref_formats      = shift;
    my $i                = shift;
    my $job_pop          = shift;
    my $revision_history = shift;
    my $workbook         = shift;

    fill_rev_history( $revision_history, $job_pop, $ref_formats, $workbook, $i,
        '1' );

#$i++;
#fill_rev_history($revision_history, $job_pop, $ref_formats, $workbook, $i,     '2');

    my $curr_job_start =
      make_curr_job( $job_pop, $ref_formats, $workbook, $i, '1' );

    my $curr_job_end =
      make_curr_job( $job_pop, $ref_formats, $workbook, $i, '2' );

    my %job_and_formats_start;

    @job_and_formats_start{ 'ref_formats', 'curr_job', 'job_pop' } =
      ( $ref_formats, $curr_job_start, $job_pop );

    my %job_and_formats_end;
    @job_and_formats_end{ 'ref_formats', 'curr_job', 'job_pop' } =
      ( $ref_formats, $curr_job_end, $job_pop );

    fill_excel_stages( \%job_and_formats_start, 'start' );

    fill_excel_stages( \%job_and_formats_end, 'end' );
    autofit_columns($curr_job_start);

    #autofit_columns($curr_job_end);
}

sub make_curr_job {
    my ( $loc_hash_prop, $ref_formats, $workbook, $i, $num ) = @_;
    my $curr_job = $workbook->add_worksheet(
        substr( $loc_hash_prop->{JobName}, -28 ) . '_' . $num );
    add_write_handler_autofit($curr_job);
    $curr_job->activate();
    $curr_job->write_url(
        'A2',
        'internal:Revision_History!H' . ( 5 + $i ),
        $ref_formats->{url_format}, 'Back'
    );
    $curr_job->write( 'D2', "Sequence",    $ref_formats->{heading} );
    $curr_job->write( 'E2', "Description", $ref_formats->{heading} );
    $curr_job->write(
        'D3',
        $loc_hash_prop->{JobName},
        $ref_formats->{rows_fmt}
    );
    $curr_job->write(
        'E3',
        $loc_hash_prop->{JobDesc},
        $ref_formats->{rows_fmt}
    );
    return $curr_job;

}

sub make_revision_history {
    my ( $prop_4_excel, $file_name ) = @_;
    my ( $head_prop,    $job_prop )  = @{$prop_4_excel};
    my @jobs_properties = @{$job_prop};
    $file_name =~ s{\.[^.]+$}{};
    my $workbook =
      Spreadsheet::WriteExcel->new( $head_prop->{ProjectName} . '_ON_'
          . $head_prop->{ServerName} . '_'
          . $file_name
          . '.xls' );
    set_excel_properties($workbook);

    # Add some worksheets
    my $revision_history = $workbook->add_worksheet("Revision_History");
    add_write_handler_autofit($revision_history);    #begin_autofit
    my $ref_formats = set_excel_formats($workbook);
    $revision_history->activate();
    fill_excel_header( $ref_formats, $revision_history, $head_prop );
    my $i = 0;
    for my $job_pop (@jobs_properties) {
        fill_excel_body( $ref_formats, $i, $job_pop, $revision_history,
            $workbook );
        $i++;
    }
    $revision_history->activate();
    autofit_columns($revision_history);              #end_autofit

    # Run the autofit after you have finished writing strings to the workbook.
}
###############################################################################
#
# Functions used for Autofit.
#
###############################################################################
###############################################################################
#
# Adjust the column widths to fit the longest string in the column.
#
sub autofit_columns {
    my $worksheet = shift;
    my $col       = 0;
    for my $width ( @{ $worksheet->{__col_widths} } ) {
        $worksheet->set_column( $col, $col, $width ) if $width;
        $col++;
    }
}
###############################################################################
#
# The following function is a callback that was added via add_write_handler()
# above. It modifies the write() function so that it stores the maximum
# unwrapped width of a string in a column.
#
sub store_string_widths {
    my $worksheet = shift;
    my $col       = $_[1];
    my $token     = $_[2];

    # Ignore some tokens that we aren't interested in.
    return if not defined $token;       # Ignore undefs.
    return if $token eq '';             # Ignore blank cells.
    return if ref $token eq 'ARRAY';    # Ignore array refs.
    return if $token =~ /^=/;           # Ignore formula

    # Ignore numbers
    return
      if $token =~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/;

    # Ignore various internal and external hyperlinks. In a real scenario
    # you may wish to track the length of the optional strings used with
    # urls.
    return if $token =~ m{^[fh]tt?ps?://};
    return if $token =~ m{^mailto:};
    return if $token =~ m{^(?:in|ex)ternal:};

    # We store the string width as data in the Worksheet object. We use
    # a double underscore key name to avoid conflicts with future names.
    #
    my $old_width    = $worksheet->{__col_widths}->[$col];
    my $string_width = string_width($token);
    if ( not defined $old_width or $string_width > $old_width ) {

        # You may wish to set a minimum column width as follows.
        #return undef if $string_width < 10;
        $worksheet->{__col_widths}->[$col] = $string_width;
    }

    # Return control to write();
    return undef;
}
###############################################################################
#
# Very simple conversion between string length and string width for Arial 10.
# See below for a more sophisticated method.
#
sub string_width {
    return 0.9 * length $_[0];

    #return 1.1 * length $_[0];
}

sub patch_dsx_for_prod {
    my ($file_name) = @_;
    my $data = read_file($file_name);
    $data =~ s/\QBEGIN DSSUBRECORD
Name "LOADING_DT"
Description "\"2011-12-12\""
ValueType "4"
DisplayValue "\"2011-12-12\""
END DSSUBRECORD\E/BEGIN DSSUBRECORD
Name "LOADING_DT"
Description "UserVars.vLoadingDt"
ValueType "4"
DisplayValue "UserVars.vLoadingDt"
END DSSUBRECORD/s;
    write_file( $file_name . ".patched", $data );
}

sub reformat_links {
    my $parsed_dsx            = shift;
    my @only_links            = ();
    my @only_stages_and_links = ();
    my %stages_with_types     = ();
    foreach my $stage ( @{$parsed_dsx} ) {
        my %only_stages  = ();
        my @input_links  = ();
        my @output_links = ();
        $only_stages{stage_name}    = $stage->{stage_name};
        $only_stages{operator_name} = $stage->{operator_name};
        if ( $stage->{ins}->{in} eq 'yes' ) {
            for my $inputs ( @{ $stage->{ins}->{inputs} } ) {
                my %in_links = ();
                $in_links{link_name}     = $inputs->{link_name};
                $in_links{is_param}      = 'no';
                $in_links{trans_name}    = $inputs->{trans_name};
                $in_links{operator_name} = $stage->{operator_name};
                $in_links{stage_name}    = $stage->{stage_name};
                $in_links{inout_type}    = $inputs->{inout_type};
                if ( $inputs->{is_param} eq 'yes' ) {
                    $in_links{is_param}         = 'yes';
                    $in_links{params}           = $inputs->{params};
                    $in_links{link_keep_fields} = $inputs->{link_keep_fields};
                }
                push @only_links,  \%in_links;
                push @input_links, $inputs->{link_name};
                $stages_with_types{ $inputs->{link_name} . '_'
                      . $inputs->{inout_type} } = \%in_links;
            }
        }
        $only_stages{input_links} = \@input_links;
        if ( $stage->{ins}->{out} eq 'yes' ) {
            for my $outputs ( @{ $stage->{ins}->{outputs} } ) {
                my %out_links = ();
                $out_links{link_name}     = $outputs->{link_name};
                $out_links{is_param}      = 'no';
                $out_links{trans_name}    = $outputs->{trans_name};
                $out_links{operator_name} = $stage->{operator_name};
                $out_links{stage_name}    = $stage->{stage_name};
                $out_links{inout_type}    = $outputs->{inout_type};
                if ( $outputs->{is_param} eq 'yes' ) {
                    $out_links{is_param}         = 'yes';
                    $out_links{params}           = $outputs->{params};
                    $out_links{link_keep_fields} = $outputs->{link_keep_fields};
                }
                push @only_links,   \%out_links;
                push @output_links, $outputs->{link_name};
                $stages_with_types{ $outputs->{link_name} . '_'
                      . $outputs->{inout_type} } = \%out_links;
            }
        }
        $only_stages{output_links} = \@output_links;
        push @only_stages_and_links, \%only_stages;
    }
    my %out_hash = ();
    $out_hash{only_links}            = \@only_links;
    $out_hash{only_stages_and_links} = \@only_stages_and_links;
    $out_hash{stages_with_types}     = \%stages_with_types;
    my %cnt_links;
    for (@only_links) {
        $cnt_links{ $_->{link_name} . '_' . $_->{inout_type} }++;
    }
    return \%out_hash;
}

sub make_regexp {
    my $operator_rx      = qr{\Q#### STAGE: \E(?<stage_name>\w+)};
    my $operator_name_rx = qr{\Q## Operator\E\n(?<operator_name>\w+)\n\#};
    my $header_rx        = qr{
$operator_rx \n
$operator_name_rx
}sx;
    my $ORCHESTRATE_BODY_RX = qr{
(?<stage_body>
$header_rx
.*?
^;
)
}sxm;
    return $ORCHESTRATE_BODY_RX;
}

#
# New subroutine "head_of_stage" extracted - Mon Nov 17 10:15:21 2014.
#
sub show_head_of_stage {
    my ( $t, $i, $stage ) = @_;
    my ( $in, $in_type, $out, $out_type ) = ( '', '', '', '' );
    if ( $stage->{ins}->{in} eq 'yes' ) {
        for ( @{ $stage->{ins}->{inputs} } ) {
            $in = $in . $_->{link_name} . "\n";
        }
    }
    if ( $stage->{ins}->{out} eq 'yes' ) {
        for ( @{ $stage->{ins}->{outputs} } ) {
            $out = $out . $_->{link_name} . "\n";
        }
    }
    $t->addRow( $i, $stage->{stage_name}, $stage->{operator_name},
        $in, '', '', '', '', $out, '', '', '', '' );
    return $t;
}

#
# New subroutine "show_in_fields" extracted - Mon Nov 17 10:20:07 2014.
#
sub show_in_fields {
    my $t     = shift;
    my $stage = shift;
    if ( $stage->{ins}->{in} eq 'yes'
        && ${ $stage->{ins}->{inputs} }[0]->{is_param} eq 'yes' )
    {
        $t->addRowLine();
        my $j = 1;
        for my $f ( @{ ${ $stage->{ins}->{inputs} }[0]->{params} } ) {
            $t->addRow( '', '', '', '', $j, $f->{field_name}, $f->{field_type},
                $f->{is_null}, '', '', '', '', '' );
            $t->addRowLine();
            $j++;
        }
    }
    return $t;
}

#
# New subroutine "show_out_fields" extracted - Mon Nov 17 10:20:53 2014.
#
sub show_out_fields {
    my $t     = shift;
    my $stage = shift;
    if ( $stage->{ins}->{out} eq 'yes'
        && ${ $stage->{ins}->{outputs} }[0]->{is_param} eq 'yes' )
    {
        $t->addRowLine();
        my $y = 1;
        for my $f ( @{ ${ $stage->{ins}->{outputs} }[0]->{params} } ) {
            $t->addRow( '', '', '', '', '', '', '', '', '', $y,
                $f->{field_name}, $f->{field_type}, $f->{is_null} );
            $t->addRowLine();
            $y++;
        }
    }
    return $t;
}

#
# New subroutine "display_main_header" extracted - Mon Nov 17 10:30:17 2014.
#
sub show_main_header {
    my $file_name = shift;
    my $t         = Text::ASCIITable->new(
        { headingText => 'Parsing ORCHESTRATE of ' . $file_name } );
    $t->setCols(
        'Id',      'stage_name', 'op_name',    'inputs',
        'num',     'field_name', 'field_type', 'is_null',
        'outputs', 'num',        'field_name', 'field_type',
        'is_null'
    );
    return $t;
}

sub show_dsx_content {
    my ( $parsed_dsx, $file_name ) = @_;
    my $t = show_main_header($file_name);
    my $i = 1;
    foreach my $stage ( @{$parsed_dsx} ) {

        # if ($stage->{stage_name} eq 'LJ108') {
        # p $stage;
        $t = show_head_of_stage( $t, $i, $stage );
        $t = show_in_fields( $t, $stage );
        $t = show_out_fields( $t, $stage );
        $t->addRowLine();
        $i++;

        # }
    }
    print $t;
}

sub parse_orchestrate_body {
    my $data                = shift;
    my $ORCHESTRATE_BODY_RX = make_regexp();
    local $/ = '';
    my @parsed_dsx = ();
    while ( $data =~ m/$ORCHESTRATE_BODY_RX/xsg ) {
        my %stage = ();
        my $ins   = parse_stage_body( $+{stage_body} );
        $stage{ins}           = $ins;
        $stage{stage_name}    = $+{stage_name};
        $stage{operator_name} = $+{operator_name};
        push @parsed_dsx, \%stage;
    }
    return \@parsed_dsx;
}

sub parse_stage_body {
    my ($stage_body) = @_;
    my %outs;
    my $inputs_rx  = qr{## Inputs\n(?<inputs_body>.*?)(?:#|^;$)}sm;
    my $outputs_rx = qr{## Outputs\n(?<outputs_body>.*?)^;$}sm;

=pod
## General options
[ident('LKUP101'); jobmon_ident('LKUP101')]
## Inputs
0< [] 'T100:L101.v'
1< [] 'T10:L11.v'
## Outputs
=cut

    my ( $inputs, $outputs ) = ( '', '' );
    $outs{in}   = 'no';
    $outs{out}  = 'no';
    $outs{body} = $stage_body;
    if ( $stage_body =~ $inputs_rx ) {
        $outs{inputs} = parse_in_links( $+{inputs_body} );
        $outs{in}     = 'yes';
    }
    if ( $stage_body =~ $outputs_rx ) {
        $outs{outputs} = parse_out_links( $+{outputs_body} );
        $outs{out}     = 'yes';
    }
    return \%outs;
}

sub parse_in_links {
    my ($body) = @_;
    my @links = ();

=pod
0< [] 'T100:L101.v'
1< [] 'T10:L11.v'
=cut

    my $link = qr{\d+
< (?:\||)
\s \[
(?<link_fields>
.*?
)
\]
\s
'
(?:
(?<link_name>
(?<trans_name>\w+):
\w+)
.v
|
\[.*?\]	
(?<link_name>
\w+.ds
)
)'
}xs;
    while ( $body =~ m/$link/g ) {
        my %link_param = ();
        $link_param{link_name}  = $+{link_name};
        $link_param{link_type}  = $+{link_fields};
        $link_param{inout_type} = 'input_links';

        # 'input_links'
        #$link_param{link_type} = $+{link_type};
        $link_param{trans_name} = $+{trans_name}
          if defined $+{trans_name};
        $link_param{is_param} = 'no';
        if ( defined $+{link_fields} )

          #if ( length( $link_param{link_type} ) >= 6
          #&& substr( $link_param{link_type}, 0, 6 ) eq 'modify' )
        {
            $link_param{is_param} = 'yes';
            $link_param{params}   = parse_fields( $+{link_fields} );
            $link_param{link_keep_fields} =
              parse_keep_fields( $+{link_keep_fields} )
              if defined $+{link_keep_fields};
        }
        push @links, \%link_param;
    }

    #print "\n\n Debug in_links!!! \n\n";
    #p $body;
    #p @links;
    return \@links;
}

sub parse_out_links {
    my ($body) = @_;
    my @links = ();

=pod
## General options
[ident('T108'); jobmon_ident('T108')]
## Inputs
0< [] 'T107:L107.v'
## Outputs
0> [] 'T108:L108.v'
1> [] 'T108:L_DBG01.v'
;
## General options
[ident('T199'); jobmon_ident('T199')]
## Inputs
0< [] 'LJ108:L109.v'
## Outputs
0> [] 'T199:INS.v'
1> [] 'T199:UPD.v'
;
=cut

    my $link = qr{\d+
(?:<|>)
(?:\||)
\s
\[
(?<link_type>
(?:
modify\s\(
(?:
(?<link_fields>
.*?;|.*?
)
)\n
keep
(?<link_keep_fields>
.*?
)
;
.*?
\)
)
|.*?
)
\]
\s
'
(?:
(?<link_name>
(?<trans_name>\w+):
\w+)
.v
|
\[.*?\]	
(?<link_name>
\w+.ds
)
)'
}xs;
    while ( $body =~ m/$link/g ) {
        my %link_param = ();
        $link_param{link_name}  = $+{link_name};
        $link_param{link_type}  = $+{link_fields};
        $link_param{inout_type} = 'output_links';

        #$link_param{link_type} = $+{link_type};
        $link_param{trans_name} = $+{trans_name}
          if defined $+{trans_name};
        $link_param{is_param} = 'no';
        if ( defined $+{link_fields} )

          #if ( length( $link_param{link_type} ) >= 6
          #&& substr( $link_param{link_type}, 0, 6 ) eq 'modify' )
        {
            $link_param{is_param} = 'yes';
            $link_param{params}   = parse_fields( $+{link_fields} );
            $link_param{link_keep_fields} =
              parse_keep_fields( $+{link_keep_fields} )
              if defined $+{link_keep_fields};
        }
        push @links, \%link_param;
    }

    # print "\n\n Debug out_links!!! \n\n";
    #p $body;
    #p @links;
    return \@links;
}

sub parse_keep_fields {
    my $body_for_keep_fields = shift;
    $body_for_keep_fields =~ s/^\s+|\s+$//g;

    #p $body_for_keep_fields;
    my @fields = split /\s*,\s*/s, $body_for_keep_fields;
    return \@fields;
}

sub parse_fields {
    my $body_for_fields = shift;

    #p $body_for_fields;
    my @fields = ();
    my $field  = qr{
(?<field_name>\w+)
:
(?<is_null>not_nullable|nullable)\s
(?<field_type>.*?)
=
\g{field_name}
;
}xs;
    while ( $body_for_fields =~ m/$field/g ) {
        my %field_param = ();
        $field_param{field_name} = $+{field_name};
        $field_param{is_null}    = $+{is_null};
        $field_param{field_type} = $+{field_type};
        push @fields, \%field_param;
    }
    return \@fields;
}
1;    # Magic true value required at end of module
__END__

=head1 NAME
Datahub::Tools - [One line description of module's purpose here]
=head1 VERSION
This document describes Datahub::Tools version 0.0.1
=head1 SYNOPSIS
use Datahub::Tools;
=for author to fill in:
Brief code example(s) here showing commonest usage(s).
This section will be as far as many users bother reading
so make it as educational and exeplary as possible.
=head1 DESCRIPTION
=for author to fill in:
Write a full description of the module and its features here.
Use subsections (=head2, =head3) as appropriate.
=head1 INTERFACE
=for author to fill in:
Write a separate section listing the public components of the modules
interface. These normally consist of either subroutines that may be
exported, or methods that may be called on objects belonging to the
classes provided by the module.
=head1 DIAGNOSTICS
=for author to fill in:
List every single error and warning message that the module can
generate (even the ones that will "never happen"), with a full
explanation of each problem, one or more likely causes, and any
suggested remedies.
=over
=item C<< Error message here, perhaps with %s placeholders >>
[Description of error here]
=item C<< Another error message here >>
[Description of error here]
[Et cetera, et cetera]
=back
=head1 CONFIGURATION AND ENVIRONMENT
=for author to fill in:
A full explanation of any configuration system(s) used by the
module, including the names and locations of any configuration
files, and the meaning of any environment variables or properties
that can be set. These descriptions must also include details of any
configuration language used.
Datahub::Tools requires no configuration files or environment variables.
=head1 DEPENDENCIES
=for author to fill in:
A list of all the other modules that this module relies upon,
including any restrictions on versions, and an indication whether
the module is part of the standard Perl distribution, part of the
module's distribution, or must be installed separately. ]
None.
=head1 INCOMPATIBILITIES
=for author to fill in:
A list of any modules that this module cannot be used in conjunction
with. This may be due to name conflicts in the interface, or
competition for system or program resources, or due to internal
limitations of Perl (for example, many modules that use source code
filters are mutually incompatible).
None reported.
=head1 BUGS AND LIMITATIONS
=for author to fill in:
A list of known problems with the module, together with some
indication Whether they are likely to be fixed in an upcoming
release. Also a list of restrictions on the features the module
does provide: data types that cannot be handled, performance issues
and the circumstances in which they may arise, practical
limitations on the size of data sets, special cases that are not
(yet) handled, etc.
No bugs have been reported.
Please report any bugs or feature requests to
C<bug-datahub-tools@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.
=head1 AUTHOR
Nikolay Mishin C<< <mi@ya.ru> >>
=head1 LICENCE AND COPYRIGHT
Copyright (c) 2014, Nikolay Mishin C<< <mi@ya.ru> >>. All rights reserved.
This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
=head1 DISCLAIMER OF WARRANTY
BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.
IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
=cut
__DATA__
