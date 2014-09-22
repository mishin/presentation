{composition-setup}
cloak.toggle.type = wiki
cloak.toggle.open = (+)
cloak.toggle.close = (-)
cloak.toggle.zone = true
{composition-setup}

{toc:outline=false\|style=none\|maxLevel=3\|printable=true}{*}Contributors*
{contributors-summary}
{toggle-cloak:id=Query110}Oracle Code Generate{cloak:id=Query110|visible=false}{code} 


sqlsh -d DBI:Oracle:FRFCLOP1.DE.DB.COM -u RWA_OWNER -p newd0cument
 sqlsh -d DBI:Oracle:FRFCLOP1.DE.DB.COM -u mishnik -p ynAlIFeIsO4S
set multiline on;
ALTER SESSION SET CURRENT_SCHEMA =RWA_OWNER;
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';
SQL> EXEC KILL_SESSION(1022);
with a as
 (select rownum name, 1 chunk_id
    from dual
   start with rownum = 1
  connect by rownum <= 3
  union
  select rownum name, 2 chunk_id
    from dual
   start with rownum = 1
  connect by rownum <= 3)
SELECT chunk_id, ltrim(SYS_CONNECT_BY_PATH(name, ','), ',') name
  FROM (select chunk_id,
               name,
               rank() over(partition by chunk_id order by rownum) num
          from a)
 where connect_by_isleaf = 1
 START WITH num = 1
CONNECT BY PRIOR num + 1 = num
       and prior chunk_id = chunk_id;



select chunk_id, wm_concat(name) name
  from (SELECT distinct t3.chunk_id, t2.display_name || ' ' || t2.email name
          FROM rwa_fcat_owner.t_fcat_report t1,
               upm_owner.t_ups_user t2,
               ((select a.chunk_id, a.chunk_revision_sk
                   from rwa_owner.t_chunk_revisions a,
                        (select MAX(chunk_revision_sk) KEEP(DENSE_RANK LAST ORDER BY chunk_revision_sk) chunk_revision_sk
                           from (select a.chunk_id, a.chunk_revision_sk
                                   from rwa_owner.t_chunk_revisions a
                                  where chunk_id in
                                        ('KIWIAG_SWAPS_SO',
                                         'EM_EXOTIC_SO',
                                         'EM_GRF_SO',
                                         'MMD_LONDON_AUD_SO',
                                         'LAG_SWAPS_SO',
                                         'MAIN_NY_GPF_LDNBOOKED_SO',
                                         'DB_LN_EMLA_SO',
                                         'MUM_HYBRID_CREDIT_SO',
                                         'SIN_SYND_SO',
                                         'EM_SWAPS_FFT_SO',
                                         'EM_FUND_SO',
                                         'MMD_LONDON_USD_SO',
                                         'OTAG_SO',
                                         'FUNDAG_SO',
                                         'EMZAR_SWAPS_SO',
                                         'INFLT_INDEX_SO',
                                         'NEW_YORK_CRESWAP_SO',
                                         'TCHAG_SWAPS_SO',
                                         'INDEX_GLOBAL_SO',
                                         'HYBRID_SO',
                                         'YAG_BASIS_SO')
                                    and cob_date = '29-Jul-2011'
                                    and data_quality_cd = 'O')
                          group by chunk_id) b
                  where a.chunk_revision_sk = b.chunk_revision_sk)) t3,
               rwa_fcat_owner.t_fcat_report_source t4
         WHERE t1.cob_date = '29-Jul-2011'
           and t1.fcat_report_type = 'Query Wizard Report'
           AND t1.fcat_report_sk = t4.fcat_report_sk
           and t3.chunk_revision_sk = t4.chunk_revision_sk
           and t1.create_user = t2.user_id
         order by chunk_id)
 group by chunk_id;

