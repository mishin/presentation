ORCHESTRATE_CODE_FULL_RX START=1

#################################################################
#### STAGE: DWH_REESTRS_DS
## Operator
copy
## General options
[ident('DWH_REESTRS_DS')]
## Inputs
0< [ds] '[&"psProjectsPath.ProjectFilePath"]DWH_REESTRS_AUDIT_R.ds'
## Outputs
0> [modify (
  SCAB:not_nullable string[4]=SCAB;
  SCAN:not_nullable string[6]=SCAN;
  SCAS:not_nullable string[3]=SCAS;
  PTDTN:not_nullable date=PTDTN;
  KB_DATE:nullable date=KB_DATE;
  SUP_DATE:nullable date=SUP_DATE;
  REASON_CODE:nullable string[max=20]=REASON_CODE;
  AGENT_SRC_STM_ID:nullable int32=AGENT_SRC_STM_ID;
  AGENT_SRC_STM_ID_AR:nullable int32=AGENT_SRC_STM_ID_AR;
  AGENT_SRC_STM_ID_PV:nullable int32=AGENT_SRC_STM_ID_PV;
  CHAR1_AGENT_CD:nullable string[max=1]=CHAR1_AGENT_CD;
  FIL:nullable int32=FIL;
keep
  SCAB,SCAN,SCAS,PTDTN,
  KB_DATE,SUP_DATE,REASON_CODE,AGENT_SRC_STM_ID,
  AGENT_SRC_STM_ID_AR,AGENT_SRC_STM_ID_PV,CHAR1_AGENT_CD,FIL;
)] 'DWH_REESTRS_DS:L10.v'
;

#################################################################
#### STAGE: DWH_CCH_DS
## Operator
copy
## General options
[ident('DWH_CCH_DS')]
## Inputs
0< [ds] '[&"psProjectsPath.ProjectFilePath"]DWH_CCH_AUDIT_R.ds'
## Outputs
0> [modify (
  SCAB:not_nullable string[4]=SCAB;
  SCAN:not_nullable string[6]=SCAN;
  SCAS:not_nullable string[3]=SCAS;
  PTDTN:not_nullable date=PTDTN;
  CONTACT_ID:nullable string[20]=CONTACT_ID;
  EXEC_DATE:nullable date=EXEC_DATE;
  SCRIPT_ID:nullable int32=SCRIPT_ID;
  SRC_STM_ID_CCH:nullable int32=SRC_STM_ID_CCH;
  AGENT_SRC_STM_ID_SCRIPT:nullable int32=AGENT_SRC_STM_ID_SCRIPT;
keep
  SCAB,SCAN,SCAS,PTDTN,
  CONTACT_ID,EXEC_DATE,SCRIPT_ID,SRC_STM_ID_CCH,
  AGENT_SRC_STM_ID_SCRIPT;
)] 'DWH_CCH_DS:L20.v'
;

#################################################################
#### STAGE: MART_UREP_WRH_DS
## Operator
copy
## General options
[ident('MART_UREP_WRH_DS')]
## Inputs
0< [ds] '[&"psProjectsPath.ProjectFilePath"]MART_UREP_WRH_AUDIT_R.ds'
## Outputs
0> [modify (
  SCAB:not_nullable string[4]=SCAB;
  SCAN:not_nullable string[6]=SCAN;
  SCAS:not_nullable string[3]=SCAS;
  IDAT:not_nullable date=IDAT;
  PTDTN:not_nullable date=PTDTN;
  SRC_STM_ID:not_nullable int32=SRC_STM_ID;
  PTDTPP:nullable date=PTDTPP;
  PTDTPO:nullable date=PTDTPO;
  PTUSR6_D:nullable date=PTUSR6_D;
  PTDATRE:nullable date=PTDATRE;
keep
  SCAB,SCAN,SCAS,IDAT,
  PTDTN,SRC_STM_ID,PTDTPP,PTDTPO,
  PTUSR6_D,PTDATRE;
)] 'MART_UREP_WRH_DS:L100.v'
;

#################################################################
#### STAGE: T100
## Operator
transform
## Operator options
-flag run
-name 'V0S218_audi_05_ChangeCaptureApplyUPP_T100'

## General options
[ident('T100'); jobmon_ident('T100')]
## Inputs
0< [] 'MART_UREP_WRH_DS:L100.v'
## Outputs
0> [] 'T100:L101.v'
;

#################################################################
#### STAGE: T10
## Operator
transform
## Operator options
-flag run
-name 'V0S222_audi_05_ChangeCaptureApplyUPP_T10'

## General options
[ident('T10'); jobmon_ident('T10')]
## Inputs
0< [] 'DWH_REESTRS_DS:L10.v'
## Outputs
0> [] 'T10:L11.v'
;

#################################################################
#### STAGE: T20
## Operator
transform
## Operator options
-flag run
-name 'V0S226_audi_05_ChangeCaptureApplyUPP_T20'

## General options
[ident('T20'); jobmon_ident('T20')]
## Inputs
0< [] 'DWH_CCH_DS:L20.v'
## Outputs
0> [] 'T20:L21.v'
;

#################################################################
#### STAGE: LKUP101
## Operator
lookup
## Operator options
-table
-key SCAB
-key SCAN
-key SCAS
-key PTDTN
-ifNotFound continue

## General options
[ident('LKUP101'); jobmon_ident('LKUP101')]
## Inputs
0< [] 'T100:L101.v'
1< [] 'T10:L11.v'
## Outputs
0> [modify (
keep
  SCAB,SCAN,SCAS,IDAT,
  PTDTN,SRC_STM_ID,PTDTPP,PTDTPO,
  PTUSR6_D,PTDATRE,KB_DATE,SUP_DATE,
  REASON_CODE,AGENT_SRC_STM_ID,AGENT_SRC_STM_ID_AR,AGENT_SRC_STM_ID_PV,
  CHAR1_AGENT_CD,FIL;)] 'LKUP101:L102.v'
;

#################################################################
#### STAGE: LKUP102
## Operator
lookup
## Operator options
-table
-key SCAB
-key SCAN
-key SCAS
-key PTDTN
-key AGENT_SRC_STM_ID_AR
-ifNotFound continue

## General options
[ident('LKUP102'); jobmon_ident('LKUP102')]
## Inputs
0< [] 'LKUP101:L102.v'
1< [view (
  AGENT_SRC_STM_ID_AR=SRC_STM_ID_CCH;
)] 'T20:L21.v'
## Outputs
0> [modify (
keep
  SCAB,SCAN,SCAS,IDAT,
  PTDTN,SRC_STM_ID,PTDTPP,PTDTPO,
  PTUSR6_D,PTDATRE,KB_DATE,SUP_DATE,
  REASON_CODE,AGENT_SRC_STM_ID,AGENT_SRC_STM_ID_AR,AGENT_SRC_STM_ID_PV,
  CHAR1_AGENT_CD,FIL,EXEC_DATE,SCRIPT_ID,
  AGENT_SRC_STM_ID_SCRIPT,CONTACT_ID;)] 'LKUP102:L103.v'
