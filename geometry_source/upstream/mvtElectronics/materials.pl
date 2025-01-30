use strict;
use warnings;

our %configuration;

sub materials
{	
	# carbon fiber
	my %mat = init_mat();
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
	$mat{"ncomponents"}   = "4";  # 1 Si atom, 2 Oxygen, 3 Carbon, and 3 Hydrogen
	$mat{"components"}    = "G4_Si 0.283 G4_O 0.323  G4_C 0.364  G4_H 0.030";
	print_mat(\%configuration, \%mat);
	
}


