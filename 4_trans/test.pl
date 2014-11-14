#!/usr/bin/perl
package Datahub::Tools;

use utf8;
use warnings;
use strict;
use Carp;
use DBI;
use Encode::Locale;
use Data::Dumper;
use Tie::IxHash;
use Spreadsheet::WriteExcel;
use POSIX qw(strftime);

use DDP;

if (-t) {
    binmode( STDIN,  ":encoding(console_in)" );
    binmode( STDOUT, ":encoding(console_out)" );
    binmode( STDERR, ":encoding(console_out)" );
}

use version; our $VERSION = qv('0.0.1');

use Sub::Exporter -setup => {
    exports => [
        qw/
          is_table_in_bis
          is_table_in_dev_datahub
          is_table_in_dev_datahub_has_partition
          is_table_in_dev_datahub_has_data
          patch_dsx_for_prod
          conDB
          read_DATA
          is_table_in_metadata_dev_datahub
          get_job_name
          read_file
          /
    ],
};

# Other recommended modules (uncomment to use):
#  use IO::Prompt;
#  use Perl6::Export;
#  use Perl6::Slurp;
#  use Perl6::Say;

# Module implementation here
sub is_table_in_bis {
    my ( $dbh, $table_name ) = @_;
    my $statement =
      "SELECT count(*) FROM qsys2.tables WHERE table_name IN ('?') WITH UR";

    # return exec_cnt_sql( $dbh, $table_name,$statement );
    # my $statement=get_sql();
    # say $statement;
    # return exec_cnt_sql( $dbh, $table_name,$statement );

    # $sql->{'is_table_in_bis'};
    my $sth = $dbh->prepare($statement);
    $sth->execute($table_name);
    return $sth->fetchrow_array() >= 1 ? 1 : 0;
}

sub is_table_in_dev_datahub {
    my ( $dbh, $table_name ) = @_;
    my $sth = $dbh->prepare(
"SELECT count(*) FROM SYSIBM.SYSTABLES WHERE name IN ('$table_name') WITH UR"
    );
    $sth->execute();
    return $sth->fetchrow_array() >= 1 ? 1 : 0;
}

sub is_table_in_metadata_dev_datahub {
    my ( $dbh, $table_name ) = @_;
    my $sth = $dbh->prepare(
"SELECT count(*) FROM HUB_META.DATASET_CATALOG WHERE DATASET_DH_NAME IN ('$table_name')  WITH UR"
    );
    $sth->execute();
    return $sth->fetchrow_array() >= 1 ? 1 : 0;
}

# sub is_table_exists_in_metadata{
# # ...
# }

sub conDB {
    my ( $dsn, $user, $pass ) = @_;
    my $dbh = DBI->connect( $dsn, $user, $pass ) or die "DB connect Error :$!";

    # , {RaiseError => 1 ,PrintError => 1 , AutoCommit => 0}
    return $dbh;
}

sub exec_cnt_sql {
    my ( $dbh, $table_name, $statement ) = @_;
    my ($cnt) = $dbh->selectrow_array( $statement, undef, ($table_name) );
    return $cnt >= 1 ? 1 : 0;
}

# selectrow_array to selectrow_hashref,

sub is_table_in_dev_datahub_has_partition {
    my ( $dbh, $table_name, $str_date ) = @_;

    # $table_name=1;
    # print $table_name."\n";
    my $sql = qq{
	SELECT COUNT(*)
  FROM SYSCAT.DATAPARTITIONS
  WHERE TABSCHEMA = 'HUB_CNL' AND TABNAME = '$table_name'
    AND SUBSTR(LOWVALUE, 2, 10) = '$str_date'
	WITH UR
	};

    # print $sql."\n";
    my $sth = $dbh->prepare($sql)
      or die
      "Can't prepare SQL statement: $DBI::errstr\n";    #$table_name 2014-09-10
    $sth->execute();
    my $cnt = $sth->fetchrow_array();

    # print "\n]$cnt]\n";
    return $cnt >= 1 ? 1 : 0;
}

