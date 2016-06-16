#!/usr/bin/perl

use strict;
use DBI;

my $dbh = DBI->connect(          
    "dbi:SQLite:dbname=test.db", 
    "",
    "",
    { RaiseError => 1}
) or die $DBI::errstr;


my $stmt = qq(SELECT banner_id, title, url from banners;);
my $sth = $dbh->prepare( $stmt );
my $rv = $sth->execute() or die $DBI::errstr;
if($rv < 0){
   print $DBI::errstr;
}
while(my @row = $sth->fetchrow_array()) {
      print "banner_id = ". $row[0] . "\n";
      print "title = ". $row[1] ."\n";
      print "url = ". $row[2] ."\n\n";
}
print "Operation done successfully\n";

$dbh->disconnect();
