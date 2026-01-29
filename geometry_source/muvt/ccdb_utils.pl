#!/usr/bin/env perl
use strict;
use warnings;
use DBI;

# Connect to CCDB (MySQL or SQLite) using CCDB_CONNECTION
sub connect_ccdb {
    my ($conn) = @_;
    my $dbh;

    if ($conn =~ m{^mysql://}) {
        my ($user, $host, $dbname) =
          $conn =~ m{^mysql://([^@]+)@([^/]+)/(.+)$}
            or die "Bad CCDB_CONNECTION (mysql): $conn\n";

        my $dsn  = "DBI:mysql:database=$dbname;host=$host;port=3306";
        my $pass = "";

        $dbh = DBI->connect($dsn, $user, $pass,
                            { RaiseError => 1, AutoCommit => 1 })
          or die "Cannot connect (mysql): $DBI::errstr\n";

    } elsif ($conn =~ m{^sqlite:}) {
        my ($file) = $conn =~ m{^sqlite:(.+)$}
          or die "Bad CCDB_CONNECTION (sqlite): $conn\n";

        $file =~ s{^/+}{/};
        my $dsn = "dbi:SQLite:dbname=$file";

        $dbh = DBI->connect($dsn, "", "",
                            { RaiseError => 1, AutoCommit => 1 })
          or die "Cannot connect (sqlite): $DBI::errstr\n";

    } else {
        die "Unsupported CCDB_CONNECTION: $conn\n";
    }

    return $dbh;
}

# Given "test/urwt2" returns its directory id
sub get_directory_id {
    my ($dbh, $dir_path) = @_;

    my @parts = split m{/}, $dir_path;
    my $parent_id;
    my $dir_id;

    for my $name (@parts) {
        if (defined $parent_id) {
            ($dir_id) = $dbh->selectrow_array(
                "SELECT id FROM directories WHERE name = ? AND parentId = ?",
                undef, $name, $parent_id
            );
        } else {
            ($dir_id) = $dbh->selectrow_array(
                "SELECT id FROM directories WHERE name = ? AND (parentId = 0 OR parentId IS NULL)",
                undef, $name
            );
        }
        die "Directory '$name' (path '$dir_path') not found\n"
          unless defined $dir_id;

        $parent_id = $dir_id;
    }

    return $parent_id;
}

# Generic: given a full CCDB path and variation,
# returns all rows (arrayref of arrayrefs).
sub read_ccdb_table {
    my ($dbh, $full_path, $variation) = @_;

    my $path = $full_path;
    $path =~ s{^/}{};

    my ($dir_path, $type_name) = $path =~ m{^(.*)/(.*)$}
      or die "Invalid CCDB path: $full_path\n";

    my $dir_id = get_directory_id($dbh, $dir_path);

    my ($type_id) = $dbh->selectrow_array(
        "SELECT id FROM typeTables WHERE name = ? AND directoryId = ?",
        undef, $type_name, $dir_id
    ) or die "Type '$type_name' not found under '$dir_path'\n";

    my ($ncols) = $dbh->selectrow_array(
        "SELECT COUNT(*) FROM columns WHERE typeId = ?",
        undef, $type_id
    );

    my ($var_id) = $dbh->selectrow_array(
        "SELECT id FROM variations WHERE name = ?",
        undef, $variation
    ) or die "Variation '$variation' not found\n";

    my ($vault) = $dbh->selectrow_array(<<'SQL', undef, $type_id, $var_id);
SELECT cs.vault
FROM constantSets cs
JOIN assignments a ON a.constantSetId = cs.id
WHERE cs.constantTypeId = ?
  AND a.variationId     = ?
LIMIT 1
SQL

    die "No constantSet for $full_path, variation=$variation\n"
      unless defined $vault;

    my @vals = split /\|/, $vault;
    my @rows;
    while (@vals) {
        push @rows, [ splice @vals, 0, $ncols ];
    }

    return \@rows;
}

1;  # important for "require"
