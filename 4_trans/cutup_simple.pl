package PerlCodeGenerator;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use PPI;

__PACKAGE__->mk_accessors(qw/table gram/);

sub new {
    my ($class, $args) = @_;

    $class->SUPER::new({
        table => {},
        gram => 1,
        %$args,
    });
}

sub add_source_code {
    my ($self, $body) = @_;

    my $last_token = substr($body, 0, $self->gram);
    for my $from (1 .. length($body) - $self->gram) {
        my $token = substr($body, $from, $self->gram);
        $self->table->{$last_token} ||= [];
        push @{$self->table->{$last_token}}, $token;
        $last_token = $token;
    }

}

sub get_next_of {
    my ($self, $last_token) = @_;

    die "no entry for \"$last_token\"" unless $self->table->{$last_token};

    $self->_array_select($self->table->{$last_token});
}

sub _array_select {
    my ($self, $array) = @_;
    $array->[int(rand() * scalar @$array)];
}

package main;
use strict;
use warnings;
use Path::Class qw/file/;
use Time::HiRes qw/usleep/;

my $g = PerlCodeGenerator->new({gram => 3});

for my $file_path (@ARGV) {
    $g->add_source_code(scalar file($file_path)->slurp);
}

my $token = 'use';
print $token;

while(1) {
    $token = $g->get_next_of($token);
    print substr $token, 0, 1;

    usleep(15000);
}
