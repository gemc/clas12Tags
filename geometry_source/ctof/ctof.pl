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

# all STL files are the same, the only difference is the gxml file
# here we copy the run 11 files to cad and cad_upstream directories
sub copy_run11_files {
    opendir(my $dh, 'javacad_11') or die "Cannot open directory 'javacad_11': $!";
    while (my $file = readdir($dh)) {
        if ($file =~ /\.stl$/) {
            copy("javacad_11/$file", "cad/$file") or die "Copy failed: $!";
        }
    }
    closedir($dh);

    opendir($dh, 'javacad_11_upstream') or die "Cannot open directory 'javacad_11_upstream': $!";
    while (my $file = readdir($dh)) {
        if ($file =~ /\.stl$/) {
            copy("javacad_11_upstream/$file", "cad_upstream/$file") or die "Copy failed: $!";
        }
    }
    closedir($dh);
}

# subroutines create_system with arguments (variation, run number)
sub create_system {

    my $variation = shift;
    my $runNumber = shift;
    my $javaCadDir = "javacad_$runNumber";

    # materials, hits
    materials();
    define_hit();

    # 4/17/2025 we create the cad volumes using the /CTOFGeant4Factory.java at
    # https://github.com/JeffersonLab/coatjava/blob/development/common-tools/clas-jcsg/src/main/java/org/jlab/detector/geant4/v2/CTOFGeant4Factory.java
    # that factory reads from /geometry/shifts/solenoid/ but that offset is rewritten for the light guides in the factory.groovy
    if ($configuration{"factory"} eq "TEXT") {
        # create an empty ctof__geometry_variation.txt so the banks are correctly loaded
        my $filename = "ctof__geometry_$variation.txt";

        open(my $fh, '>', $filename) or die "Could not create file: $filename";
        close($fh);
        print "File '$filename' has been re-created and is now empty.\n";
    }

    # this will overwrite ctof__volumes_default but we don't care as it's a transient file
    if ($configuration{"factory"} eq "SQLITE") {

        if (!-d $javaCadDir) {
            system(join(' ', "groovy -cp '../*:..' factory.groovy --variation $variation --runnumber $runNumber", $javaCadDir));
            our @volumes = get_volumes(%configuration);
            coatjava::makeCTOF($javaCadDir);
        }

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

# Use glob to expand javacad* into actual paths
my @dirs = glob("cad*");
remove_tree(@dirs);
make_path('cad');
make_path('cad_upstream');

# SQLITE Factory
$configuration{"factory"} = "SQLITE";
define_bank();
my $variation = "default";
foreach my $run (@runs) {
    $configuration{"variation"} = $variation;
    $configuration{"run_number"} = $run;
    create_system($variation, $run);
}

copy_run11_files();

foreach my $run (@runs) {
    my $variation = clas12_variation($run);
    copy("javacad_$run/cad.gxml", "cad/cad_$variation.gxml") or die "Copy failed: $!";
    copy("javacad_$run"."_upstream/cad.gxml", "cad_upstream/cad_$variation.gxml") or die "Copy failed: $!";
}

# port gxml to sqlite
require "gxml_to_sqlite.pl";

foreach my $variation (@variations) {
    $configuration{"run_number"} = clas12_run($variation);
    process_gxml("cad/cad_$variation.gxml", "experiments/clas12/ctof/cad");
    process_gxml("cad_upstream/cad_$variation.gxml", "experiments/clas12/ctof/cad_upstream");
}

# Use glob to expand javacad* into actual paths
my @dirs = glob("javacad*");
remove_tree(@dirs);
