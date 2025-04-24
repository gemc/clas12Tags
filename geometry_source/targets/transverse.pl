# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;

sub build_transverse {
    #	Length: 28.4 mm
    #	ID: 27.0 mm
    #	OD: 29.0
    #	Al foils: 25 um thick

    print("Target_zpos for $configuration{'factory'}/$configuration{'variation'}/$configuration{'run_number'}  : $target_zpos\n");
    my %detector = init_det();

    my $ttlength = 14.2; # half length
    my $ttid = 13.5;
    my $ttod = 14.5;
    my $ttfoil = 0.0125; # half length


    # cell frame
    $detector{"name"} = "ttargetCellFrame";
    $detector{"mother"} = "root";
    $detector{"description"} = "Target Container";
    $detector{"color"} = "222222";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $ttod*mm $ttlength*mm 0*deg 360*deg";
    $detector{"material"} = "Kel-F";
    $detector{"style"} = 1;
    #print_det(\%configuration, \%detector);

    # cell
    %detector = init_det();
    $detector{"name"} = "ttargetCell";
    $detector{"mother"} = "root";
    $detector{"description"} = "Target Container";
    $detector{"color"} = "994422";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $ttid*mm $ttlength*mm 0*deg 360*deg";
    $detector{"material"} = "NH3target";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # downstream al window
    my $zpos = $ttlength + $ttfoil;
    %detector = init_det();
    $detector{"name"} = "al_window_entrance";
    $detector{"mother"} = "root";
    $detector{"description"} = "25 mm thick aluminum window upstream";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $ttid*mm $ttfoil*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # upstream al window
    $zpos = -$ttlength - $ttfoil;
    %detector = init_det();
    $detector{"name"} = "al_window_exit";
    $detector{"mother"} = "root";
    $detector{"description"} = "25 mm thick aluminum window upstream";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $ttid*mm $ttfoil*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

}

sub build_transverse_mats {
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


    # lHe coolant
    %mat = init_mat();
    $mat{"name"} = "lHeCoolant";
    $mat{"description"} = "liquid He coolant for the polarized target cell";
    $mat{"density"} = "0.147"; # 0.145 g/cm3 <—————————————
    $mat{"ncomponents"} = "1";
    $mat{"components"} = "G4_He 1";
    print_mat(\%configuration, \%mat);

    # NH3
    %mat = init_mat();
    my $NH3_density = 0.867;
    my $N_mass_fraction = 15 / 18;
    my $H_mass_fraction = 3 / 18;
    $mat{"name"} = "NH3";
    $mat{"description"} = "NH3 material";
    $mat{"density"} = $NH3_density;
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "G4_N $N_mass_fraction G4_H $H_mass_fraction";
    print_mat(\%configuration, \%mat);

    # NH3 target with lHe3 coolant
    %mat = init_mat();
    my $NH3trg_density = 0.6 * 0.867 + 0.4 * 0.145; # 60% of NH3 and 40% of liquid-helium
    my $NH3_mass_fraction = 0.6 * 0.867 / $NH3trg_density;
    my $lHe_mass_fraction = 0.4 * 0.145 / $NH3trg_density;
    $mat{"name"} = "NH3target";
    $mat{"description"} = "solid NH3 target";
    $mat{"density"} = $NH3trg_density;
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "NH3 $NH3_mass_fraction lHeCoolant $lHe_mass_fraction";
    print_mat(\%configuration, \%mat);
}

1;
