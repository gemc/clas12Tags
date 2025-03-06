#!/usr/bin/perl -w

use strict;
use warnings;
use lib ("$ENV{GEMC}/api/perl");
use utils;
use parameters;
use geometry;
use math;
use materials;
use Math::Trig;
use lib ("../");
use clas12_configuration_string;

# Help Message
sub help() {
    print "\n Usage: \n";
    print "   beamline.pl <configuration filename>\n";
    print "   Will create the CLAS12 beamline and materials\n";
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

# General:
our $inches = 25.4;

# materials
require "./materials.pl";
require "./vacuumLine.pl";
require "./ELMOline.pl";
require "./rghline.pl";
require "./transverseUpstreamBeampipe.pl";

sub create_system {
    my $variation = clas12_configuration_string(\%configuration);

    if ($variation eq "rgc_fall2022") {
        ELMOline();
    }
    elsif ($variation eq "TransverseUpstreamBeampipe") {
        transverseUpstreamBeampipe();
    }
    elsif ($variation eq "rghFTOut" || $configuration{"variation"} eq "rghFTOn") {
        rghline();
    }
    else {
        vacuumLine();
    }

    materials();
}

my @variations = ("default", "rgk_winter2018", "rgb_spring2019", "rgf_spring2020", "rgc_summer2022", "rgc_fall2022", "rge_spring2024", "rgl_spring2025");
my @runs = clas12_runs(@variations);

my @custom_variations = ("rghFTOut", "rghFTOn", "TransverseUpstreamBeampipe");

# TEXT Factory, include extra variations
$configuration{"factory"} = "TEXT";
my $runNumber = 11;
foreach my $variation (@variations, @custom_variations) {
    $configuration{"variation"} = $variation;
    create_system($variation, $runNumber);
}

# SQLITE Factory
$configuration{"factory"} = "SQLITE";
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
    process_gxml("cad/cad_$variation.gxml", "experiments/clas12/beamline/cad");
}