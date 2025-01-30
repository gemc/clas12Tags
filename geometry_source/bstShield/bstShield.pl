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
	print "   bstShield.pl <configuration filename>\n";
 	print "   Will create the CLAS12 bst shield in various configurations\n";
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

my @allConfs = ( "w51", "w51-rge");

my $rmin   = 51;
my $rmin_rge   = 52.1;
my $length = 180;
my $pos    = "0*mm 0*mm -50*mm";

# Adding the neoprene insulation Heat Shield

my $HSrmin   = 130.0;
my $HSlength = 270.0;
my $HSpos    = "0*mm 0*mm -10*mm";

foreach my $conf ( @allConfs )
{
	$configuration{"variation"} = $conf ;
	
	my %detector = init_det();
	
	$detector{"name"}        = "bstShield";
	$detector{"mother"}      = "root";
	$detector{"description"} = "bst shielding";
	$detector{"color"}       = "88aaff";
	$detector{"type"}        = "Tube";
	$detector{"pos"}         =  $pos ;

	my $rmax = 0;
	
	if($conf eq "w51") {
		$rmax = $rmin + 0.051;
		$detector{"material"}    = "beamline_W";
	}

	elsif($conf eq "w51-rge") {
		$rmin = $rmin_rge;
		$rmax = $rmin + 0.051;
		$detector{"material"}    = "G4_W";
	}
	
	my $dimen = "$rmin*mm $rmax*mm $length*mm 0*deg 360*deg";

	$detector{"dimensions"}  = $dimen;
	$detector{"visible"}     = 1;
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
}