;

#################################################################
#### STAGE: T107
## Operator
transform
## Operator options
-flag run
-name 'V0S236_audi_05_ChangeCaptureApplyUPP_T107'

## General options
[ident('T107'); jobmon_ident('T107')]
## Inputs
0< [] 'LKUP105:L106.v'
## Outputs
0> [] 'T107:L107.v'
;

#################################################################
#### STAGE: LKUP103
## Operator
lookup
## Operator options
-table
-key SCAB
-key SCAN
-key SCAS
-key PTDTN
-ifNotFound continue

## General options
[ident('LKUP103'); jobmon_ident('LKUP103')]
## Inputs
0< [] 'LKUP102:L103.v'
1< [] 'T30:L31.v'
## Outputs
0> [modify (
keep
  SCAB,SCAN,SCAS,IDAT,
  PTDTN,SRC_STM_ID,PTDTPP,PTDTPO,
  PTUSR6_D,PTDATRE,KB_DATE,SUP_DATE,
  REASON_CODE,AGENT_SRC_STM_ID,AGENT_SRC_STM_ID_AR,AGENT_SRC_STM_ID_PV,
  CHAR1_AGENT_CD,FIL,EXEC_DATE,SCRIPT_ID,
  AGENT_SRC_STM_ID_SCRIPT,FLG_CCT,CONTACT_ID;)] 'LKUP103:L104.v'
;

#################################################################
#### STAGE: LKUP104
## Operator
lookup
## Operator options
-table
-key SCAB
-key SCAN
-key SCAS
-key IDAT
-key PTDTN
-ifNotFound continue

## General options
[ident('LKUP104'); jobmon_ident('LKUP104')]
## Inputs
0< [] 'LKUP103:L104.v'
1< [] 'T40:L41.v'
## Outputs
0> [modify (
keep
  SCAB,SCAN,SCAS,IDAT,
  PTDTN,SRC_STM_ID,PTDTPP,PTDTPO,
  PTUSR6_D,PTDATRE,KB_DATE,SUP_DATE,
  REASON_CODE,AGENT_SRC_STM_ID,AGENT_SRC_STM_ID_AR,AGENT_SRC_STM_ID_PV,
  CHAR1_AGENT_CD,FIL,EXEC_DATE,SCRIPT_ID,
  AGENT_SRC_STM_ID_SCRIPT,FLG_CCT,FLG_UREP_ORA,CONTACT_ID;)] 'LKUP104:L105.v'
;

#################################################################
#### STAGE: CLI_CONT_TASK_DS
## Operator
copy
## General options
[ident('CLI_CONT_TASK_DS')]
## Inputs
0< [ds] '[&"psProjectsPath.ProjectFilePath"]ORA_CLI_CONT_TASK_AUDIT_R.ds'
## Outputs
0> [modify (
  CR_SRC_STM_ID:not_nullable int32=CR_SRC_STM_ID;
  SCAB:not_nullable string[4]=SCAB;
  SCAN:not_nullable string[6]=SCAN;
  SCAS:not_nullable string[3]=SCAS;
  PTDTN:not_nullable date=PTDTN;
  FLG_CCT:nullable int16=FLG_CCT;
keep
  CR_SRC_STM_ID,SCAB,SCAN,SCAS,
  PTDTN,FLG_CCT;
)] 'CLI_CONT_TASK_DS:L30.v'
;

#################################################################
#### STAGE: T30
## Operator
transform
## Operator options
-flag run
-name 'V0S247_audi_05_ChangeCaptureApplyUPP_T30'

## General options
[ident('T30'); jobmon_ident('T30')]
## Inputs
0< [] 'CLI_CONT_TASK_DS:L30.v'
## Outputs
0> [] 'T30:L31.v'
;

#################################################################
#### STAGE: UREP_ORA_DS
## Operator
copy
## General options
[ident('UREP_ORA_DS')]
## Inputs
0< [ds] '[&"psProjectsPath.ProjectFilePath"]ORA_UREP_AUDIT_R.ds'
## Outputs
0> [modify (
  SRC_STM_ID:not_nullable int32=SRC_STM_ID;
  SCAB:not_nullable string[4]=SCAB;
  SCAN:not_nullable string[6]=SCAN;
  SCAS:not_nullable string[3]=SCAS;
  PTDTN:not_nullable date=PTDTN;
  IDAT:not_nullable date=IDAT;
  FLG_UREP_ORA:nullable int16=FLG_UREP_ORA;
keep
  SRC_STM_ID,SCAB,SCAN,SCAS,
  PTDTN,IDAT,FLG_UREP_ORA;
)] 'UREP_ORA_DS:L40.v'
;

#################################################################
#### STAGE: T40
## Operator
transform
## Operator options
-flag run
-name 'V0S250_audi_05_ChangeCaptureApplyUPP_T40'

## General options
[ident('T40'); jobmon_ident('T40')]
## Inputs
0< [] 'UREP_ORA_DS:L40.v'
## Outputs
0> [] 'T40:L41.v'
;

#################################################################
#### STAGE: T108
## Operator
transform
## Operator options
-flag run
-name 'V0S252_audi_05_ChangeCaptureApplyUPP_T108'
-argvalue 'IDAT=[&"IDAT"]'

## General options
[ident('T108'); jobmon_ident('T108')]
## Inputs
0< [] 'T107:L107.v'
## Outputs
0> [] 'T108:L108.v'
1> [] 'T108:L_DBG01.v'
;

#################################################################
#### STAGE: DBG_05_DS
## Operator
copy
## General options
[ident('DBG_05_DS')]
## Inputs
0< [] 'T108:L_DBG01.v'
## Outputs
0>| [ds] '[&"psProjectsPath.ProjectFilePath"]DBG05_AUDIT_R.ds'
;

#################################################################
#### STAGE: DWH_STOP_LIST_DS
## Operator
copy
## General options
[ident('DWH_STOP_LIST_DS')]
## Inputs
0< [ds] '[&"psProjectsPath.ProjectFilePath"]DWH_STOP_LIST_AUDIT_R.ds'
## Outputs
0> [modify (
  SCAB:not_nullable string[4]=SCAB;
  SCAN:not_nullable string[6]=SCAN;
  SCAS:not_nullable string[3]=SCAS;
  PTDTN:not_nullable date=PTDTN;
  FLG_STOP_LIST:nullable int32=FLG_STOP_LIST;
keep
  SCAB,SCAN,SCAS,PTDTN,
  FLG_STOP_LIST;
)] 'DWH_STOP_LIST_DS:L50.v'
;

