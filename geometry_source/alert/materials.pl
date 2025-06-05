use strict;
use warnings;

our %configuration;

sub materials {
    # ALERT drift chamber gas
    my %mat = init_mat();
    my $He_prop = 0.8;
    my $CO2_prop = 0.2;
    my $He_dens = 0.0001664;   #in g cm-3
    my $CO2_dens = 0.00184212; #in g cm-3
    my $He_fractionMass = ($He_prop * $He_dens) / ($He_prop * $He_dens + $CO2_prop * $CO2_dens);
    my $CO2_fractionMass = ($CO2_prop * $CO2_dens) / ($He_prop * $He_dens + $CO2_prop * $CO2_dens);

    #my $He_molarmass = 4.002602; #in g mol-1
    #my $CO2_molarmass = 44.0087; #in g mol-1
    #my $MolarVolume = 24000.; # in cm3 mol-1
    #my $AHDCGas_Density = $He_prop*$He_dens+$CO2_prop*$CO2_dens;
    my $AHDCGas_Density = $He_fractionMass * $He_dens + $CO2_fractionMass * $CO2_dens;
    #my $AHDCGas_Density = ($He_prop*$He_molarmass+$CO2_prop*$CO2_molarmass)/($CO2_prop/$CO2_molarmass+$He_prop/$He_molarmass)/$MolarVolume;
    $mat{"name"} = "AHDCgas";
    $mat{"description"} = "80:20 He:CO2 drift region gas taken from bonus12";
    $mat{"density"} = $AHDCGas_Density; # in g/cm3
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "G4_He $He_prop G4_CARBON_DIOXIDE $CO2_prop";
    print_mat(\%configuration, \%mat);

    # ALERT time of flight scintillator
    %mat = init_mat();
    $mat{"name"} = "atof_scintillator";
    $mat{"description"} = "scintillator material EJ-204";
    $mat{"density"} = "1.023";
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "C 9 H 10";
    print_mat(\%configuration, \%mat);


    # HE4_gas_3atm
    my %mat = init_mat();
    $mat{"name"} = "He4_gas_3atm";
    $mat{"description"} = "Target gas";
    $mat{"density"} = "0.000487"; # in g/cm3
    $mat{"ncomponents"} = "1";
    $mat{"components"} = "G4_He 1";
    print_mat(\%configuration, \%mat);

    # HECO2
    %mat = init_mat();
    $mat{"name"} = "HECO2";
    $mat{"description"} = "Wires layer gas";
    $mat{"density"} = "0.000487"; # in g/cm3
    $mat{"ncomponents"} = "3";
    $mat{"components"} = "He 1 C 1 O 2";
    print_mat(\%configuration, \%mat);

    # BC404
    %mat = init_mat();
    $mat{"name"} = "BC404";
    $mat{"description"} = "Scintillator layer";
    $mat{"density"} = "1.032"; # in g/cm3
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "H 9 C 10";
    print_mat(\%configuration, \%mat);

    # Epoxy only
    %mat = init_mat();
    $mat{"name"} = "EpoxyOnly";
    $mat{"description"} = "Epoxy only for back and front DC covers";
    $mat{"density"} = "1.2"; # in g/cm3
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "H 2 C 2";
    print_mat(\%configuration, \%mat);

    # SiO2 only
    %mat = init_mat();
    $mat{"name"} = "SiO2";
    $mat{"description"} = "SiO2";
    $mat{"density"} = "2.2"; # in g/cm3
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "Si 1 O 2";
    print_mat(\%configuration, \%mat);

    # Epoxy + GlassFiber
    %mat = init_mat();
    $mat{"name"} = "EpoxyFiberGlass";
    $mat{"description"} = "Epoxy FiberGlass back and front DC covers";
    $mat{"density"} = "1.85"; # in g/cm3
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "EpoxyOnly 0.35 SiO2 0.65";
    print_mat(\%configuration, \%mat);

    # lHe gas
    %mat = init_mat();
    $mat{"name"} = "HeBagGas";
    $mat{"description"} = "Downstream He bag gas ";
    $mat{"density"} = "0.000164"; # 0.164 kg/m3 <—————————————
    $mat{"ncomponents"} = "1";
    $mat{"components"} = "G4_He 1";
    print_mat(\%configuration, \%mat);

    #HECO2
    %mat = init_mat();
    $mat{"name"} = "HECO2";
    $mat{"description"} = "Wires layer gas";
    $mat{"density"} = "0.000487"; # in g/cm3
    $mat{"ncomponents"} = "3";
    $mat{"components"} = "He 1 C 1 O 2";
    print_mat(\%configuration, \%mat);
}
