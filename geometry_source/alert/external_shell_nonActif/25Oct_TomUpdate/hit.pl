use strict;
use warnings;

our %configuration;

sub define_hit
{

		# uploading the hit definition. This one is NON ACTIVE material!
		my %hit = init_hit();
		$hit{"name"}            = "alertshell";
		$hit{"description"}     = "alertshell hit is not sensitive, it is just for material budget";
		$hit{"identifiers"}     = "alertshell";
		$hit{"signalThreshold"} = "0.1*MeV";
		$hit{"timeWindow"}      = "0.1*ns";
		$hit{"prodThreshold"}   = "0.1*mm";
		$hit{"maxStep"}         = "0.2*mm";
		$hit{"delay"}           = "10*ns";
		$hit{"riseTime"}        = "50*ns";
		$hit{"fallTime"}        = "20*ns";
		$hit{"mvToMeV"}         = 100;
		$hit{"pedestal"}        = -20;
		print_hit(\%configuration, \%hit);

}
