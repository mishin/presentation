#!/usr/bin/perl
##############################################################################
#      $URL: http://mishin.narod.ru $
#     $Date: 2011-11-01 16:32:04 +0400 (Nov, 01 Nov 2011) $
#   $Author: mishnik $
# $Revision: 1.02 $
#   $Source: test  check variables $
#   $Description:  check input parameters of function
#   $ Domian Conway in PBP offer to use croak, is it correct? $
#   01-11-2011:
#   put question to
#   http://stackoverflow.com/questions/7963866/is-it-correct-way-to-check-function-input-values
##############################################################################

use strict;
use warnings;
use 5.010;

use Carp qw(cluck carp);
use Data::Dumper;
use Readonly;

#use autodie;
use Attribute::Signature;

our $VERSION = '0.01';

#run main procedure
main();

sub main : returns(integer) {

    #make test for chack input parameters
    Readonly my $CHECK_LEVEL => 100;
    my %filials;
    my $ref_hash = \%filials;
    my @test     = qw/444 33a 2 d 300 ffd 22/;
    my $ret;
    for my $test_val (@test) {
        $ref_hash->{foo} = $test_val;
        $ret = test_var( $ref_hash->{foo}, $CHECK_LEVEL )
          || carp("couldn't invoke test_var \%filials, $CHECK_LEVEL ");
    }

    return 1;
}

sub test_var : with(integer, integer) returns(integer) {
    my $evaluated_value = shift;
    my $check_value     = shift;

    #check values by business rule
    if ( $evaluated_value > $check_value ) {
        say "$evaluated_value > $check_value";
    }
    else {
        say "$evaluated_value <= $check_value";
    }
    return 1;
}
