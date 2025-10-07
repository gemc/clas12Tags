use strict;
use warnings;

our %configuration;


sub define_hit
{
	# uploading the hit definition
	# the last identifier is needed by gemc if nphe so the hit info
	# can be displayed accordingly
	my %hit = init_hit();
	$hit{"name"}            = "htcc";
	$hit{"description"}     = "htcc hit definitions";
	$hit{"identifiers"}     = "sector ring half nphe";
	$hit{"signalThreshold"} = "0.5*MeV";
	$hit{"timeWindow"}      = "5*ns";
	$hit{"prodThreshold"}   = "1*mm";
	$hit{"maxStep"}         = "1*cm";
	$hit{"delay"}           = "50*ns";
	$hit{"riseTime"}        = "1*ns";
	$hit{"fallTime"}        = "2*ns";
	$hit{"mvToMeV"}         = 100;
	$hit{"pedestal"}        = -20;
	print_hit(\%configuration, \%hit);
}

