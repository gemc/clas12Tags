use strict;
use warnings;

our %configuration;


sub define_hit
{
	# uploading the hit definition
	my %hit = init_hit();
	$hit{"name"}            = "ctof";
	$hit{"description"}     = "ctof hit definitions";
	$hit{"identifiers"}     = "paddle pmt";
	$hit{"signalThreshold"} = "0.5*MeV";
	$hit{"timeWindow"}      = "400*ns";
	$hit{"prodThreshold"}   = "2*mm";
	$hit{"maxStep"}         = "1*cm";
	$hit{"delay"}           = "50*ns";
	$hit{"riseTime"}        = "5*ns";
	$hit{"fallTime"}        = "8*ns";
	$hit{"mvToMeV"}         = 100;
	$hit{"pedestal"}        = -20;
	print_hit(\%configuration, \%hit);

}