#################################################################
#### STAGE: T50
## Operator
transform
## Operator options
-flag run
-name 'V0S262_audi_05_ChangeCaptureApplyUPP_T50'

## General options
[ident('T50'); jobmon_ident('T50')]
## Inputs
0< [] 'DWH_STOP_LIST_DS:L50.v'
## Outputs
0> [] 'T50:L51.v'
;

#################################################################
#### STAGE: LKUP105
## Operator
lookup
## Operator options
-table
-key SCAB
-key SCAN
-key SCAS
-key PTDTN
-ifNotFound continue

## General options
[ident('LKUP105'); jobmon_ident('LKUP105')]
## Inputs
0< [] 'LKUP104:L105.v'
1< [] 'T50:L51.v'
## Outputs
0> [modify (
keep
  SCAB,SCAN,SCAS,IDAT,
  PTDTN,SRC_STM_ID,PTDTPP,PTDTPO,
  PTUSR6_D,PTDATRE,KB_DATE,SUP_DATE,
  REASON_CODE,AGENT_SRC_STM_ID,AGENT_SRC_STM_ID_AR,AGENT_SRC_STM_ID_PV,
  CHAR1_AGENT_CD,FIL,EXEC_DATE,SCRIPT_ID,
  AGENT_SRC_STM_ID_SCRIPT,FLG_CCT,FLG_UREP_ORA,FLG_STOP_LIST,
  CONTACT_ID;)] 'LKUP105:L106.v'
;

#################################################################
#### STAGE: LJ108
## Operator
leftouterjoin
## Operator options
-key 'SCAB'
-key 'SCAN'
-key 'SCAS'
-key 'IDAT'
-key 'PTDTN'

## General options
[ident('LJ108'); jobmon_ident('LJ108')]
## Inputs
0< [] 'T108:L108.v'
1< [] 'T90:L91.v'
## Outputs
0> [modify (
keep
  SRC_STM_ID,SCAB,SCAN,SCAS,
  IDAT,PTDTN,MORGAN,EXPRESS,
  SVS,INBGPARAVO,ARGUMENT,AKCEPT,
  IUCB,ETAP,INKOR,BIUS,
  AROSD,SP,EKK,AKCEPT_NT,
  FEMIDA,AKSECUIRITY,UDN,RECOVERY,
  SKA,AVD,PRISTAV,SEQUOIA,
  PKB,AOS,RFB,FASP,
  USB,FIL,DAYS_OD,DAYS_PR,
  DAYS_OD_REAG,DAYS_PR_REAG,US,OB,
  PSKP,STOP_LIST,UREP_ORA,CCT_ORA,
  MSB,REASON_CODE,JOIN_DUMMY,SRC_STM_ID_DST,
  UREP_ORA_DST,CCT_ORA_DST,CCH_DST,AVD_DST,
  FIL_DST,PSKP_DST,OB_DST,US_DST,
  DAYS_OD_DST,DAYS_PR_DST,DAYS_OD_REAG_DST,DAYS_PR_REAG_DST,
  STOP_LIST_DST,MSB_DST,PRISTAV_DST,SEQUOIA_DST,
  PKB_DST,AOS_DST,MORGAN_DST,EXPRESS_DST,
  SVS_DST,INBGPARAVO_DST,ARGUMENT_DST,AKCEPT_DST,
  IUCB_DST,ETAP_DST,INKOR_DST,BIUS_DST,
  AROSD_DST,SP_DST,EKK_DST,AKCEPT_NT_DST,
  FEMIDA_DST,AKSECUIRITY_DST,UDN_DST,RECOVERY_DST,
  SKA_DST,RFB_DST,FASP_DST,USB_DST;
)] 'LJ108:L109.v'
;

#################################################################
#### STAGE: T199
## Operator
transform
## Operator options
-flag run
-name 'V0S276_audi_05_ChangeCaptureApplyUPP_T199'

## General options
[ident('T199'); jobmon_ident('T199')]
## Inputs
0< [] 'LJ108:L109.v'
## Outputs
0> [] 'T199:INS.v'
1> [] 'T199:UPD.v'
;