sub is_table_in_dev_datahub_has_data {
    my ( $dbh, $table_name, $str_date ) = @_;
    my $sql = qq{
	SELECT COUNT(*)
    FROM (SELECT *
            FROM HUB_CNL.$table_name
            WHERE LOADING_DT = '$str_date'
            FETCH FIRST ROW ONLY)
    WITH UR	
	};
    my $sth = $dbh->prepare($sql)
      or die
      "Can't prepare SQL statement: $DBI::errstr\n";    #$table_name 2014-09-10
    $sth->execute();
    my $cnt = $sth->fetchrow_array();
    return $cnt >= 1 ? 1 : 0;
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

    my @stage_and_fields = ();
    while ( $orchestrate_code_body =~ m/$ORCHESTRATE_CODE_RX/g ) {
        my %stage_and_fields = ();
        print "\nFound Orchestrate StageName: $+{stage_name}\n";
        print "Found Orchestrate OperatorName: $+{operator_name}\n";
        $stage_and_fields{stage_name}    = $+{stage_name};
        $stage_and_fields{operator_name} = $+{operator_name};
        if ( defined $+{source_body} ) {

            # print "Found Orchestrate SourceBody: $+{source_body}\n";
            $fields = process_orchestrate_body( $+{source_body} );
            $stage_and_fields{fields} = $fields;
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
        print "\nInput Fields:\n";
        $fields =
          process_orchestrate_sql_type( $+{sql_type}, $+{sql_precision} );
    }
    return $fields;
}

sub process_orchestrate_sql_type {
    my ( $sql_type, $sql_precision ) = @_;
    my $prec_hash = process_orchestrate_sql_precision($sql_precision);
    tie my %hash, 'Tie::IxHash';
    %hash = map { split /=/, $_ } ( split /, /, $sql_type );
    my @fields = ();
    for my $key ( keys %hash ) {
        my %hash_datatypes = ();
        print $key. ": "
          . decode_sql_type( $hash{$key} ) . "("
          . $prec_hash->{$key} . ")\n";
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

# $transformer_stage_prop = process_transformer_stage_properties( $stage_body,  $CONNECT_PROPERTIES_RX );

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

#    my $CONNECT_PROPERTIES_RX =
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
qr{\Q**************************************************\E\nL\$V0S(?<activity_number>\d{3})\$START:\n\Q***\E Activity "(?<activity_name>\w+)": Initialize job\n   jb\$V0S\g{activity_number} = "(?<job_name>\w+)"(:\'\.\':\("(?<invocation_id>\w+)"\)|)}s;
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

    my @stages = ();
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
qr{(?<field_body>BEGIN DSSUBRECORD\s+Name "(?<field_name>\w+)"\s+SqlType "(?<field_type>\w+)"\s+Precision "(?<prec_value>\w+)".*?(.*?ParsedDerivation "(?<parsed_deriv>.*?)(?<!\\)"|.*?).*?(SourceColumn "(?<source_column>.*?)"|.*?).*?END DSSUBRECORD)}s;

# write_file('out_stages/'.$+{stage_name}.'_'.$+{ole_type}.'.dsx',$stage_body);
        while ( $stage_body =~ m/$FIELD_RECORD_RX/g ) {

		p $+;
#$+{stage_name}	out_stages	$stage_body
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
			 print "Found field_name: " .  $hash_datatypes{field_name} . " \n";
            $hash_datatypes{sql_type} =
              decode_sql_type( $+{field_type} ) . "(" . $+{prec_value} . ")";
			print "Found sql_type: " . $hash_datatypes{sql_type}. " \n";  
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
    my %job_prop;
    while ( $job_body =~ m/$COMPILE_RX_REF->{JOB_DESC_RX}/g ) {
        $job_prop{JobName} = from_dsx_2_utf( $+{job_name} );
        if ( defined( $+{job_description} ) ) {
            $job_prop{JobDesc} = from_dsx_2_utf( $+{job_description} );
        }

    }
    my @fields_all = ();
    my $fields;
    while ( $job_body =~ m/$COMPILE_RX_REF->{ORCHESTRATE_CODE_FULL_RX}/g ) {
        $fields =
          process_orchestrate_code_properties( $+{orchestrate_code_body},
            $COMPILE_RX_REF->{ORCHESTRATE_CODE_RX} );
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
        'fields_all', 'IdentList', 'Activity',
        'StagesInfo', 'job_annotation_texts'
      }
      = (
        $fields, $job_identlist_value, $ref_activity, $ref_stages,
        \@job_annotation_texts
      );

    # $job_prop{fields_all}           = $fields;
    # $job_prop{IdentList}            = $job_identlist_value;
    # $job_prop{Activity}             = $ref_activity;
    # $job_prop{StagesInfo}           = $ref_stages;
    # $job_prop{job_annotation_texts} = \@job_annotation_texts;
    return \%job_prop;
}

sub get_job_name {
    my ($file_name) = @_;
    my $data = read_file($file_name);
    my $ORCHESTRATE_CODE_FULL_RX =
      qr{OrchestrateCode \Q=+=+=+=\E(?<orchestrate_code_body>.*?)\Q=+=+=+=\E}s;

# my $ORCHESTRATE_CODE_RX =qr#STAGE: (?<stage_name>\w+).*?Operator\n(?<operator_name>\w)\n.*?source 0 '{(<?source_body>.*?)\n}'#s;
#    my $ORCHESTRATE_CODE_RX =
#qr{STAGE: (?<stage_name>\w+).*?Operator\n(?<operator_name>\w+)(.*?\-source 0 \'\{(?<source_body>.*?)\n\}\'|.*?)(\#\# Inputs\n0\< \[.*?\] '(?<inputs_name>.*?)'|.*?)(\#\# Outputs\n0\> \[.*?\] '(?<outputs_name>.*?)'|.*?)}s;
    my $stage_operator =
      qr{STAGE: (?<stage_name>\w+).*?Operator\n(?<operator_name>\w+)};
    my $outputs     = qr{## Outputs.*?'(?<outputs_name>.*?)'};
    my $inputs      = qr{## Inputs.*? '(?<inputs_name>.*?)'};
    my $source_body = qr{-source 0 '{(?<source_body>.*?)\n}'};
    my $ORCHESTRATE_CODE_RX =
qr%($stage_operator(.*?$source_body.*?$outputs)|($stage_operator(.*?$inputs|.*?)(.*?$outputs|.*?)))%s;

#my $stage_operator=q{STAGE: (?<stage_name>\w+).*?Operator\n(?<operator_name>\w+)};
#my $ORCHESTRATE_CODE_RX =qr%($stage_operator(.*?-source 0 '{(?<source_body>.*?)\n}'.*?## Outputs.*?'(?<outputs_name>.*?)')|(STAGE: (?<stage_name>\w+).*?Operator\n(?<operator_name>\w+)(.*?## Inputs.*? '(?<inputs_name>.*?)'|.*?)(.*?## Outputs.*? '(?<outputs_name>.*?)'|.*?)))%s;

#my $ORCHESTRATE_CODE_RX =qr{STAGE: (?<stage_name>\w+).*?Operator\n(?<operator_name>\w+)(.*?\-source 0 \'\{(?<source_body>.*?)\n\}\'|.*?).*?(.*?\#\#( Inputs\n0\< \[.*?\] '(?<inputs_name>.*?)').*?|.*?).*?(.*?\#\#( Outputs\n0\> \[.*?\] '(?<outputs_name>.*?)').*?|.*?)}s;
#my $ORCHESTRATE_CODE_RX =qr{(\#\#\#\#\ STAGE\:\ (?<stage_name>\w+)\n\#\#\ Operator\n(?<operator_name>\w+)\n.*?|.*?)(\-source 0 \'\{(?<source_body>.*?)\n\}\'|.*?).*?(.*?\#\#\ Inputs\n0\<\ \[\]\ \'(?<inputs_name>.*?)\'\n|.*?)}s;

# my $ORCHESTRATE_CODE_RX =
# qr{STAGE: (?<stage_name>\w+).*?Operator\n(?<operator_name>\w+)(.*?\-source 0 \'\{(?<source_body>.*?)\n\}\'|.*?)}s;

    # .*?source 0 \'\{(<?source_body>.*?)\n\}\'
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
qr{BEGIN DSRECORD.*?OLEType "CJobDefn".*?Name "(?<job_name>\w+)"(\n\s+Description "(?<job_description>.*?)(?<!\\)"|)}s;
    my $JOB_ANNOTATION_TEXT_RX =
qr{BEGIN DSRECORD.*?OLEType "CAnnotation".*?AnnotationText "(?<annotation_text>.*?)(?<!\\)"}s;

#StageType "CTransformerStage"
#    my $JOB_STAGE_RX =
#qr{(?<stage_body>BEGIN DSRECORD.*?OLEType "(?<ole_type>CCustomStage|CTransformerStage|CTrxOutput|CTrxInput|CCustomOutput|CCustomInput)".*?Name "(?<stage_name>\w+)".*?(StageType "(?<stage_type>\w+)"|.*?).*?END DSRECORD)}s;

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

    # my @COMPILE_RX    = (
    # $CPARAMETERS_RX,         $JOB_DESC_RX,
    # $JOB_ANNOTATION_TEXT_RX, $JOB_STAGE_RX,
    # $CONNECT_PROPERTIES_RX,  $PARAMETER_RX,
    # $IDENTLIST_RX,           $ORCHESTRATE_CODE_FULL_RX,
    # $ORCHESTRATE_CODE_RX,    $JOB_STAGE_TYPE_RX
    # );
    my %COMPILE_RX = ();
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

    # my @COMPILE_PARAM_RX = ( $PARAMETER_RX, $PARAMETER_SET_RX );
    my %COMPILE_PARAM_RX = ();
    @COMPILE_PARAM_RX{ 'PARAMETER_RX', 'PARAMETER_SET_RX' } =
      ( $PARAMETER_RX, $PARAMETER_SET_RX );

    my ( $head_prop, $job_prop );
    my @jobs_properties;
    {
        local $/ = '';    # Paragraph mode
        while ( $data =~ m/$JOB_HEADER_RX/g ) {
            $head_prop = process_job_header( $+{job_header} );
        }
        while ( $data =~ m/$JOB_RX/g ) {
            $job_prop = process_stage( $+{job_body}, \%COMPILE_RX );
            push @jobs_properties, $job_prop;
        }
		p  $job_prop;
        while ( $data =~ m/$PARAMETER_SETS_RX/g ) {
            process_parameters( $+{parameter_sets_body}, \%COMPILE_PARAM_RX );
        }
    }

	
    my @prop_4_excel = ( $head_prop, \@jobs_properties );
    make_revision_history( \@prop_4_excel );
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
   ServerVersion "8.7"
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
# New subroutine "set_excel_properties" extracted - Wed Nov  5 09:44:48 2014.
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
        comments =>
'Автосгенерированный Excel файл',

        # status   => 'В Работе',
    );

}

#
# New subroutine "set_excel_formats" extracted - Wed Nov  5 09:47:05 2014.
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

    # size          => 20,
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
# New subroutine "add_write_handler_autofit" extracted - Wed Nov  5 09:49:47 2014.
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
# New subroutine "fill_excel_header" extracted - Wed Nov  5 09:54:20 2014.
#
sub fill_excel_header {
    my $ref_formats      = shift;
    my $revision_history = shift;
    my $head_prop        = shift;

    my $date = strftime "%d.%m.%Y", localtime;
    $revision_history->write( 0, 0, "Date",        $ref_formats->{heading} );
    $revision_history->write( 0, 1, "Version",     $ref_formats->{heading} );
    $revision_history->write( 0, 2, "Description", $ref_formats->{heading} );
    $revision_history->write( 0, 3, "Author",      $ref_formats->{heading} );

    $revision_history->write( 1, 0, $date, $ref_formats->{date_fmt} );
    $revision_history->write( 1, 1, "1.0", $ref_formats->{num_fmt} );
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
# New subroutine "fill_excel_name_stages" extracted - Wed Nov  5 16:08:24 2014.
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
#$j,     $col,

#
# New subroutine "fill_excel_job_annotation_text" extracted - Wed Nov  5 16:10:45 2014.
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
        $col_map = $col_map + 6;
    }
    return $col_map;
}

#
# New subroutine "fill_excel_stage_info" extracted - Wed Nov  5 16:12:45 2014.
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
# New subroutine "fill_excel_stage_fields" extracted - Wed Nov  5 16:12:45 2014.
#
sub fill_excel_stage_fields {
    my $ref_formats = shift;
    my $curr_job    = shift;
    my $col         = shift;
    my $stages      = shift;
    my $j           = shift;

    $curr_job->write( $j + 6, $col, "table_name",    $ref_formats->{heading} );
    $curr_job->write( $j + 7, $col, "operator_name", $ref_formats->{heading} );

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
    }

    return $j;
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
        $curr_job->write(
            $j + 8,
            $col_map + 2,
            "Source Column",
            $ref_formats->{map_fmt}
        );
        $curr_job->write( $j + 8, $col_map + 3,
            "Datatype", $ref_formats->{map_fmt} );
        $curr_job->write( $j + 8, $col_map + 4,
            "Expression/Decode", $ref_formats->{map_fmt} );

    }
    return 1;
}

#
# New subroutine "fill_excel_activity_info" extracted - Wed Nov  5 16:14:26 2014.
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
# New subroutine "fill_excel_fields_all" extracted - Wed Nov  5 16:14:26 2014.
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
                $q++;

                $max_q = max_q( $max_q, $q );
            }
            $col = $col + 2;
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
# New subroutine "fill_excel_ident_list" extracted - Wed Nov  5 16:14:26 2014.
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
# New subroutine "fill_excel_stages" extracted - Wed Nov  5 11:13:56 2014.
#
sub fill_excel_stages {
    my ( $ref_formats, $curr_job, $job_pop ) = @_;
    my $stages                   = $job_pop->{StagesInfo};
    my $activity                 = $job_pop->{Activity};
    my $ref_job_annotation_texts = $job_pop->{job_annotation_texts};
    my $ident_list               = $job_pop->{IdentList};
    my $fields_all               = $job_pop->{fields_all};
    my $j                        = 1;
    my $col                      = 3;

    # $j = fill_excel_name_stages( $ref_formats, $curr_job, $stages, $j );

    $j = fill_excel_job_annotation_text( $ref_formats, $curr_job,
        $ref_job_annotation_texts, $j );
    $j = fill_excel_stage_info( $ref_formats, $curr_job, $col, $stages, $j );
    $j =
      fill_excel_activity_info( $ref_formats, $curr_job, $col, $activity, $j );
    $j =
      fill_excel_ident_list( $ref_formats, $curr_job, $col, $ident_list, $j );
    $j =
      fill_excel_fields_all( $ref_formats, $curr_job, $col, $fields_all, $j );
    $j = fill_excel_stage_fields( $ref_formats, $curr_job, $col, $stages, $j );
}

#
# New subroutine "fill_excel_body" extracted - Wed Nov  5 09:58:42 2014.
#

sub fill_excel_body {
    my $ref_formats      = shift;
    my $i                = shift;
    my $job_pop          = shift;
    my $revision_history = shift;
    my $workbook         = shift;

    my %loc_hash_prop = %{$job_pop};
    $revision_history->write( 5 + $i, 5, $i,  $ref_formats->{rows_fmt} );
    $revision_history->write( 5 + $i, 6, "0", $ref_formats->{rows_fmt} );
    $revision_history->write_url(
        5 + $i, 7,
        'internal:' . $loc_hash_prop{JobName} . '!A2',
        $ref_formats->{url_format},
        $loc_hash_prop{JobName}
    );

    $revision_history->write( 5 + $i, 8, $loc_hash_prop{JobDesc},
        $ref_formats->{rows_fmt} );
    my $curr_job = $workbook->add_worksheet( $loc_hash_prop{JobName} );
    add_write_handler_autofit($curr_job);

    $curr_job->activate();
    $curr_job->write_url(
        'A2',
        'internal:Revision_History!H' . ( 5 + $i ),
        $ref_formats->{url_format}, 'Back'
    );

    $curr_job->write( 'D2', "Sequence",    $ref_formats->{heading} );
    $curr_job->write( 'E2', "Description", $ref_formats->{heading} );

    $curr_job->write( 'D3', $loc_hash_prop{JobName}, $ref_formats->{rows_fmt} );
    $curr_job->write( 'E3', $loc_hash_prop{JobDesc}, $ref_formats->{rows_fmt} );

    fill_excel_stages( $ref_formats, $curr_job, $job_pop );
    autofit_columns($curr_job);
}

sub make_revision_history {
    my ($prop_4_excel) = @_;
    my ( $head_prop, $job_prop ) = @{$prop_4_excel};
    my @jobs_properties = @{$job_prop};

    my $workbook =
      Spreadsheet::WriteExcel->new( $head_prop->{ProjectName} . '_ON_'
          . $head_prop->{ServerName}
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
    return if $token =~ /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/;

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

# my $match_exactly='\(412)\(41D)\(418)\(41C)\(410)\(41D)\(418)\(415)!!';
# $data =~ s/BEGIN DSRECORD.*AnnotationText "\Q${match_exactly}\E.*END DSRECORD//gs;
# $data =~ s/BEGIN DSRECORD.*AnnotationText*END DSRECORD//mxs;
#remove_red_box

=pod	
	$data =~ s/(.*)(BEGIN DSRECORD
      Identifier "V132A0".*AnnotationText "\\\(412\)\\\(41D\)\\\(418\)\\\(41C\)\\\(410\)\\\(41D\)\\\(418\)\\\(415\)!!.*END DSRECORD)(
(?=   BEGIN DSRECORD
      Identifier "V133S0").*)/$1$3/s;
=cut	  

    #return LOADING_DT
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

sub read_file {
    my ($filename) = @_;

    open my $in, '<:encoding(UTF-8)', $filename
      or die "Could not open '$filename' for reading $!";
    local $/ = undef;
    my $all = <$in>;
    close $in;

    return $all;
}

sub write_file {
    my ( $filename, $content ) = @_;

    open my $out, '>:encoding(UTF-8)', $filename
      or die "Could not open '$filename' for writing $!";
    print $out $content;
    close $out;

    return;
}

sub append_file {
    my ( $filename, $content ) = @_;

    open my $out, '>>:encoding(UTF-8)', $filename
      or die "Could not open '$filename' for writing $!";
    print $out $content;
    close $out;

    return;
}

# my %contents_of = do { local $/; "", split /_____\[ (\S+) \]_+\n/, <DATA> };
# for (values %contents_of) {
# s/^!=([a-z])/=$1/gxms;
# }
# my $data = &read_DATA( join '', <DATA> );
# my @golf = split /\n/, $data->{'Perl_Golf'};
# sub get_sql{
# # no warnings 'once';
# # return read_DATA( join '', <DATA> );
# # return read_DATA( <DATA> );
# }

# sub read_DATA {
# no warnings;    #Name "Datahub::Tools::DATA" used only once:
# # my $string = shift;
# # print {*STDERR} "Reading from __DATA__...\n";
# my %contents_of = do { local $/; "", split /_____\[ (\S+) \]_+\n/, <DATA> };

# # use YAML;
# # print "# %contents_of\n", Dump \%contents_of;
# for ( values %contents_of ) {

# # s/^!=([a-z])/=$1/gxms;
# s/^!=(\w+)/=$1/gxms;
# }

# # print {*STDERR} "done\n";
# return \%contents_of;
# }

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

Nikolay Mishin  C<< <mi@ya.ru> >>


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
_____[ is_table_in_bis ]________________________________________________
SELECT count (*)
  FROM qsys2.tables
 WHERE table_name IN ('?')
  WITH UR
_____[ Makefile.PL ]_____________________________________________
use strict;
use warnings;
use ExtUtils::MakeMaker;
 
WriteMakefile(
    NAME                => '<MAIN MODULE>',
    AUTHOR              => '<AUTHOR> <<EMAIL>>',
    VERSION_FROM        => '<MAIN PM FILE>',
    ABSTRACT_FROM       => '<MAIN PM FILE>',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => '<DISTRO>-*' },
);
_____[ README ]__________________________________________________
<DISTRO> version 0.0.1
