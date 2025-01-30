#!/usr/bin/perl -w


use strict;
use lib ("$ENV{GEMC}/api/perl");
use utils;
use parameters;
use geometry;
use math;

use Math::Trig;

# Help Message
sub help()
{
	print "\n Usage: \n";
	print "   flux.pl <configuration filename>\n";
 	print "   Will create the CLAS12 FLUX disk geometry\n";
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


# sensitive geometry
require "./geometry.pl";


# all the scripts must be run for every configuration
my @allConfs = ("beamline");


foreach my $conf ( @allConfs )
{
	$configuration{"variation"} = $conf ;
	
	# geometry
	makeFlux();
	
}


