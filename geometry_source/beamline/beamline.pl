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
	print "   beamline.pl <configuration filename>\n";
	print "   Will create the CLAS12 beamline and materials\n";
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
require "./vacuumLine.pl";
require "./ELMOline.pl";
require "./rghline.pl";
require "./transverseUpstreamBeampipe.pl";

# require "./torusShielding.pl";

my @allConfs = ("FTOn", "FTALERT" , "FTOff", "ELMO", "rghFTOut", "rghFTOn", "TransverseUpstreamBeampipe");

foreach my $conf ( @allConfs ) {

	$configuration{"variation"} = $conf ;

	# materials
	materials();

	# vacuum line throughout the shields, torus and downstream
	# temp includes the torus back nose
	if( $configuration{"variation"} eq "FTOff" or $configuration{"variation"} eq "FTOn" or $configuration{"variation"} eq "FTALERT") {
		vacuumLine();
	} elsif( $configuration{"variation"} eq "ELMO") {
		ELMOline();
	} elsif( $configuration{"variation"} eq "TransverseUpstreamBeampipe") {
		transverseUpstreamBeampipe();
	} elsif( $configuration{"variation"} eq "rghFTOut" or $configuration{"variation"} eq "rghFTOn") {
		rghline();
	}

	# torusShield();
}



