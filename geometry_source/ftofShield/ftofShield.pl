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
	print "   ftofShield.pl <configuration filename>\n";
	print "   Will create the CLAS12 ftof shield in various configurations\n";
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

my @allConfs = ("pb0.1", "pb0.2", "pb0.5", "pb1");

my $rmin   = 240;
my $length = 420;
my $pos    = "0*mm 0*mm -80*mm";

foreach my $conf ( @allConfs )
{
	$configuration{"variation"} = $conf ;
	
	my $panel1b_mother_dx1 = 8.635;
	my $panel1b_mother_dx2 = 207.1;
	my $panel1b_mother_dz  = 189.619;
	
	my $pos = "0*cm -4.0*cm 0*cm";
	
	# thickness in mm
	my $panel1b_mother_dy  = 0.01; # 0.1 mm
	
	if($conf eq "pb0.2") {
		$panel1b_mother_dy = 0.02;
	} elsif($conf eq "pb0.5") {
		$panel1b_mother_dy = 0.05;
	} elsif($conf eq "pb1") {
		$panel1b_mother_dy = 0.1;
	}
	
	
	# loop over sectors
	for (my $isect = 0; $isect < 6; $isect++)
	{
		my $sector = $isect +1;
		
		my %detector = init_det();
		$detector{"name"}         = "ftof_p1bshield_sector$sector";
		$detector{"mother"}       = "ftof_p1b_s$sector";
		$detector{"description"}  = "Layer of lead - Sector $sector";
		$detector{"pos"}          = $pos;
		$detector{"rotation"}     = "0*deg 0*deg 0*deg";
		$detector{"color"}        = "222299";
		$detector{"type"}         = "Trd";
		$detector{"dimensions"}   = "$panel1b_mother_dx1*cm $panel1b_mother_dx2*cm $panel1b_mother_dy*cm $panel1b_mother_dy*cm $panel1b_mother_dz*cm";
		$detector{"material"}     = "G4_Pb";
		$detector{"visible"}      = 1;
		$detector{"style"}        = 1;
		print_det(\%configuration, \%detector);
	}
}



