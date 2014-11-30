#!/usr/bin/perl
use warnings;
use strict;

use Modern::Perl;
use Test::More;
use Regexp::Common qw/URI/;


sub get_hostname {
    my $url = shift;
    die "Usage: get_hostname(\$url), $url must be correct"
	      if ($url !~  $RE{URI}{HTTP}{ -scheme => "https?" });

    my ($hostname);
    if ($url =~ $RE{URI}{HTTP}{-keep}{ -scheme => "https?" })
    {
        $hostname = $3;
    }

    return $hostname;
}

is (get_hostname('http://www.example.com:80/some/path?query'),'www.example.com','hostname correct');
is (get_hostname('https://www.example.com:80/some/path?query'),'www.example.com','hostname correct');
#try $RE{URI}{HTTP}{-keep};
done_testing 2;
