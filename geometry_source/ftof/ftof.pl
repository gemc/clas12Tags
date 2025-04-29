#!/usr/bin/perl -w

use strict;
use warnings;
use lib ("$ENV{GEMC}/api/perl");
use utils;
use parameters;
use geometry;
use hit;
use bank;
use materials;
use Math::Trig;
use lib ("../");
use clas12_configuration_string;

# Help Message
sub help() {
    print "\n Usage: \n";
    print "   ftof.pl <configuration filename>\n";
    print "   Will create the CLAS12 FTOF geometry, materials, bank and hit definitions\n";
    print "   Note: if the sqlite file does not exist, create one with:  \$GEMC/api/perl/sqlite.py -n ../../clas12.sqlite\n";
    exit;
}

# Make sure the argument list is correct
if (scalar @ARGV != 1) {
    help();
    exit;
}

# Loading configuration file
our %configuration = load_configuration($ARGV[0]);
 our %parameters;

# import scripts
require "./materials.pl";
require "./bank.pl";
require "./hit.pl";
require "./geometry_java.pl";

# subroutines create_system with arguments (variation, run number)
sub create_system {
    my $variation = shift;
    my $runNumber = shift;

    # materials, hits
    materials();
    define_hit();

    # run EC factory from COATJAVA to produce volumes
    system("groovy -cp '../*:..' factory.groovy --variation $variation --runnumber $runNumber");

    # Global pars - these should be read by the load_parameters from file or DB
    %parameters = get_parameters(%configuration);
    our @volumes = get_volumes(%configuration);

    coatjava::makeFTOF();
    coatjava::make_pb();
}

my @variations = ("default", "rga_spring2018");
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
my $system = $configuration{'detector_name'};
foreach my $variation (@variations) {
    foreach my $run (clas12_runs_for_variations($variation)) {
        upload_parameters(\%configuration, "$system" . "__parameters_$variation.txt", "$system", "default", $run);
    }
}

foreach my $run (@runs) {
    $configuration{"variation"} = "default";
    $configuration{"run_number"} = $run;
    create_system("default", $run);
}


