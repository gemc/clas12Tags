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
    print "   dc.pl <configuration filename>\n";
    print "   Will create the CLAS12 DC geometry, materials, bank and hit definitions\n";
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
require "./materials.pl";
require "./shield_material.pl";
require "./bank.pl";
require "./hit.pl";
require "./geometry_java.pl";
require "./geometry.pl";
require "./basePlates.pl";
require "./endPlates.pl";
require "./region3_shield.pl";
require "./utils.pl";

use File::Copy;


# subroutines create_system with arguments (variation, run number)
sub create_system {
    my $variation = shift;
    my $runNumber = shift;

    # materials
    materials();
    shield_material();
    define_hit();

    if ($variation eq "original") {
        calculate_dc_parameters();

        makeDC_perl();
        make_plates();
    }
    elsif ($variation eq "ddvcs") {
        system("groovy -cp '../*:..' factory.groovy --variation default --runnumber $runNumber");
        copy("dc__volumes_default.txt", "dc__volumes_ddvcs.txt") or die "Copy failed: $!";

        our @volumes = get_volumes(%configuration);
        coatjava::makeDC();
        make_region3_front_shield();
        make_region3_back_shield();
    }
    else {
        system("groovy -cp '../*:..' factory.groovy --variation $variation --runnumber $runNumber");
        our @volumes = get_volumes(%configuration);
        coatjava::makeDC();
    }
}

# TEXT Factory
$configuration{"factory"} = "TEXT";
define_bank();

#my @variations = ("default");
my @variations = ("default",  "ddvcs");
my $runNumber = 11;

foreach my $variation (@variations) {
    $configuration{"variation"} = $variation;
    create_system($variation, $runNumber);
}


# SQLITE Factory
$configuration{"factory"} = "SQLITE";
define_bank();

my $variation = "default";
my @runs = (11);

foreach my $run (@runs) {
    $configuration{"variation"} = $variation;
    $configuration{"run_number"} = $run;
    create_system($variation, $run);
}
