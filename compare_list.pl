#!/usr/bin/perl
use strict;
use warnings;
use v5.14;    # subwarnings unavailable any earlier

use utf8;
use Modern::Perl;
use Array::Utils qw(:all);
use Data::Dumper qw( Dumper );
use Text::CSV;

main();

sub main {

    my $dev_list_file  = 'list_dev.txt';
    my $sert_list_file = '20150806_FLAGS.FLAGS_LIST.txt';
    my $dev_data       = get_csv_data($dev_list_file);
    my $sert_data      = get_csv_data($sert_list_file);

    my $dev_id  = get_flag_id($dev_data);
    my $sert_id = get_flag_id($sert_data);

    my @minus = array_minus(@$dev_id, @$sert_id);
    make_insert($dev_data, \@minus);
    my @minus_sert = array_minus(@$sert_id, @$dev_id);
}

sub make_insert {
    my ($dev_list, $delta) = @_;
    for my $id (@$delta) {
        my $rec = get_rec_by_id($dev_list, $id);
        printf
          q{INSERT INTO FLAGS.FLAGS_LIST (FLAG_ID, FLAG_NAME, SRC_STM_ID, DST_ID, FLAG_GROUP_ID, FLAG_DSC, FLAG_ALT_DSC) 
 VALUES (%s, '%s', %s, %s, %s, %s,  %s);}, @$rec[0 .. 6];
        say '';
    }
}

sub get_rec_by_id {
    my ($dev_list, $id) = @_;
    my $ret_rec = '';
    for my $rec (@$dev_list) {
        if ($rec->[0] eq $id) {
            $ret_rec = $rec;
        }
    }
    return $ret_rec;
}

sub get_csv_data {
    my ($file) = @_;
    my $csv = Text::CSV->new(
        {   binary    => 1,
            auto_diag => 1,
            sep_char  => '\s+',    # not really needed as this is the default
            allow_whitespace => 1
        }
    );

    my $sum    = 0;
    my @result = ();
    open(my $data, '<:encoding(utf8)', $file)
      or die "Could not open '$file' $!\n";
    while (my $fields = $csv->getline($data)) {
        my @field = split /\s+/, "@{$fields}";

        if (   defined $field[0]
            && $field[0] ne 'FLAG_ID'
            && $field[0] ne '-------')
        {
            push @result, \@field;
        }
    }
    if (not $csv->eof) {
        $csv->error_diag();
    }
    close $data;
    return \@result;
}


sub get_flag_id {
    my ($data) = @_;
    my @id_arr = ();
    for my $id (@$data) {
        push @id_arr, $id->[0];
    }
    return \@id_arr;
}
