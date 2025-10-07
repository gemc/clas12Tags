use strict;
use warnings;

our %configuration;


sub materials
{
	# Beamline_Tungsten
	my %mat = init_mat();
	$mat{"name"}          = "beamline_W";
	$mat{"description"}   = "beamline tungsten alloy 17.6 g/cm3";
	$mat{"density"}       = "17.6";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_Fe 0.08 G4_W 0.92";
	print_mat(\%configuration, \%mat);

	# Carbon Steel ASTM A36 - this come from google
	%mat = init_mat();
	$mat{"name"}          = "beamline_CarbonSteel";
	$mat{"description"}   = "beamline carbon steel ASTM A36 7.85 g/cm3";
	$mat{"density"}       = "7.85";
	$mat{"ncomponents"}   = "6";
	$mat{"components"}    = "G4_Fe 0.98 G4_C 0.003 G4_Si 0.002 G4_Mn 0.01 G4_P 0.003 G4_Cu 0.002";
	print_mat(\%configuration, \%mat);


}






