#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;
use Cache::Memcached;
use DBI;
use Getopt::Long;
use YAML::Syck;

my %options = (
    'show!'         => \(my $show = 0),
    'create!'       => \(my $create = 0),
    'update!'       => \(my $update = 0),
    'delete!'       => \(my $delete = 0),

    'client=s'      => \(my $client),
    'like!'         => \(my $like),

    'info=s'        => \(my $info),

    'help!'         => \(my $help),

    'db=s'          => \(my $database_host = 'localhost'),
    'memcached=s'   => \(my $memcached = 'localhost:11211'),

    'backend-id=s'  => \(my $backend_id),
    'class=s'       => \(my $special_class),
    'trust=f'       => \(my $trust),
    'mutable!'      => \(my $trust_mutable),
    'enabled!'      => \(my $enabled),
    'may-query!'    => \(my $may_query),
    'train-spam!'   => \(my $may_train_spam),
    'train-ham!'    => \(my $may_train_ham),
    'follow!'       => \(my $may_follow_link),
    'confidence!'   => \(my $send_confidence),
    'last-ip=s'     => \(my $last_ip),

    'trusted!'      => \(my $trusted),
    'bless!'        => \(my $bless),
    'enable!'       => \(my $enable),
    'disable!'      => \(my $disable),
);

GetOptions(%options);

my $database_port       = 3306;
my $database_name       = 'serotype';
my $database_user       = 'serotype';
my $database_password   = '';
my $dsn                 = "DBI:mysql:database=$database_name;host=$database_host;$database_port";

my $dbh = DBI->connect($dsn, $database_user, $database_password, {RaiseError => 1});

$client = shift @ARGV if !defined $client && @ARGV;

if ($help) {
    my $me = basename($0);
    print <<END_HELP;
Usage: $me <--show|--create|--update|--delete> [options] <apikey>
Options:
  --client=<client>
      Looks up API key in known-client alias database; negates need to specify apikey.
  --db=<host>
      Specifies Serotype client database host to query.
  --memcached=<hosts>
      Comma-separated list of memcached hosts to use.
  --info=<string>
      Sets the free-text info record for the key.
  --like
      Instead of requiring exact match to API key/info string, use SQL's LIKE to search.
  --backend-id=<string>
  --class=<string>
  --trust=<0.0-1.0>
  --[no-]mutable
  --[no-]enabled
  --[no-]may-query
  --[no-]train-spam
  --[no-]train-ham
  --[no-]follow
  --[no-]confidence
  --last-ip=<string>
      Specify the value to set for the corresponding field when using --create or --update.
  --trusted, --bless
      Shorthand for --trust=1 --no-mutable.
END_HELP
    exit;
}

die "client info/key required" unless defined $client;

$trusted ||= $bless;

if (
    (
        defined $info ||
        defined $backend_id ||
        defined $special_class ||
        defined $trust ||
        defined $trust_mutable ||
        defined $enabled ||
        defined $may_query ||
        defined $may_train_spam ||
        defined $may_train_ham ||
        defined $may_follow_link ||
        defined $send_confidence ||
        defined $last_ip ||
        defined $trusted ||
        defined $enable ||
        defined $disable
    ) &&
    !$create &&
    !$update &&
    !$delete
) {
    warn "Note: parameter modification requested; assuming --update\n";
    $update = 1;
}

$show = 1 unless $create || $update || $delete;

die "exactly one of --show, --create, --update, --delete must be supplied\n"
    if $show+$create+$update+$delete != 1;

my $special_class_id;
if (defined $special_class) {
    my $ref = $dbh->selectrow_arrayref("SELECT special_class_id FROM special_class WHERE name=?", undef, $special_class);
    if ($ref && @$ref) {
        $special_class_id = $ref->[0];
    }
    else {
        die "couldn't find id for special class $special_class\n";
    }
}

if ($trusted) {
    $trust = 1;
    $trust_mutable = 0;
    $send_confidence = 1;
}

$enabled =   $enable if defined $enable;
$enabled = !$disable if defined $disable;

my $matcher = $like ? 'LIKE' : '=';
$client = '%' . $client . '%' if $like;

my ($exists) = @{ $dbh->selectrow_arrayref("SELECT COUNT(*) FROM client_dim WHERE api_key $matcher ?", undef, $client) };

my $api_key;
if ($exists) {
    $api_key = $client;
}
else {
    # try to pull by info record
    my $ref = $dbh->selectrow_arrayref("
        SELECT  api_key
        FROM    client_dim
        JOIN    client_info
        USING   (client_dim_id)
        WHERE   info $matcher ?
        ",
        undef,
        $client
    );
    if ($ref && @$ref) {
        $api_key = $ref->[0];
        $exists = 1;
        warn "Note: key $api_key matched client spec '$client'\n";
    }
}

