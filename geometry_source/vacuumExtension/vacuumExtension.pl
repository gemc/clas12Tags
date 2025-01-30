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
	print "   vacuumExtension.pl <configuration filename>\n";
	print "   Will create the CLAS12 vacuumExtension in various configurations\n";
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

my @allConfs = ( "original", "cone21", "cone30");


# Adding the neoprene insulation Heat Shield

my $VErmin   = 15;
my $VErmax   = $VErmin + 6;  # 2mm thickness
my $VElength = 320.0;

# should start 5cm from downstream end of the scattering chamber
# so at 350
my $pos = 300 + $VElength ;

foreach my $conf ( @allConfs )
{
	$configuration{"variation"} = $conf ;

	my $thisVariation = $configuration{"variation"} ;

	if($thisVariation eq "original") {

		my %detector = init_det();

		$detector{"name"}        = "extensionVacuumCarbonShell";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Vacuum extension made of carbon fiber";
		$detector{"color"}       = "222222";
		$detector{"type"}        = "Tube";
		$detector{"material"}    = "rohacell";
		
		$detector{"pos"}         =  "0*mm 0*mm $pos*mm" ;

		my $dimen = "0*mm $VErmax*mm $VElength*mm 0*deg 360*deg";

		$detector{"dimensions"}  = $dimen;
		$detector{"visible"}     = 1;
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);


		%detector = init_det();

		$detector{"name"}        = "extensionVacuum";
		$detector{"mother"}      = "extensionVacuumCarbonShell";
		$detector{"description"} = "Vacuum inside";
		$detector{"color"}       = "ff8888";
		$detector{"type"}        = "Tube";


		$dimen = "0*mm $VErmin*mm $VElength*mm 0*deg 360*deg";

		$detector{"dimensions"}  = $dimen;
		$detector{"visible"}     = 1;
		$detector{"style"}       = 1;
		$detector{"material"}    = "G4_Galactic";
		print_det(\%configuration, \%detector);
	}
	elsif($thisVariation eq "cone21") {

		my $nzplanes = 5;

		my @IR      = (   0.0  ,     0.0   ,   0.0  ,    0.0,   0.0);   # Inner radii
		my @OR      = (  31.0  ,    31.0   ,  21.0  ,   21.0,   0.0);   # Outer radii
		my @ORV     = (  21.0  ,    21.0   ,  15.0  ,   15.0,   15.0);  # Vacuum Outer radii
		my @zplane  = ( 300.0  ,   400.0   , 400.0  ,  960.0,  960.0);
		my @zplanev = ( 300.0  ,   390.0   , 390.0  ,  960.0,  960.0);


		my $dimensions = "0.0*deg 360*deg $nzplanes*counts";
		for(my $i = 0; $i <$nzplanes ; $i++) { $dimensions = $dimensions ." $IR[$i]*mm"; }
		for(my $i = 0; $i <$nzplanes ; $i++) { $dimensions = $dimensions ." $OR[$i]*mm"; }
		for(my $i = 0; $i <$nzplanes ; $i++) { $dimensions = $dimensions ." $zplane[$i]*mm"; }

		my %detector = init_det();
		$detector{"name"}        = "extensionVacuumRohacellShell";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Vacuum extension made of carbon fiber";
		$detector{"color"}       = "222222";
		$detector{"type"}        = "Polycone";
		$detector{"dimensions"}  = $dimensions;
		$detector{"material"}    = "rohacell";
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);

		my $dimensionsv = "0.0*deg 360*deg $nzplanes*counts";
		for(my $i = 0; $i <$nzplanes ; $i++) { $dimensionsv = $dimensionsv ." $IR[$i]*mm"; }
		for(my $i = 0; $i <$nzplanes ; $i++) { $dimensionsv = $dimensionsv ." $ORV[$i]*mm"; }
		for(my $i = 0; $i <$nzplanes ; $i++) { $dimensionsv = $dimensionsv ." $zplanev[$i]*mm"; }

		%detector = init_det();
		$detector{"name"}        = "extensionVacuum";
		$detector{"mother"}      = "extensionVacuumRohacellShell";
		$detector{"description"} = "Vacuum extension made of carbon fiber";
		$detector{"color"}       = "99aabb";
		$detector{"type"}        = "Polycone";
		$detector{"dimensions"}  = $dimensionsv;
		$detector{"material"}    = "G4_Galactic";
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);

	}

	elsif($thisVariation eq "cone30") {

		my $nzplanes = 5;

		my @IR      = (   0.0  ,     0.0   ,   0.0  ,    0.0,   0.0);   # Inner radii
		my @OR      = (  40.0  ,    40.0   ,  21.0  ,   21.0,   0.0);   # Outer radii
		my @ORV     = (  30.0  ,    30.0   ,  15.0  ,   15.0,   15.0);  # Vacuum Outer radii
		my @zplane  = ( 300.0  ,   400.0   , 400.0  ,  960.0,  960.0);
		my @zplanev = ( 300.0  ,   390.0   , 390.0  ,  960.0,  960.0);


		my $dimensions = "0.0*deg 360*deg $nzplanes*counts";
		for(my $i = 0; $i <$nzplanes ; $i++) { $dimensions = $dimensions ." $IR[$i]*mm"; }
		for(my $i = 0; $i <$nzplanes ; $i++) { $dimensions = $dimensions ." $OR[$i]*mm"; }
		for(my $i = 0; $i <$nzplanes ; $i++) { $dimensions = $dimensions ." $zplane[$i]*mm"; }

		my %detector = init_det();
		$detector{"name"}        = "extensionVacuumRohacellShell";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Vacuum extension made of carbon fiber";
		$detector{"color"}       = "222222";
		$detector{"type"}        = "Polycone";
		$detector{"dimensions"}  = $dimensions;
		$detector{"material"}    = "rohacell";
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);

		my $dimensionsv = "0.0*deg 360*deg $nzplanes*counts";
		for(my $i = 0; $i <$nzplanes ; $i++) { $dimensionsv = $dimensionsv ." $IR[$i]*mm"; }
		for(my $i = 0; $i <$nzplanes ; $i++) { $dimensionsv = $dimensionsv ." $ORV[$i]*mm"; }
		for(my $i = 0; $i <$nzplanes ; $i++) { $dimensionsv = $dimensionsv ." $zplanev[$i]*mm"; }

		%detector = init_det();
		$detector{"name"}        = "extensionVacuum";
		$detector{"mother"}      = "extensionVacuumRohacellShell";
		$detector{"description"} = "Vacuum extension made of carbon fiber";
		$detector{"color"}       = "99aabb";
		$detector{"type"}        = "Polycone";
		$detector{"dimensions"}  = $dimensionsv;
		$detector{"material"}    = "G4_Galactic";
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);





	}
}




