package FBS::Load;

use 5.01;
use warnings;
use strict;
use Carp;
use Smart::Comments;
use POSIX;
use Test::More;

our ( @ISA, $VERSION, @EXPORT_OK );

BEGIN {
    $VERSION = '0.0.1';

    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT_OK =
      qw(get_user_param get_connect get_cobdate_sql welcome_cob_date test_10_persent);

}

#use version;
#my $VERSION = qv('0.0.1');
# Other recommended modules (uncomment to use):
#use IO::Prompt;
#use Perl6::Export;
#use Perl6::Slurp;
#use Perl6::Say;
#use YAML::Tiny;
use YAML::Tiny;

#read config

sub get_user_param {
    my ( $pwd, $config_name ) = @_;

    my $my_yml_file = $pwd . qq{/$config_name};

    # Open the config
    my $yaml = YAML::Tiny::LoadFile($my_yml_file);
    return $yaml;
}

#conn to database
sub get_connect_string {
    my $yaml              = shift;
    my $init_user         = shift;
    my $user              = $yaml->{ $init_user . '_un' };
    my $password          = $yaml->{ $init_user . '_pw' };
    my $prod_database_tns = $yaml->{prod_database_tns};
    my $driver            = $yaml->{driver};

 #return " sqlsh -d DBI:$driver:$prod_database_tns -u $user -p $password -i < ";
    my $connections;
    my $MAX_TRIES = 3;
  TRY:
    for my $try ( 1 .. $MAX_TRIES )
    {    ### Connecting to server $prod_database_tns under user $user... done
        $connections =
          DBI->connect( 'dbi:' . $driver . ':' . $prod_database_tns,
            $user, $password );
        last TRY if $connections;
    }
    croak "Can't contact server ($prod_database_tns)"
      if not $connections;
    return $connections;
}

#
# make connect to database
#
sub get_connect {
    my $ref_init_users = shift;
    my $yaml           = shift;
    my @init_users     = @{$ref_init_users};
    my %connect_of;
    for my $user (@init_users) {
        $connect_of{$user} = get_connect_string( $yaml, $user );
    }
    return \%connect_of;
}

#
# get sql for search COB_DATE
#
sub get_cobdate_sql {
    return <<END;
select to_char(t.cob_date, 'yyyy-mm-dd') cd,
       to_char(t.cob_date, 'dd-Mon-yyyy') cd_disp,
       case
         when t.is_tue_cob = 1 then
          'WE'
         when t.is_me_cob = 1 then
          'ME'
         else
          'WE'
       end we_name
  from fbs_owner.FBS_COB_DATES t
 where cob_date <= sysdate -- + 6
   and rownum < 2
 order by t.cob_date desc
END
}