if ($create || ($update && !$exists)) {
    $api_key = $client;

    if (!defined $backend_id) {
        my @backend_id_alphabet = 'a'..'z';
        my $backend_id_length = 30;
        my $backend_id_namespace = 's_';
        $backend_id = join '',
            $backend_id_namespace,
            map { @backend_id_alphabet[rand @backend_id_alphabet] } 1 .. $backend_id_length;
    }

    $trust              = 0.001 if !defined $trust;
    $trust_mutable      = 1 if !defined $trust_mutable;
    $enabled            = 1 if !defined $enabled;
    $may_query          = 1 if !defined $may_query;
    $may_train_spam     = 1 if !defined $may_train_spam;
    $may_train_ham      = 1 if !defined $may_train_ham;
    $may_follow_link    = 0 if !defined $may_follow_link;
    $send_confidence    = 0 if !defined $send_confidence;

    $dbh->do('
        INSERT
        INTO    client_dim

                (
                    backend_id,
                    api_key,
                    special_class_id,
                    trust,
                    trust_mutable,
                    enabled,
                    may_query,
                    may_train_spam,
                    may_train_ham,
                    may_follow_link,
                    send_confidence,
                    num_queries,
                    num_spam,
                    num_ham,
                    first_contact,
                    last_contact,
                    last_ip
                )

        VALUES  (
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    ?,
                    0,
                    0,
                    0,
                    NOW(),
                    NOW(),
                    ?
                )
        ',
        undef,
        $backend_id,
        $api_key,
        $special_class_id,
        $trust,
        $trust_mutable,
        $enabled,
        $may_query,
        $may_train_spam,
        $may_train_ham,
        $may_follow_link,
        $send_confidence,
        $last_ip,
    );

    if ($info) {
        my ($id) = @{ $dbh->selectrow_arrayref('SELECT last_insert_id()') };

        $dbh->do('
            INSERT
            INTO    client_info
                    (client_dim_id, info)
            VALUES  (?, ?)
            ',
            undef,
            $id,
            $info
        );
    }
}
elsif ($update) {
    my %updates;

    $updates{backend_id}        = $backend_id           if defined $backend_id;
    $updates{special_class_id}  = $special_class_id     if defined $special_class_id;
    $updates{trust}             = $trust                if defined $trust;
    $updates{trust_mutable}     = $trust_mutable        if defined $trust_mutable;
    $updates{enabled}           = $enabled              if defined $enabled;
    $updates{may_query}         = $may_query            if defined $may_query;
    $updates{may_train_ham}     = $may_train_ham        if defined $may_train_ham;
    $updates{may_train_spam}    = $may_train_spam       if defined $may_train_spam;
    $updates{may_follow_link}   = $may_follow_link      if defined $may_follow_link;
    $updates{send_confidence}   = $send_confidence      if defined $send_confidence;
    $updates{last_ip}           = $last_ip              if defined $last_ip;

    die "update requested but no values changed" unless %updates || $info;

    my $sql = sprintf 'UPDATE client_dim SET %s WHERE api_key=?',
        join ',', map {"$_=?"} keys %updates;

    $dbh->do($sql, undef, values %updates, $api_key) if %updates;

    if ($info) {
        my ($id) = @{ $dbh->selectrow_arrayref('SELECT client_dim_id FROM client_dim WHERE api_key=?', undef, $api_key) };

        $dbh->do('
            REPLACE
            INTO    client_info
                    (client_dim_id, info)
            VALUES  (?, ?)
            ',
            undef,
            $id,
            $info
        );
    }
}
elsif ($delete) {
    $dbh->do('DELETE FROM client_dim WHERE api_key=?', undef, $api_key);
}

if (defined $api_key) {
    # invalidate memcache
    my $memcache = Cache::Memcached->new({'servers' => [split /,/, $memcached]});
    my $mc_key = "serotype:keydata:$api_key";
    $memcache->delete($mc_key);
}

my $new = $dbh->selectrow_hashref('SELECT * FROM client_dim WHERE api_key=?', undef, $api_key);

my $info_ref = $dbh->selectrow_arrayref('
    SELECT  info
    FROM    client_info
    WHERE   client_dim_id = ?
    ',
    undef,
    $new->{client_dim_id}
);
if ($info_ref && @$info_ref) {
    $new->{info} = $info_ref->[0];
}

print Dump($new);