#################################################################
#### STAGE: INS
## Operator
pxbridge
## Operator options
-Orientation link
-XMLProperties '<?xml version=\\'1.0\\' encoding=\\'UTF-16\\'?><Properties version=\\'1.1\\'><Common><Context type=\\'int\\'>2</Context><Variant type=\\'string\\'>9.1</Variant><DescriptorVersion type=\\'string\\'>1.0</DescriptorVersion><PartitionType type=\\'int\\'>-1</PartitionType><RCP type=\\'int\\'>0</RCP></Common><Connection><Database modified=\\'1\\' type=\\'string\\'><![CDATA[[&"psConnectionsMART.martDatabase"]]]></Database><Username modified=\\'1\\' type=\\'string\\'><![CDATA[[&"psConnectionsMART.martUserName"]]]></Username><Password modified=\\'1\\' type=\\'string\\'><![CDATA[[&"psConnectionsMART.martPassword"]]]></Password><Conductor collapsed=\\'1\\' type=\\'bool\\'><![CDATA[0]]></Conductor><UseDirectConnections type=\\'bool\\'><![CDATA[0]]></UseDirectConnections><KeepConductorConnectionAlive type=\\'bool\\'><![CDATA[1]]></KeepConductorConnectionAlive></Connection><Usage><WriteMode type=\\'int\\'><![CDATA[0]]></WriteMode><GenerateSQL modified=\\'1\\' type=\\'bool\\'><![CDATA[1]]></GenerateSQL><TableName modified=\\'1\\' type=\\'string\\'><![CDATA[[&"psConnectionsMART.martScheme"].UREP_POINT_PLACE]]></TableName><EnableQuotedIDs type=\\'bool\\'><![CDATA[0]]></EnableQuotedIDs><XMLColumnAsLOB type=\\'bool\\'><![CDATA[0]]></XMLColumnAsLOB><PrefixForExpressionColumns type=\\'string\\'><![CDATA[EXPR]]></PrefixForExpressionColumns><SQL></SQL><TableAction collapsed=\\'1\\' type=\\'int\\'><![CDATA[0]]></TableAction><Transaction><RecordCount type=\\'int\\'><![CDATA[2000]]></RecordCount></Transaction><Session><IsolationLevel modified=\\'1\\' type=\\'int\\'><![CDATA[0]]></IsolationLevel><AutocommitMode type=\\'int\\'><![CDATA[0]]></AutocommitMode><ArraySize type=\\'int\\'><![CDATA[2000]]></ArraySize><SchemaReconciliation><FailOnSizeMismatch type=\\'bool\\'><![CDATA[1]]></FailOnSizeMismatch><FailOnTypeMismatch type=\\'bool\\'><![CDATA[1]]></FailOnTypeMismatch><FailOnCodePageMismatch type=\\'bool\\'><![CDATA[0]]></FailOnCodePageMismatch><DropUnmatchedFields type=\\'bool\\'><![CDATA[1]]></DropUnmatchedFields></SchemaReconciliation><FailOnRowErrorPX type=\\'bool\\'><![CDATA[1]]></FailOnRowErrorPX><InsertBuffering type=\\'int\\'><![CDATA[0]]><AtomicArrays type=\\'int\\'><![CDATA[0]]></AtomicArrays></InsertBuffering></Session><Logging><LogColumnValues collapsed=\\'1\\' type=\\'bool\\'><![CDATA[0]]></LogColumnValues></Logging><BeforeAfter collapsed=\\'1\\' type=\\'bool\\'><![CDATA[0]]></BeforeAfter><ReOptimization type=\\'int\\'><![CDATA[2]]></ReOptimization><LockWaitMode collapsed=\\'1\\' type=\\'int\\'><![CDATA[1]]></LockWaitMode></Usage></Properties >'
-connector '{
   variant='9.1', 
   library=ccdb2, 
   version=1.0, 
   variantlist='9.1', 
   versionlist='1.0', 
   name=DB2Connector
}'
-target 0 '{
      DSIsKey={SCAB=1, SCAN=1, SCAS=1, IDAT=1, PTDTN=1}, 
      DSDisplayWidth={SRC_STM_ID=11, SCAB=4, SCAN=6, SCAS=3, IDAT=10, PTDTN=10, UREP_ORA=11, CCT_ORA=11, CCH=11, AVD=11, FIL=11, PSKP=11, OB=11, US=11, DAYS_OD=11, DAYS_PR=11, DAYS_OD_REAG=11, DAYS_PR_REAG=11, STOP_LIST=11, MSB=11, PRISTAV=11, SEQUOIA=11, PKB=11, AOS=11, MORGAN=11, EXPRESS=11, SVS=11, INBGPARAVO=11, ARGUMENT=11, AKCEPT=11, IUCB=11, ETAP=11, INKOR=11, BIUS=11, AROSD=11, SP=11, EKK=11, AKCEPT_NT=11, FEMIDA=11, AKSECUIRITY=11, UDN=11, RECOVERY=11, SKA=11, RFB=11, FASP=11, USB=11}, 
      DSSQLType={SRC_STM_ID=4, SCAB=1, SCAN=1, SCAS=1, IDAT=9, PTDTN=9, UREP_ORA=4, CCT_ORA=4, CCH=4, AVD=4, FIL=4, PSKP=4, OB=4, US=4, DAYS_OD=4, DAYS_PR=4, DAYS_OD_REAG=4, DAYS_PR_REAG=4, STOP_LIST=4, MSB=4, PRISTAV=4, SEQUOIA=4, PKB=4, AOS=4, MORGAN=4, EXPRESS=4, SVS=4, INBGPARAVO=4, ARGUMENT=4, AKCEPT=4, IUCB=4, ETAP=4, INKOR=4, BIUS=4, AROSD=4, SP=4, EKK=4, AKCEPT_NT=4, FEMIDA=4, AKSECUIRITY=4, UDN=4, RECOVERY=4, SKA=4, RFB=4, FASP=4, USB=4, PPN_DT=9, PPN_TM=10}, 
      DSDerivation={SRC_STM_ID=\\'L109\\.SRC_STM_ID\\', SCAB=\\'L109\\.SCAB\\', SCAN=\\'L109\\.SCAN\\', SCAS=\\'L109\\.SCAS\\', IDAT=\\'L109\\.IDAT\\', PTDTN=\\'L109\\.PTDTN\\', UREP_ORA=\\'L109\\.UREP_ORA\\', CCT_ORA=\\'L109\\.CCT_ORA\\', CCH=\\'0\\', AVD=\\'L109\\.AVD\\', FIL=\\'L109\\.FIL\\', PSKP=\\'L109\\.PSKP\\', OB=\\'L109\\.OB\\', US=\\'L109\\.US\\', DAYS_OD=\\'L109\\.DAYS_OD\\', DAYS_PR=\\'L109\\.DAYS_PR\\', DAYS_OD_REAG=\\'L109\\.DAYS_OD_REAG\\', DAYS_PR_REAG=\\'L109\\.DAYS_PR_REAG\\', STOP_LIST=\\'L109\\.STOP_LIST\\', MSB=\\'L109\\.MSB\\', PRISTAV=\\'L109\\.PRISTAV\\', SEQUOIA=\\'L109\\.SEQUOIA\\', PKB=\\'L109\\.PKB\\', AOS=\\'L109\\.AOS\\', MORGAN=\\'L109\\.MORGAN\\', EXPRESS=\\'L109\\.EXPRESS\\', SVS=\\'L109\\.SVS\\', INBGPARAVO=\\'L109\\.INBGPARAVO\\', ARGUMENT=\\'L109\\.ARGUMENT\\', AKCEPT=\\'L109\\.AKCEPT\\', IUCB=\\'L109\\.IUCB\\', ETAP=\\'L109\\.ETAP\\', INKOR=\\'L109\\.INKOR\\', BIUS=\\'L109\\.BIUS\\', AROSD=\\'L109\\.AROSD\\', SP=\\'L109\\.SP\\', EKK=\\'L109\\.EKK\\', AKCEPT_NT=\\'L109\\.AKCEPT_NT\\', FEMIDA=\\'L109\\.FEMIDA\\', AKSECUIRITY=\\'L109\\.AKSECUIRITY\\', UDN=\\'L109\\.UDN\\', RECOVERY=\\'L109\\.RECOVERY\\', SKA=\\'L109\\.SKA\\', RFB=\\'L109\\.RFB\\', FASP=\\'L109\\.FASP\\', USB=\\'L109\\.USB\\', PPN_DT=\\'CurrentDate()\\', PPN_TM=\\'CurrentTime()\\'}, 
      DSSQLPrecision={SRC_STM_ID=10, SCAB=4, SCAN=6, SCAS=3, IDAT=10, PTDTN=10, UREP_ORA=10, CCT_ORA=10, CCH=10, AVD=10, FIL=10, PSKP=10, OB=10, US=10, DAYS_OD=10, DAYS_PR=10, DAYS_OD_REAG=10, DAYS_PR_REAG=10, STOP_LIST=10, MSB=10, PRISTAV=10, SEQUOIA=10, PKB=10, AOS=10, MORGAN=10, EXPRESS=10, SVS=10, INBGPARAVO=10, ARGUMENT=10, AKCEPT=10, IUCB=10, ETAP=10, INKOR=10, BIUS=10, AROSD=10, SP=10, EKK=10, AKCEPT_NT=10, FEMIDA=10, AKSECUIRITY=10, UDN=10, RECOVERY=10, SKA=10, RFB=10, FASP=10, USB=10, PPN_DT=10, PPN_TM=8}, 
      DSSchema=\\'record
         (
           SRC_STM_ID\\:int32\\;
           SCAB\\:string\\[4\\]\\;
           SCAN\\:string\\[6\\]\\;
           SCAS\\:string\\[3\\]\\;
           IDAT\\:date\\;
           PTDTN\\:date\\;
           UREP_ORA\\:nullable int32\\;
           CCT_ORA\\:nullable int32\\;
           CCH\\:nullable int32\\;
           AVD\\:nullable int32\\;
           FIL\\:nullable int32\\;
           PSKP\\:nullable int32\\;
           OB\\:nullable int32\\;
           US\\:nullable int32\\;
           DAYS_OD\\:nullable int32\\;
           DAYS_PR\\:nullable int32\\;
           DAYS_OD_REAG\\:nullable int32\\;
           DAYS_PR_REAG\\:nullable int32\\;
           STOP_LIST\\:nullable int32\\;
           MSB\\:nullable int32\\;
           PRISTAV\\:nullable int32\\;
           SEQUOIA\\:nullable int32\\;
           PKB\\:nullable int32\\;
           AOS\\:nullable int32\\;
           MORGAN\\:nullable int32\\;
           EXPRESS\\:nullable int32\\;
           SVS\\:nullable int32\\;
           INBGPARAVO\\:nullable int32\\;
           ARGUMENT\\:nullable int32\\;
           AKCEPT\\:nullable int32\\;
           IUCB\\:nullable int32\\;
           ETAP\\:nullable int32\\;
           INKOR\\:nullable int32\\;
           BIUS\\:nullable int32\\;
           AROSD\\:nullable int32\\;
           SP\\:nullable int32\\;
           EKK\\:nullable int32\\;
           AKCEPT_NT\\:nullable int32\\;
           FEMIDA\\:nullable int32\\;
           AKSECUIRITY\\:nullable int32\\;
           UDN\\:nullable int32\\;
           RECOVERY\\:nullable int32\\;
           SKA\\:nullable int32\\;
           RFB\\:nullable int32\\;
           FASP\\:nullable int32\\;
           USB\\:nullable int32\\;
           PPN_DT\\:nullable date\\;
           PPN_TM\\:nullable time\\;
         )\\'
}'
   

