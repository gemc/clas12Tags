#!/usr/bin/perl -w

use strict;
use lib ("$ENV{GEMC}/io");
use utils;
use hit;
use strict;
use warnings;

# Help Message
sub help()
{
	print "\n Usage: \n";
	print "   hit.pl  <configuration filename>\n";
 	print "   Will create the CLAS12 BONUS hit definition\n";
 	print "   Note: The passport and .visa files must be present to connect to MYSQL. \n\n";
	exit;
}

# Make sure the argument list is correct
# If not pring the help
if( scalar @ARGV != 1)
{
	help();
	exit;
}

# Loading configuration file and parameters
#our %configuration = load_configuration($ARGV[0]);
our %configuration;

# One can change the "variation" here if one is desired different from the config.dat
# $configuration{"variation"} = "myvar";

sub define_hit
{
	# uploading the hit definition
	my %hit = init_hit();
	$hit{"name"}            = "rtpc";
	$hit{"description"}     = "bonus hit definitions";
	$hit{"identifiers"}     = "CellID ADC TDC step";
	$hit{"signalThreshold"} = "73*eV";
	$hit{"timeWindow"}      = "120*ns";  #0.1*ns
	$hit{"prodThreshold"}   = "5*mm";  #0.1*mm
	$hit{"maxStep"}         = "0.6*mm";    #kp: 2*mm; it was 30*mm; #"0.2*mm";
	$hit{"delay"}           = "1*ns";
	$hit{"riseTime"}        = "1*ns";
	$hit{"fallTime"}        = "2*ns";
	$hit{"mvToMeV"}         = 100;
	$hit{"pedestal"}        = -20;
	print_hit(\%configuration, \%hit);
}

define_hit();


1;
