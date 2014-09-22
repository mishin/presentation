#!/usr/bin/perl
use 5.010;
use strict;
use warnings;
use Carp;
use HTML::Template;

main();

sub main {

    #read sql and data from source
    my $ref_source_data = import_sql_and_data();
    my @method          = qw/id file _name _description _date _time _size/;
    my $template_name   = 'setter_and_getter';
    for my $field_name (@method) {
        my ( $prefix, $var ) = check_protected($field_name);
### $prefix
### $var
### $field_name
        get_template( $ref_source_data, $template_name, $prefix, $var );
    }
}

sub check_protected {
    my ($field) = @_;
    my $prefix = substr( $field, 0, 1 );
    given ($prefix) {
        when ('_') { return $prefix, substr( $field, 1, length($field) ) }
        default {
            return '',$field;
        }
    }
}

#
# New subroutine "get_template" extracted - Fri Dec 16 13:37:34 2011.
#
sub get_template {
    my $ref_source_data  = shift;
    my $template_name    = shift;
    my $prefix           = shift;
    my $var              = shift;
    my $welcome_template = $ref_source_data->{$template_name};
    my $filter           = sub {
        my $text_ref = shift;
        $$text_ref =~ s/%(.*?)%/<TMPL_VAR $1>/g;
    };

    my $t = HTML::Template->new(
        scalarref => \$welcome_template,
        filter    => $filter,
    );
    $t->param( prefix => $prefix );
    $t->param( var    => $var );

    print $t->output;
}

sub import_sql_and_data {
    print {*STDERR} "Reading sql query...\n";
    my %contents_of = do { local $/; "", split /_____\[ (\S+) \]_+\n/, <DATA> };
    for ( values %contents_of ) {
        s/^!=([a-z])/=$1/gxms;
    }
    print {*STDERR} "done\n";
    return \%contents_of;
}

__DATA__
_____[ setter_and_getter ]________________________________________________
sub %prefix%get_%var% {
    my $self = shift;
    return $self->{%prefix%%var%};
}

sub %prefix%set_%var% {
    my $self      = shift;
    $self->{%prefix%%var%} = shift;
}
