use strict;
use warnings;

our %configuration;

sub materials
{
	# TDR 1100 is 100parts Bisphenol A  and 42parts hardener (Polyamide resin)
	# Bisphenol A is  (CH3)2C(C6H4OH)2 or 5C H14 O2
	# Hardnerer is 46H 4N 5O 24C (source: http://www.britannica.com/EBchecked/topic/468270/polyamide)
	# so the total is, accounting for the parts:
	# 32 H
	# 2 N
	# 4 O
	# 15 C
	# density is 1.16
	my %mat = init_mat();
	$mat{"name"}          = "tdr1100";
	$mat{"description"}   = "bst epoxy material (tdr1100) is 100parts Bisphenol A  and 42parts hardener";
	$mat{"density"}       = "1.16";
	$mat{"ncomponents"}   = "4";
	$mat{"components"}    = "H 32 N 2 O 4 C 15";
	print_mat(\%configuration, \%mat);
	
	# Peek chemical formula (C19 H12 O3)
	%mat = init_mat();
	$mat{"name"}          = "peek";
	$mat{"description"}   = "bst peek";
	$mat{"density"}       = "1.31";
	$mat{"ncomponents"}   = "3";
	$mat{"components"}    = "C 19 H 12 O 3";
	print_mat(\%configuration, \%mat);
	
	# Carbon Fiber
	# 74.5% C
	# 25.5% tdr1100 (epoxy)
	%mat = init_mat();
	$mat{"name"}          = "carbonFiber";
	$mat{"description"}   = "bst carbon fiber material";
	$mat{"density"}       = "1.75";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_C 0.745 tdr1100 0.255";
	print_mat(\%configuration, \%mat);
	
	# Neoprene foam
	%mat = init_mat();
	$mat{"name"}          = "neoprene";
	$mat{"description"}   = "faraday cage neoprene material";
	$mat{"density"}       = "0.1";
	$mat{"ncomponents"}   = "3";
	$mat{"components"}    = "G4_H 0.05692 G4_C 0.542646 G4_Cl 0.400434";
	print_mat(\%configuration, \%mat);

	# PC Board
	%mat = init_mat();
	$mat{"name"}          = "pcBoardMaterial";
	$mat{"description"}   = "bst pc board material";
	$mat{"density"}       = "1.860";
	$mat{"ncomponents"}   = "3";
	$mat{"components"}    = "G4_Fe 0.3 G4_C 0.4 G4_Si 0.3";
	print_mat(\%configuration, \%mat);
    
	# Rohacell
	%mat = init_mat();
	$mat{"name"}          = "rohacell";
	$mat{"description"}   = "bst rohacell material";
	$mat{"density"}       = "0.1";
	$mat{"ncomponents"}   = "4";
	$mat{"components"}    = "G4_C 0.6465 G4_H 0.0784 G4_N 0.0839 G4_O 0.1912";
	print_mat(\%configuration, \%mat);
    
	# Rohacell110
	%mat = init_mat();
	$mat{"name"}          = "rohacell110";
	$mat{"description"}   = "faraday cage rohacell material";
	$mat{"density"}       = "0.11";
	$mat{"ncomponents"}   = "4";
	$mat{"components"}    = "G4_C 0.6465 G4_H 0.0784 G4_N 0.0839 G4_O 0.1912";
	print_mat(\%configuration, \%mat);
    
	# wirebonds
	%mat = init_mat();
	$mat{"name"}          = "svtwirebond";
	$mat{"description"}   = "wirebond material";
	$mat{"density"}       = "2.69";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_Al 0.99 G4_Si 0.01";
    
	# bst aluminized mylar
	%mat = init_mat();
	$mat{"name"}          = "bstalmylar";
	$mat{"description"}   = "bst aluminized mylar material - 2% Al and the rest is mylar";
	$mat{"density"}       = "1.4";
	$mat{"ncomponents"}   = "4";
	$mat{"components"}    = "G4_Al 0.02 G4_H 0.03 G4_C 0.63 G4_O 0.32";
	print_mat(\%configuration, \%mat);

	# silver epoxy
	%mat = init_mat();
	$mat{"name"}          = "SilverEpoxy";
	$mat{"description"}   = "silver epoxy, density based on percentages - silver is 9.32 g/cm3";
	$mat{"density"}       = "3.608";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "tdr1100 0.7 G4_Ag 0.3";
	print_mat(\%configuration, \%mat);
	
	# glue + polyiamide coverlay
	%mat = init_mat();
	$mat{"name"}          = "EpoxyPolyI";
	$mat{"description"}   = "glue + polyiamide coverlay -  12.7 microns of p.c. 65 microns of epoxy";
	$mat{"density"}       = "3.608";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "tdr1100 0.83 G4_POLYETHYLENE 0.17";
	print_mat(\%configuration, \%mat);
	
	# bus cable with mesh, is a mix of copper and kapton
	# the mesh is 0.381mm width with a pitch of 6mm
	# so the percentage of  actual copper is 0.381*4 / 6    (4 sides on the square)
	# that's 25.4% of the 3 microns thikness. The polyimide is 25.4 microns.
	# copper density is 8.94 polyiamide density is 0.94
	# percentage of poly: 25.4*0.94 / (25.4*0.94 + 25% * 3 *8.94)   =   / 30.581
	# percentage of Cu: 25% * 3 *8.94 / (25.4*0.94 + 25% * 3 *8.94) =   / 30.581
	%mat = init_mat();
	$mat{"name"}          = "BusCable";
	$mat{"description"}   = "ilver epoxy, density based on percentages - silver is 9.32 g/cm3";
	$mat{"density"}       = "2.692";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_Cu 0.219 G4_POLYETHYLENE 0.781";
	print_mat(\%configuration, \%mat);
	
	# the pad is made of:
	# 0.2 microns Au
	# 3.81 microns Ni
	# 25.4 microns Cu
	# total is 29.41 microns
	# 50 microns is epoxy
	# so total thickness is 79.41
	# gold density is 19.3
	# nickel density is 7.8
	# copper density is 8.94
	# S.E density is 3.608
	# total rad thickness is sum (d_i * l*i) = 0.2*19.3 + 3.81*7.8 + 25.4*8.94 + 50*3.608 = 412.098
	# thickness of average material is tot rad thick / thickness (in microns)
	# individual thicknesses are d_i*l_i / sum
	%mat = init_mat();
	$mat{"name"}          = "BusCableCopperAndNickelAndGold";
	$mat{"description"}   = "bus cable copper and nickel and gold";
	$mat{"density"}       = "5.16";
	$mat{"ncomponents"}   = "4";
	$mat{"components"}    = "G4_Cu 0.552 G4_Ni 0.072 G4_Au 0.009 SilverEpoxy 0.367";
	print_mat(\%configuration, \%mat);

	# Bst_Tungsten shielding
	my %mat = init_mat();
	$mat{"name"}          = "bst_W";
	$mat{"description"}   = "bst tungsten alloy 17.6 g/cm3";
	$mat{"density"}       = "17.6";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_Fe 0.08 G4_W 0.92";
	print_mat(\%configuration, \%mat);

}


