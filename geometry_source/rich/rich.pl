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
# Help Message
sub help()
{
	print "\n Usage: \n";
	print "   rich.pl <configuration filename>\n";
 	print "   Will create the CLAS12 Ring Imaging Cherenkov (rich) using the variation specified in the configuration file\n";
 	print "   Note: The passport and .visa files must be present to connect to MYSQL. \n\n";
	exit;
}

# Make sure the argument list is correct
if( scalar @ARGV != 1) 
{
	help();
	exit;
}

# stop and exit if $COATJAVA env variable is not set
if( !defined $ENV{COATJAVA} ) {
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
    "default" => [4,1],
    "rga_fall2018" => [4],
    "rgc_summer2022" => [4,1],
    );
#foreach my $variation (@allConfs){
while (my ($variation, $sectorarr) = each %conf_module_pos) {
    print("variation: $variation \n");
    my @sectors = @{$sectorarr}; #$module_pos{$variation};
    my $nmodules = scalar @sectors;
    print("sectors: @sectors \n");
    
    $configuration{"variation"} = $variation;    
    system(join(' ', 'groovy -cp "$COATJAVA/lib/clas/*" factory.groovy', $variation, ' ', $nmodules));
    our @volumes = get_volumes(%configuration);    
    
    define_MAPMT();
    define_CFRP();
    define_hit();
    makeRICHcad($variation,\@sectors);
    
    for (my $i = 0; $i < @sectors; $i++){
	my $module = $i + 1;
	my $sector = $sectors[$i];
	
	define_aerogels($module); #was sector
	buildMirrorsSurfaces($module); #was sector
	makeRICHtext($module,$sector);
	#print("temporary: copying RICH mother volume stl file \n");
	#copy("cadTemp/RICH_mother_corrected.stl","cad_".$variation."/RICH_m".$module.".stl");

    }
}



use File::Copy;
use File::Path qw(make_path remove_tree);

# Create directories
make_path('cad');

# Copy STL files from javacad_default to cad_ctof
my $javacad_default = 'cad_default';
my $cad = 'cad';

opendir(my $dh, $javacad_default) or die "Cannot open directory $javacad_default: $!";
while (my $file = readdir($dh)) {
    if ($file =~ /\.stl$/) {
        copy("$javacad_default/$file", "$cad/$file") or die "Copy failed: $!";
    }
}
closedir($dh);


# Copy specific GXML files
copy("$javacad_default/cad.gxml", "$cad/cad_default.gxml") or die "Copy failed: $!";
copy("cad_rgc_summer2022/cad.gxml", "$cad/cad_rgc_summer2022.gxml") or die "Copy failed: $!";
copy("cad_rga_fall2018/cad.gxml", "$cad/cad_rga_fall2018.gxml") or die "Copy failed: $!";


# Remove javacad directories created with the geometry service
remove_tree($javacad_default);
remove_tree('cad_rgc_summer2022');
remove_tree('cad_rga_fall2018');

