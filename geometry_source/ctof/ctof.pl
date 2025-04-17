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
    print "   ctof.pl <configuration filename>\n";
    print "   Will create the CLAS12 CTOF geometry, materials, bank and hit definitions\n";
    print "   Note: if the sqlite file does not exist, create one with:  \$GEMC/api/perl/sqlite.py -n ../../clas12.sqlite\n";
    exit;
}

# Make sure the argument list is correct
if (scalar @ARGV != 1) {
    help();
    exit;
}

# Loading configuration file and parameters
# Notice: parameters are common to all variations so they are read for default variation only
our %configuration = load_configuration($ARGV[0]);
our %parameters = get_parameters(%configuration);

# import scripts
require "./materials.pl";
require "./bank.pl";
require "./hit.pl";
require "./geometry.pl";
require "./geometry_java.pl";


# subroutines create_system with arguments (variation, run number)
sub create_system {
    my $variation = shift;
    my $runNumber = shift;
    my $javaCadDir = "javacad_$variation";

    # materials, hits
    materials();
    define_hit();

    # 4/17/2025 we create the cad volumes using the /CTOFGeant4Factory.java at
    # https://github.com/JeffersonLab/coatjava/blob/development/common-tools/clas-jcsg/src/main/java/org/jlab/detector/geant4/v2/CTOFGeant4Factory.java
    # that factory reads from /geometry/shifts/solenoid/ but that offset is rewritten in the factory.groovy which need to be fixed to read run numbers
    # instead of variations
    if ($configuration{"factory"} eq "TEXT") {
        # create an empty ctof__geometry_variation.txt so the banks are correctly loaded
        my $filename = "ctof__geometry_$variation.txt";

        open(my $fh, '>', $filename) or die "Could not create file: $filename";
        close($fh);
        print "File '$filename' has been re-created and is now empty.\n";

        system(join(' ', "groovy -cp '../*:..' factory.groovy --variation $variation --runnumber $runNumber", $javaCadDir));
        our @volumes = get_volumes(%configuration);

        coatjava::makeCTOF($javaCadDir);

    }

    # if directory does not exist, create it
    if ($configuration{"factory"} eq "SQLITE") {
        my $variation_string = clas12_configuration_string(\%configuration);
        $javaCadDir = "javacad_$variation_string";
    }

}

my @variations = ("default", "rga_spring2018", "rga_fall2018");
my @runs = clas12_runs(@variations);

# TEXT Factory
$configuration{"factory"} = "TEXT";
define_bank();
my $runNumber = 11;
foreach my $variation (@variations) {
    $configuration{"variation"} = $variation;
    create_system($variation, $runNumber);
}


# Handling directory changes
use File::Copy;
use File::Path qw(make_path remove_tree);

if (-d "cad" || -d "cad_upstream") {
    
    remove_tree('cad');
    remove_tree('cad_upstream');

    make_path('cad');
    make_path('cad_upstream');

    opendir(my $dh, 'javacad_default') or die "Cannot open directory 'javacad_default': $!";
    while (my $file = readdir($dh)) {
        if ($file =~ /\.stl$/) {
            copy("javacad_default/$file", "cad/$file") or die "Copy failed: $!";
        }
    }
    closedir($dh);

    # Copy STL files from javacad_default_upstream to cad_ctof_upstream

    opendir($dh, 'javacad_default_upstream') or die "Cannot open directory 'javacad_default_upstream': $!";
    while (my $file = readdir($dh)) {
        if ($file =~ /\.stl$/) {
            copy("javacad_default_upstream/$file", "cad_upstream/$file") or die "Copy failed: $!";
        }
    }
    closedir($dh);
    # Copy specific GXML files
    copy("javacad_default/cad.gxml", "cad/cad_default.gxml") or die "Copy failed: $!";
    copy("javacad_rga_spring2018/cad.gxml", "cad/cad_rga_spring2018.gxml") or die "Copy failed: $!";
    copy("javacad_rga_fall2018/cad.gxml", "cad/cad_rga_fall2018.gxml") or die "Copy failed: $!";
    copy("javacad_default_upstream/cad.gxml", "cad_upstream/cad_default.gxml") or die "Copy failed: $!";
    copy("javacad_rga_spring2018_upstream/cad.gxml", "cad_upstream/cad_rga_spring2018.gxml") or die "Copy failed: $!";
    copy("javacad_rga_fall2018_upstream/cad.gxml", "cad_upstream/cad_rga_fall2018.gxml") or die "Copy failed: $!";

    # Remove javacad directories created with the geometry service
    remove_tree('javacad_default');
    remove_tree('javacad_default_upstream');
    remove_tree('javacad_rga_spring2018');
    remove_tree('javacad_rga_fall2018');
    remove_tree('javacad_rga_spring2018_upstream');
    remove_tree('javacad_rga_fall2018_upstream');

    # remove volumes files, the default one is not correct after using SQLITE because it used a different run number
    remove_tree("ctof__parameters*");

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

# port gxml to sqlite
require "../gxml_to_sqlite.pl";

foreach my $variation (@variations) {
    $configuration{"run_number"} = clas12_run($variation);
    process_gxml("cad/cad_$variation.gxml", "experiments/clas12/ctof/cad");
    process_gxml("cad_upstream/cad_$variation.gxml", "experiments/clas12/ctof/cad_upstream");
}