#
# get sql for search COB_DATE
#
sub welcome_cob_date {
    my ( $rwa_owner_user, $ref_ini ) = @_;
    my ( $ref_connect,    $ref_cd )  = @{$ref_ini};
    my %connect_of = %{$ref_connect};
    my ( $cob_date, $cob_date_display, $we_name ) = @{$ref_cd};
    my $now_time = get_now( $rwa_owner_user, $ref_connect, $cob_date );
    my $BST =
      "London time:\t" . DateTime->now->set_time_zone("Europe/London")->iso8601;
    my $disp = qq{
For COB_DATE=$cob_date
1 http://jira.gto.intranet.db.com:2020/jira/secure/Dashboard.jspa
2 Create Issue ('c')
Project : FRM Disclosures Support; 
Issue Type: Production support;
Create -> sybmit
Priority->Medium;Component/s->FBS
Title ->$we_name FBS load $cob_date_display
==========================================================
Description
==========================================================
For $we_name FBS load it needs to:

    * do regular FBS data load (fcl_copy_tuned_new_prod.sh 
      for FCL_COPY, EUS script)
    * check manually FxRates table load
    * check manually DB_INSTRUMENT tables load
    * prepare checking counts report    

Component/s: FBS
Assignee: "Assign To Me"
Priority: Medium (don't change)
==========================================================
add Watchers (nicks for speed)
==========================================================
eealina,marlch,herrdx,agrahar,bhnehas
==========================================================    
NOW_TIME: $now_time
BST_TIME: $BST
==========================================================    
add number of Jira to "runs history" in
https://wiki.tools.intranet.db.com/confluence/display/FCL/FBS+Production+Life+Cycle
};
    return $disp;
}

#
# data in t+1 10pm fiormat, where t=COB_DATE
#
sub get_now {
    my ( $rwa_owner_user, $ref_connect, $cob_date ) = @_;
    my %connect_of = %{$ref_connect};
    my $sql        = q{};
    $sql = <<"END";
select 't+'||round(trunc(sysdate)- to_date('$cob_date','yyyy-mm-dd'))||' '||to_char(sysdate,'hham') "Time Now" from dual
END

    my $dbh = $connect_of{$rwa_owner_user};
    my $now = $dbh->selectrow_array($sql);
    return $now;

#select 't+'||round(sysdate- to_date('$cob_date','yyyy-mm-dd'))||' '||to_char(sysdate,'hhmiam') "Time Now" from dual

}

#test if bigger or lower not lower then 10%
sub test_10_persent {
    my ( $calc_value, $orig_value, $persent, $message ) = @_;

    if ( $calc_value >= $orig_value ) {
        cmp_ok( $calc_value, '>=', $orig_value,
            $message . " $calc_value >= $orig_value " );
    }
    else {
        my $cal_persent =
          floor( abs( ( ( $calc_value - $orig_value ) / $orig_value ) * 100 ) );
        cmp_ok( $cal_persent, '<=', $persent,
            $message . " $calc_value <= $orig_value but not lower then 10 %" );
    }
}

# Module implementation here

1;    # Magic true value required at end of module
__END__

=head1 NAME

FBS::Load - [Weekly load FBS data in group SL3 . Automate some operation and stored rules in local database. SQL::Lite]


=head1 VERSION

This document describes FBS::Load version 0.0.1


=head1 SYNOPSIS

    use FBS::Load;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.

=head2 Methods

=over 4

=item *  C<< get_user_param ( $pwd, $config_name  ) >>

=item *  my $yaml =  get_user_param( $ENV{PWD}, 'fbs_load.yml' );    #Global hash with parameters

Read ini file_name as input parameter in YAML in current directory.Returns hash $yaml. 

=item *  C<< get_connect_string (   $yaml, $init_user ) >>

=item *  $connect_of{$user} = get_connect_string( $yaml, $user );

Read connect parameters from $yaml hash, make connect string and make connect to database:

=item *  C<< get_connect ( \@init_user_connects, $yaml  ) >>

=item *  my %connect_of  = ();my $ref_connect = \%connect_of;
=item *  my $ref_connect = get_connect( \@init_user_connects, $yaml ); %connect_of  = %{$ref_connect};

Make connect to appropriate database

=item *  C<< get_cobdate_sql ( ) >>

=item *  my $ref_cd = $dbh_fbs->selectrow_arrayref( get_cobdate_sql() );

Return sql for find COB_DATE from fbs_owner.FBS_COB_DATES

=item *  C<< welcome_cob_date ( $rwa_owner_user, $ref_ini  ) >>

=item *  my $echo_curr_fbsl_load = welcome_cob_date($rwa_owner_user, $ref_ini);
=item *  print $echo_curr_fbsl_load;

Return current FBS load parameters for create Jira and information needed to add to Confluence.

=item *  C<< get_now ( $rwa_owner_user, $ref_connect, $ref_cd ) >>

=item *  my $now_time = get_now($rwa_owner_user, $ref_connect,$cob_date);

Return date in format  t+1 10pm where t - COB_DATE.

=item *  C<< test_10_persent( $calc_value, $orig_value, $persent, $message ) >>

=item *  test is passed if the result is more or less does not less than 10 per cent

use Test::More qw/no_plan/;
use POSIX;
my $calc_value = 22;
my $orig_value = 20;
my $persent    = 10;      #%
my $message    = 'MIS';

test_10_persent( $calc_value, $orig_value, $persent, $message );

=back


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
FBS::Load requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-fbs-load@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Nikolay Mishin  C<< <mi@ya.ru> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2011, Nikolay Mishin C<< <mi@ya.ru> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
