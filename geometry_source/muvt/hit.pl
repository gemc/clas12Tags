use strict;
use warnings;

our %configuration;

sub define_hit
{
	# uploading the hit definition
	my %hit = init_hit();
	$hit{"name"}            = "muvt";
	$hit{"description"}     = "muvt hit definitions ";
	$hit{"identifiers"}     = "sector chamber layer component";
	$hit{"signalThreshold"} = "2*KeV";
	$hit{"timeWindow"}      = "50*ns";
	$hit{"prodThreshold"}   = "1*mm";
	$hit{"maxStep"}         = "100*um";
	$hit{"delay"}           = "50*ns";
	$hit{"riseTime"}        = "1*ns";
	$hit{"fallTime"}        = "2*ns";
	$hit{"mvToMeV"}         = 100;
	$hit{"pedestal"}        = -20;
	print_hit(\%configuration, \%hit);
}

