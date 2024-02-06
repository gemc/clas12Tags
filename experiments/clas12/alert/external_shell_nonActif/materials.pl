use strict;
use warnings;

our %configuration;

sub materials
{
	# HE4_gas_3atm
	my %mat = init_mat();
	$mat{"name"}          ="He4_gas_3atm";
	$mat{"description"}   = "Target gas";
	$mat{"density"}       = "0.000487";  # in g/cm3
	$mat{"ncomponents"}   = "1";
	$mat{"components"}    = "G4_He 1";
	print_mat(\%configuration, \%mat);
	
	# HECO2
	%mat = init_mat();
	$mat{"name"}          ="HECO2";
	$mat{"description"}   = "Wires layer gas";
	$mat{"density"}       = "0.000487";  # in g/cm3
	$mat{"ncomponents"}   = "3";
	$mat{"components"}    = "He 1 C 1 O 2";
	print_mat(\%configuration, \%mat);
	
	# BC404
	%mat = init_mat();
	$mat{"name"}          ="BC404";
	$mat{"description"}   = "Scintillator layer";
	$mat{"density"}       = "1.032";  # in g/cm3
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "H 9 C 10";
	print_mat(\%configuration, \%mat);
	
	# Epoxy only
	%mat = init_mat();
	$mat{"name"}          ="EpoxyOnly";
	$mat{"description"}   = "Epoxy only for back and front DC covers";
	$mat{"density"}       = "1.2";  # in g/cm3
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "H 2 C 2";
	print_mat(\%configuration, \%mat);
	
	# SiO2 only
	%mat = init_mat();
	$mat{"name"}          ="SiO2";
	$mat{"description"}   = "SiO2";
	$mat{"density"}       = "2.2";  # in g/cm3
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "Si 1 O 2";
	print_mat(\%configuration, \%mat);
	
	# Epoxy + GlassFiber 
	%mat = init_mat();
	$mat{"name"}          ="EpoxyFiberGlass";
	$mat{"description"}   = "Epoxy FiberGlass back and front DC covers";
	$mat{"density"}       = "1.85";  # in g/cm3
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "EpoxyOnly 0.35 SiO2 0.65";
	print_mat(\%configuration, \%mat);

}
