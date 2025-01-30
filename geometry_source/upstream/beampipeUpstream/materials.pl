use strict;
use warnings;

our %configuration;



sub materials
{
	my $thisVariation = $configuration{"variation"} ;
	
	my %mat = init_mat();
	# rohacell
	$mat{"name"}          = "rohacell";
	$mat{"description"}   = "target  rohacell scattering chamber material";
	$mat{"density"}       = "0.1";  # 100 mg/cm3
	$mat{"ncomponents"}   = "4";
	$mat{"components"}    = "G4_C 0.6429 G4_H 0.0065 G4_N 0.0973 G4_O 0.2533";
	print_mat(\%configuration, \%mat);


	# epoxy
	%mat = init_mat();
	$mat{"name"}          = "epoxy";
	$mat{"description"}   = "epoxy glue 1.16 g/cm3";
	$mat{"density"}       = "1.16";
	$mat{"ncomponents"}   = "4";
	$mat{"components"}    = "H 32 N 2 O 4 C 15";
	print_mat(\%configuration, \%mat);


	# carbon fiber
	%mat = init_mat();
	$mat{"name"}          = "carbonFiber";
	$mat{"description"}   = "ft carbon fiber material is epoxy and carbon - 1.75g/cm3";
	$mat{"density"}       = "1.75";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_C 0.745 epoxy 0.255";
	print_mat(\%configuration, \%mat);


	# G10 fiberglass
	%mat = init_mat();
	$mat{"name"}          = "G10";
	$mat{"description"}   = "G10 - 1.70 g/cm3";
	$mat{"density"}       = "1.70";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_SILICON_DIOXIDE 0.60 epoxy 0.40";
	print_mat(\%configuration, \%mat);
}
