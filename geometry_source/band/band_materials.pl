use strict;
use warnings;

our %configuration;

sub materials
{	
	# EJ-200 or BC-408 Scintillant
	my %mat = init_mat();
	$mat{"name"}          = "ej200";
	$mat{"description"}   = "band scintillator material";
	$mat{"density"}       = "1.023"; # g/cm^3 or g/cc
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_C 0.915 G4_H 0.085";	
	print_mat(\%configuration, \%mat);

#####
	# CTOF Scintillator
	%mat = init_mat();
	$mat{"name"}          = "scintillator";
	$mat{"description"}   = "ctof scintillator material";
	$mat{"density"}       = "1.032";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "C 9 H 10";	
	print_mat(\%configuration, \%mat);

	# Hiperm-49
	%mat = init_mat();
	$mat{"name"}          = "hiperm49";
	$mat{"description"}   = "ctof pmt shield material";
	$mat{"density"}       = "18.4";  # 0.295 lb/in3 ~ 18.4375 g/cm3
	$mat{"ncomponents"}   = "5"; # OLD "7";
	$mat{"components"}    = "G4_Ni 0.48 G4_Mg 0.005 G4_Si 0.0035 G4_C 0.0002 G4_Fe 0.5113";
	# OLD $mat{"components"}    = "G4_Ni 0.48 G4_P 0.0002 G4_Si 0.005 G4_Mn 0.008 G4_C 0.00035 G4_S 0.00008 G4_Fe 0.50637";
	print_mat(\%configuration, \%mat);

	# CO-NETIC
	%mat = init_mat();
	$mat{"name"}          = "conetic";
	$mat{"description"}   = "pmt shield material";
	$mat{"density"}       = "8.7";  # 0.316 lb/in3 ~ 18.4375 g/cm3
	$mat{"ncomponents"}   = "6";
	$mat{"components"}    = "G4_Ni 0.79080 G4_Fe 0.13069 G4_Mo 0.07202 G4_Si 0.00188 G4_Mn 0.00459 G4_C 0.00002";
	print_mat(\%configuration, \%mat);

#####
	%mat = init_mat();
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

	# lHe gas
	%mat = init_mat();
	$mat{"name"}          = "HeGas";
	$mat{"description"}   = "Upstream He gas ";
	$mat{"density"}        = "0.000164";  # 0.164 kg/m3 <—————————————
	$mat{"ncomponents"}   = "1";
	$mat{"components"}    = "G4_He 1";
	print_mat(\%configuration, \%mat);

#####
	# MuShield
	%mat = init_mat();
	$mat{"name"}          = "mushield";
	$mat{"description"}   = "MuShield magnetic shielding material";
	$mat{"density"}       = "8.747";  # 0.316 lb/in^3 ~ 8747 kg/m^3
	$mat{"ncomponents"}   = "6";
	$mat{"components"}    = "G4_C 0.00004 G4_Ni 0.78654 G4_Mn 0.00460 G4_Mo 0.06751 G4_Si 0.00165 G4_Fe 0.13966";
	print_mat(\%configuration, \%mat);

	# MuMETAL(R) 
	%mat = init_mat();
	$mat{"name"}          = "mumetal";
	$mat{"description"}   = "ctof pmt shield material";
	$mat{"density"}       = "8.747";  # 0.316 lb/in3 ~ 8.7 g/cm3
	$mat{"ncomponents"}   = "6"; #  ncomponents: "6,11,8,8,6,4,4,4";
	$mat{"components"}    = "G4_Ni 0.81 G4_Mo 0.05 G4_Si 0.005 G4_Mn 0.005 G4_C 0.0005 G4_Fe 0.1295";
	# RANGE iqsdirectory.c G4_Ni 0.80-0.81 G4_Mo 0.045-0.06 G4_Si 0.005-0.04 G4_Mn 0-0.005 G4_C 0.001 G4_Fe balance
	# RANGE mu-metal.com   G4_Ni 0.80-0.82 G4_Mo 0.035-0.06 G4_Mn 0.008max G4_Si 0.005max G4_Co 0.005max
	#                      G4_Cu 0.003max G4_Cr 0.003max G4_P 0.0002max G4_S 0.0001max G4_C 0.0005max G4_Fe balance
	# Both HY-MU 80 and MIL-N-14411 C from aircraftmaterials.com and harshsteel.com
	# RANGE (HY-MU 80)     G4_Ni 0.790-0.806 G4_S 0.00008 G4_P 0.0002 G4_Si 0.0042
	#        Permalloy     G4_Mn 0-0.0095 G4_C 0.0003 G4_Mo 0.038-0.05 G4_Fe rem
	# RANGE (MIL N 14411C) G4_Ni 0.750-0.770 G4_Cu 0.04-0.06 G4_Cr 0.030 G4_S 0.0002
	#        ASTM A753     G4_P 0.0002 G4_Si 0.0050 G4_Mn 0.018 G4_C 0.0005
	# RANGE spacematdb.com G4_Ni 0.80 G4_Mo 0.042 G4_Mn 0.005 G4_Si 0.0035 G4_C 0.0002 G4_Fe rem     [aka "hynu80"]
	# RANGE matbase.com    G4_Ni 0.77 G4_Fe rest G4_Cu 0.05 G4_Cr 0.0015 [density 8600 kg/m^3]
	# RANGE wikipedia         G4_Ni 0.77 G4_Fe 0.16 G4_Cu 0.05 G4_[Cr or Mo] 0.02
	# RANGE ASTM A753 Alloy 4 G4_Ni 0.80 G4_Mo 0.05 G4_Si ? G4_Fe 0.12-0.15
	print_mat(\%configuration, \%mat);

	# Permalloy80 fotofab.com and wikipedia
	%mat = init_mat();
	$mat{"name"}          = "permalloy80";
	$mat{"description"}   = "magnetic shielding material";
	$mat{"density"}       = "8.747";  # 0.316 lb/in^3 ~ 8747 kg/m^3 ?
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_Ni 0.80 G4_Fe 0.20";
	print_mat(\%configuration, \%mat);

	# Alperm [Alfenol 16, Vacodur 16, IU 16] wikipedia
	%mat = init_mat();
	$mat{"name"}          = "alperm";
	$mat{"description"}   = "magnetic shielding material";
	$mat{"density"}       = "8";  # ? lb/in^3 ~ ? kg/m^3
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_Fe 0.84 G4_Al 0.16";
	# RANGE  wikipedia     G4_Fe 0.83-0.90 G4_Al 0.10-0.17 [density 8600 kg/m^3]
	print_mat(\%configuration, \%mat);

	# Alfer   wikipedia
	%mat = init_mat();
	$mat{"name"}          = "alfer";
	$mat{"description"}   = "magnetic shielding material";
	$mat{"density"}       = "8";  # ? lb/in^3 ~ ? kg/m^3
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_Fe 0.87 G4_Al 0.13";
	print_mat(\%configuration, \%mat);

	# Supermalloy matbase.com and wikipedia
	%mat = init_mat();
	$mat{"name"}          = "supermalloy";
	$mat{"description"}   = "magnetic shielding material";
	$mat{"density"}       = "8.8";  # 8800 kg/m^3
	$mat{"ncomponents"}   = "3";
	$mat{"components"}    = "G4_Ni 0.75 G4_Fe 0.20 G4_Mo 0.05";
	print_mat(\%configuration, \%mat);

	# Sendust cwsbytemark.com and wikipedia
	%mat = init_mat();
	$mat{"name"}          = "sendust";
	$mat{"description"}   = "magnetic shielding material";
	$mat{"density"}       = "8";  # ?
	$mat{"ncomponents"}   = "3";
	$mat{"components"}    = "G4_Fe 0.85 G4_Al 0.06 G4_Si 0.09";
	print_mat(\%configuration, \%mat);
	
}


