perl -MCPAN -e "foreach (@ARGV) { CPAN::Shell->rematein('notest', 'install', $_) }" %1