## General options
[ident('INS'); jobmon_ident('INS')]
## Inputs
0< [] 'T199:INS.v'
;

#################################################################
#### STAGE: UPD
## Operator
pxbridge
## Operator options
-Orientation link
-XMLProperties '<?xml version=\\'1.0\\' encoding=\\'UTF-16\\'?><Properties version=\\'1.1\\'><Common><Context type=\\'int\\'>2</Context><Variant type=\\'string\\'>9.1</Variant><DescriptorVersion type=\\'string\\'>1.0</DescriptorVersion><PartitionType type=\\'int\\'>-1</PartitionType><RCP type=\\'int\\'>0</RCP></Common><Connection><Database modified=\\'1\\' type=\\'string\\'><![CDATA[[&"psConnectionsMART.martDatabase"]]]></Database><Username modified=\\'1\\' type=\\'string\\'><![CDATA[[&"psConnectionsMART.martUserName"]]]></Username><Password modified=\\'1\\' type=\\'string\\'><![CDATA[[&"psConnectionsMART.martPassword"]]]></Password><Conductor collapsed=\\'1\\' type=\\'bool\\'><![CDATA[0]]></Conductor><UseDirectConnections type=\\'bool\\'><![CDATA[0]]></UseDirectConnections><KeepConductorConnectionAlive type=\\'bool\\'><![CDATA[1]]></KeepConductorConnectionAlive></Connection><Usage><WriteMode modified=\\'1\\' type=\\'int\\'><![CDATA[1]]></WriteMode><GenerateSQL modified=\\'1\\' type=\\'bool\\'><![CDATA[1]]></GenerateSQL><TableName modified=\\'1\\' type=\\'string\\'><![CDATA[[&"psConnectionsMART.martScheme"].UREP_POINT_PLACE]]></TableName><EnableQuotedIDs type=\\'bool\\'><![CDATA[0]]></EnableQuotedIDs><XMLColumnAsLOB type=\\'bool\\'><![CDATA[0]]></XMLColumnAsLOB><PrefixForExpressionColumns type=\\'string\\'><![CDATA[EXPR]]></PrefixForExpressionColumns><SQL></SQL><Transaction><RecordCount type=\\'int\\'><![CDATA[2000]]></RecordCount></Transaction><Session><IsolationLevel modified=\\'1\\' type=\\'int\\'><![CDATA[0]]></IsolationLevel><AutocommitMode type=\\'int\\'><![CDATA[0]]></AutocommitMode><ArraySize type=\\'int\\'><![CDATA[2000]]></ArraySize><SchemaReconciliation><FailOnSizeMismatch type=\\'bool\\'><![CDATA[1]]></FailOnSizeMismatch><FailOnTypeMismatch type=\\'bool\\'><![CDATA[1]]></FailOnTypeMismatch><FailOnCodePageMismatch type=\\'bool\\'><![CDATA[0]]></FailOnCodePageMismatch><DropUnmatchedFields type=\\'bool\\'><![CDATA[1]]></DropUnmatchedFields></SchemaReconciliation><FailOnRowErrorPX type=\\'bool\\'><![CDATA[1]]></FailOnRowErrorPX></Session><Logging><LogColumnValues collapsed=\\'1\\' type=\\'bool\\'><![CDATA[0]]></LogColumnValues></Logging><BeforeAfter collapsed=\\'1\\' type=\\'bool\\'><![CDATA[0]]></BeforeAfter><ReOptimization type=\\'int\\'><![CDATA[2]]></ReOptimization><LockWaitMode collapsed=\\'1\\' type=\\'int\\'><![CDATA[1]]></LockWaitMode></Usage></Properties >'
-connector '{
   variant='9.1', 
   library=ccdb2, 
   version=1.0, 
   variantlist='9.1', 
   versionlist='1.0', 
   name=DB2Connector
}'
-target 0 '{
      DSIsKey={SCAB=1, SCAN=1, SCAS=1, IDAT=1, PTDTN=1}, 
      DSDisplayWidth={SCAB=4, SCAN=6, SCAS=3, IDAT=10, PTDTN=10, SRC_STM_ID=11, UREP_ORA=11, CCT_ORA=11, AVD=11, FIL=11, PSKP=11, OB=11, US=11, DAYS_OD=11, DAYS_PR=11, DAYS_OD_REAG=11, DAYS_PR_REAG=11, STOP_LIST=11, MSB=11, PRISTAV=11, SEQUOIA=11, PKB=11, AOS=11, MORGAN=11, EXPRESS=11, SVS=11, INBGPARAVO=11, ARGUMENT=11, AKCEPT=11, IUCB=11, ETAP=11, INKOR=11, BIUS=11, AROSD=11, SP=11, EKK=11, AKCEPT_NT=11, FEMIDA=11, AKSECUIRITY=11, UDN=11, RECOVERY=11, SKA=11, RFB=11, FASP=11, USB=11}, 
      DSSQLType={SCAB=1, SCAN=1, SCAS=1, IDAT=9, PTDTN=9, SRC_STM_ID=4, UREP_ORA=4, CCT_ORA=4, AVD=4, FIL=4, PSKP=4, OB=4, US=4, DAYS_OD=4, DAYS_PR=4, DAYS_OD_REAG=4, DAYS_PR_REAG=4, STOP_LIST=4, MSB=4, PRISTAV=4, SEQUOIA=4, PKB=4, AOS=4, MORGAN=4, EXPRESS=4, SVS=4, INBGPARAVO=4, ARGUMENT=4, AKCEPT=4, IUCB=4, ETAP=4, INKOR=4, BIUS=4, AROSD=4, SP=4, EKK=4, AKCEPT_NT=4, FEMIDA=4, AKSECUIRITY=4, UDN=4, RECOVERY=4, SKA=4, RFB=4, FASP=4, USB=4, PPN_DT=9, PPN_TM=10}, 
      DSDerivation={SCAB=\\'L109\\.SCAB\\', SCAN=\\'L109\\.SCAN\\', SCAS=\\'L109\\.SCAS\\', IDAT=\\'L109\\.IDAT\\', PTDTN=\\'L109\\.PTDTN\\', SRC_STM_ID=\\'L109\\.SRC_STM_ID\\', UREP_ORA=\\'L109\\.UREP_ORA\\', CCT_ORA=\\'L109\\.CCT_ORA\\', AVD=\\'L109\\.AVD\\', FIL=\\'L109\\.FIL\\', PSKP=\\'L109\\.PSKP\\', OB=\\'L109\\.OB\\', US=\\'L109\\.US\\', DAYS_OD=\\'L109\\.DAYS_OD\\', DAYS_PR=\\'L109\\.DAYS_PR\\', DAYS_OD_REAG=\\'L109\\.DAYS_OD_REAG\\', DAYS_PR_REAG=\\'L109\\.DAYS_PR_REAG\\', STOP_LIST=\\'L109\\.STOP_LIST\\', MSB=\\'L109\\.MSB\\', PRISTAV=\\'L109\\.PRISTAV\\', SEQUOIA=\\'L109\\.SEQUOIA\\', PKB=\\'L109\\.PKB\\', AOS=\\'L109\\.AOS\\', MORGAN=\\'L109\\.MORGAN\\', EXPRESS=\\'L109\\.EXPRESS\\', SVS=\\'L109\\.SVS\\', INBGPARAVO=\\'L109\\.INBGPARAVO\\', ARGUMENT=\\'L109\\.ARGUMENT\\', AKCEPT=\\'L109\\.AKCEPT\\', IUCB=\\'L109\\.IUCB\\', ETAP=\\'L109\\.ETAP\\', INKOR=\\'L109\\.INKOR\\', BIUS=\\'L109\\.BIUS\\', AROSD=\\'L109\\.AROSD\\', SP=\\'L109\\.SP\\', EKK=\\'L109\\.EKK\\', AKCEPT_NT=\\'L109\\.AKCEPT_NT\\', FEMIDA=\\'L109\\.FEMIDA\\', AKSECUIRITY=\\'L109\\.AKSECUIRITY\\', UDN=\\'L109\\.UDN\\', RECOVERY=\\'L109\\.RECOVERY\\', SKA=\\'L109\\.SKA\\', RFB=\\'L109\\.RFB\\', FASP=\\'L109\\.FASP\\', USB=\\'L109\\.USB\\', PPN_DT=\\'CurrentDate()\\', PPN_TM=\\'CurrentTime()\\'}, 
      DSSQLPrecision={SCAB=4, SCAN=6, SCAS=3, IDAT=10, PTDTN=10, SRC_STM_ID=10, UREP_ORA=10, CCT_ORA=10, AVD=10, FIL=10, PSKP=10, OB=10, US=10, DAYS_OD=10, DAYS_PR=10, DAYS_OD_REAG=10, DAYS_PR_REAG=10, STOP_LIST=10, MSB=10, PRISTAV=10, SEQUOIA=10, PKB=10, AOS=10, MORGAN=10, EXPRESS=10, SVS=10, INBGPARAVO=10, ARGUMENT=10, AKCEPT=10, IUCB=10, ETAP=10, INKOR=10, BIUS=10, AROSD=10, SP=10, EKK=10, AKCEPT_NT=10, FEMIDA=10, AKSECUIRITY=10, UDN=10, RECOVERY=10, SKA=10, RFB=10, FASP=10, USB=10, PPN_DT=10, PPN_TM=8}, 
      DSSchema=\\'record
         (
           SCAB\\:string\\[4\\]\\;
           SCAN\\:string\\[6\\]\\;
           SCAS\\:string\\[3\\]\\;
           IDAT\\:date\\;
           PTDTN\\:date\\;
           SRC_STM_ID\\:int32\\;
           UREP_ORA\\:nullable int32\\;
           CCT_ORA\\:nullable int32\\;
           AVD\\:nullable int32\\;
           FIL\\:nullable int32\\;
           PSKP\\:nullable int32\\;
           OB\\:nullable int32\\;
           US\\:nullable int32\\;
           DAYS_OD\\:nullable int32\\;
           DAYS_PR\\:nullable int32\\;
           DAYS_OD_REAG\\:nullable int32\\;
           DAYS_PR_REAG\\:nullable int32\\;
           STOP_LIST\\:nullable int32\\;
           MSB\\:nullable int32\\;
           PRISTAV\\:nullable int32\\;
           SEQUOIA\\:nullable int32\\;
           PKB\\:nullable int32\\;
           AOS\\:nullable int32\\;
           MORGAN\\:nullable int32\\;
           EXPRESS\\:nullable int32\\;
           SVS\\:nullable int32\\;
           INBGPARAVO\\:nullable int32\\;
           ARGUMENT\\:nullable int32\\;
           AKCEPT\\:nullable int32\\;
           IUCB\\:nullable int32\\;
           ETAP\\:nullable int32\\;
           INKOR\\:nullable int32\\;
           BIUS\\:nullable int32\\;
           AROSD\\:nullable int32\\;
           SP\\:nullable int32\\;
           EKK\\:nullable int32\\;
           AKCEPT_NT\\:nullable int32\\;
           FEMIDA\\:nullable int32\\;
           AKSECUIRITY\\:nullable int32\\;
           UDN\\:nullable int32\\;
           RECOVERY\\:nullable int32\\;
           SKA\\:nullable int32\\;
           RFB\\:nullable int32\\;
           FASP\\:nullable int32\\;
           USB\\:nullable int32\\;
           PPN_DT\\:nullable date\\;
           PPN_TM\\:nullable time\\;
         )\\'
}'
   

