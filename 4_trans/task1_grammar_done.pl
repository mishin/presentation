#!/usr/bin/env perl 
##############################################################################
# Copyright (c) 2012 Nikolay Mishin
#
# You may distribute under the terms of either the GNU General Public License
# or the Artistic License, as specified in the Perl README file.
#
#      $URL: http://mishin.narod.ru $
#     $Date: 2012-01-21 20:53:20 +0300 (Sat, 21 Jan 2012) $
#   $Author: mishin nikolay $
# $Revision: 0.02 $
#   $Source: task1_grammar_done.pl $
#   $Description: create report using grammar, task1 for rutube  $
##############################################################################
use strict;
use warnings;
use Modern::Perl;

use Parse::RecDescent;
use Carp;
use utf8;
use open qw/:std :utf8/;

our $VERSION = '0.02';

$::RD_ERRORS = 1;    # kill parser if it encounters an error
$::RD_WARN   = 1;    # enable warnings
$::RD_HINT   = 1;    # helpful hints

my $p = Parse::RecDescent->new( << 'GRAMMAR') or carp 'cannot parse grammar!';
{
      use strict;
      use warnings;
      use charnames ':full';
}

   start: 
                     subrule 
                             { print "$item{subrule}\n" }
       
   subrule:          
                     dogovor num_sign dogovor_number ot data_from status data_when               
                                
                                { $return = "|$item{dogovor_number}|$item{status}|$item{data_when}|" }                       
                     
    dogovor:         'Договор'
    status:          'пролонгирован'|'расторгнут'       
    ot:              'от'
    data:            /\d{2}[.]\d{2}[.]\d{4}/ 
    data_from:       data
    data_when:       data
    num_sign:        /[№]/
    dogovor_number:  /\d+/
GRAMMAR

say
'|| № договора || статус                 || дата изменения статуса ||';

while (<DATA>) { $p->start($_); }
__DATA__
Договор №1234 от 20.05.2010 пролонгирован 20.05.2011 
Договор №412456 от 12.12.2007 расторгнут 20.05.2011 
Договор №725 от 03.05.1982 пролонгирован 08.11.2011 
