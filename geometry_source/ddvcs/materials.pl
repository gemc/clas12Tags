use strict;
use warnings;

our %configuration;

sub materials
{
	# uploading the mat definition
	
	
   # Beamline_Tungsten
   my %mat = init_mat();
   $mat{"name"}          = "beamline_W";
   $mat{"description"}   = "beamline tungsten alloy 17.6 g/cm3";
   $mat{"density"}       = "17.6";
   $mat{"ncomponents"}   = "2";
   $mat{"components"}    = "G4_Fe 0.08 G4_W 0.92";
   print_mat(\%configuration, \%mat);

	%mat = init_mat();
   $mat{"name"}          = "ddvcs_W";
   $mat{"description"}   = "ddvcs tungsten alloy 17.6 g/cm3";
   $mat{"density"}       = "17.6";
   $mat{"ncomponents"}   = "2";
   $mat{"components"}    = "G4_Fe 0.08 G4_W 0.92";
   print_mat(\%configuration, \%mat);

	# rohacell
	$mat{"name"}          = "rohacell";
	$mat{"description"}   = "target  rohacell scattering chamber material";
	$mat{"density"}       = "0.1";  # 100 mg/cm3
	$mat{"ncomponents"}   = "4";
	$mat{"components"}    = "G4_C 0.6465 G4_H 0.0784 G4_N 0.0839 G4_O 0.1912";
	print_mat(\%configuration, \%mat);

}


