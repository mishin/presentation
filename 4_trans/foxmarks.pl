#! /usr/bin/env perl
# -*- coding: utf-8; indent-tabs-mode: nil; tab-width: 4; c-basic-offset: 4; -*-
# vim:fileencodings=utf-8:expandtab:tabstop=4:shiftwidth=4:softtabstop=4

use 5.010;
#use diagnostics;
use strict;
use warnings;

use DBI;

my $debug = $ENV{'DEBUG'} // 0;

sub folders_by_title {
    my $dbh = shift;
    my $title = shift;

    my $sth = $dbh->prepare("SELECT id FROM moz_bookmarks WHERE type = 2 AND title = '$title'");
    $sth->execute();

    my @id = ();
    my $id;
    $sth->bind_columns( \$id );

    while ($sth->fetch()) {
        push @id, $id;
    }

    $sth->finish();

    @id;
}

sub bookmarks_by_parent {
    my $dbh = shift;
    my $id = shift;

    my $sth = $dbh->prepare("SELECT title, fk FROM moz_bookmarks WHERE type = 1 AND parent = $id");
    $sth->execute();

    my %fk = ();
    my ($title, $fk);
    $sth->bind_columns( \$title, \$fk );
    while ($sth->fetch()) {
        $fk{$fk} = $title;
    }
    $sth->finish();

    %fk;
}

sub url_by_fk {
    my $dbh = shift;
    my $fk = shift;

    my $sth = $dbh->prepare("SELECT url FROM moz_places WHERE id = $fk");
    $sth->execute();

    my $url;
    $sth->bind_columns( \$url );
    $sth->fetch();
    $sth->finish();

    $url;
}

sub folders_in_menu {
    my $dbh = shift;

    my @titles;
    my $title;
    my $sth = $dbh->prepare("SELECT title FROM moz_bookmarks WHERE type = 2 AND parent = 2 ORDER BY position");
    $sth->execute();
    $sth->bind_columns( \$title );
    while ($sth->fetch()) {
        push @titles, $title;
    }
    $sth->finish();

    @titles;
}

sub folders_in_toolbar {
    my $dbh = shift;

    my @titles;
    my $title;
    my $sth = $dbh->prepare("SELECT title FROM moz_bookmarks WHERE type = 2 AND parent = 3 ORDER BY position");
    $sth->execute();
    $sth->bind_columns( \$title );
    while ($sth->fetch()) {
        push @titles, $title;
    }
    $sth->finish();

    @titles;
}

sub fetch_from_dump {
    my @folders = ();
    my $record = undef;
    while (<STDIN>) {
        chomp;
        if (/^(menu|toolbar)\t(.*)$/) {
            $record = {
                NAME => $2,
                TYPE => $1,
                LIST => [],
            };
        } elsif (/^(.*)\t(.*)$/) {
            my %item = (
                TITLE => $1,
                URL => $2,
            );
            push @{$record->{LIST}}, \%item;
        } else {
            push @folders, $record;
            $record = undef;
        }
    }
    @folders;
}

sub dump_by_folder {
    my $file = shift;
    my $dbh = DBI->connect("dbi:SQLite:dbname=$file","","");

    my @titles = folders_in_menu($dbh);

    foreach (@titles) {
        say "menu\t$_";
        my @id = folders_by_title($dbh, $_);

        if (@id) {
            my %bk = bookmarks_by_parent($dbh, $id[0]);
            foreach (sort { $a <=> $b } keys %bk) {
                my $url = url_by_fk($dbh, $_);
                say "$bk{$_}\t$url";
            }
        }
        print "\n";;
    }

    @titles = folders_in_toolbar($dbh);

    foreach (@titles) {
        next if /Latest Headlines/;
        say "toolbar\t$_";
        my @id = folders_by_title($dbh, $_);

        if (@id) {
            my %bk = bookmarks_by_parent($dbh, $id[0]);
            foreach (sort { $a <=> $b } keys %bk) {
                my $url = url_by_fk($dbh, $_);
                say "$bk{$_}\t$url";
            }
        }
        print "\n";;
    }

    $dbh->disconnect();
}

sub debug_data {
    my @folders = @_;
    foreach (@folders) {
        say "$_->{TYPE}\t$_->{NAME}";
        foreach (@{$_->{LIST}}) {
            say "\t$_->{TITLE}\t$_->{URL}";
        }
    }
}

