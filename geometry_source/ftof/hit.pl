use strict;
use warnings;

our %configuration;

sub define_hit
{
	# uploading the hit definition
	my %hit = init_hit();
	$hit{"name"}            = "ftof";
	$hit{"description"}     = "ftof hit definitions for panel ";
	$hit{"identifiers"}     = "sector panel paddle";
	$hit{"signalThreshold"} = "0.5*MeV";
	$hit{"timeWindow"}      = "400*ns";
	$hit{"prodThreshold"}   = "1*mm";
	$hit{"maxStep"}         = "1*cm";
	$hit{"delay"}           = "50*ns";
	$hit{"riseTime"}        = "1*ns";
	$hit{"fallTime"}        = "2*ns";
	$hit{"mvToMeV"}         = 100;
	$hit{"pedestal"}        = -20;
	print_hit(\%configuration, \%hit);
}
