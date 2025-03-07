#!/usr/bin/perl -w

use strict;
use warnings;
use lib ("$ENV{GEMC}/api/perl");
use cad;
use utils;
use parameters;
use geometry;
use hit;
use bank;
use math;
use Math::Trig;
use materials;
use mirrors;
use lib ("../");
use clas12_configuration_string;


our $startS = 1;
our $endS = 6;
our $startN = 1;
our $endN = 18;


# Help Message
sub help() {
    print "\n Usage: \n";
    print "   htcc.pl <configuration filename>\n";
    print "   Will create the CLAS12 LTCC geometry, materials, bank and hit definitions\n";
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
our %parameters = get_parameters(%configuration);


# import scripts
require "./materials.pl";
require "./bank.pl";
require "./hit.pl";
require "./ltccBox.pl";     # mother volume
require "./ltcc_frame.pl";  # frame
require "./cyl_mirrors.pl"; # cyl mirrors
require "./hyp_mirrors.pl"; # hyp mirrors
require "./ell_mirrors.pl"; # ell mirrors
require "./pmts.pl";        # pmts
require "./cones.pl";       # cones
require "./shields.pl";     # shields
require "./mirrors.pl";     # mirrors properties


# subroutines create_system with arguments (variation, run number)
sub create_system {
    my $variation = shift;
    my $runNumber = shift;


    materials();            # materials
    define_hit();           # hits
    build_ltcc_box();       # Building LTCC Box
    buildLtccFrame();       # frame
    buildCylMirrors();      # Cylindrical mirrors
    buildHypMirrors();      # Hyperbolic mirrors
    buildEllMirrors();      # Elliptical mirrors
    buildPmts();            # PMTs
    buildCones();           # Cones
    buildShields();         # Shields
    buildMirrorsSurfaces(); # mirrors surfaces

}

# sectors 1 2 3 4 5 6 presence
our @rga_spring2018_sectorsPresence = (0, 1, 1, 0, 1, 1);
our @rga_spring2018_materials = ("na", "N2", "N2", "na", "C4F10", "N2");

our @rga_fall2018_sectorsPresence = (0, 0, 1, 0, 1, 0);
our @rga_fall2018_materials = ("na", "na", "C4F10", "na", "N2", "na");

our @rgb_spring2019_sectorsPresence = (0, 0, 1, 0, 1, 0);
our @rgb_spring2019_materials = ("na", "na", "C4F10", "na", "C4F10", "na");

our @rgb_winter2020_sectorsPresence = (0, 0, 1, 0, 1, 0);
our @rgb_winter2020_materials = ("na", "na", "C4F10", "na", "C4F10", "na");

our @rgm_winter2021_sectorsPresence = (0, 1, 1, 0, 1, 1);
our @rgm_winter2021_materials = ("na", "N2", "N2", "na", "N2", "N2");

my @variations = ("default", "rga_spring2018", "rga_fall2018",  "rgb_spring2019", "rgb_winter2020", "rgm_winter2021");
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
my $variation = "default";
foreach my $run (@runs) {
    $configuration{"variation"} = $variation;
    $configuration{"run_number"} = $run;
    create_system($variation, $run);
}

# port gxml to sqlite
require "../gxml_to_sqlite.pl";

foreach my $variation (@variations) {
    $configuration{"run_number"} = clas12_run($variation);
    process_gxml("cad/cad_$variation.gxml", "experiments/clas12/ltcc/cad");
}
