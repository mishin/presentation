#!/usr/bin/perl                                                                                       
use strict;
use warnings;
use Coro;
use Coro::LWP;
use LWP::UserAgent;
use URI;
use File::Spec;
use Digest::MD5 qw( md5_hex );
use Image::JpegCheck;

my $target_url = $ARGV[0]  || 'http://pinkimg.blog57.fc2.com/blog-entry-2044.html';
my $uri = URI->new($target_url);
my $ua  = LWP::UserAgent->new( show_progress => 1 );
my $res = $ua->get($uri);
die $res->status_line if $res->is_error;
my $html = $res->content;

my @imgs = $html =~ m!<a.*?href="(.+?\.jpg)"!g;
@imgs = $html =~ m!<img.*?src="(.+?\.jpg)"!g unless scalar @imgs > 10;

my @coros;
for my $img (@imgs) {
    push @coros, async {
        $res = $ua->get($img);
        return if $res->is_error;
        my $content_length = $res->header('Content-Length') or return;
        return unless $content_length > 10000; #XXX                                                   
        return unless is_jpeg( \$res->content );
        my $filename =
          File::Spec->catfile( "./images/", md5_hex($img) . '.jpg' );
        open my $fh, '>', $filename or die $!;
        print $fh $res->content;
        warn "Save: $img\n";
    };
}

$_->join for @coros;
