package Ftree::Name;
use Kelp::Base;
attr title      => undef;
attr prefix     => undef;
attr first_name => undef;
attr mid_name   => undef;
attr last_name  => undef;
attr suffix     => undef;
attr nickname   => undef;

attr full_name => sub {
    my $self = shift;
    my @name_array = ( $self->last_name, $self->first_name, $self->mid_name );
    join( ' ', @name_array );
};

package main;
use Test::More;

my $o = Ftree::Name->new;

isa_ok $o, 'Ftree::Name';

can_ok $o, qw/title prefix first_name mid_name last_name suffix suffix/;

$o->first_name('Николай');
is $o->first_name, 'Николай', 'set name is ok';
$o->last_name('Мишин');
$o->mid_name('Алексеевич');
is $o->full_name, 'Мишин Николай Алексеевич', 'fullname ok';

done_testing;
