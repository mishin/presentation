#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use DBI;
use Test::More qw/no_plan/;
use POSIX;
use DateTime;
use Carp;
use FindBin '$Bin';    #get $path_to_current_script !!!
use Smart::Comments;
use FBS::Load
  qw(get_user_param get_connect get_cobdate_sql  welcome_cob_date test_10_persent);

#my @init_user_connects = ( 'rwa_owner', 'mishnik', 'fbs_exec', 'qv_fbs_ro' );
#my $rwa_owner_user='mishnik';
my @init_user_connects = ( 'rwa_owner', 'fbs_exec', 'qv_fbs_ro' );
my $rwa_owner_user     = 'rwa_owner';
my $config_name        = 'fbs_load.yml';

# read init
#==START_UNCOMMENT
my $ref_ini = init_load( $config_name, \@init_user_connects );
### $ref_ini
my ( $ref_connect, $ref_cd ) = @{$ref_ini};
my %connect_of = %{$ref_connect};
my ( $cob_date, $cob_date_display, $we_name ) = @{$ref_cd};
### $cob_date
#==END_UNCOMMENT

# print  initial comment about COB_DATE and how create Jira ticket
#print welcome_cob_date( $rwa_owner_user, $ref_ini );

# execute according with https://wiki.tools.intranet.db.com/confluence/display/FCL/FBS+Production+Life+Cycle
# 2. Procedure
# 2.1 Step 1. Several FCL/FBS feeds arrival
#step_1
#my $content = import_sql_and_data();
## $content
#read sql and data from source
my $ref_source_data = import_sql_and_data();
## $ref_source_data
my %sql_and_data = %{$ref_source_data};

my $ref_tests = get_data_from_source( $ref_source_data, 'Data' );
my $ref_data_and_sql =
  get_data_from_source( $ref_source_data, 'Data_and_Check_and_Date_sql' );
my ( $ref_step_all, $ref_step_sql ) = get_step_sql($ref_data_and_sql);
## $ref_step_sql
## $ref_step_all
# my %step_all=%{$ref_step_all};
# my $var=$step_all{'Step_2_1_1'};
# my @vars=@{$var};
# ### $var
# say $vars[0];
# say $vars[1];

#make_test( $ref_tests, $ref_step_sql, $ref_source_data );
make_test( $ref_tests, $ref_step_all, $ref_source_data, $ref_connect,
    $cob_date );

## $ref_data_and_sql
sub get_step_sql {
    my $data        = shift;
    my %step_sql_of = ();
    my %step_all_of = ();
    foreach my $step (@$data) {
        my $user_name     = pop @$step;
        my $time          = pop @$step;
        my $day           = pop @$step;
        my $sql_name      = pop @$step;
        my $step_name     = pop @$step;
        my @access_values = ( $sql_name, $user_name, $day, $time );
        $step_all_of{$step_name} = \@access_values;
        $step_sql_of{$step_name} = $sql_name;
    }
    my $ref_all = \%step_all_of;
    my $ref_sql = \%step_sql_of;

    #my @sql_all_rets = ( $ref_all, $ref_sql );
    return ( $ref_all, $ref_sql );
}
## %sql_step_of

#Data_and_Check_and_Date_sql

#
# New subroutine "test_database_values" extracted - Fri Oct 21 22:33:12 2011.
#
sub test_database_values {
    my $ref_dbms_vars = shift;
## $ref_dbms_vars    
    my ( $database_connect, $orig_value, $source_system_cd, $SQL_query,
        $persent, $cob_date, $message, $sql_name )
      = @{$ref_dbms_vars};

    if ( !defined $database_connect ) {
        say $message. ' : ' . $SQL_query;
    }
    else {
        my $calc_value = 0;

        #found my $calc_value = 22;!!
        my $sth = $database_connect->prepare($SQL_query);
## $database_connect
        # Check_Chunks cob_date
        # Check_Chunks source_system_cd
        # DBInstruments_Check NO
        if ( $sql_name eq 'Check_Chunks' ) {
            $sth->execute( $cob_date, $source_system_cd );
        }
        elsif ( $sql_name eq 'DBInstruments_Check' ) {
            $sth->execute();
        }
        else {
            $sth->execute($cob_date);
        }

        if (   ( $sql_name eq 'Sum_FCL_COPY' )
            or ( $sql_name eq 'DBInstruments_Check' ) )
        {

            while ( my @values = $sth->fetchrow_array ) {
###   @values
            }

        }
        else {
            $calc_value = $sth->fetchrow_array();
        }

        test_10_persent( $calc_value, $orig_value, $persent, $message );

    }

}

