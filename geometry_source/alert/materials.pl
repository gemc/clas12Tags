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
    my %mat = init_mat();
    $mat{"name"} = "atof_scintillator";
    $mat{"description"} = "scintillator material EJ-204";
    $mat{"density"} = "1.023";
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "C 9 H 10";
    print_mat(\%configuration, \%mat);
}
