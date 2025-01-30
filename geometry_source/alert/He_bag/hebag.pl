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
	print "   Hebag.pl <configuration filename>\n";
 	print "   Will create the CLAS12 simple He bag geometry, materials, for ALERT case\n";
 	print "   Note: The passport and .visa files must be present if connecting to MYSQL. \n\n";
	exit;
}

# Make sure the argument list is correct
if( scalar @ARGV != 1)
{
	help();
	exit;
}

# Loading configuration file from argument
our %configuration = load_configuration($ARGV[0]);

# materials
require "./materials.pl";

# sensitive geometry
require "./geometry.pl";

#foreach my $conf ( @allConfs )
{
	#$configuration{"variation"} = $conf ;
	
	# materials
	materials();
		
	# geometry
	build_hebag();
	
}


