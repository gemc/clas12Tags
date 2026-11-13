#!/usr/bin/perl -w

use strict;
use warnings;
use FindBin;
use lib "$FindBin::RealBin/../../api/perl";
use utils;
use parameters;
use geometry;
use materials;
use Math::Trig;
use lib ("../");
use clas12_configuration_string;

# Help Message
sub help() {
    print "\n Usage: \n";
    print "   magnets.pl \n";
    print "   Will create the CLAS12 Torus and Solenoid geometry\n";
    print "   Note: if the sqlite file does not exist, create one with:  ../../api/perl/sqlite.py -n ../../clas12.sqlite\n";
    exit;
}

# Make sure the argument list is correct
if (scalar @ARGV != 0 && scalar @ARGV != 1) {
    help();
    exit;
}

# Loading configuration file and parameters
our %configuration = load_configuration($ARGV[0]);


require "./solenoid.pl";
require "./torus.pl";
require "./materials.pl";
require "./cad_copies.pl";

# Remove obsolete banks from previous geometry generations.
unlink glob('solenoid__*.txt'), glob('magnets_copies__*.txt');
my $dbh = open_db(%configuration);
for my $table ('geometry', 'materials') {
    $dbh->do("DELETE FROM $table WHERE system IN ('solenoid', 'magnets_copies')");
}

my @variations = ("default", "rga_spring2018", "rga_fall2018");
my @runs = clas12_runs(@variations);

sub create_system {
    my $variation = shift;
    my $runNumber = shift;
    my $factory   = shift;
    # Native torus geometry remains disabled; its coils are supplied by CAD.

    makeSolenoid($variation, $runNumber);
    magnet_materials();
    build_magnets_copies();
}

# TEXT Factory, include extra variations
my $runNumber = 11;
$configuration{"factory"} = "TEXT";
foreach my $variation (@variations) {
    $configuration{"variation"} = $variation;
    create_system($variation, $runNumber);
}

# SQLITE Factory
$configuration{"factory"} = "SQLITE";
foreach my $run (@runs) {
    $configuration{"variation"} = "default";
    create_system("default", $run);
}


# Publish shared CAD sources and native copies without duplicating tessellated solids.
build_magnets_cad();
