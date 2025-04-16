# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;

sub build_hdice {
    print("   - target_zpos for $configuration{'variation'}: $target_zpos\n");
    my %detector = init_det();

    $detector{"name"} = "hdIce_mother";
    $detector{"mother"} = "root";
    $detector{"description"} = "Target Container";
    $detector{"color"} = "22ff22";
    $detector{"type"} = "Box";
    $detector{"dimensions"} = "160*mm 160*mm 800*mm";
    $detector{"material"} = "G4_Galactic";
    $detector{"style"} = 0;
    $detector{"mfield"} = "hdicefield";
    print_det(\%configuration, \%detector);
}

sub build_hdice_mats {
    #HDIce
    %mat = init_mat();
    my $H_atomic_weight = 1.00784;
    my $D_atomic_weight = 2.014;
    my $H_mass_fraction = $H_atomic_weight / ($H_atomic_weight + $D_atomic_weight);
    my $D_mass_fraction = $D_atomic_weight / ($H_atomic_weight + $D_atomic_weight);

    $mat{"name"} = "HDIce";
    $mat{"description"} = "solid HD ice";
    $mat{"density"} = "0.147";
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "G4_H $H_mass_fraction deuteriumGas $D_mass_fraction";
    print_mat(\%configuration, \%mat);

    #HDIce+Al
    %mat = init_mat();
    my $HD_mass_fraction = 1 - (0.175 - 0.147) / (2.7 - 0.147);
    my $Al_mass_fraction = (0.175 - 0.147) / (2.7 - 0.147);
    $mat{"name"} = "solidHD";
    $mat{"description"} = "solidHD target";
    $mat{"density"} = "0.175";
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "HDIce $HD_mass_fraction G4_Al $Al_mass_fraction";
    print_mat(\%configuration, \%mat);

    #MgB2
    %mat = init_mat();
    my $Mg_atomic_weight = 24.305;
    my $B_atomic_weight = 10.811;
    my $Mg_mass_fraction = $Mg_atomic_weight / ($Mg_atomic_weight + 2 * $B_atomic_weight);
    my $B_mass_fraction = 2 * $B_atomic_weight / ($Mg_atomic_weight + 2 * $B_atomic_weight);
    $mat{"name"} = "MgB2";
    $mat{"description"} = "MgB2";
    $mat{"density"} = "2.57";
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "G4_Mg $Mg_mass_fraction G4_B $B_mass_fraction";
    print_mat(\%configuration, \%mat);

    #CTFE = C_2ClF_3
    %mat = init_mat();
    my $my_density = 2.135; # 2 C, 3 F, 1 Cl
    my $C_mass_fraction = 2 * 12 / (2 * 12 + 3 * 19 + 35);
    my $F_mass_fraction = 3 * 19 / (2 * 12 + 3 * 19 + 35);
    my $Cl_mass_fraction = 35 / (2 * 12 + 3 * 19 + 35);
    $mat{"name"} = "Kel-F";
    $mat{"description"} = "Kel-F PCTFE target walls C_2ClF_3";
    $mat{"density"} = $my_density;
    $mat{"ncomponents"} = "3";
    $mat{"components"} = "G4_C $C_mass_fraction G4_Cl $Cl_mass_fraction G4_F $F_mass_fraction";
    print_mat(\%configuration, \%mat);

    #Alloy of Cu-Ni
    %mat = init_mat();
    $my_density = 8.95;
    my $Cu_mass_fraction = 0.7;
    my $Ni_mass_fraction = 0.3;
    $mat{"name"} = "Cu70Ni30";
    $mat{"description"} = "Cupronickel 70-30";
    $mat{"density"} = $my_density;
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "G4_Cu $Cu_mass_fraction G4_Ni $Ni_mass_fraction";
    print_mat(\%configuration, \%mat);
}

1;
