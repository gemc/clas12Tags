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
our %parameters;


# import scripts
require "./geometry.pl";
require "./materials.pl";

# subroutines create_system with arguments (variation, run number)
sub create_system {

    my $variation = shift;
    my $runNumber = shift;

    %parameters = get_parameters(%configuration);

    build_target();
    build_materials();
}

my @variations = ("default", "rga_spring2018", "rga_fall2018", "rgb_spring2019", "rga_spring2019", "rgb_fall2019", "rgf_spring2020",
    "rgm_fall2021_Sn");

my @runs = clas12_runs(@variations);

my @custom_variations = ("pbtest", "ND3", "hdice", "longitudinal", "transverse");

# list of original variations:
# lH2, lD2, lHe, ND3, PolTarg, APOLLOnh3, APOLLOnd3, lH2e,
# bonusD2, bonusH2, bonusHe, pbTest, hdIce, longitudinal, transverse,
# RGM_2_C, RGM_2_Sn, RGM_8_C_S, RGM_8_C_L, RGM_8_Sn_S, RGM_8_Sn_L, RGM_Ca,
# alertD2, alertH2, alertHe, lD2CxC, lD2CuSn, 2cm-lD2, 2cm-lD2-empty

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
    upload_parameters(\%configuration, "$system" . "__parameters_$variation.txt", "$system", "default", $runNumber);
}

my $i = 0;
foreach my $variation (@custom_variations) {
    my $runNumber = 50000 + $i++;
    upload_parameters(\%configuration, "$system" . "__parameters_$variation.txt", "$system", "default", $runNumber);
}

my $variation = "default";
foreach my $run (@runs) {
    $configuration{"variation"} = $variation;
    $configuration{"run_number"} = $run;
    create_system($variation, $run);
}

# port gxml to sqlite
require "gxml_to_sqlite.pl";

# default is the same for rga/rgb/rgf and the rgm targets
foreach my $variation ("default") {
    $configuration{"run_number"} = clas12_run($variation);
    process_gxml("cad/cad_$variation.gxml", "experiments/clas12/targets/cad");
    process_gxml("cad_rgm/cad_$variation.gxml", "experiments/clas12/targets/cad_rgm");
}


