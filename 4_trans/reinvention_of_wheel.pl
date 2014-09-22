
sub read_file {
    my ($filename) = @_;
    my $content;
    open( my $fh, '<', $filename ) or die "cannot open file $filename";
    {
        local $/;
        $content = <$fh>;
    }
    close($fh);
    return $content;
}

#export get_files select_files
sub select_files {
    my ( $regex, $ar_ref ) = @_;
    my @path  = @{$ar_ref};
    my @files = ();
    if ( $regex =~ /qr\/(.*)\//sm ) {
        @files = File::Find::Rule->file()->maxdepth(1)->name(qr/$1/)->in(@path);
    }
    else {
        @files = File::Find::Rule->file()->maxdepth(1)->name($regex)->in(@path);
    }
    return \@files;
}
