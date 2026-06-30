#!/usr/bin/perl -w

use strict;
use warnings;
use lib ("$ENV{GEMC}/api/perl");
use utils;
use parameters;
use geometry;
use hit;
use bank;
use math;
use materials;
use Math::Trig;

# Help Message
sub help() {
    print "\n Usage: \n";
    print "   band.pl <configuration filename>\n";
    print "   Will create the CLAS12 BAND geometry, materials, bank and hit definitions\n";
    print "   Note: if the sqlite file does not exist, create one with:  \$GEMC/api/perl/sqlite.py -n ../../clas12.sqlite\n";
    exit;
}

# Make sure the argument list is correct
if (scalar @ARGV != 1) {
    help();
    exit;
}

# Loading configuration file and parameters
our %configuration = load_configuration($ARGV[0]);

# Global pars - these should be read by the load_parameters from file or DB

# General:
our $inches = 25.4;

# import scripts
require "./band_materials.pl";
require "./bank.pl";
require "./hit.pl";
require "./geometry.pl";

# subroutine create_system with argument (exists)
sub create_system {
    my $exist = shift;
    $exist = 1 unless defined $exist;

    materials();
    define_hit();

    # BAND, frame, and lead shielding upstream of target
    # Hole in mother volume allows beampipe to fit through BAND
    build_bandMother($exist);
}

# BAND uses only the default variation. The SQLITE factory resolves the latest row with
# run <= RUNNO, so each presence transition needs an explicit row.
my @band_run_states = (
    [11, 0],
    [6141, 1],
    [11572, 0],
    [14776, 1],
    [15885, 0],
    [18305, 1],
    [23066, 0],
);

# TEXT Factory
$configuration{"factory"} = "TEXT";
define_bank();
$configuration{"variation"} = "default";
$configuration{"run_number"} = 6141;
create_system(1);

# SQLITE Factory
$configuration{"factory"} = "SQLITE";
define_bank();
foreach my $run_state (@band_run_states) {
    my ($run, $exist) = @$run_state;

    $configuration{"variation"} = "default";
    $configuration{"run_number"} = $run;
    create_system($exist);
}
