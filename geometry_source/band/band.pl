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
use lib ("../");
use clas12_configuration_string;

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

# subroutines create_system with arguments (variation, run number)
sub create_system {
    materials();
    define_hit();
    # BAND, frame, and lead shielding upstream of target
    # Hole in mother volume allows beampipe to fit through BAND
    build_bandMother();
}

# BAND geometry is run/variation independent: a single "default" variation and
# its run (11) are sufficient. The SQLITE factory resolves any later run to the
# latest row with run <= RUNNO, so the run-11 row serves every subsequent run.
my @variations = ("default");
my @runs = clas12_runs(@variations);

# TEXT Factory
$configuration{"factory"} = "TEXT";
define_bank();
my $runNumber = 11;
foreach my $variation (@variations) {
    $configuration{"variation"} = $variation;
    create_system($variation, $runNumber);
}

# SQLITE Factory
$configuration{"factory"} = "SQLITE";
define_bank();
foreach my $run (@runs) {
    $configuration{"variation"} = "default";
    $configuration{"run_number"} = $run;
    create_system("default", $run);
}
