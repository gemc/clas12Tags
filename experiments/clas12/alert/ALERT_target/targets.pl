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

# Loading configuration file and paramters
our %configuration = load_configuration($ARGV[0]);


# materials
require "./materials.pl";

# sensitive geometry
require "./geometry.pl";


# all the scripts must be run for every configuration
my @allConfs = ("lH2", "lD2", "ND3", "PolTarg", "12C", "63Cu", "118Sn", "208Pb", "27Al", "lH2e", "bonus", "alert");

foreach my $conf ( @allConfs )
{
	$configuration{"variation"} = $conf ;
	
	# materials
	materials();
		
	# geometry
	build_targets();
	
}


