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
    print "   targets.pl <configuration filename>\n";
    print "   Will create the CLAS12 targets geometry, materials, both original and elaborate versions\n";
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
our %parameters ;


# import scripts
require "./materials.pl";
require "./geometry.pl";
#
# require "./apollo.pl";

# subroutines create_system with arguments (variation, run number)
sub create_system {

    my $variation = shift;
    my $runNumber = shift;

    %parameters = get_parameters(%configuration);

    build_target();
}

my @variations = ("default", "rga_spring2018", "rga_fall2018");
my @runs = clas12_runs(@variations);

my @custom_variations = ("pbTest");

# TEXT Factory
$configuration{"factory"} = "TEXT";
my $runNumber = 11;
foreach my $variation (@variations, @custom_variations) {
    $configuration{"variation"} = $variation;
    create_system($variation, $runNumber);
}
# SQLITE Factory
$configuration{"factory"} = "SQLITE";
my $system = $configuration{'detector_name'};
foreach my $variation (@variations) {
    my $runNumber = clas12_run($variation);
    upload_parameters(\%configuration, "$system"."__parameters_$variation.txt", "$system", "$variation", $runNumber);
}
foreach my $variation (@custom_variations) {
    my $i = 0;
    my $runNumber = 50000 + $i++;
    upload_parameters(\%configuration, "$system"."__parameters_$variation.txt", "$system", "$variation", $runNumber);
}
