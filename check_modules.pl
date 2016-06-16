#!perl
use strict;
use warnings;
use feature qw(:5.12);

use ExtUtils::Installed;
use Module::CoreList;
use Module::Info;

my $inst  = ExtUtils::Installed->new();
my $count = 0;
my %modules;
foreach ( $inst->modules() ) {
    next if m/^[[:lower:]]/;    # skip pragmas
    next if $_ eq 'Perl';       # core modules aren't present in this list,
                                # instead coming under the name Perl
    my $version = $inst->version($_);
    $version = $version->stringify if ref $version; # version may be returned as
                                                    # a version object
    $modules{$_} = { name => $_, version => $version };
    $count++;
}
foreach ( Module::CoreList->find_modules() ) {
    next if m/^[[:lower:]]/;    # skip pragmas
    my $module = Module::Info->new_from_module($_) or next;
    $modules{$_} = { name => $_, version => $module->version // q(???) };
    $count++;
}
foreach ( sort keys %modules ) {
    say "$_ v$modules{$_}{version}";
}
say "\nModules: $count";
__END__