#
# New subroutine "test_current_system" extracted - Fri Oct 21 22:21:59 2011.
#
sub test_current_system {
    my ( $t, $cob_date, $data_and_sql, $connect_of, $step_all ) = @_;
    my ( $sql_name, $user );

    #get values from array
    my $step_name        = pop @$t;
    my $expected_value   = pop @$t;
    my $source_system_cd = pop @$t;
    say '*********current_step: ' . $step_name . '*************';

    #my $calc_value = 22;
    my $orig_value = $expected_value;
    my $persent    = 10;                #%
                                        #get_user_name?

    my $ref_sql_and_user = $step_all->{$step_name};
    my @sql_and_users    = @{$ref_sql_and_user};

    ( $sql_name, $user ) = ( '', '' );
    $sql_name = $sql_and_users[0];
    $user     = $sql_and_users[1];
    my $database_connect = '';
    $database_connect = $connect_of->{$user};
    my $SQL_query = '';
    $SQL_query = $data_and_sql->{$sql_name};

    my $message       = $source_system_cd;
    my @test_dbms_var = (
        $database_connect, $orig_value, $source_system_cd, $SQL_query, $persent,
        $cob_date, $message, $sql_name
    );
    test_database_values( \@test_dbms_var );

}

sub make_test {
    my ( $ref_tests, $ref_step_all, $ref_data_and_sql, $ref_connect, $cob_date )
      = @_;
    my @tests = @{$ref_tests};

    #get first 2 values
    my @someNames = splice( @tests, 0, 9 );

    #foreach my $t (@tests) {
    foreach my $t (@someNames) {
        test_current_system( $t, $cob_date, $ref_data_and_sql, $ref_connect,
            $ref_step_all );
    }
}

# #             if ( $orig_value eq 'ANY' ) {
# say $message. ' : ' . $SQL_query;
## $calc_value
# }

sub get_data_from_source {
    my $ref_sql      = shift;
    my $sign_of_data = shift;
    my @complex_data = ();
    my %sql_and_data = %{$ref_sql};

    #say $sql_and_data{Data};
    my @data = split /\n/, $sql_and_data{$sign_of_data};
## @data
    for my $line (@data) {
        my @line_data = split /\s+/, $line;
        push @complex_data, \@line_data;
    }
    return \@complex_data;
}

# while ( my $line = <$sql_and_data{Data}> ) {
# next if $line =~ /^\s*(#.*)?$/;
# my @data = split /\s+/, $line;
## @data
## $line
# push @tests, \@data;
# }
## @tests

# my $calc_value = 22;
# my $orig_value = 20;
# my $persent    = 10;      #%
# my $message    = 'MIS';

# # test_10_persent( $calc_value, $orig_value, $persent, $message );

#test_cnt_persent()

#read init parameters and get connect to database
sub init_load {
    my $config_name            = shift;
    my $ref_init_user_connects = shift;

    #read start parameter to connect oracle database!!
    my $yaml =
      get_user_param( $Bin, $config_name );    #Global hash with parameters
## $yaml

    #generate connect to database!
    my $ref_connect = get_connect( $ref_init_user_connects, $yaml );
    my %connect_of = %{$ref_connect};
## $ref_connect

    #find currecnt cob_date
    my $dbh_fbs     = $connect_of{fbs_exec};
    my $ref_cd      = $dbh_fbs->selectrow_arrayref( get_cobdate_sql() );
    my @init_values = ( $ref_connect, $ref_cd );
    return \@init_values;
}

