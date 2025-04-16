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
    print "   micromegas.pl <configuration filename>\n";
    print "   Will create the CLAS12 Micromegas BMT and FMT geometries, materials, bank and hit definitions\n";
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
require "./bank.pl";
require "./hit.pl";
require "./bmt.pl";
require "./fmt.pl";


# subroutines create_system with arguments (variation, run number)
sub create_system {

    my $variation = shift;
    my $runNumber = shift;

    %parameters = get_parameters(%configuration);

    # materials, hits
    materials();
    define_hit();
    load_parameters_bmt();
    define_bmt();
    load_parameters_fmt();
    define_fmt();
}

my @variations = ("rga_spring2018", "rgf_spring2020", "rgm_winter2021");
my @runs = clas12_runs(@variations);

my @custom_variations = ("michel_9mmcopper");


# TEXT Factory
$configuration{"factory"} = "TEXT";
define_bank();
my $runNumber = 11;
foreach my $variation (@variations, @custom_variations) {
    $configuration{"variation"} = $variation;
    create_system($variation, $runNumber);
}

# SQLITE Factory
$configuration{"factory"} = "SQLITE";
define_bank();
foreach my $variation (@variations) {
    my $runNumber = clas12_run($variation);
    my $system = $configuration{'detector_name'};
    upload_parameters(\%configuration, "$system"."__parameters_$variation.txt", "$system", "default", $runNumber);
}
upload_parameters(\%configuration, "micromegas__parameters_michel_9mmcopper.txt", "micromegas", "default", 30000);

my $variation = "default";
foreach my $run (@runs) {
    $configuration{"variation"} = $variation;
    $configuration{"run_number"} = $run;
    create_system($variation, $run);
}



