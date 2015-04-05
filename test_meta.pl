    #############################################
    # In your program
    use Modern::Perl;
    use Parse::CPAN::Meta;
    my $dir='/home/mishin/github/Perl-GD/';
    my $distmeta = Parse::CPAN::Meta->load_file($dir.'META.yml');
    
    # Reading properties
    my $name     = $distmeta->{name};
    my $version  = $distmeta->{version};
    my $repo = $distmeta->{x_repository}{url};
    my $repo = $distmeta->{resources}{repository};

say $name;
say $version;
say $repo;
