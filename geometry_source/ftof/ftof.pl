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

# Help Message
sub help() {
    print "\n Usage: \n";
    print "   ftof.pl <configuration filename>\n";
    print "   Will create the CLAS12 FTOF geometry, materials, bank and hit definitions\n";
    print "   Note: if the sqlite file does not exist, create one with:  \$GEMC/api/perl/sqlite.py -n ../clas12.sqlite\n";
    exit;
}

# Make sure the argument list is correct
if (scalar @ARGV != 1) {
    help();
    exit;
}

# Loading configuration file
our %configuration = load_configuration($ARGV[0]);

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
    our %parameters = get_parameters(%configuration);
    our @volumes = get_volumes(%configuration);

    coatjava::makeFTOF();
    coatjava::make_pb();
}


# TEXT Factory
$configuration{"factory"} = "TEXT";
define_bank();

my @variations = ("default", "rga_fall2018");
my $runNumber = 11;

foreach my $variation (@variations) {
    $configuration{"variation"} = $variation;
    create_system($variation, $runNumber);
}


# SQLITE Factory
$configuration{"factory"} = "SQLITE";
define_bank();
upload_parameters(\%configuration, "ftof__parameters_default.txt", "ftof", "default", 11);
upload_parameters(\%configuration, "ftof__parameters_rga_fall2018.txt", "ftof", "default", 3029);

my $variation = "default";
my @runs = (11, 3029);

foreach my $run (@runs) {
    $configuration{"variation"} = $variation;
    $configuration{"run_number"} = $run;
    create_system($variation, $run);
}


