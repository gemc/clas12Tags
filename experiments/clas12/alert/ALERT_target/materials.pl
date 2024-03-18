use strict;
use warnings;

our %configuration;



sub materials
{
	my $thisVariation = $configuration{"variation"} ;
	
	my %mat = init_mat();
	if($thisVariation ne "PolTarg")
	{
	# rohacell
	$mat{"name"}          = "rohacell";
	$mat{"description"}   = "target  rohacell scattering chamber material";
	$mat{"density"}       = "0.1";  # 100 mg/cm3
	$mat{"ncomponents"}   = "4";
	$mat{"components"}    = "G4_C 0.6465 G4_H 0.0784 G4_N 0.0839 G4_O 0.1912";
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
	}
	
	if($thisVariation eq "PolTarg")
	{

	# carbon fiber
	%mat = init_mat();
	$mat{"name"}          = "carbonFiber";
	$mat{"description"}   = "carbon fiber material is epoxy and carbon - 1.75g/cm3";
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

	# lHe gas
	%mat = init_mat();
	$mat{"name"}          = "HeGas";
	$mat{"description"}   = "Upstream He gas ";
	$mat{"density"}        = "0.000164";  # 0.164 kg/m3 <—————————————
	$mat{"ncomponents"}   = "1";
	$mat{"components"}    = "G4_He 1";
	print_mat(\%configuration, \%mat);


	# Al target cell(s)
	%mat = init_mat();
	$mat{"name"}          = "AlCell";
	$mat{"description"}   = "Aluminum for target cells ";
	$mat{"density"}        = "2.70";  # 2.7 g/cm3 <—————————————
	$mat{"ncomponents"}   = "1";
	$mat{"components"}    = "G4_Al 1";

	print_mat(\%configuration, \%mat);

	# Shim coils, need to confirm mass fractions and density
	%mat = init_mat();
	my %mat = init_mat();
	my $NbTi_density=6.63;
	#my $NbTi_density=(0.475*8.57+0.525*4.54);

	my $ShimCoil_density=(1.3*8.96+$NbTi_density)/2.3;
	my $Cu_mass_fraction=29/(29+41+22);
	my $Nb_mass_fraction=41/(29+41+22);
	my $Ti_mass_fraction=22/(29+41+22);
	$mat{"name"}          = "ShimCoil";
	$mat{"description"}   = "Cu/NbTi correction coils ratio is 1.3 Cu  to 1 NbTi ";
	$mat{"density"}        = $ShimCoil_density;  #Cu=8.96 g/cm3 NbTi= 4.5 g/cm3 = Nb-47.5 wt % Ti 47.5% of the materials weight is Nb <—————————————
	$mat{"ncomponents"}   = "3";
	$mat{"components"}    = "G4_Cu $Cu_mass_fraction G4_Nb $Nb_mass_fraction G4_Ti $Ti_mass_fraction";
	print_mat(\%configuration, \%mat);

	# Target cup walls with holes, need to confirm mass ratios
	#my %mat = init_mat();
	my $my_density = 2.135; # 2 C, 3 F, 1 Cl
	my $C_mass_fraction=2*12/(2*12+3*19+35);
	my $F_mass_fraction=3*19/(2*12+3*19+35);
	my $Cl_mass_fraction=35/(2*12+3*19+35);
	$mat{"name"}          = "AmmoniaCellWalls";
	$mat{"description"}   = "PCTFE target cell walls with holes C_2ClF_3";
	$mat{"density"}        = $my_density;  #2.10-2.17 g/cm3  has a dipole moment <—————————————
	$mat{"ncomponents"}   = "3";
	$mat{"components"}    = "G4_C $C_mass_fraction G4_Cl $Cl_mass_fraction G4_F $F_mass_fraction";
	print_mat(\%configuration, \%mat);

	# lHe coolant
	%mat = init_mat();
	$mat{"name"}          = "lHeCoolant";
	$mat{"description"}   = "liquid He coolant for the polarized target cell";
	$mat{"density"}        = "0.147";  # 0.145 g/cm3 <—————————————
	$mat{"ncomponents"}   = "1";
	$mat{"components"}    = "G4_He 1";
	print_mat(\%configuration, \%mat);

	# NH3 
	#my %mat = init_mat();
	my $NH3_density = 0.867; 
	my $N_mass_fraction=15/18;
	my $H_mass_fraction=3/18;
	$mat{"name"}          = "NH3";
	$mat{"description"}   = "NH3 material";
	$mat{"density"}        = $NH3_density ; 
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_N $N_mass_fraction G4_H $H_mass_fraction";
	print_mat(\%configuration, \%mat);

	# NH3 target with lHe3 coolant
	#my %mat = init_mat();
	my $NH3trg_density = 0.6*0.867+0.4*0.145; # 60% of ND3 and 40% of liquid-helium
	my $NH3_mass_fraction=0.6*0.867/$NH3trg_density ;
	my $lHe_mass_fraction=0.4*0.145/$NH3trg_density ;
	$mat{"name"}          = "NH3target";
	$mat{"description"}   = "solid NH3 target";
	$mat{"density"}        =  $NH3trg_density;
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "NH3 $NH3_mass_fraction lHeCoolant $lHe_mass_fraction";
	print_mat(\%configuration, \%mat);

	# ND3 , not sure if G4 has H2 material so used H for now
	#my %mat = init_mat();
	my $ND3_density = 1.007; 
	my $NN_mass_fraction=15/21;
	my $H2_mass_fraction=6/21;
	$mat{"name"}          = "ND3";
	$mat{"description"}   = "ND3 material";
	$mat{"density"}        = $ND3_density ; 
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_N $NN_mass_fraction G4_H $H2_mass_fraction";
		#	print_mat(\%configuration, \%mat);

	# ND3 target with lHe3 coolant
	#my %mat = init_mat();
	my $ND3targ_density = 0.6*1.007+0.4*0.145; # 60% of ND3 and 40% of liquid-helium
	my $ND3_mass_fraction=0.6*1.007/$ND3targ_density;
	my $llHe_mass_fraction=0.4*0.145/$ND3targ_density;
	$mat{"name"}          = "ND3target";
	$mat{"description"}   = "solid ND3 target";
	$mat{"density"}        =  $ND3targ_density;
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "ND3 $ND3_mass_fraction lHeCoolant $llHe_mass_fraction";
	print_mat(\%configuration, \%mat);
	


	}	

	if($thisVariation eq "ND3")
	{
		#my %mat = init_mat();
		#$mat{"name"}          = "solidND3";
		#$mat{"description"}   = "solid ND3 target";
		#$mat{"density"}       = "1.007";  # 1.007 g/cm3
		#$mat{"ncomponents"}   = "1";
		#$mat{"components"}    = "ND3 1";
		#print_mat(\%configuration, \%mat);
		my %mat = init_mat();
		$mat{"name"}          = "lHe";
		$mat{"description"}   = "liquid helium";
		$mat{"density"}        = "0.145";  # 0.145 g/cm3 <—————————————
		$mat{"ncomponents"}   = "1";
		$mat{"components"}    = "G4_He 1";
		print_mat(\%configuration, \%mat);
		
		%mat = init_mat();
		my $my_density = 0.6*1.007+0.4*0.145; # 60% of ND3 and 40% of liquid-helium
		my $ND3_mass_fraction=0.6*1.007/$my_density;
		my $lHe_mass_fraction=0.4*0.145/$my_density;
		$mat{"name"}          = "solidND3";
		$mat{"description"}   = "solid ND3 target";
		$mat{"density"}        =  $my_density;
		$mat{"ncomponents"}   = "2";
		$mat{"components"}    = "ND3 $ND3_mass_fraction lHe $lHe_mass_fraction";
		print_mat(\%configuration, \%mat);
	}
    
    if($thisVariation eq "bonus")
    {
        # TargetbonusGas
        %mat = init_mat();
        $mat{"name"}          = "bonusTargetGas";
        $mat{"description"}   = "7 atm deuterium gas";
        $mat{"density"}       = "0.00126";  # in g/cm3
        $mat{"ncomponents"}   = "1";
        $mat{"components"}    = "deuteriumGas 1";
        print_mat(\%configuration, \%mat);
    }

    if($thisVariation eq "alert")
    {
        # TargetALERTGas
        %mat = init_mat();
        $mat{"name"}          = "alertTargetGas";
        $mat{"description"}   = "5 atm deuterium gas";
        $mat{"density"}       = "0.0009";  # in g/cm3
        $mat{"ncomponents"}   = "1";
        $mat{"components"}    = "deuteriumGas 1";
        print_mat(\%configuration, \%mat);
    }

}
