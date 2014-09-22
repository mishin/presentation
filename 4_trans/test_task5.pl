use Test::More;
use GenericClass;
my $user_id=1420;
my $unit=GenericClass->new();
$unit->set_id($user_id);
#print $unit->get_id;
is ($unit->get_id,$user_id,"\$user_id=$user_id set and get successfully");
done_testing 1;