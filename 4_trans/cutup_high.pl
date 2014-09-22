package PerlCodeGenerator;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use PPI;
use Path::Class;
use File::Sync qw(fsync sync);

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

    my $document = PPI::Document->new(\$body);
    my @tokens = map { $_->content } @{$document->find(q{PPI::Token})};

    my @last_tokens;
    push @last_tokens, shift @tokens for (1..$self->gram);
    foreach my $token (@tokens) {
        my $key = join '', @last_tokens;
        $self->table->{$key} ||= [];
        push @{$self->table->{$key}}, $token;
        push @last_tokens, $token;
        shift @last_tokens;
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


while (1) {
    eval {
        my @last_tokens = ('use', ' ', 'strict');
        my @tokens;
        push @tokens, join('', @last_tokens);
        for my $count (0..100) {


            my $key = join '', @last_tokens;

            my $token = $g->get_next_of($key);
            push @tokens, $token;

            push @last_tokens, $token;
            shift @last_tokens;

            my $buffer = join('', @tokens);
            system "clear";
            print $buffer;
            if (system("echo '$buffer' | perl -wc") == 0  && length $buffer > 100) {
                system "echo '$buffer' > tmp.pl";
                exit;
            }
        }
    };
}