sub import_sql_and_data {
    print {*STDERR} "Reading sql query...\n";

    # Then install the various files...
    my @sql_query =
      ( 'Check_Chunks', 'Check_Chunks_MIS', 'Data', 'Data_and_Check_sql' );

    my %contents_of = do { local $/; "", split /_____\[ (\S+) \]_+\n/, <DATA> };
    ## %contents_of
    for ( values %contents_of ) {
        s/^!=([a-z])/=$1/gxms;
    }

    # for my $select (@sql_query) {
    # print {*STDERR} "\t$select...";
    # print "$select:\n";
    # print $contents_of{$select};
    print {*STDERR} "done\n";

    # }
## %contents_of;
    return \%contents_of;
}

=pod
=item *  C<< import_sql_and_data ()  >>
=item *  my $content=import_sql_and_data () 

Read sql-query and data from source of module
=cut

__DATA__

_____[ Check_Chunks ]________________________________________________
select count(*)
  from rwa_owner.T_CHUNK_REVISIONS
 where cob_date = TO_DATE (?, 'yyyy-mm-dd')
   AND source_system_cd = ?
   AND data_quality_cd = 'O'
   AND chunk_revision = 1
   AND chunk_status_cd = 'PC'
_____[ Check_Chunks_MIS ]_____________________________________________
select count(*)
  from rwa_owner.T_CHUNK_REVISIONS
 where source_system_cd = 'MIS'
   and cob_date = TO_DATE (?, 'yyyy-mm-dd')
   and data_quality_cd = 'O'
   and chunk_revision = 1
   and reset_ind = 'N'
   and chunk_status_cd in ('PC', 'LE')
_____[ Check_FX_Rates ]_____________________________________________
select count(1)
from fbs_owner.t_pvs_ccy_rate
where rate_date = TO_DATE (?, 'yyyy-mm-dd')
_____[ DBInstruments_Check ]_____________________________________________
SELECT   'EQT' tname, report_date
  		FROM   fbs_owner.db_instrument_equity
WHERE   ROWNUM = 1
UNION ALL
SELECT   'FIX' tname, report_date
 		FROM   fbs_owner.db_instrument_fixedincome
WHERE   ROWNUM = 1
UNION ALL
SELECT   'MBS' tname, report_date
  		FROM   fbs_owner.db_instrument_mbs
 	WHERE   ROWNUM = 1
_____[ CALICO_NYK_sql ]_____________________________________________
select count(*)
from rwa_owner.T_IDS_GCDS_TRADE
where CHUNK_REVISION_SK in
(select chunk_revision_sk
from rwa_owner.T_CHUNK_REVISIONS
where CHUNK_ID in( 'CALICOTBA|NYK')
  	and cob_date = TO_DATE (?, 'yyyy-mm-dd')
        and data_quality_cd = 'O'
        and chunk_status_cd in ('PS', 'IS', 'EC', 'ES', 'PC', 'XC', 'XS', 'PF', 'VC', 'VS', 'VW'))
_____[ CALICO_OTHERS_sql ]_____________________________________________
 select count(*)
   from T_IDS_GCDS_TRADE
  where CHUNK_REVISION_SK in
        (select chunk_revision_sk
           from T_CHUNK_REVISIONS
          where CHUNK_ID = 'CALICO | OTHER'
            and cob_date =  TO_DATE (?, 'yyyy-mm-dd')
            and data_quality_cd = 'O'
           and chunk_status_cd in ('PS', 'IS', 'EC', 'ES', 'PC', 'XC', 'XS', 'PF', 'VC', 'VS', 'VW'))
