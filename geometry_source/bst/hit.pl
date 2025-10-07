use strict;
use warnings;

our %configuration;

sub define_hit
{
	# uploading the hit definition
	my %hit = init_hit();
	$hit{"name"}            = "bst";
	$hit{"description"}     = "bst hit definitions";
	$hit{"identifiers"}     = "superlayer  type  segment  module  strip";
	$hit{"signalThreshold"} = "2.0*KeV";
	$hit{"timeWindow"}      = "128*ns";
	$hit{"prodThreshold"}   = "1*mm";
	$hit{"maxStep"}         = "0.03*mm";
	$hit{"delay"}           = "50*ns";
	$hit{"riseTime"}        = "1*ns";
	$hit{"fallTime"}        = "2*ns";
	$hit{"mvToMeV"}         = 100;
	$hit{"pedestal"}        = -20;
	print_hit(\%configuration, \%hit);
}
