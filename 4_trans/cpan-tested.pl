#!/usr/bin/env perl
use 5.008;
use strict;
use utf8;
use warnings 'all';

use CPAN::DistnameInfo;
use Config;
use File::Spec;
use Getopt::Long;
use HTTP::Tiny;
use JSON::XS qw(decode_json);
use Pod::Usage qw(pod2usage);

our $VERSION = q(0.001);

# parse the options file
my $rcname = File::Spec->catfile($ENV{HOME}, q(.cpan-tested.conf));
if (open(my $rcfile, '<', $rcname)) {
    while (<$rcfile>) {
        s/\#.*$//x;
        s/^\s+//x;
        s/\s+$//x;
        next unless $_;
        my @pair = split /\s+/x, $_, 2;
        $pair[0] = q(--) . $pair[0];
        unshift @ARGV, @pair;
    }
    close $rcfile;
}

Getopt::Long::GetOptions(
    'h|help'        => \my $help,
    'b|blacklist=s' => \my @blacklist,
) or pod2usage();
pod2usage() if $help;

my $ua = HTTP::Tiny->new;

while (my $name = <>) {
    my $d = CPAN::DistnameInfo->new($name);
    my %prop = $d->properties;
    next unless $prop{dist};

    # do not update blacklisted modules
    next if grep { $prop{dist} =~ /^$_$/x } @blacklist;

    my $url = sprintf
        q(http://www.cpantesters.org/distro/%s/%s.json),
        substr($prop{dist}, 0, 1),
        $prop{dist};

    my $res = $ua->get($url);
    next unless $res->{success};

    my $json = eval { decode_json($res->{content}) };
    next if $@ or 'ARRAY' ne ref $json;

    for my $test (@{$json}) {
        next if
            $test->{status}         ne q(PASS)
            or $test->{version}     ne $prop{version}
            or $test->{perl}        ne $Config{version}     # "5.14.2"
            or $test->{platform}    ne $Config{archname}    # "x86_64-linux"
        ;

        print $name;
        last;
    }
}
