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
    print "   cnd.pl <configuration filename>\n";
    print "   Will create the CLAS12 CND geometry, materials, bank and hit definitions\n";
    print "   Note: if the sqlite file does not exist, create one with:  \$GEMC/api/perl/sqlite.py -n ../clas12.sqlite\n";
    exit;
}

# Make sure the argument list is correct
if (scalar @ARGV != 1) {
    help();
    exit;
}

# Loading configuration file and parameters
our %configuration = load_configuration($ARGV[0]);
our %parameters = get_parameters(%configuration);


# import scripts
require "./materials.pl";
require "./bank.pl";
require "./hit.pl";
require "./geometry.pl";


# subroutines create_system with arguments (variation, run number)
sub create_system {

    # my $variation = shift;
    # my $runNumber = shift;

    # materials, hits
    materials();
    define_hit();
    makeCND();

}

# materials

# TEXT Factory
$configuration{"factory"} = "TEXT";
define_bank();

my @variations = ("default", "rga_spring2018", "rga_fall2018");
my $runNumber = 11;

foreach my $variation (@variations) {
    $configuration{"variation"} = $variation;
    create_system($variation, $runNumber);
}

# SQLITE Factory
$configuration{"factory"} = "SQLITE";
define_bank();

my $variation = "default";
my @runs = (11, 3029, 4763);

foreach my $run (@runs) {
    $configuration{"variation"} = $variation;
    $configuration{"run_number"} = $run;
    create_system($variation, $run);
}