with tmp as
 (SELECT distinct t3.chunk_id, t2.display_name || ' ' || t2.email name
    FROM rwa_fcat_owner.t_fcat_report t1,
         upm_owner.t_ups_user t2,
         ((select a.chunk_id, a.chunk_revision_sk
             from rwa_owner.t_chunk_revisions a,
                  (select MAX(chunk_revision_sk) KEEP(DENSE_RANK LAST ORDER BY chunk_revision_sk) chunk_revision_sk
                     from (select a.chunk_id, a.chunk_revision_sk
                             from rwa_owner.t_chunk_revisions a
                            where chunk_id in ('KIWIAG_SWAPS_SO',
                                               'EM_EXOTIC_SO',
                                               'EM_GRF_SO',
                                               'MMD_LONDON_AUD_SO',
                                               'LAG_SWAPS_SO',
                                               'MAIN_NY_GPF_LDNBOOKED_SO',
                                               'DB_LN_EMLA_SO',
                                               'MUM_HYBRID_CREDIT_SO',
                                               'SIN_SYND_SO',
                                               'EM_SWAPS_FFT_SO',
                                               'EM_FUND_SO',
                                               'MMD_LONDON_USD_SO',
                                               'OTAG_SO',
                                               'FUNDAG_SO',
                                               'EMZAR_SWAPS_SO',
                                               'INFLT_INDEX_SO',
                                               'NEW_YORK_CRESWAP_SO',
                                               'TCHAG_SWAPS_SO',
                                               'INDEX_GLOBAL_SO',
                                               'HYBRID_SO',
                                               'YAG_BASIS_SO')
                              and cob_date = '29-Jul-2011'
                              and data_quality_cd = 'O')
                    group by chunk_id) b
            where a.chunk_revision_sk = b.chunk_revision_sk)) t3,
         rwa_fcat_owner.t_fcat_report_source t4
   WHERE t1.cob_date = '29-Jul-2011'
     and t1.fcat_report_type = 'Query Wizard Report'
     AND t1.fcat_report_sk = t4.fcat_report_sk
     and t3.chunk_revision_sk = t4.chunk_revision_sk
     and t1.create_user = t2.user_id
   order by chunk_id)
SELECT chunk_id, ltrim(SYS_CONNECT_BY_PATH(name, ','), ',') name
  FROM (select chunk_id,
               name,
               rank() over(partition by chunk_id order by rownum) num
          from tmp)
 where connect_by_isleaf = 1
 START WITH num = 1
CONNECT BY PRIOR num + 1 = num
       and prior chunk_id = chunk_id;


   
with tmp as
 (SELECT distinct t3.chunk_id, t2.display_name || ' ' || t2.email name
    FROM rwa_fcat_owner.t_fcat_report t1,
         upm_owner.t_ups_user t2,
         ((select a.chunk_id, a.chunk_revision_sk
             from rwa_owner.t_chunk_revisions a,
                  (select MAX(chunk_revision_sk) KEEP(DENSE_RANK LAST ORDER BY chunk_revision_sk) chunk_revision_sk
                     from (select a.chunk_id, a.chunk_revision_sk
                             from rwa_owner.t_chunk_revisions a
                            where chunk_id in ('KIWIAG_SWAPS_SO',
                                               'EM_EXOTIC_SO',
                                               'EM_GRF_SO',
                                               'MMD_LONDON_AUD_SO',
                                               'LAG_SWAPS_SO',
                                               'MAIN_NY_GPF_LDNBOOKED_SO',
                                               'DB_LN_EMLA_SO',
                                               'MUM_HYBRID_CREDIT_SO',
                                               'SIN_SYND_SO',
                                               'EM_SWAPS_FFT_SO',
                                               'EM_FUND_SO',
                                               'MMD_LONDON_USD_SO',
                                               'OTAG_SO',
                                               'FUNDAG_SO',
                                               'EMZAR_SWAPS_SO',
                                               'INFLT_INDEX_SO',
                                               'NEW_YORK_CRESWAP_SO',
                                               'TCHAG_SWAPS_SO',
                                               'INDEX_GLOBAL_SO',
                                               'HYBRID_SO',
                                               'YAG_BASIS_SO')
                              and cob_date = '29-Jul-2011'
                              and data_quality_cd = 'O')
                    group by chunk_id) b
            where a.chunk_revision_sk = b.chunk_revision_sk)) t3,
         rwa_fcat_owner.t_fcat_report_source t4
   WHERE t1.cob_date = '29-Jul-2011'
     and t1.fcat_report_type = 'Query Wizard Report'
     AND t1.fcat_report_sk = t4.fcat_report_sk
     and t3.chunk_revision_sk = t4.chunk_revision_sk
     and t1.create_user = t2.user_id
   order by chunk_id)
