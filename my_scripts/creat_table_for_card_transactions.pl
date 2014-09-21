#!/usr/bin/env perl
######################################
# $URL: http://mishin.narod.ru $
# $Date: Mon Oct 14 18:52:21 2011 $
# $Author: Nikolay Mishin $
# $Revision: 0.02 $
# $Source: creat_table_for_card_transactions.pl $
# $Description: create table for initial insert card_transactions. $
##############################################################################

use strict;
use warnings;

use Modern::Perl;
use DateTime;
use File::Slurp;

our $VERSION = '0.02';
our $EMPTY   = q{};

# use DDP;
manip_date();

# for my $manip (qw/ add /) {
# say "--${manip}ing...";
# for my $day (1) {
# manip_date( $manip, 4, $day, 19 );
# }
# }

sub manip_date {

    # my ( $month, $day ) = ( 4, 1 );
    use Date::Calc qw(Today Add_Delta_YMD Days_in_Month);

    my @tables = ();
    my @view   = ();
    my @insert = ();

    # p $dt;
    use Readonly;
    Readonly my $NUMBER_OF_MONTHS => 18;

    #my $retries = $NUMBER_OF_RETRIES;

    for my $m_delta ( 0 .. $NUMBER_OF_MONTHS ) {
        my ( $year, $month, undef ) = Add_Delta_YMD( Today(), 0, -$m_delta, 0 );
        my $start = sprintf '%02d.%02d.%04d', 1, $month, $year;
        my $name_start = sprintf '%04d_%02d', $year,
          $month;    #$dt->strftime('%Y_%m');
        my $end = sprintf '%02d.%02d.%04d', Days_in_Month( $year, $month ),
          $month,
          $year;

        my $view_name = "DWH_Z#IP_TR_INIT_${name_start}_V";
        my $out       = <<"END";
CREATE OR REPLACE VIEW $view_name
AS
   SELECT t.id,
          t.C_SRV_COM_STATUS,
          t.c_TRANSACTION_NUM,
          t.c_TRANS_DTIME,
          NVL (t.C_PROCEEDED, TO_DATE ('01/01/1970', 'dd/mm/yyyy'))
             AS C_PROCEEDED,
          t.c_SRV_CARD_REF,
          t.c_SRV_IP_TRANS_TYP,
          t.c_SRV_INTERNAL_REF,
          t.c_TRANS_AMOUNT,
          m.id AS TRANSACTION_CUR,
          t.c_TRG_AMOUNT,
          CASE
             WHEN (   (SELECT MAX (f.c_val)
                         FROM ibs.z#CARD_REE_FIELDS f,
                              ibs.z#CARD_REE_FIELD_F cf
                        WHERE     cr.c_FIELDS = f.collection_id
                              AND f.c_format = cf.id
                              AND cf.c_code IN 'MBRR_XML_TRAN_LF_3') = '02'
                   OR (SELECT MAX (f.c_val)
                         FROM ibs.z#CARD_REE_FIELDS f,
                              ibs.z#CARD_REE_FIELD_F cf
                        WHERE     cr.c_FIELDS = f.collection_id
                              AND f.c_format = cf.id
                              AND cf.c_code IN 'MBRR_XML_TRAN_LF_4') = '02')
             THEN
                1
             ELSE
                0
          END
             AS flg_ors,
          t.c_SRV_PAY_SYS_REF AS pay_sys_card,
          t.c_SRV_TERMINAL_REF,
               t.c_SRV_FEE_PRC_AMT,                                  -- комиссия ПЦ
          t.c_SRV_FEE_PRC_CUR,                           -- валюта комиссии ПЦ
          t.c_SRV_FEE_BANK_AMT,                              -- комиссия банка
          t.c_SRV_FEE_BANK_CUR,                       --  сумма комиссии банка
          t.c_SRV_FEE_ISS_AMT,                      -- комиссия банка Эмитента
          t.c_SRV_STTL_PRC_CUR                -- сумма комиссии банка Эмитента
     FROM ibs.z#IP_TRANSACTION t
          LEFT JOIN ibs.z#CARD_REE_RECORDS cr
             ON (cr.c_REQUEST = t.id)
          JOIN ibs.z#FT_MONEY m
             ON (t.c_TRANS_CUR = m.c_cur_short)
    WHERE     1 = 1
          AND t.C_PROCEEDED IS NOT NULL
          AND t.C_PROCEEDED BETWEEN TO_DATE ('$start', 'dd.mm.yyyy')
                                AND TO_DATE ('$end', 'dd.mm.yyyy');  
END

        write_file( "${view_name}.sql", $out );
        push @view, "${view_name}.sql";

        my $table_name = "STG_ACC_CTRNS_S02_${name_start}";
        my $table      = <<"END";
drop table $table_name;		
create table $table_name
   (	"CTRNS_SRC_ID" VARCHAR2(30), 
	"CTRNS_CTRNS_NUM" VARCHAR2(200), 
	"CTRNS_AS_OF_DATE" DATE, 
	"CTRNS_AS_OF_TIME" DATE, 
	"CTRNS_AMOUNT" NUMBER, 
	"CTRNS_ACNT_CRNC_AMOUNT" NUMBER, 
	"CTRNS_CRNC_SRC_ID" VARCHAR2(30), 
	"CRTNS_CARD_SRC_ID" VARCHAR2(30), 
	"CRTNS_CARD_TRNS_TYPE_SRC_CD" VARCHAR2(30), 
	"CRTNS_CRTNS_MVMNT_TYPE_SRC_CD" VARCHAR2(30), 
	"CRTNS_ACQR_PYMN_SYSTEM_SRC_CD" VARCHAR2(30), 
	"CRTNS_ISS_PYMNT_SYSTEM_SRC_CD" VARCHAR2(30), 
	"CTRNS_ORS_FLG" VARCHAR2(200), 
	"CTRNS\$AUDIT_ID" NUMBER DEFAULT -1, 
	"CTRNS\$HASH" NUMBER DEFAULT -1, 
	"CTRNS\$SOURCE" VARCHAR2(4) DEFAULT '*', 
	"CTRNS\$PROVIDER" VARCHAR2(80) DEFAULT '*', 
	"CTRNS\$SOURCE_PK" VARCHAR2(2000), 
	"CTRNS_TRNS_SRC_ID" VARCHAR2(30), 
	"CTRNS_AS_OF_PROCEEDED_DATE" DATE, 
	"CTRNS_TRMNL_SRC_ID" VARCHAR2(30), 
	"CTRNS_FEE_PROCESSING_AMOUNT" NUMBER, 
	"CTRNS_FEE_PROCESS_CRNC_SRC_ID" VARCHAR2(30), 
	"CTRNS_FEE_BANK_AMOUNT" NUMBER, 
	"CTRNS_FEE_BANK_CRNC_SRC_ID" VARCHAR2(30), 
	"CTRNS_FEE_ISSUER_AMOUNT" NUMBER, 
	"CTRNS_FEE_ISSUER_CRNC_SRC_ID" VARCHAR2(30)
   ); 

END

        write_file( "${table_name}.sql", $table );

        push @tables, "${table_name}.sql";

        my $insert = <<"END";
INSERT
INTO ${table_name}
  (
    CTRNS_SRC_ID,
    CTRNS_CTRNS_NUM,
    CTRNS_AS_OF_DATE,
    CTRNS_AS_OF_TIME,
    CTRNS_AMOUNT,
    CTRNS_ACNT_CRNC_AMOUNT,
    CTRNS_CRNC_SRC_ID,
    CRTNS_CARD_SRC_ID,
    CRTNS_CARD_TRNS_TYPE_SRC_CD,
    crtns_iss_pymnt_system_src_cd,
    CTRNS_ORS_FLG,
    CTRNS\$AUDIT_ID,
    CTRNS\$SOURCE,
    CTRNS\$SOURCE_PK,
    CTRNS_AS_OF_PROCEEDED_DATE,
    CTRNS_TRMNL_SRC_ID,
    CTRNS_FEE_PROCESSING_AMOUNT,
    CTRNS_FEE_PROCESS_CRNC_SRC_ID,
    CTRNS_FEE_BANK_AMOUNT,
    CTRNS_FEE_BANK_CRNC_SRC_ID,
    CTRNS_FEE_ISSUER_AMOUNT,
    CTRNS_FEE_ISSUER_CRNC_SRC_ID
  )
with S02_Z#IP_TRANSACTION_INIT_V as
(select "ID","C_SRV_COM_STATUS","C_TRANSACTION_NUM","C_TRANS_DTIME","C_PROCEEDED","C_SRV_CARD_REF","C_SRV_IP_TRANS_TYP","C_SRV_INTERNAL_REF","C_TRANS_AMOUNT","TRANSACTION_CUR","C_TRG_AMOUNT","FLG_ORS","PAY_SYS_CARD","C_SRV_TERMINAL_REF","C_SRV_FEE_PRC_AMT","C_SRV_FEE_PRC_CUR","C_SRV_FEE_BANK_AMT","C_SRV_FEE_BANK_CUR","C_SRV_FEE_ISS_AMT","C_SRV_STTL_PRC_CUR" from  ${view_name}\@rbo)
SELECT CAST(ID AS VARCHAR2(30)),
  C_TRANSACTION_NUM,
  CAST(TRUNC(C_TRANS_DTIME, 'DD') AS DATE),
  CAST(C_TRANS_DTIME AS              DATE),
  C_TRANS_AMOUNT,
  C_TRG_AMOUNT,
  CAST(TRANSACTION_CUR AS    VARCHAR2(30)),
  CAST(C_SRV_CARD_REF AS     VARCHAR2(30)),
  CAST(C_SRV_IP_TRANS_TYP AS VARCHAR2(30)),
  CAST(PAY_SYS_CARD AS       VARCHAR2(30)),
  CAST(FLG_ORS AS            VARCHAR2(200)),
  CAST(ROUND(CAST('11275' AS NUMBER)) AS FLOAT),
  '2',
  CAST(ID AS                 VARCHAR2(2000)),
  CAST(C_PROCEEDED AS        DATE),
  CAST(C_SRV_TERMINAL_REF AS VARCHAR2(30)),
  C_SRV_FEE_PRC_AMT,
  CAST(C_SRV_FEE_PRC_CUR AS VARCHAR2(30)),
  C_SRV_FEE_BANK_AMT,
  CAST(C_SRV_FEE_BANK_CUR AS VARCHAR2(30)),
  C_SRV_FEE_ISS_AMT,
  CAST(C_SRV_STTL_PRC_CUR AS VARCHAR2(30))
FROM S02_Z#IP_TRANSACTION_INIT_V;
commit;
END

        #nohup sqlplus  dwh_stage/dwh_stage@tstehd @exec_proc.sql &

        my $ins_name = "insert_STG_ACC_CTRNS_S02_${name_start}.sql";
        write_file( $ins_name, $insert );
        push @insert, $ins_name;
    }

    write_file( 'main_create_tables.sql', gen_sql_main( \@tables ) );
    write_file( 'main_create_view.sql',   gen_sql_main( \@view ) );
    write_file( 'main_create_insert.sql', gen_sql_main_nohup( \@insert ) );
    return 1;
}

sub gen_sql_main {
    my ($in_data) = @_;
    my $cmd_file;
    for my $t ( @{$in_data} ) {
        $cmd_file = $cmd_file . "\@$t\n";
    }
    return $cmd_file;
}

sub gen_sql_main_nohup {
    my ($in_data) = @_;
    my $cmd_file;
    for my $t ( @{$in_data} ) {
        $cmd_file =
          $cmd_file . "nohup sqlplus  dwh_stage/dwh_stage\@tstehd \@$t &\n";
    }
    return $cmd_file;
}

__END__
