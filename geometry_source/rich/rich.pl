#!/usr/bin/perl -w

use strict;
use lib ("$ENV{GEMC}/api/perl");
use utils;
use parameters;
use geometry;
use hit;
use bank;
use mirrors;
use math;
use materials;
use POSIX;
use File::Copy;
use lib ("../");
use clas12_configuration_string;

# Help Message
sub help() {
    print "\n Usage: \n";
    print "   rich.pl <configuration filename>\n";
    print "   Will create the CLAS12 Ring Imaging Cherenkov (rich) using the variation specified in the configuration file\n";
    print "   Note: if the sqlite file does not exist, create one with:  \$GEMC/api/perl/sqlite.py -n ../../clas12.sqlite\n";
    exit;
}

# Make sure the argument list is correct
if (scalar @ARGV != 1) {
    help();
    exit;
}

# stop and exit if $COATJAVA env variable is not set
if (!defined $ENV{COATJAVA}) {
    print "\n*** ERROR *** ERROR *** ERROR *** ERROR *** ERROR *** ERROR ***\n";
    print "FATAL: COATJAVA environment variable is not set. \n";
    print "Please set the COATJAVA variable to the coatjava installation directory.\n";
    print "Example: export COATJAVA=../coatjava \n";
    print "*** ERROR *** ERROR *** ERROR *** ERROR *** ERROR *** ERROR ***\n\n";
    exit;
}

# Loading configuration file and parameters
our %configuration = load_configuration($ARGV[0]);

# geometry                                                                                                                                                                    
require "./geometry.pl";

# materials
require "./materials.pl";

# banks definitions
require "./bank.pl";

# hits definitions
require "./hit.pl";

#mirror material
require "./mirrors.pl";

# hash of variations and sector positions of modules
my %conf_module_pos = (
    "default"        => [ 4, 1 ],
    "rga_spring2018" => [ 4 ],
    "rgc_summer2022" => [ 4, 1 ],
);

# subroutines create_system with arguments (variation, run number)
sub create_system {
    #my $variation = shift;
    #my $runNumber = shift;

    # forcing $configuration variation to be the same as the one in the loop
    # otherwise for SQLITE we'd call the geometry service with the wrong variation
    my $variation = clas12_configuration_string(\%configuration);
    my $coatjava_variation = $variation;

    # for rich, rga_fall2018 applies also to spring
    if ($variation eq "rga_spring2018") {
        $coatjava_variation = "rga_fall2018";
    }

    my $sectors_ref = $conf_module_pos{$variation};

    # Dereference the array reference to get the array
    my @sectors = @{$sectors_ref};
    my $nmodules = scalar @sectors;

    system(join(' ', 'groovy -cp "../*:.." factory.groovy', $variation, ' ', $nmodules));
    our @volumes = get_volumes(%configuration);

    if ($configuration{"factory"} eq "SQLITE") {
        $configuration{"variation"} = "default";
    }

    define_MAPMT();
    define_CFRP();
    define_hit();
    makeRICHcad($variation, \@sectors);

    for (my $i = 0; $i < @sectors; $i++) {
        my $module = $i + 1;
        my $sector = $sectors[$i];

        define_aerogels($module);
        buildMirrorsSurfaces($module);
        makeRICHtext($module, $sector);
    }
}

my @variations = sort keys %conf_module_pos;
my @runs = clas12_runs(@variations);

# TEXT Factory
$configuration{"factory"} = "TEXT";
define_bank();
my $runNumber = 11;
foreach my $variation (@variations) {
    $configuration{"variation"} = $variation;
    create_system($variation, $runNumber);
}

# SQLITE Factory
$configuration{"factory"} = "SQLITE";
define_bank();
my $variation = "default";
foreach my $run (@runs) {
    $configuration{"variation"} = $variation;
    $configuration{"run_number"} = $run;
    create_system($variation, $run);
}

use File::Copy;
use File::Path qw(make_path remove_tree);

# Create directories
make_path('cad');

# Copy STL files from javacad_default to cad
my $javacad_default = 'cad_default';

# Copy all STL files from the other variations to the cad directory
opendir(my $dh, $javacad_default) or die "Cannot open directory $javacad_default: $!";
while (my $file = readdir($dh)) {
    if ($file =~ /\.stl$/) {
        copy("$javacad_default/$file", "cad/$file") or die "Copy failed: $!";
    }
}
closedir($dh);

# Copy specific GXML files
copy("$javacad_default/cad.gxml",   "cad/cad_default.gxml") or die "Copy failed: $!";
copy("cad_rgc_summer2022/cad.gxml", "cad/cad_rgc_summer2022.gxml") or die "Copy failed: $!";
copy("cad_rga_spring2018/cad.gxml", "cad/cad_rga_spring2018.gxml") or die "Copy failed: $!";


# Remove javacad directories created with the geometry service
remove_tree($javacad_default);
remove_tree('cad_rgc_summer2022');
remove_tree('cad_rga_spring2018');


# port gxml to sqlite
require "../gxml_to_sqlite.pl";

$configuration{"run_number"} = 11;
process_gxml("cad/cad_default.gxml", "rich/cad");

$configuration{"run_number"} = 3029;
process_gxml("cad/cad_rga_spring2018.gxml", "experiments/clas12/rich/cad");

$configuration{"run_number"} = 16043;
process_gxml("cad/cad_rgc_summer2022.gxml", "experiments/clas12/rich/cad");

