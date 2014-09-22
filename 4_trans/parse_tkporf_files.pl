use Modern::Perl;
use File::Slurp;
my $fname=$ARGV[0];#'orcl_ora_4474_BI_MART.tkp';
 my $text = read_file( $fname )    ;
my $Str = 'SQL ID: 1mjd9xp80vuqa Plan Hash: 3023518864

select node,owner,name 
from
 syn$ where obj#=:1


call  ' ;

my @Blocks = ($text =~ m#(select..+?(?:(?=call)|$))#gs);
write_file( "$fname.sql",join ";\n", @Blocks);

__END__

ls -la|egrep '(BI_MART.trc|BI_MART.tkp)'
tkprof orcl_ora_2020_BI_MART.trc orcl_ora_2020_BI_MART.tkp

CREATE OR REPLACE TRIGGER trace_trig_BI_MART
AFTER LOGON
ON DATABASE
DECLARE
 filestr VARCHAR2(200) :='ALTER SESSION SET tracefile_identifier = ''BI_MART'' ';
 sqlstr VARCHAR2(200) := 'ALTER SESSION SET EVENTS ''10046 TRACE NAME CONTEXT FOREVER, LEVEL 12''';
BEGIN
 IF (USER = 'BI_MART') THEN
 execute immediate filestr;
 execute immediate sqlstr;
 END IF;
END trace_trig_BI_MART;
/

#path to trace files:
show param user_dump_dest

# SQL ID: 1mjd9xp80vuqa Plan Hash: 3023518864

# select node,owner,name 
# from
 # syn$ where obj#=:1


# call  


# ********************************************************************************

# select * from sys.all_constraints
# where table_name = :object_name
# and owner = :object_owner
# and constraint_type in ('P', 'U', 'R', 'C')
# order by decode(constraint_type, 'P', 0, 'U', 1, 'R', 2, 3), constraint_name

# call     count       cpu    elapsed       disk      query    current        rows
# -----
