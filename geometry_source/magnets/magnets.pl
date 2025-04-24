#!/usr/bin/perl -w

use strict;
use warnings;
use lib ("$ENV{GEMC}/api/perl");
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
    print "   Note: if the sqlite file does not exist, create one with:  \$GEMC/api/perl/sqlite.py -n ../../clas12.sqlite\n";
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

# manually removing the txt files because the api does not have the capability to distinguish
# between the first system and subsequent systems
system('rm *.txt');

my @variations = ("default", "rga_spring2018", "rga_fall2018");
my @runs = clas12_runs(@variations);

sub create_system {
    my $variation = shift;
    my $runNumber = shift;
    my $factory   = shift;
    # only make torus for default variation. We actually do not use this, but
    # if enable this will trigger deletion of all solenoid volumes in the SQLITE due to API
    # probably not worth fix this perl API for it.
    # makeTorus($variation, $runNumber, $factory) if $variation eq "default";

    makeSolenoid($variation, $runNumber, $factory);
}

# TEXT Factory, include extra variations
my $runNumber = 11;
foreach my $variation (@variations) {
    $configuration{"variation"} = $variation;
    create_system($variation, $runNumber, "TEXT");
}

# SQLITE Factory
foreach my $run (@runs) {
    $configuration{"variation"} = "default";
    create_system("default", $run);
}


# port gxml to sqlite
require "gxml_to_sqlite.pl";
foreach my $variation (@variations) {
    $configuration{"run_number"} = clas12_run($variation);
    process_gxml("cad/cad_$variation.gxml", "experiments/clas12/magnets/cad");
}