#!/usr/bin/perl

use strict;
use DBI;

my $dbh = DBI->connect(          
    "dbi:SQLite:dbname=test.db", 
    "",
    "",
    { RaiseError => 1}
) or die $DBI::errstr;


$dbh->do(<<'END_SQL');
create table banners (
     banner_id int unsigned not null primary key,
     title varchar(200),
     url varchar(4000)
)
END_SQL


$dbh->disconnect();
