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
	print "   magnets.pl \n";
 	print "   Will create the CLAS12 Torus and Solenoid geometry and materials\n";
 	print "   Note: The passport and .visa files must be present if connecting to MYSQL. \n\n";
	exit;
}

# Make sure the argument list is correct
if( scalar @ARGV != 0 && scalar @ARGV != 1)
{
	help();
	exit;
}


# solenoid geometry
require "./solenoid.pl";

# torus geometry
require "./torus.pl";


# all the scripts must be run for every configuration
my @allConfs = ("original");

# manually removing the txt files as the scripts are not meant to produce 2 different
# systems
system('rm *.txt');


# the configuration here is passed as an argument
foreach my $conf ( @allConfs )
{
	# geometry
	makeTorus($conf);
	makeSolenoid($conf);
	
}