select chunk_id, ltrim (max (sys_connect_by_path (name, ',')), ',') name
from (select chunk_id, name, rank () over (partition by chunk_id order by name) num from tmp)
start with num = 1
connect by prior num + 1 = num and prior chunk_id = chunk_id
group by chunk_id
order by chunk_id

WITH DATA AS (
SELECT table_name, column_name, row_number() over(PARTITION BY table_name ORDER BY column_id) rn,
       COUNT(*) over(PARTITION BY table_name) cnt
  FROM all_tab_columns where all_tab_columns.TABLE_NAME = 'ALL_TAB_PARTITIONS'
)
SELECT table_name, ltrim(sys_connect_by_path(column_name, ', '), ', ') scbp
  FROM data
 WHERE rn = cnt
 START WITH rn = 1
CONNECT BY PRIOR table_name = table_name
       AND PRIOR rn = rn - 1
 ORDER BY table_name

{code}{cloak}
{toggle-cloak:id=Query0}&nbsp;*Search trade_id,version,type* [FRWA-14011|http://jira.gto.intranet.db.com:2020/jira/browse/FRWA-14011]
{cloak:id=Query0|visible=false}{code} 
create table z_mi_rms_14757
as
select /*+ index(t T_ODS_TE_TRADE_IDX04) index(l T_ODS_TE_LEG_PK) */
 t.TRANSACTION_ID,
 t.TRADE_TYPE,
 t.TRANSACTION_ID_SRC,
 t.FCL_TRADE_SK,
 t.TRADE_STATUS,
 t.CANCEL_DATE,
 t.CHUNK_REVISION_SK,
 l.FCL_TRADE_SK       FCL_TRADE_SK_LEG,
 l.PAY_REC,
 p.FCL_TRADE_SK       FCL_TRADE_SK_PA,
 p.CURRENCY,
 p.FLOW_TYPE,
 p.PAY_DATE,
 p.VALUE
  from t_ods_te_trade t, t_ods_te_leg l, t_ids_te_payment p
 where t.chunk_revision_sk in
       (select r.chunk_revision_sk
          from t_chunk_revisions r
         where r.cob_date = '30-jun-2011'
           and r.source_system_cd = 'RMS')
   and t.fcl_sk = l.fcl_sk
   and l.fcl_sk = p.fcl_sk
   and l.fcl_leg_sk = p.fcl_leg_sk;


create table z_mi_smt_14757
as
select /*+ index(t T_ODS_TE_TRADE_IDX04) index(l T_ODS_TE_LEG_PK) */
 t.TRANSACTION_ID,
 t.TRADE_TYPE,
 t.TRANSACTION_ID_SRC,
 t.FCL_TRADE_SK,
 t.TRADE_STATUS,
 t.CANCEL_DATE,
 t.CHUNK_REVISION_SK,
 l.FCL_TRADE_SK       FCL_TRADE_SK_LEG,
 l.PAY_REC,
 p.FCL_TRADE_SK       FCL_TRADE_SK_PA,
 p.CURRENCY,
 p.FLOW_TYPE,
 p.PAY_DATE,
 p.VALUE
  from t_ods_te_trade t, t_ods_te_leg l, t_ids_te_payment p
 where t.chunk_revision_sk in
       (select r.chunk_revision_sk
          from t_chunk_revisions r, t_chunk_revisions_source e
         where r.cob_date = '30-jun-2011'
           and r.source_system_cd = 'MIS'
           and e.source_system_cd = 'SMT'
           and r.chunk_revision_sk = e.chunk_revision_sk)
   and t.fcl_sk = l.fcl_sk
   and l.fcl_sk = p.fcl_sk
   and l.fcl_leg_sk = p.fcl_leg_sk;

select * from rwa_owner.t_ids_gcds_trade where cob_dt = '15-Jul-2011'
and trn_src_cd = 'OpenLink'

select * from rwa_owner.t_chunk_revisions where chunk_revision_sk = 7736447

select * from rwa_owner.t_chunk_revisions_source where chunk_revision_sk = 7736447

WITH a AS
 (select a.fcl_trade_sk, a.fcl_sk, a.trn_cd, a.MTRX_CALC_CNTRL_EPE
    from T_IDS_GCDS_TRADE a,
         (select MAX(fcl_sk) KEEP(DENSE_RANK LAST ORDER BY pcp_gcds_revision) fcl_sk
            from (select a.fcl_sk, a.pcp_gcds_revision, a.trn_cd
                    from T_IDS_GCDS_TRADE a, Z_MI_14011 b
                   where a.cob_dt = to_date('31052011', 'ddmmyyyy')
                     and a.trn_src_cd = 'SUMMIT'
                     and a.trn_cd = b.TRANSACTION_ID)
           group by trn_cd) b
   where a.fcl_sk = b.fcl_sk)
SELECT s.fcl_create_timestamp,s.fcl_trade_sk,
       s.transaction_id || ',' || s.trade_version_key || ',' ||
       s.trade_type val
  FROM rwa_owner.t_smt_trade s, a
 WHERE a.fcl_trade_sk = s.fcl_trade_sk

select * from t_smt_trade where fcl_trade_sk='105511305397'
select * from t_smt_leg where fcl_trade_sk='105511305397'
 {code}{cloak}
{toggle-cloak:id=Query1}&nbsp;*Select chunks if they processed* [FRWA-13499|http://jira.gto.intranet.db.com:2020/jira/browse/FRWA-13499]
{cloak:id=Query1|visible=false}{code} 
dump SELECT rownum RN,t.trn_src_cd src_cd,
       t.MTM_CCY_CD_IFRS CCY_CD_IFRS,
       t.MTM_CCY_CD CCY_CD,       
       t.GRC_PROD_TYPE_ID      PT,
       t.fcl_sk,
       t.chunk_revision_sk     CH_SK,
       t.cob_dt,
       t.trn_cd,
       t.trn_link_cd,
       t.fcl_matrix_trade_type ST_TYPE,
       t.MTM_AMT      
  FROM rwa_owner.t_ids_gcds_trade t,z_mi_14306_2 t2
 WHERE t.fcl_sk =t2.fcl_sk into histogram.txt delimited by |;

for i in *.txt.dealId.txt;do echo "'$i',"; done
for i in FCL_CRM*20110429.txt;do echo $i;cut -d'|' -f 6  $i > $i.dealId.txt; done

for i in FCL_CRMAlice*20110429.txt;do echo $i;cut -d'|' -f 6,7,10,12,30 $i > $i.crm; done
for i in FCL_IFRSAlice*20110429.txt;do echo $i;cut -d'|' -f 1,5,6,20,43 $i > $i.ifrs; done


for file in `find . -name '*.gz'` 
do
    ((gunzip -c $file | grep 'C694981M') && (echo ">>>>>>>>> $file"))
done


select a.fcl_sk,a.trn_cd,a.MTRX_CALC_CNTRL_EPE from T_IDS_GCDS_TRADE a,
(select MAX(fcl_sk) KEEP(DENSE_RANK LAST ORDER BY pcp_gcds_revision) fcl_sk
  from (select a.fcl_sk, a.pcp_gcds_revision, a.trn_cd
          from T_IDS_GCDS_TRADE a, Z_MI_14011 b
         where a.cob_dt = to_date('31052011', 'ddmmyyyy')
           and a.trn_src_cd = 'SUMMIT'
           and a.trn_cd = b.TRANSACTION_ID)
 group by trn_cd)b
 where a.fcl_sk=b.fcl_sk

create table z_mi_14306_2
as
select MAX(fcl_sk) KEEP(DENSE_RANK LAST ORDER BY pcp_gcds_revision) fcl_sk
  from (select a.fcl_sk, a.pcp_gcds_revision, a.trn_cd
          from T_IDS_GCDS_TRADE a
         where a.cob_dt in (to_date('30062011', 'ddmmyyyy'))
           and a.trn_cd in ('139985155',
                            '172325659',
                            '298235968',
                            '298235970'))
 group by trn_cd;

SELECT   chunk_revision_sk,
         chunk_status_cd ch_st,
         cob_date,
         chunk_id,
         data_quality_cd dq,
         update_datetime
  FROM   rwa_owner.T_CHUNK_REVISIONS t
 WHERE   chunk_revision_sk IN
               (SELECT   chunk_sk
                  FROM   t_mis_tmp_stubmsg
                 WHERE   signoff_group IN ('INDEX_SO')
                         AND stub_cob_date = DATE '2011-06-01');

SELECT   chunk_sk,
         stub_cob_date,
         fcl_create_timestamp,
         signoff_group,
         location,
         signoff_status
  FROM   t_mis_tmp_stubmsg t
 WHERE   signoff_group IN ('INDEX_SO') AND stub_cob_date = DATE '2011-06-01';
{code}{cloak}
{toggle-cloak:id=Query2}&nbsp;*Generate Jql (perl)*
{cloak:id=Query2|visible=false}{code}#my $p='2011-05-31'; User access
my $created='2011-06-02';
my $p="GRC_PROD_TYPE_ID";#"'Stranded Chunks'";#"'access'";
#my $u='mishnik';
#('kapandr','rudyser','apbogdanov','kbuyanova','mishnik','bplatonov')
#my $u='kapandr';
# for my $user('kapandr','rudyser','apbogdanov','kbuyanova','mishnik','bplatonov'){
# my $user="(((summary ~ $p OR description ~ $p OR comment ~ $p) and assignee = $u) or
# ( (summary ~ $p OR description ~ $p OR comment ~ $p)  and  comment ~$u ))";
# }
#
# print <<EOF;
# (created >= $created AND created <= $created) and
# (((summary ~ $p OR description ~ $p OR comment ~ $p) and assignee = $u) or
# ( (summary ~ $p OR description ~ $p OR comment ~ $p)  and  comment ~$u ))
  # ORDER BY updated DESC
# EOF
 #

 print <<EOF;
(created >= $created AND created <= $created) and
((summary ~ $p OR description ~ $p OR comment ~ $p) or
 (summary ~ $p OR description ~ $p OR comment ~ $p) )
  ORDER BY updated DESC
EOF
 {code}{cloak}
{toggle-cloak:id=Query3}&nbsp;*Find chunks by system and cob_date* [FRWA-13548|http://jira.gto.intranet.db.com:2020/jira/browse/FRWA-13548]
{cloak:id=Query3|visible=false}{code}SELECT   GRC_PROD_TYPE_ID PT,
         t.fcl_sk,
         chunk_revision_sk CH_SK,
         t.cob_dt,
         trn_cd,
         trn_link_cd,
         trn_src_cd,
         fcl_matrix_trade_type ST_TYPE
  FROM   rwa_owner.t_ids_gcds_trade t
 WHERE   cob_dt IN ('31-may-2011')
         AND chunk_revision_sk IN
                  (SELECT   t.chunk_revision_sk
                     FROM   rwa_owner.t_chunk_revisions t
                    WHERE       cob_date IN ('31-may-2011')
                            AND source_system_cd = 'PBR'
                            AND chunk_revision = 2)
         AND trn_cd IN
                  ('KGMSF:AFR.AX:PCKISGAU:', 'VELOCITY:AFR.AX:PCTVEFAU:');

{code}{cloak}
{toggle-cloak:id=Query4}&nbsp;*Split file, Mail file*
{cloak:id=Query4|visible=false}{code}$perl /rwa/data/team/MISHNIK/get_trade/sp_all.pl --file infa.log --outdir out  --size 10000000
$uuencode  fnd.zip fnd.zip | mailx -s FRWA-13530 jira.requests@db.com
{code}{cloak}
{toggle-cloak:id=Query5}&nbsp;*Load data to Oracle*
{cloak:id=Query5|visible=false}{code}$cat Z_12093_MISHNIK.bat
sqlldr rwa_owner/newd0cument@FRFCLOP1.DE.DB.COM control=Z_12093_MISHNIK.ctl  direct=true

[05:56:58]rwaprd01@fracsfclap1 /rwa/data/team/MISHNIK/FRWA-13854
$cat Z_12093_MISHNIK.ctl
LOAD DATA
INFILE 'Z_mishnik_12755.txt'
APPEND
INTO TABLE Z_MISHNIK_12755
TRAILING NULLCOLS
 ( SYSTEM_ID)

sqlplus command

SET NEWPAGE NONE;
SET SPACE 0;
SET LINESIZE 32767;
SET PAGESIZE 0;
SET ECHO OFF;
SET FEEDBACK OFF;
SET VERIFY OFF;
SET HEADING OFF;
SET MARKUP HTML OFF;
SET TERMOUT OFF;
SET TRIMOUT ON;
SET TRIMSPOOL ON;
SET TAB OFF;
SET LONG 4000;
SET LONGCHUNKSIZE 4000;
SET WRAP OFF;
ALTER SESSION SET NLS_DATE_FORMAT='dd/MM/yyyy';
WHENEVER SQLERROR EXIT -1;
WHENEVER OSERROR EXIT -2;
{code}{cloak}
{toggle-cloak:id=Query6}&nbsp;*Right CTL File in Oracle*
{cloak:id=Query6|visible=false}{code}[04:27:41]rwaprd01@fracsfclap1 /rwa/data/team/MISHNIK/get_trade
$cat load_data.sh
sqlldr rwa_owner/newd0cument@FRFCLOP1.DE.DB.COM control=$1 direct=true
[04:27:45]rwaprd01@fracsfclap1 /rwa/data/team/MISHNIK/get_trade

$cat mm.ctl
LOAD DATA
INFILE 'load_id.csv'
BADFILE './load_id.BAD'
DISCARDFILE './load_id.DSC'
APPEND INTO TABLE RWA_OWNER.Z_MI_13854_2
Fields terminated by "," --Optionally enclosed by '"'
TRAILING NULLCOLS
(
  NEW_VALUE
)

[04:26:44]rwaprd01@fracsfclap1 /rwa/data/team/MISHNIK/FRWA-13854
$

$cat crm.ctl
LOAD DATA
INFILE 'crm.txt'
BADFILE './crm.BAD'
DISCARDFILE './crm.DSC'
APPEND INTO TABLE RWA_OWNER.z_mish_13854_crm
Fields terminated by "|" --Optionally enclosed by '"'
TRAILING NULLCOLS
(
  dealId,
productType,
 reportDate DATE "DD/MM/YYYY" ,
 valueDate DATE "DD/MM/YYYY" ,
descr
)

{code}
{cloak}
{toggle-cloak:id=Query7}&nbsp;*Import data from Oracle*

{cloak:id=Query7|visible=false}cd /rwa/data/team/MISHNIK/FRWA-14203
set colsep ,;
set feed off;
set trimspool on;
set linesize 32767;
set pagesize 0;
set heading off;
set echo off;
set termout off;
spool Z_14203.csv
select trade_id\|\|','\|\|audit_version
from rwa_owner.t_utp_rec_expected
where cob_dt = '30-Jun-2011'
and dm_owner_table = 'SWAPTION'
and audit_entitystate in ('VER', 'DONE');
/
SPOOL OFF
exit;
cat /rwa/data/team/MISHNIK/get_trade/exec_sql.sh
nohup sqlplus \-s RWA_OWNER/newd0cument@FRFCLOP1.DE.DB.COM @$1 &

exec_sql.sh 13530.sql

{cloak}