sub process_folder {
    my ($dbh, $name, $type) = @_;
    my $sth;
    my $parent = $type ~~ /menu/ ? 2 : 3; # menu or toolbar
    my $id;

    # Find the id of specified folder.
    $sth = $dbh->prepare("SELECT id FROM moz_bookmarks WHERE type = 2 AND parent = $parent AND title = '$name'");
    $sth->execute();
    $sth->bind_columns( \$id );
    $sth->fetch();
    $sth->finish();

    # If not found, create it.
    if (!$id) {
        my $pos;

        # Find the position of lastest folder.
        $sth = $dbh->prepare("SELECT position FROM moz_bookmarks WHERE type = 2 AND parent = $parent ORDER BY position DESC");
        $sth->execute();
        $sth->bind_columns( \$pos );
        $sth->fetch();
        $sth->finish();

        # Create folder by increased position.
        $pos++;
        my $time = time * 1000000;
        my $sql = qq{ INSERT INTO moz_bookmarks (type, parent, position, title, folder_type, dateAdded, lastModified) VALUES (2, $parent, $pos, '$name', '', $time, $time) };
        $sth = $dbh->prepare( $sql );
        $sth->execute();
        $dbh->commit();
        $sth->finish();

        # Find the id of specified folder.
        $sth = $dbh->prepare("SELECT id FROM moz_bookmarks WHERE type = 2 AND parent = $parent AND title = '$name'");
        $sth->execute();
        $sth->bind_columns( \$id );
        $sth->fetch();
        $sth->finish();
    }

    $id;
}

sub process_bookmark {
    my ($dbh, $title, $url, $parent) = @_;

    # Get fk from bookmark entry.
    my ($fk, $sth, @fk);
    my $sql = qq{ SELECT fk FROM moz_bookmarks WHERE type = 1 AND parent = $parent AND title = '$title' };
    $sth = $dbh->prepare( $sql );
    $sth->execute();
    $sth->bind_columns( \$fk );
    while ($sth->fetch()) {
        push @fk, $fk;
    }
    $sth->finish();

    # Check if bookmark exists.
    my $found = 0;
    foreach (@fk) {
        my $link;
        my $sql = qq{ SELECT url FROM moz_places WHERE id = $_ };
        $sth = $dbh->prepare( $sql );
        $sth->execute();
        $sth->bind_columns( \$link );
        $sth->fetch();
        $sth->finish();

        if ($url eq $link) {
            $found = 1;
            last;
        }
    }

    return if $found;

    # Find fk
    $sql = qq{ SELECT id FROM moz_places WHERE url = '$url' };
    $sth = $dbh->prepare( $sql );
    $sth->execute();
    $sth->bind_columns( \$fk );
    $sth->fetch();
    $sth->finish();

    # Create a new bookmark item in moz_places.
    if (!$fk) {
        $sql = qq{ INSERT INTO moz_places (url, title, frecency) VALUES ('$url', '$title', 0) };
        $sth = $dbh->prepare( $sql );
        $sth->execute();
        $dbh->commit();
        $sth->finish();

        # Get fk
        $sql = qq{ SELECT id FROM moz_places WHERE url = '$url' };
        $sth = $dbh->prepare( $sql );
        $sth->execute();
        $sth->bind_columns( \$fk );
        $sth->fetch();
        $sth->finish();
    }

    # Find the latest position under the same folder.
    my $pos = 0;
    $sql = qq{ SELECT position FROM moz_bookmarks WHERE type = 1 AND parent = $parent ORDER BY position DESC };
    $sth = $dbh->prepare( $sql );
    $sth->execute();
    $sth->bind_columns( \$pos );
    $pos++ if $sth->fetch();
    $sth->finish();

    # Create a new bookmark entry in moz_bookmarks.
    my $time = time * 1000000;
    $sql = qq{ INSERT INTO moz_bookmarks (type, fk, parent, position, title, dateAdded, lastModified) VALUES (1, $fk, $parent, $pos, '$title', $time, $time) };
    $sth = $dbh->prepare( $sql );
    $sth->execute();
    $dbh->commit();
    $sth->finish();
}

sub restore_folder {
    my $dbh = shift;
    my $ref = shift;
    my $id = process_folder($dbh, $ref->{NAME}, $ref->{TYPE});

    foreach (@{$ref->{LIST}}) {
        process_bookmark($dbh, $_->{TITLE}, $_->{URL}, $id);
    }
}

sub restore_bookmarks {
    my ($file, @folders) = @_;
    my $dbh = DBI->connect("dbi:SQLite:dbname=$file","","");
    debug_data(@folders) if $debug;
    foreach (@folders) {
        restore_folder($dbh, $_);
    }
    $dbh->disconnect();
}

sub usage {
    say "Firefox Bookmarks dump/restore script.\n";
    say "Usage:";
    say "\t$0 dump places.sqlite > bookmarks.bak";
    say "\t$0 restore places.sqlite < bookmarks.bak";
    exit;
}

unless (@ARGV) {
    usage();
}

given ($ARGV[0]) {
    when (/dump/) {
        (defined $ARGV[1] and -r $ARGV[1]) or usage();
        dump_by_folder($ARGV[1]);
    }
    when (/restore/) {
        (defined $ARGV[1] and -r $ARGV[1]) or usage();
        my @folders = fetch_from_dump();
        restore_bookmarks($ARGV[1], @folders);
    }
    default {
        usage();
    }
}

1;
