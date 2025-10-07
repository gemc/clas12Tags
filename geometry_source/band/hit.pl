use strict;
use warnings;

our %configuration;



sub define_hit
{
	# uploading the hit definition
	my %hit = init_hit();
	$hit{"name"}            = "band";
	$hit{"description"}     = "band hit definitions for each bar";
	$hit{"identifiers"}     = "sector layer component";
	$hit{"signalThreshold"} = "0.5*MeV"; # not used for the moment
	$hit{"timeWindow"}      = "400*ns"; # defines how hits will be grouped with geant time 
					# (another step within this window will be grouped together in the same hit
					# and it's unique to a single identifier
	$hit{"prodThreshold"}   = "1*mm";
	$hit{"maxStep"}         = "1*cm";
	# Below are used to define the flash ADC shape:
	$hit{"delay"}           = "50*ns";
	$hit{"riseTime"}        = "1*ns";
	$hit{"fallTime"}        = "2*ns";
	$hit{"mvToMeV"}         = 100;
	$hit{"pedestal"}        = -20;
	print_hit(\%configuration, \%hit);
}