## General options
[ident('UPD'); jobmon_ident('UPD')]
## Inputs
0< [] 'T199:UPD.v'
;

#################################################################
#### STAGE: UPP_DST
## Operator
pxbridge
## Operator options
-Orientation link
-XMLProperties '<?xml version=\\'1.0\\' encoding=\\'UTF-16\\'?><Properties version=\\'1.1\\'><Common><Context type=\\'int\\'>1</Context><Variant type=\\'string\\'>9.1</Variant><DescriptorVersion type=\\'string\\'>1.0</DescriptorVersion><PartitionType type=\\'int\\'>-1</PartitionType><RCP type=\\'int\\'>0</RCP></Common><Connection><Instance modified=\\'1\\' type=\\'string\\'><![CDATA[]]></Instance><Database modified=\\'1\\' type=\\'string\\'><![CDATA[[&"psConnectionsMART.martDatabase"]]]></Database><Username modified=\\'1\\' type=\\'string\\'><![CDATA[[&"psConnectionsMART.martUserName"]]]></Username><Password modified=\\'1\\' type=\\'string\\'><![CDATA[[&"psConnectionsMART.martPassword"]]]></Password><Conductor collapsed=\\'1\\' type=\\'bool\\'><![CDATA[0]]></Conductor><UseDirectConnections type=\\'bool\\'><![CDATA[0]]></UseDirectConnections><KeepConductorConnectionAlive type=\\'bool\\'><![CDATA[1]]></KeepConductorConnectionAlive></Connection><Usage><GenerateSQL modified=\\'1\\' type=\\'bool\\'><![CDATA[1]]></GenerateSQL><TableName modified=\\'1\\' type=\\'string\\'><![CDATA[[&"psConnectionsMART.martScheme"].UREP_POINT_PLACE WHERE IDAT = \\'[&"IDAT"]\\' WITH UR]]></TableName><EnableQuotedIDs type=\\'bool\\'><![CDATA[0]]></EnableQuotedIDs><XMLColumnAsLOB type=\\'bool\\'><![CDATA[0]]></XMLColumnAsLOB><PrefixForExpressionColumns type=\\'string\\'><![CDATA[EXPR]]></PrefixForExpressionColumns><SQL><EnablePartitioning collapsed=\\'1\\' type=\\'bool\\'><![CDATA[0]]></EnablePartitioning></SQL><Transaction><RecordCount type=\\'int\\'><![CDATA[2000]]></RecordCount><EndOfWave collapsed=\\'1\\' type=\\'int\\'><![CDATA[0]]></EndOfWave></Transaction><Session><IsolationLevel modified=\\'1\\' type=\\'int\\'><![CDATA[0]]></IsolationLevel><AutocommitMode type=\\'int\\'><![CDATA[0]]></AutocommitMode><ArraySize type=\\'int\\'><![CDATA[2000]]></ArraySize><SchemaReconciliation><FailOnSizeMismatch type=\\'bool\\'><![CDATA[1]]></FailOnSizeMismatch><FailOnTypeMismatch type=\\'bool\\'><![CDATA[1]]></FailOnTypeMismatch><FailOnCodePageMismatch type=\\'bool\\'><![CDATA[0]]></FailOnCodePageMismatch></SchemaReconciliation><PassLobLocator collapsed=\\'1\\' type=\\'bool\\'><![CDATA[0]]></PassLobLocator></Session><BeforeAfter collapsed=\\'1\\' type=\\'bool\\'><![CDATA[0]]></BeforeAfter><ReOptimization type=\\'int\\'><![CDATA[2]]></ReOptimization><LockWaitMode collapsed=\\'1\\' type=\\'int\\'><![CDATA[1]]></LockWaitMode></Usage></Properties >'
-connector '{
   variant='9.1', 
   library=ccdb2, 
   version=1.0, 
   variantlist='9.1', 
   versionlist='1.0', 
   name=DB2Connector
}'
-source 0 '{
      DSIsKey={SCAB=1, SCAN=1, SCAS=1, IDAT=1, PTDTN=1}, 
      DSDisplayWidth={SRC_STM_ID=11, SCAB=4, SCAN=6, SCAS=3, IDAT=10, PTDTN=10, UREP_ORA=11, CCT_ORA=11, CCH=11, AVD=11, FIL=11, PSKP=11, OB=11, US=11, DAYS_OD=11, DAYS_PR=11, DAYS_OD_REAG=11, DAYS_PR_REAG=11, STOP_LIST=11, MSB=11, PRISTAV=11, SEQUOIA=11, PKB=11, AOS=11, MORGAN=11, EXPRESS=11, SVS=11, INBGPARAVO=11, ARGUMENT=11, AKCEPT=11, IUCB=11, ETAP=11, INKOR=11, BIUS=11, AROSD=11, SP=11, EKK=11, AKCEPT_NT=11, FEMIDA=11, AKSECUIRITY=11, UDN=11, RECOVERY=11, SKA=11, RFB=11, FASP=11, USB=11}, 
      DSSQLType={SRC_STM_ID=4, SCAB=1, SCAN=1, SCAS=1, IDAT=9, PTDTN=9, UREP_ORA=4, CCT_ORA=4, CCH=4, AVD=4, FIL=4, PSKP=4, OB=4, US=4, DAYS_OD=4, DAYS_PR=4, DAYS_OD_REAG=4, DAYS_PR_REAG=4, STOP_LIST=4, MSB=4, PRISTAV=4, SEQUOIA=4, PKB=4, AOS=4, MORGAN=4, EXPRESS=4, SVS=4, INBGPARAVO=4, ARGUMENT=4, AKCEPT=4, IUCB=4, ETAP=4, INKOR=4, BIUS=4, AROSD=4, SP=4, EKK=4, AKCEPT_NT=4, FEMIDA=4, AKSECUIRITY=4, UDN=4, RECOVERY=4, SKA=4, RFB=4, FASP=4, USB=4}, 
      DSSQLPrecision={SRC_STM_ID=10, SCAB=4, SCAN=6, SCAS=3, IDAT=10, PTDTN=10, UREP_ORA=10, CCT_ORA=10, CCH=10, AVD=10, FIL=10, PSKP=10, OB=10, US=10, DAYS_OD=10, DAYS_PR=10, DAYS_OD_REAG=10, DAYS_PR_REAG=10, STOP_LIST=10, MSB=10, PRISTAV=10, SEQUOIA=10, PKB=10, AOS=10, MORGAN=10, EXPRESS=10, SVS=10, INBGPARAVO=10, ARGUMENT=10, AKCEPT=10, IUCB=10, ETAP=10, INKOR=10, BIUS=10, AROSD=10, SP=10, EKK=10, AKCEPT_NT=10, FEMIDA=10, AKSECUIRITY=10, UDN=10, RECOVERY=10, SKA=10, RFB=10, FASP=10, USB=10}, 
      DSSchema=\\'record
         (
           SRC_STM_ID\\:int32\\;
           SCAB\\:string\\[4\\]\\;
           SCAN\\:string\\[6\\]\\;
           SCAS\\:string\\[3\\]\\;
           IDAT\\:date\\;
           PTDTN\\:date\\;
           UREP_ORA\\:nullable int32\\;
           CCT_ORA\\:nullable int32\\;
           CCH\\:nullable int32\\;
           AVD\\:nullable int32\\;
           FIL\\:nullable int32\\;
           PSKP\\:nullable int32\\;
           OB\\:nullable int32\\;
           US\\:nullable int32\\;
           DAYS_OD\\:nullable int32\\;
           DAYS_PR\\:nullable int32\\;
           DAYS_OD_REAG\\:nullable int32\\;
           DAYS_PR_REAG\\:nullable int32\\;
           STOP_LIST\\:nullable int32\\;
           MSB\\:nullable int32\\;
           PRISTAV\\:nullable int32\\;
           SEQUOIA\\:nullable int32\\;
           PKB\\:nullable int32\\;
           AOS\\:nullable int32\\;
           MORGAN\\:nullable int32\\;
           EXPRESS\\:nullable int32\\;
           SVS\\:nullable int32\\;
           INBGPARAVO\\:nullable int32\\;
           ARGUMENT\\:nullable int32\\;
           AKCEPT\\:nullable int32\\;
           IUCB\\:nullable int32\\;
           ETAP\\:nullable int32\\;
           INKOR\\:nullable int32\\;
           BIUS\\:nullable int32\\;
           AROSD\\:nullable int32\\;
           SP\\:nullable int32\\;
           EKK\\:nullable int32\\;
           AKCEPT_NT\\:nullable int32\\;
           FEMIDA\\:nullable int32\\;
           AKSECUIRITY\\:nullable int32\\;
           UDN\\:nullable int32\\;
           RECOVERY\\:nullable int32\\;
           SKA\\:nullable int32\\;
           RFB\\:nullable int32\\;
           FASP\\:nullable int32\\;
           USB\\:nullable int32\\;
         )\\'
}'
   