_____[ DARE_sql ]_____________________________________________
select count(*)
from rwa_owner.T_IDS_GCDS_TRADE
where CHUNK_REVISION_SK in
(select chunk_revision_sk
from rwa_owner.T_CHUNK_REVISIONS
where CHUNK_ID = 'DARE'
  	and cob_date = TO_DATE (?, 'yyyy-mm-dd')
  	and data_quality_cd = 'O'
  	and chunk_status_cd = 'PC')
_____[ FCR_sql ]_____________________________________________
select count(*)
from rwa_owner.T_IDS_GCDS_TRADE
where CHUNK_REVISION_SK in
(select chunk_revision_sk
from rwa_owner.T_CHUNK_REVISIONS
where CHUNK_ID = 'FCR'
 	and cob_date = TO_DATE (?, 'yyyy-mm-dd')
  	and data_quality_cd = 'O'
 	and chunk_status_cd = 'PC')
_____[ Everest+_sql ]_____________________________________________
select count(*)
from rwa_owner.T_IDS_GCDS_TRADE
where CHUNK_REVISION_SK in
(select chunk_revision_sk
from rwa_owner.T_CHUNK_REVISIONS
where CHUNK_ID = 'EVEREST+'
  	and cob_date = TO_DATE (?, 'yyyy-mm-dd')
  	and data_quality_cd = 'O'
        and chunk_status_cd in ('PS', 'IS', 'EC', 'ES', 'PC', 'XC', 'XS', 'PF', 'VC', 'VS', 'VW'))
_____[ Update_ESS ]_____________________________________________
UPDATE fbs_owner.FBS_COB_DATES set
IS_ONLINE_ESS_DATA_LON='Y',
IS_ONLINE_ESS_DATA_NY='Y'
where COB_DATE= TO_DATE (?, 'yyyy-mm-dd')
_____[ FCL_COPY_proc ]_____________________________________________
1. Launch the script below (PROD,pbrun ssh -l fbs_owner fracsfclap1.de.db.com, /fbs/prd/scripts/FCL_COPY by user FBS_OWNER ):
nohup ./fcl_copy_tuned_new_prod.sh 'COB_date' CHL/CLC/IMG/GL1/PBR/ALC/DRE/ESS/LNT/LS2/MDS/BAS/GDH/FPA/RMS/EV+/MIS/RMW/FCR NONE &
_____[ FCL_COPY_process_example ]_____________________________________________
nohup ./fcl_copy_tuned_new_prod.sh '18.10.2011'  CHL/CLC/IMG/GL1/PBR/ALC/DRE/ESS/LNT/LS2/MDS/BAS/GDH/FPA/RMS/EV+/MIS/RMW/FCR NONE &
_____[ Sum_FCL_COPY ]_____________________________________________
WITH cob_dt AS (SELECT   TO_DATE (?, 'yyyy-mm-dd') cob FROM DUAL),
    tmp_table
       AS (SELECT         /*+ index(t_ids_gcds_trade T_IDS_GCDS_TRADE_IDX06)*/
                 mtm_amt,
                    desired_cob_dt,
                    DECODE (
                       trn_src_cd,
                       'DARE',
                       'DARE',
                       'FCR',
                       'FCR',
                       'IMAGINE-ASIAPAC',
                       'IMG',
                       'IMAGINE-HK',
                       'IMG',
                       'IMAGINE-SYD',
                       'IMG',
                       'IMAGINE-TKO',
                       'IMG',
                       'ALICE_REPO_2',
                       'FCS',
                       'LOANET',
                       'FCS',
                       'GLOBAL1:DAUD',
                       'FCS',
                       'GLOBAL1:DBIL',
                       'FCS',
                       'GLOBAL1:DFFT',
                       'FCS',
                       'GLOBAL1:DGED',
                       'FCS',
                       'GLOBAL1:DMDB',
                       'FCS',
                       'GLOBAL1:DMMG',
                       'FCS',
                       'GLOBAL1:DMNY',
                       'FCS',
                       'GLOBAL1:DMTK',
                       'FCS',
                       'DBCALICO',
                       'Calico',
                       'EVEREST+',
                       'Everest Plus',
                       'OpenLink',
                       'FCP',
                       'RMS',
                       'FCP',
                       'SUMMIT',
                       DECODE (src_prod_type_cd,
                               'BND_OPT', 'FCD',
                               'BOND_OPT', 'FCD',
                               'BONDOP', 'FCD',
                               'CAP', 'FCD',
                               'CASHCOLLAT', 'FCD',
                               'CCY_SWAP', 'FCD',
                               'CIRS', 'FCD',
                               'COM_SWP', 'FCD',
                               'DEF_BSKT', 'FCD',
                               'DEF_CDS', 'FCD',
                               'DEF_PORT', 'FCD',
                               'DEF_TRN', 'FCD',
                               'DEF_TRS', 'FCD',
                               'DEFSWAP', 'FCD',
                               'DLPMT', 'FCD',
                               'EQ_OPT', 'FCD',
                               'EQ_SWP', 'FCD',
                               'EXOTIC', 'FCD',
                               'FEE', 'FCD',
                               'FLOOR', 'FCD',
                               'FRA', 'FCD',
                               'FX_FWD', 'FCD',
                               'FX_OPT', 'FCD',
                               'FX_SWP', 'FCD',
                               'GENDEPTRS', 'FCD',
                               'GENDEPTS', 'FCD',
                               'GENTROR_SW', 'FCD',
                               'INTEARNDEP', 'FCD',
                               'IR_FWD', 'FCD',
                               'IR_SWAP', 'FCD',
                               'IRO', 'FCD',
                               'IRS', 'FCD',
                               'OI_SWAP', 'FCD',
                               'OTH_SWP', 'FCD',
                               'PM_SWP', 'FCD',
                               'RESERVE', 'FCD',
                               'SPRDLOCK', 'FCD',
                               'SWAPTION', 'FCD',
                               'SWOPT', 'FCD',
                               'TROR_SWAP', 'FCD',
                               'TRS', 'FCD',
                               'BOND', 'FCT',
                               'CLN', 'FCT',
                               'EQUITY', 'FCT',
                               'ETF', 'FCT',
                               'LOAN', 'FCT',
                               'LS2', 'FCT',
                               'TRAD_LOAN', 'FCT',
                               'Other'),
                       'DBTrader',
                       'FCT',
                       'ICI',
                       'FCT',
                       'LS2',
                       'FCT',
                       'TRINITY',
                       'FCT',
                       'Other'
                    )
                       file_name
             FROM   fbs_owner.t_ids_gcds_trade, cob_dt
            WHERE   desired_cob_dt = cob_dt.cob)
