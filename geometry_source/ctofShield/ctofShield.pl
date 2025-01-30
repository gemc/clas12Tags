#!/usr/bin/perl -w


use strict;
use lib ("$ENV{GEMC}/api/perl");
use utils;
use geometry;

use Math::Trig;

# Help Message
sub help()
{
	print "\n Usage: \n";
	print "   ctofShield.pl <configuration filename>\n";
 	print "   Will create the CLAS12 ctof shield in various configurations\n";
	exit;
}

# Make sure the argument list is correct
if( scalar @ARGV != 1) 
{
	help();
	exit;
}

# Loading configuration file and parameters
our %configuration = load_configuration($ARGV[0]);

my @allConfs = ("w0.1");
#my @allConfs = ("w0.5", "w1", "w2", "w3");

my $rmin   = 240;
my $length = 420;
my $pos    = "0*mm 0*mm -80*mm";

foreach my $conf ( @allConfs )
{
	$configuration{"variation"} = $conf ;
	
	my %detector = init_det();
	
	$detector{"name"}        = "ctofShield";
	$detector{"mother"}      = "root";
	$detector{"description"} = "ctof tungsten shielding";
	$detector{"color"}       = "ff88aa";
	$detector{"type"}        = "Tube";
	$detector{"pos"}         =  $pos ;
	$detector{"material"}    = "beamline_W";

	my $rmax = 0;

	if($conf eq "w0.1") {
		$rmax = $rmin + 0.1;
	} elsif($conf eq "w1") {
		$rmax = $rmin + 1;
	} elsif($conf eq "w2") {
		$rmax = $rmin + 2;
	} elsif($conf eq "w3") {
		$rmax = $rmin + 3;
	} elsif($conf eq "w0.5") {
		$rmax = $rmin + 0.5;
	}
	
	my $dimen = "$rmin*mm $rmax*mm $length*mm 0*deg 360*deg";

	$detector{"dimensions"}  = $dimen;
	$detector{"visible"}     = 1;
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
}




