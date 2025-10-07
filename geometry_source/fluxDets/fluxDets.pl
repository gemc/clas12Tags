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
    print "   fluxDets.pl <configuration filename>\n";
    print "   Will create the Various FLUX geometry\n";
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

# sensitive geometry
require "./geometry.pl";

my @custom_variations = ("beamline", "ddvcs");

sub create_system {
    makeFlux();
}



# TEXT Factory, include extra variations
$configuration{"factory"} = "TEXT";
my $runNumber = 11;
foreach my $variation (@custom_variations) {
    $configuration{"variation"} = $variation;
    create_system($variation, $runNumber);
}

