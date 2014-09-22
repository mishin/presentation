use Data::Dumper;
my $t = Person->new(); 
 $t->run(); 
 #print Dumper \%main::;
 print Dumper $t;
 

package Person;
    use strict;
use Data::Dumper;	
	 my $Census = 3;
	 my @array = ('foo','bar'); 
sub new {
        my $class = shift;
        my $self  = {};
        # "private" data
        $self->{"_array"} = \@array;
        bless ($self, $class);
   		push @{ $self->{"_array"} },'foo';#=@array;
		push @{ $self->{"_array"} },'bar';#=@array;
     return $self;
    }

   	sub run {
     my $self = shift;     
     print "Array: " . Dumper($self->{"_array"}); return;
 } 
