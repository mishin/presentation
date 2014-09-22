package GenericClass;

use strict;
use warnings;

sub new {
    my $class = shift;
    my %args  = @_;

    my $self = {
        id           => $args{id},
        file         => $args{file},
        _name        => $args{name},
        _description => $args{description},
        _date        => $args{date},
        _time        => $args{time},
        _size        => $args{size},
    };

    return bless $self, $class;
}

sub get_id {
    my $self = shift;
    return $self->{id};
}

sub set_id {
    my $self      = shift;
    $self->{id} = shift;
}
sub get_file {
    my $self = shift;
    return $self->{file};
}

sub set_file {
    my $self      = shift;
    $self->{file} = shift;
}
sub _get_name {
    my $self = shift;
    return $self->{_name};
}

sub _set_name {
    my $self      = shift;
    $self->{_name} = shift;
}
sub _get_description {
    my $self = shift;
    return $self->{_description};
}

sub _set_description {
    my $self      = shift;
    $self->{_description} = shift;
}
sub _get_date {
    my $self = shift;
    return $self->{_date};
}

sub _set_date {
    my $self      = shift;
    $self->{_date} = shift;
}
sub _get_time {
    my $self = shift;
    return $self->{_time};
}

sub _set_time {
    my $self      = shift;
    $self->{_time} = shift;
}
sub _get_size {
    my $self = shift;
    return $self->{_size};
}

sub _set_size {
    my $self      = shift;
    $self->{_size} = shift;
}

1;

 __END__ 
