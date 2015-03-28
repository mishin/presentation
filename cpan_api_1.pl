
use MetaCPAN::Client;
my $client = MetaCPAN::Client->new();
my $query  = { all => [ { status => 'latest' }, { maturity => 'released' }, ] };
my $params = { fields => [qw/ metadata download_url /] };
my $result_set = $client->release( $query, $params );

while ( my $release = $result_set->next ) {
	my $distname = $release->metadata->{name};
	say $distname;
	# "URI-Title"
	#
	 my $path = $release->download_url;
	 say $path;
	# # "http://cpan.metacpan.org/authors/id/B/BO/BOOK/URI-Title-1.89.tar.gz"
	#  
}

