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

my @rga = qw(
    rga_spring2018
    rga_fall2018
    rga_spring2019
);

my @rgb = qw(
    rgb_spring2019
    rgb_fall2019
);

my @rgc = qw(
    rgc_summer2022
);

my @rge = qw(
    rge_spring2024_Empty_Al
    rge_spring2024_Empty_C
    rge_spring2024_Empty_Empty
    rge_spring2024_Empty_Pb
    rge_spring2024_LD2_Al
    rge_spring2024_LD2_C
    rge_spring2024_LD2_Cu
    rge_spring2024_LD2_Pb
    rge_spring2024_LD2_Sn
);

my @rgf = qw(
    rgf_spring2020
);

my @rgl = qw(
    rgl_spring2025_H2
    rgl_spring2025_D2
    rgl_spring2025_He
);

my @rgm = qw(
    rgm_fall2021_He
    rgm_fall2021_C
    rgm_fall2021_Sn
    rgm_fall2021_Cx4
    rgm_fall2021_Snx4
    rgm_fall2021_Ca
);

my @variations = ("default", @rga, @rgb, @rgc, @rge, @rgf, @rgl, @rgm);

my @runs = clas12_runs(@variations);
my $system = $configuration{'detector_name'};

my @custom_variations = ("pbtest", "ND3", "hdice", "longitudinal", "transverse", "APOLLOnd3", "bonusH2", "bonusHe", "lH2e");


# list of original variations in gemc 5.11:
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
foreach my $variation (@variations) {
    foreach my $run (clas12_runs_for_variations($variation)) {
        upload_parameters(\%configuration, "$system" . "__parameters_$variation.txt", "$system", "default", $run);
    }
}

my $i = 0;
foreach my $variation (@custom_variations) {
    my $run = 50000 + $i++;
    upload_parameters(\%configuration, "$system" . "__parameters_$variation.txt", "$system", "default", $run);
}

foreach my $run (@runs) {
    $configuration{"variation"} = "default";
    $configuration{"run_number"} = $run;
    create_system("default", $run);
}

# port gxml to sqlite
require "gxml_to_sqlite.pl";

# default is the same for rga/rgb/rgf and the rgm targets
foreach my $variation ("default") {
    $configuration{"run_number"} = clas12_run($variation);
    process_gxml("cad/cad_$variation.gxml", "experiments/clas12/targets/cad");
}


