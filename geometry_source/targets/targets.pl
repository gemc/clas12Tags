#!/usr/bin/perl -w

use strict;
use lib ("$ENV{GEMC}/api/perl");
use utils;
use parameters;
use geometry;
use materials;

use Math::Trig;

# Help Message
sub help()
{
	print "\n Usage: \n";
	print "   targets.pl <configuration filename>\n";
 	print "   Will create the CLAS12 targets geometry, materials, both original and elaborate versions\n";
 	print "   Note: The passport and .visa files must be present if connecting to MYSQL. \n\n";
	exit;
}

# Make sure the argument list is correct
if( scalar @ARGV != 1)
{
	help();
	exit;
}

# Loading configuration file and parameters
our %configuration = load_configuration($ARGV[0]);


# materials
require "./materials.pl";

# sensitive geometry
require "./geometry.pl";
require "./apollo.pl";


# all the scripts must be run for every configuration
my @allConfs = ("lH2", "lD2", "lHe", "ND3", "PolTarg", "APOLLOnh3", "APOLLOnd3", "lH2e", "bonusD2", "bonusH2", "bonusHe", "pbTest", "hdIce", "longitudinal", "transverse", "RGM_2_C", "RGM_2_Sn", "RGM_8_C_S", "RGM_8_C_L", "RGM_8_Sn_S", "RGM_8_Sn_L", "RGM_Ca", "alertD2", "alertH2", "alertHe", "lD2CxC", "lD2CuSn", "2cm-lD2", "2cm-lD2-empty");


foreach my $conf ( @allConfs )
{
	$configuration{"variation"} = $conf ;
	
	# materials
	materials();
		
	# geometry
	if( $configuration{"variation"} eq "APOLLOnh3" || $configuration{"variation"} eq "APOLLOnd3") {
	    apollo();
	}
	else {
	  build_targets();
	}
}


