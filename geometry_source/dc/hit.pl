use strict;
use warnings;

our %configuration;

sub define_hit
{
	# uploading the hit definition
	my %hit = init_hit();
	$hit{"name"}            = "dc";
	$hit{"description"}     = "dc hit definitions ";
	$hit{"identifiers"}     = "sector  superlayer layer wire";
	$hit{"signalThreshold"} = "0.1*KeV";
	$hit{"timeWindow"}      = "500*ns";
	$hit{"prodThreshold"}   = "1*mm";
	$hit{"maxStep"}         = "1*mm";
	$hit{"delay"}           = "50*ns";
	$hit{"riseTime"}        = "1*ns";
	$hit{"fallTime"}        = "2*ns";
	$hit{"mvToMeV"}         = 100;
	$hit{"pedestal"}        = -20;
	print_hit(\%configuration, \%hit);
}

