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

# TEXT Factory
$configuration{"factory"} = "TEXT";
define_banks();

my @variations = ("default", "rgk_winter2018", "rgb_spring2019", "rgf_spring2020", "rgc_summer2022", "rge_spring2024");
my $runNumber = 11;

foreach my $variation (@variations) {
    $configuration{"variation"} = $variation;
    create_system($variation, $runNumber);
}

# SQLITE Factory
$configuration{"factory"} = "SQLITE";
define_banks();

my $variation = "default";
my @runs = (11, 5874, 4763, 6150, 11620, 16043, 20000);

foreach my $run (@runs) {
    $configuration{"variation"} = $variation;
    $configuration{"run_number"} = $run;
    create_system($variation, $run);
}

