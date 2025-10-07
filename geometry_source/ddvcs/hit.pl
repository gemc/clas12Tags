use strict;
use warnings;

our %configuration;
our %parameters;


sub define_mucal_hit
{
	# uploading the hit definition
	my %hit = init_hit();
	$hit{"name"}            = "ft_cal";
	$hit{"description"}     = "forward tagger calorimeter hit definition";
	$hit{"identifiers"}     = "idx idy";
	$hit{"signalThreshold"} = "0.5*MeV";
	$hit{"timeWindow"}      = "50*ns";
	$hit{"prodThreshold"}   = "1*cm";
	$hit{"maxStep"}         = "2*cm";
	$hit{"delay"}           = "10*ns";
	$hit{"riseTime"}        = "1*ns";
	$hit{"fallTime"}        = "1*ns";
	$hit{"mvToMeV"}         = 100;
	$hit{"pedestal"}        = -20;
	print_hit(\%configuration, \%hit);
}



1;
