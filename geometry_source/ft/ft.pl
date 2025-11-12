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
    print "   ft.pl <configuration filename>\n";
    print "   Will create the CLAS12 Forward Tagger (ft) using the variation specified in the configuration file\n";
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

# import scripts
require "./hit.pl";
require "./bank.pl";
require "./geometry.pl";
require "./materials.pl";

# subroutines create_system with arguments (variation, run number)
sub create_system {

    materials();
    define_ft_hits();
    make_ft_cal();
    make_ft_hodo();
    make_ft_trk();

}

# the rgc fall variation contains an empty volume to indicate it's 'out'. This way we can include it in all gcards.
my @variations = ("default",
    "rgk_winter2018",
    "rgb_spring2019",
    "rgf_spring2020",
    "rgc_summer2022",
    "rgd_spring2023",
    "rgd_fall2023",
    "rgl_spring2025");
my @runs = clas12_runs(@variations);


# TEXT Factory
$configuration{"factory"} = "TEXT";
define_banks();
my $runNumber = 11;
foreach my $variation (@variations) {
    $configuration{"variation"} = $variation;
    create_system($variation, $runNumber);
}

# SQLITE Factory
$configuration{"factory"} = "SQLITE";
define_banks();
foreach my $run (@runs) {
    $configuration{"variation"} = "default";
    $configuration{"run_number"} = $run;
    create_system("default", $run);
}

