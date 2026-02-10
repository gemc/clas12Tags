#!/usr/bin/env perl
use strict;
use warnings;

use IPC::Open3;
use Symbol qw(gensym);

# ----------------------------------------------------------------------
# No-DBI CCDB utilities: use external mysql client and parse TSV output.
# ----------------------------------------------------------------------

# Connect to CCDB using CCDB_CONNECTION = mysql://user@host/dbname
# Returns a hashref with connection info (NOT a DB handle).
sub connect_ccdb {
    my ($conn) = @_;
    die "CCDB_CONNECTION not provided\n" unless defined $conn && length $conn;

    if ($conn =~ m{^mysql://}) {
        my ($user, $host, $dbname) =
          $conn =~ m{^mysql://([^@]+)@([^/]+)/(.+)$}
            or die "Bad CCDB_CONNECTION (mysql): $conn\n";

        my $mysql = _find_mysql_client();

        return {
            kind   => 'mysql-cli',
            conn   => $conn,
            user   => $user,
            host   => $host,
            dbname => $dbname,
            port   => 3306,
            mysql  => $mysql,
        };
    }

    die "Unsupported CCDB_CONNECTION (this no-DBI version supports only mysql://...): $conn\n";
}

# --------- Internal helpers (mysql-cli) --------------------------------

sub _find_mysql_client {
    # Prefer the Homebrew mysql client you already have.
    for my $candidate (
        $ENV{MYSQL_CLIENT},
        "/opt/homebrew/opt/mysql-client@8.4/bin/mysql",
        "/opt/homebrew/bin/mysql",
        "mysql",
    ) {
        next unless defined $candidate && length $candidate;

        # If it's an absolute path, test it directly.
        if ($candidate =~ m{^/} && -x $candidate) {
            return $candidate;
        }

        # Otherwise, rely on PATH.
        my $which = `command -v $candidate 2>/dev/null`;
        chomp $which;
        return $which if $which && -x $which;
    }

    die "Cannot find mysql client binary. Set MYSQL_CLIENT=/path/to/mysql or ensure 'mysql' is in PATH.\n";
}

sub _sql_quote {
    my ($v) = @_;
    return "NULL" if !defined $v;

    # If it's a plain number, keep as-is
    if ($v =~ /\A[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?\z/) {
        return $v;
    }

    # Otherwise single-quote with escaping
    $v =~ s/\\/\\\\/g;
    $v =~ s/'/\\'/g;
    return "'" . $v . "'";
}

sub _bind_sql {
    my ($sql, @bind) = @_;
    my $i = 0;
    $sql =~ s/\?/
        die "Too few bind values for SQL: $sql\n" if $i > $#bind;
        _sql_quote($bind[$i++])
    /ge;

    die "Too many bind values for SQL: $sql\n" if $i <= $#bind;
    return $sql;
}

# Run mysql, return stdout as string, die on error with stderr.
sub _mysql_exec {
    my ($cc, $sql) = @_;
    die "Not a mysql-cli connection\n" unless $cc && $cc->{kind} && $cc->{kind} eq 'mysql-cli';

    my @cmd = (
        $cc->{mysql},
        "-h", $cc->{host},
        "-P", $cc->{port},
        "-u", $cc->{user},
        "-D", $cc->{dbname},
        "--protocol=TCP",
        "-N",        # no column names
        "-B",        # batch mode (TSV)
        "--raw",     # don't escape tabs/newlines
        "-e", $sql,
    );

    my $err = gensym;
    my $pid = open3(undef, my $out, $err, @cmd);

    local $/;
    my $stdout = <$out> // '';
    my $stderr = <$err> // '';

    waitpid($pid, 0);
    my $exit = $? >> 8;

    if ($exit != 0) {
        die "mysql command failed (exit=$exit)\nSQL: $sql\nERR:\n$stderr\n";
    }

    return $stdout;
}

# Like DBI->selectrow_array: returns list of columns from first row.
sub _selectrow_array {
    my ($cc, $sql, @bind) = @_;
    $sql = _bind_sql($sql, @bind);

    my $out = _mysql_exec($cc, $sql);
    return () unless defined $out && length $out;

    # First non-empty line
    for my $line (split /\n/, $out) {
        next if $line =~ /\A\s*\z/;
        chomp $line;
        return split /\t/, $line, -1;
    }
    return ();
}

# Like DBI->selectall_arrayref: returns arrayref of arrayrefs (rows).
sub _selectall_arrayref {
    my ($cc, $sql, @bind) = @_;
    $sql = _bind_sql($sql, @bind);

    my $out = _mysql_exec($cc, $sql);
    my @rows;

    for my $line (split /\n/, $out) {
        next if $line =~ /\A\s*\z/;
        chomp $line;
        push @rows, [ split /\t/, $line, -1 ];
    }
    return \@rows;
}

# ----------------------------------------------------------------------
# Given "test/urwt2" returns its directory id
sub get_directory_id {
    my ($cc, $dir_path) = @_;

    my @parts = split m{/}, $dir_path;
    my $parent_id;
    my $dir_id;

    for my $name (@parts) {
        if (defined $parent_id) {
            ($dir_id) = _selectrow_array(
                $cc,
                "SELECT id FROM directories WHERE name = ? AND parentId = ?",
                $name, $parent_id
            );
        } else {
            ($dir_id) = _selectrow_array(
                $cc,
                "SELECT id FROM directories WHERE name = ? AND (parentId = 0 OR parentId IS NULL)",
                $name
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
    my ($cc, $full_path, $variation) = @_;

    my $path = $full_path;
    $path =~ s{^/}{};

    my ($dir_path, $type_name) = $path =~ m{^(.*)/(.*)$}
      or die "Invalid CCDB path: $full_path\n";

    my $dir_id = get_directory_id($cc, $dir_path);

    my ($type_id) = _selectrow_array(
        $cc,
        "SELECT id FROM typeTables WHERE name = ? AND directoryId = ?",
        $type_name, $dir_id
    );
    die "Type '$type_name' not found under '$dir_path'\n"
      unless defined $type_id;

    my ($ncols) = _selectrow_array(
        $cc,
        "SELECT COUNT(*) FROM columns WHERE typeId = ?",
        $type_id
    );
    die "Could not determine number of columns for typeId=$type_id\n"
      unless defined $ncols;

    my ($var_id) = _selectrow_array(
        $cc,
        "SELECT id FROM variations WHERE name = ?",
        $variation
    );
    die "Variation '$variation' not found\n"
      unless defined $var_id;

    my ($vault) = _selectrow_array($cc, qq{
        SELECT cs.vault
        FROM constantSets cs
        JOIN assignments a ON a.constantSetId = cs.id
        WHERE cs.constantTypeId = ?
          AND a.variationId     = ?
        LIMIT 1
    }, $type_id, $var_id);

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
