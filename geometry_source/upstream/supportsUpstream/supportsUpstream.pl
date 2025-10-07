#!/usr/bin/perl -w


use strict;
use lib ("$ENV{GEMC}/api/perl");
use utils;
use parameters;
use geometry;
use math;
use materials;

use Math::Trig;

# Help Message
sub help()
{
	print "\n Usage: \n";
	print "   supportsUpstream.pl <configuration filename>\n";
 	print "   Will create the CLAS12 supportpipes and materials\n";
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


# Global pars - these should be read by the load_parameters from file or DB

# General:
our $inches = 25.4;

# materials
require "./materials.pl";


# vacuum line throughout the shields, torus and downstream
require "./geometry.pl";

my @allConfs = ("main");

foreach my $conf ( @allConfs )
{

	$configuration{"variation"} = $conf ;

	# materials
	materials();


	# support pipes for MVT and SVT, plus top of SVT cart
	# temp includes Sarclay target
	build_supportsUpstream();
}



