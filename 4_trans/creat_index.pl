use Modern::Perl;
my @array = <DATA>;
foreach my $sql(@array){
chomp($sql);
$sql =~ s{\$}{\\\$}g;
# print $sql;
print <<END;
(echo "$sql";echo exit)|sqlplus dwh_main/dwh_main\@tstehd >>create_index.log &
END

# say quotemeta $sql;
# (echo "create index ACNT_FK_GID_END_DATE_IDX on REF_ACCOUNT (ACNT_GID, ACNT\$END_DATE)   tablespace DWH_MAIN_INDEX;";echo exit)|sqlplus dwh_main/dwh_main@tstehd >>cr_imdex_stage.log &

};
# say "@array";

__DATA__
create index CTRNS_AS_OF_DATE$IDX on ACC_CARD_TRANSACTION (CTRNS_AS_OF_DATE)   tablespace DWH_MAIN_INDEX;
create index CTRNS_GID$IDX on ACC_CARD_TRANSACTION (CTRNS_GID)   tablespace DWH_MAIN_INDEX;
create index CTRNS_PROCEEDED$IDX on ACC_CARD_TRANSACTION (CTRNS_AS_OF_PROCEEDED_DATE)  tablespace DWH_MAIN_INDEX;
create index CTRNS_TRNS_GID$IDX on ACC_CARD_TRANSACTION (CTRNS_TRNS_GID)   tablespace DWH_MAIN_INDEX;