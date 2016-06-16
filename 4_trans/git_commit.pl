#!/usr/bin/perl

=head1 NAME

git_commit.pl - commit with git but using more useful date format

=head1 SYNOPSIS

    perl git_commit.pl [OPTION]... 

    -v, --verbose  use verbose mode
    --help         print this help message

    --date         date in 'dd.mm.yyyy' format
    -m            message for commit

Examples:

    perl git_commit.pl --date '15.05.2015' -m 'Hi YAPC Russia 2015'

=head1 DESCRIPTION

This program need to full holes on github history.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

=over 1

=item * Nikolay Mishin (L<MISHIN|https://metacpan.org/author/MISHIN>)

=back

=cut

use strict;
use warnings;
use 5.010;
use utf8;
use open qw/:std :utf8/;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;

use Regexp::Common qw(time);
use DateTime;
use DateTime::Format::Strptime;
use Git::Repository;
use FindBin '$RealBin';

exit main();

sub main {

    # Argument parsing
    my ( $verbose, $date, $message, $test );
    GetOptions(
        'verbose' => \$verbose,
        'date=s'  => \$date,
        'm=s'     => \$message,
        'test'    => \$test,
    ) or pod2usage(1);
    if ( !defined $date || !defined $message ) {
        pod2usage(1);
    }

    git_commit( $message, prepare_day($date), $test );

    return 0;
}

sub prepare_day {
    my ($date) = @_;
    my ( $day, $month, $year );
    if ( $date =~ $RE{time}{dmy}{-keep} ) {
        $day   = $2;
        $month = $3;
        $year  = $4;
    }

    my $dt = DateTime->now( time_zone => 'Europe/Moscow' );
    $dt->set_year($year);
    $dt->set_month($month);
    $dt->set_day($day);

    #'Fri Jul 26 19:34:15 2013 +0200';
    my $pattern = '%a %b %d %H:%M %Y %z';
    my $formatter = DateTime::Format::Strptime->new( pattern => $pattern );
    $dt->set_formatter($formatter);
    return $dt->_stringify();
}

sub git_commit {
    my ( $message, $commit_day, $test ) = @_;
    my $r = Git::Repository->new( work_tree => $RealBin );
    if ( defined $test ) {
        say "git commit --date '$commit_day' -m '$message'";
    }
    else {
        $r->run( commit => '-m', $message, "--date=$commit_day" );
    }
}