SELECT   file_name, new_cnt cnt
  FROM   (  SELECT   desired_cob_dt,
                     file_name,
                     COUNT ( * ) old_cnt,
                     SUM (DECODE (mtm_amt, 0, 0, 1)) new_cnt
              FROM   tmp_table
          GROUP BY   desired_cob_dt, file_name
          ORDER BY   desired_cob_dt, file_name)
UNION ALL
SELECT   'EUS' file_name, COUNT ( * ) cnt
  FROM   fbs_owner.eus_data, cob_dt
 WHERE       balance_type IN ('Trading Assets', 'Trading liabilities')
         AND closing_balance_tx_ccy <> 0
         AND cob_date = cob_dt.cob
UNION ALL
SELECT   'ESS' file_name, SUM (cnt) cnt
  FROM   (SELECT   COUNT ( * ) cnt
            FROM   fbs_owner.stg_ess_data_lon, cob_dt
           WHERE   balance <> 0 AND cob_date = cob_dt.cob
          UNION ALL
          SELECT   COUNT ( * ) cnt
            FROM   fbs_owner.stg_ess_data_ny, cob_dt
           WHERE   balance <> 0 AND cob_date = cob_dt.cob)
_____[ EUS_data ]_____________________________________________
1. Launch the script below (PROD,pbrun ssh -l fbs_owner fracsfclap1.de.db.com, /fbs/prd/scripts/EUS_DATA by user FBS_OWNER):
./get_and_load.sh COB_date
_____[ EUS_data_example ]_____________________________________________
nohup ./get_and_load.sh 18102011 &
_____[ Send_letter ]_____________________________________________
TO:	 Christopher Marlow/db/dbcom@DBEMEA, Samantha-X Coles/db/dbcom@DBEMEA, Michael Skilton/db/dbcom@DBEMEA, 
Garry Scott/ext/dbcom@DBEMEA, Ashu Behl/db/dbcom@DBAPAC, Gaurav-x Goyal/db/, kanchan.amarnani@db.com, 
Ravi-X Surana/db/dbcom@DBAPAC, Neha-s Bhatnagar/db/dbcom@DBAPAC, harsh.agrawal@db.com
CC:	 elena.gvozdkova@db.com, Matthew Aitken/db/dbcom@Exchange1, flashrwa-sl3@list.db.com, vadim.pidonenko@db.com, vineet.bhatt@db.com, anup-a.patel@db.com
Subject:	 The Flash Balance Sheet data for COB $COB_DATE have been successfully loaded
Body:	 Hi All, 
the Flash Balance Sheet data for COB $COB_DATE have been successfully loaded. 
_____[ Send_letter_example ]_____________________________________________
the Flash Balance Sheet data for COB 14-June-2011 have been successfully loaded. 
_____[ Data ]________________________________________________
ALC 2       Step_2_1_1
GL1	 9      Step_2_1_1 
IMG	 5      Step_2_1_1 
LNT	 3      Step_2_1_1
MIS	 400  Step_2_1_1
RMS 20    Step_2_1_1
EV+ 1        Step_2_1_1
MIS 700     Step_2_1_2
FX_Rates                    960             Step_2_3_1
DBInstruments           ANY             Step_2_4_1
CALICO_NYK            17000          Step_2_5_1
CALICO_OTHERS    17000          Step_2_5_2
DARE                          6000            Step_2_5_3
FCR                             750              Step_2_5_4
Everest+                      5500            Step_2_5_5
Update_ESS               ANY             Step_2_6_1
FCL_COPY_proc       ANY             Step_2_7_1
Sum_FCL_COPY       ANY             Step_2_7_2
EUS_data                            ANY             Step_2_8
Send_letter                        ANY             Step_2_9
_____[ Data_and_Check_and_Date_sql ]________________________________________________
Step_2_1_1 Check_Chunks                 1 10am  rwa_owner
Step_2_1_2 Check_Chunks_MIS        1 10am  rwa_owner
Step_2_2_1 Check_Chunks                 1 3pm    rwa_owner
Step_2_2_2 Check_Chunks_MIS        1 3pm    rwa_owner
Step_2_3_1 Check_FX_Rates             1 2pm    fbs_exec
Step_2_4_1 DBInstruments_Check     1 2pm    qv_fbs_ro
Step_2_5_1 CALICO_NYK_sql            2 7am    rwa_owner
Step_2_5_2 CALICO_OTHERS_sql    2 7am    rwa_owner
Step_2_5_3 DARE_sql                          2 7am    rwa_owner
Step_2_5_4 FCR_sql                             2 7am    rwa_owner
Step_2_5_5 Everest+_sql                      2 7am    rwa_owner
Step_2_6_1 Update_ESS                      2 7am    any
Step_2_7_1 FCL_COPY_proc               2 10am  any
Step_2_7_2 Sum_FCL_COPY               2 1pm    fbs_exec
Step_2_8      EUS_data                           2  10am  any
Step_2_9      Send_letter                         2  1pm    any
_____[ Data_SQL_and_parameters ]________________________________________________
Check_Chunks cob_date
Check_Chunks source_system_cd
DBInstruments_Check NO
_____[ Prerequestions ]________________________________________________
Step_2_9 Step_2_7
Step_2_9 Step_2_8
Step_2_7 Step_2_1  
Step_2_7 Step_2_2  
Step_2_7 Step_2_5
Step_2_7 Step_2_6
