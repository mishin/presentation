# hash: login, uid, pass, dir, 
sub add_user {
	my(%args) = %{$_[0]};
	my $command = "adduser -m ";
	
	if (defined $args{'uid'})  {
		$command .= "-u ".$args{'uid'};
	}
	
	if (defined $args{'dir'})  {
		$command .= "-k ".$args{'dir'};
	}
	
	if (defined $args{'pass'})  {
		$command .= "-p ".crypt($args{'pass'}, "AA");
	}
	
	$command .= " ".$args{'login'};
	
	print $command;
	
	if ($? == 1) {
		print STDERR "Can'd add user, maybe gid is taken?"
	}
}

# args login
sub del_user {
	my $login = shift;
	system("deluser ".$login);
}



# print find_free_uid();
# change_gid('couchdb', 118);
#print generate_password(20);
#print home_dir("ymir");
my %user = (login => 'testuser', pass => 'password');

&add_user(\%user);