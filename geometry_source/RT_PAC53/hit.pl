use strict;
use warnings;
use hit;

our %configuration;




sub define_BMT_hit
{
	# uploading the hit definition
	my %hit = init_hit();
	$hit{"name"}            = "bmt";
	$hit{"description"}     = "micromegas BMT";
# 	$hit{"identifiers"}     = "superlayer  type  segment  strip";
	$hit{"identifiers"}     = "layer sector strip";
	$hit{"signalThreshold"} = "2.0*KeV";
	$hit{"timeWindow"}      = "132*ns";
	$hit{"prodThreshold"}   = "1*mm";
	$hit{"maxStep"}         = "100*um";
	$hit{"delay"}           = "50*ns";
	$hit{"riseTime"}        = "1*ns";
	$hit{"fallTime"}        = "2*ns";
	$hit{"mvToMeV"}         = 100;
	$hit{"pedestal"}        = -20;
	print_hit(\%configuration, \%hit);
}


sub define_hit
{
	define_BMT_hit();
}


