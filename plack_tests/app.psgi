#!/usr/bin/env plackup

use v5.14;
# use utf8;
use DBI;
use HTML::HTML5::Parser;
use HTML::HTML5::Writer;
use Plack::Request;
use Plack::Response;

# connect to database
my $dbh = 'DBI'->connect("dbi:SQLite:database.db","","") or die "Could not connect";
my ($insert, $select);

while (1) {
   # create insert and select statements
   $insert = eval { $dbh->prepare('INSERT INTO people VALUES (?,?)') };
   $select = eval { $dbh->prepare('SELECT * FROM people') };
   # break out of loop if statements prepared
   last if $insert && $select;

   # if statements didn't prepare, assume its because the table doesn't exist
   warn "Creating table 'people'\n";
   $dbh->do('CREATE TABLE people (name varchar(255), age int);');
}

my $template = 'HTML::HTML5::Parser'->load_html(IO => \*DATA);
my $writer   = 'HTML::HTML5::Writer'->new(markup => 'html', polyglot => 1);

# the PSGI app itself
my $app = sub {
   my $req = 'Plack::Request'->new(shift);
   my $res = 'Plack::Response'->new(200);

   if ($req->method eq 'POST') {
      $insert->execute(map $req->parameters->{$_}, qw( name age ));
      $res->redirect( $req->base );
   }   
   else {
      my $page  = $template->cloneNode(1);
      my $table = $page->getElementsByTagName('table')->get_node(1);
      $select->execute;
      while (my @row = $select->fetchrow_array) {
         my $tr = $table->addNewChild($table->namespaceURI, 'tr');
         $tr->appendTextChild(td => $_) for @row;
      }
      $res->body( $writer->document($page) );
   }

   $res->finalize;
};

__DATA__
<!DOCTYPE html>
<title>People</title>
<form action="insert" method="post">
   Name: <input type="text" name="name"> 
   Age: <input type="text" name="age">
   <input type="submit" value="Add">
</form>
<br>
Data: <br>
<table border="1">
   <tr>
      <th>Name</th>
      <th>Age</th>
   </tr>
</table>