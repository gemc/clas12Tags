#!/usr/bin/perl -w

use strict;
use lib ("$ENV{GEMC}/api/perl");
use utils;
use geometry;
use math;

our %configuration;

# this script builds shielding blocks
# that parallel the beamline in the
# space below drift chambers

my $zPos   = 15.1855*$inches;
my $le_z   = 9.40*$inches/2.0;

# block params in cm
my $bottom = 2;
my $top    = 10;
my $height = 10;


sub torusShield
{
	# loop over torus sectors
	for(my $i=0; $i<6; $i++)
	{
		my %detector = init_det();
		
		$detector{"name"}        = "torusShieldingBlock_$i";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Torus shielding block";
		$detector{"pos"}         = position($i);
		$detector{"rotation"}    = rotation($i);
		$detector{"color"}       = "993333";
		$detector{"type"}        = "G4Trap";
		$detector{"dimensions"}  = "$le_z*cm 0*deg 0*deg $height*cm $bottom*cm $top*cm 0*deg $height*cm $bottom*cm $top*cm 0*deg";
		$detector{"material"}    = "G4_Pb";
		$detector{"style"}     = 1;
		
		print_det(\%configuration, \%detector);
	}
	
}


sub position
{
	my $sector = shift;
	my $phi    =  $sector*60;
	
	my $r   = 42.0/2;
	my $x   = fstr($r*cos(rad($phi)));
	my $y   = fstr($r*sin(rad($phi)));
	my $z   = $zPos;
	
	return "$x*cm $y*cm $z*cm";
}

sub rotation
{
	my $sector = shift;
	my $zrot  = 90 - $sector*60;
	
	return "ordered: zxy $zrot*deg 0*deg 0*deg ";
}


