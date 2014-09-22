
sub _get_raw_tests {
    my $self    = shift;
    my $recurse = shift;
    my @argv    = @_;
    my @tests;

    # Do globbing on Win32.
    @argv = map { glob "$_" } @argv if NEED_GLOB;
    my $extensions = $self->{extensions};

    for my $arg (@argv) {
        if ( '-' eq $arg ) {
            push @argv => <STDIN>;
            chomp(@argv);
            next;
        }

        push @tests,
            sort -d $arg
          ? $recurse
              ? $self->_expand_dir_recursive( $arg, $extensions )
              : map { glob( File::Spec->catfile( $arg, "*$_" ) ) } @{$extensions}
          : $arg;
    }
    return @tests;
}

sub _expand_dir_recursive {
    my ( $self, $dir, $extensions ) = @_;
"/rwa/data/team/MISHNIK/perl/utils/lib/App/Prove/State.pm" line 357 of 518 --68%--
