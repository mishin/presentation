#! /usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

my $man = 0;
my $help = 0;
# my $port = 0;
# my $host = "";

GetOptions(
           'help|?' => \$help,
           'man' => \$man,
#            'p|port=i' => \$port,
#            'a:s' => \$host
          ) or pod2usage(-verbose => 2);

pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;


&main; exit;

sub main {
  print "hello world\n";
}



__END__

=head1 NAME

foo.pl - Write shor description of this script here

=head1 SYNOPSIS

 foo.pl [options] [file ...]

 Options:
   -help            brief help message
   -man             full documentation

=head1 OPTIONS

=over 2

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do something
useful with the contents thereof.

=head1 AUTHOR

Kosei Moriyama <cou929@gmail.com>

=cut
