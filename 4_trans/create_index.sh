(echo "create index CTRNS_AS_OF_DATE\$IDX on ACC_CARD_TRANSACTION (CTRNS_AS_OF_DATE)   tablespace DWH_MAIN_INDEX;";echo exit)|sqlplus dwh_main/dwh_main@tstehd >>create_index.log &
(echo "create index CTRNS_GID\$IDX on ACC_CARD_TRANSACTION (CTRNS_GID)   tablespace DWH_MAIN_INDEX;";echo exit)|sqlplus dwh_main/dwh_main@tstehd >>create_index.log &
(echo "create index CTRNS_PROCEEDED\$IDX on ACC_CARD_TRANSACTION (CTRNS_AS_OF_PROCEEDED_DATE)  tablespace DWH_MAIN_INDEX;";echo exit)|sqlplus dwh_main/dwh_main@tstehd >>create_index.log &
(echo "create index CTRNS_TRNS_GID\$IDX on ACC_CARD_TRANSACTION (CTRNS_TRNS_GID)   tablespace DWH_MAIN_INDEX;";echo exit)|sqlplus dwh_main/dwh_main@tstehd >>create_index.log &
