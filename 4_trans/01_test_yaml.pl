use YAML::Tiny;
use Smart::Comments;
use Data::Dumper;
use Carp;
use English qw(-no_match_vars);
use 5.01;

my $my_yml_file =
  'c:/Users/nmishin/AppData/Local/Perl/Padre/plugins/Padre/Plugin/My.yml';

# Open the config
my $yaml = YAML::Tiny::LoadFile($my_yml_file)
  or croak "Couldn't open YAML::Tiny->errstr: $OS_ERROR";

#print YAML::Tiny->errstr;

#$yaml = YAML::Tiny->read($my_yml_file);
#print Dumper($yaml);
### $yaml
sub get_connect_string {
    my $init_user         = shift;
    my $user              = $yaml->{ $init_user . '_un' };
    my $password          = $yaml->{ $init_user . '_pw' };
    my $prod_database_tns = $yaml->{prod_database_tns};
    my $driver            = $yaml->{driver};

    return " -d DBI:$driver:$prod_database_tns -u $user -p $password ";
}

say get_connect_string('user_schema_owner');
say $yaml->{tmp_dir};