## General options
[ident('UPP_DST'); jobmon_ident('UPP_DST')]
## Outputs
0> [modify (
  SRC_STM_ID:not_nullable int32=SRC_STM_ID;
  SCAB:not_nullable string[4]=SCAB;
  SCAN:not_nullable string[6]=SCAN;
  SCAS:not_nullable string[3]=SCAS;
  IDAT:not_nullable date=IDAT;
  PTDTN:not_nullable date=PTDTN;
  UREP_ORA:nullable int32=UREP_ORA;
  CCT_ORA:nullable int32=CCT_ORA;
  CCH:nullable int32=CCH;
  AVD:nullable int32=AVD;
  FIL:nullable int32=FIL;
  PSKP:nullable int32=PSKP;
  OB:nullable int32=OB;
  US:nullable int32=US;
  DAYS_OD:nullable int32=DAYS_OD;
  DAYS_PR:nullable int32=DAYS_PR;
  DAYS_OD_REAG:nullable int32=DAYS_OD_REAG;
  DAYS_PR_REAG:nullable int32=DAYS_PR_REAG;
  STOP_LIST:nullable int32=STOP_LIST;
  MSB:nullable int32=MSB;
  PRISTAV:nullable int32=PRISTAV;
  SEQUOIA:nullable int32=SEQUOIA;
  PKB:nullable int32=PKB;
  AOS:nullable int32=AOS;
  MORGAN:nullable int32=MORGAN;
  EXPRESS:nullable int32=EXPRESS;
  SVS:nullable int32=SVS;
  INBGPARAVO:nullable int32=INBGPARAVO;
  ARGUMENT:nullable int32=ARGUMENT;
  AKCEPT:nullable int32=AKCEPT;
  IUCB:nullable int32=IUCB;
  ETAP:nullable int32=ETAP;
  INKOR:nullable int32=INKOR;
  BIUS:nullable int32=BIUS;
  AROSD:nullable int32=AROSD;
  SP:nullable int32=SP;
  EKK:nullable int32=EKK;
  AKCEPT_NT:nullable int32=AKCEPT_NT;
  FEMIDA:nullable int32=FEMIDA;
  AKSECUIRITY:nullable int32=AKSECUIRITY;
  UDN:nullable int32=UDN;
  RECOVERY:nullable int32=RECOVERY;
  SKA:nullable int32=SKA;
  RFB:nullable int32=RFB;
  FASP:nullable int32=FASP;
  USB:nullable int32=USB;
keep
  SRC_STM_ID,SCAB,SCAN,SCAS,
  IDAT,PTDTN,UREP_ORA,CCT_ORA,
  CCH,AVD,FIL,PSKP,
  OB,US,DAYS_OD,DAYS_PR,
  DAYS_OD_REAG,DAYS_PR_REAG,STOP_LIST,MSB,
  PRISTAV,SEQUOIA,PKB,AOS,
  MORGAN,EXPRESS,SVS,INBGPARAVO,
  ARGUMENT,AKCEPT,IUCB,ETAP,
  INKOR,BIUS,AROSD,SP,
  EKK,AKCEPT_NT,FEMIDA,AKSECUIRITY,
  UDN,RECOVERY,SKA,RFB,
  FASP,USB;
)] 'UPP_DST:L90.v'
;

#################################################################
#### STAGE: T90
## Operator
transform
## Operator options
-flag run
-name 'V0S287_audi_05_ChangeCaptureApplyUPP_T90'

## General options
[ident('T90'); jobmon_ident('T90')]
## Inputs
0< [] 'UPP_DST:L90.v'
## Outputs
0> [] 'T90:L91.v'
;


ORCHESTRATE_CODE_FULL_RX END=1
