use strict;
use warnings;

our %configuration;
our %parameters;


sub define_ft_trk_hit
{
	# uploading the hit definition
	my %hit = init_hit();
	$hit{"name"}            = "ft_trk";
	$hit{"description"}     = "forward tagger tracker hit definition";
	$hit{"identifiers"}     = "layer sector strip";
	$hit{"signalThreshold"} = "2.0*KeV";
	$hit{"timeWindow"}      = "132*ns";
	$hit{"prodThreshold"}   = "270*um";
	$hit{"maxStep"}         = "300*um";
	$hit{"delay"}           = "10*ns";
	$hit{"riseTime"}        = "1*ns";
	$hit{"fallTime"}        = "1*ns";
	$hit{"mvToMeV"}         = 100;
	$hit{"pedestal"}        = -20;
	print_hit(\%configuration, \%hit);
}

sub define_ft_hodo_hit
{
	# uploading the hit definition
	my %hit = init_hit();
	$hit{"name"}            = "ft_hodo";
	$hit{"description"}     = "forward tagger hodoscope hit definition";
	$hit{"identifiers"}     = "sector layer component";
	$hit{"signalThreshold"} = "0.1*MeV";
	$hit{"timeWindow"}      = "400*ns";
	$hit{"prodThreshold"}   = "1*mm";
	$hit{"maxStep"}         = "1*cm";
	$hit{"delay"}           = "10*ns";
	$hit{"riseTime"}        = "1*ns";
	$hit{"fallTime"}        = "1*ns";
	$hit{"mvToMeV"}         = 100;
	$hit{"pedestal"}        = -20;
	print_hit(\%configuration, \%hit);
}

sub define_ft_cal_hit
{
	# uploading the hit definition
	my %hit = init_hit();
	$hit{"name"}            = "ft_cal";
	$hit{"description"}     = "forward tagger calorimeter hit definition";
	$hit{"identifiers"}     = "idx idy";
	$hit{"signalThreshold"} = "0.5*MeV";
	$hit{"timeWindow"}      = "400*ns";
	$hit{"prodThreshold"}   = "1*mm";
	$hit{"maxStep"}         = "1*cm";
	$hit{"delay"}           = "10*ns";
	$hit{"riseTime"}        = "1*ns";
	$hit{"fallTime"}        = "1*ns";
	$hit{"mvToMeV"}         = 100;
	$hit{"pedestal"}        = -20;
	print_hit(\%configuration, \%hit);
}


sub define_ft_hits
{
	define_ft_trk_hit();
	define_ft_hodo_hit();
	define_ft_cal_hit();
}


1;
