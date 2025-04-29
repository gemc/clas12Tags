# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;

sub build_ND3 {
    print("Target_zpos for $configuration{'factory'}/$configuration{'variation'}/$configuration{'run_number'}  : $target_zpos\n");
    my %detector = init_det();

    # vacuum container
    my $Rout = 44;
    my $length = 50; # half length
    $detector{"name"} = "scatteringChamberVacuum";
    $detector{"mother"} = "root";
    $detector{"description"} = "clas12 scattering chamber vacuum rohacell container for ND3 target";
    $detector{"color"} = "aaaaaa4";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Galactic";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);


    # rohacell
    $Rout = 43;
    $length = 48; # half length
    %detector = init_det();
    $detector{"name"} = "scatteringChamber";
    $detector{"mother"} = "scatteringChamberVacuum";
    $detector{"description"} = "clas12 rohacell scattering chamber for ND3 target";
    $detector{"color"} = "ee3344";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "rohacell";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);


    # vacuum container for plastic cell
    $Rout = 40;
    $length = 45; # half length
    %detector = init_det();
    $detector{"name"} = "plasticCellVacuum";
    $detector{"mother"} = "scatteringChamber";
    $detector{"description"} = "clas12 rohacell vacuum aluminum container chamber for ND3 target";
    $detector{"color"} = "aaaaaa4";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Galactic";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # helium cylinder
    $Rout = 12.62;
    $length = 25.10; # half length
    %detector = init_det();
    $detector{"name"} = "HeliumCell";
    $detector{"mother"} = "plasticCellVacuum";
    $detector{"description"} = "Helium volume for ND3 target";
    $detector{"color"} = "aaaaaa3";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_He";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # plastic cylinder cell
    $Rout = 12.60;
    $length = 20.10; # half length
    %detector = init_det();
    $detector{"name"} = "plasticCell";
    $detector{"mother"} = "HeliumCell";
    $detector{"description"} = "clas12 plastic cell for ND3 target";
    $detector{"color"} = "aaaaaa";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_TEFLON"; #using teflon which is similar to the actual cell
    print_det(\%configuration, \%detector);


    # actual target
    $Rout = 12.50;   # target has a 25mm diameter
    $length = 20.00; # half length (target is 4cm long)
    %detector = init_det();
    $detector{"name"} = ND3;
    $detector{"mother"} = "plasticCell";
    $detector{"description"} = "clas12 ND3 target";
    $detector{"color"} = "ee8811";
    $detector{"type"} = "Tube";
    $detector{"style"} = "1";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";

    $detector{"material"} = "solidND3";
    print_det(\%configuration, \%detector);

}

sub build_ND3_mats {
    #my %mat = init_mat();
    #$mat{"name"}          = "solidND3";
    #$mat{"description"}   = "solid ND3 target";
    #$mat{"density"}       = "1.007";  # 1.007 g/cm3
    #$mat{"ncomponents"}   = "1";
    #$mat{"components"}    = "ND3 1";
    #print_mat(\%configuration, \%mat);

    my %mat = init_mat();
    $mat{"name"} = "lHe";
    $mat{"description"} = "liquid helium";
    $mat{"density"} = "0.145"; # 0.145 g/cm3 <—————————————
    $mat{"ncomponents"} = "1";
    $mat{"components"} = "G4_He 1";
    print_mat(\%configuration, \%mat);

    %mat = init_mat();
    my $my_density = 0.6 * 1.007 + 0.4 * 0.145; # 60% of ND3 and 40% of liquid-helium
    my $ND3_mass_fraction = 0.6 * 1.007 / $my_density;
    my $lHe_mass_fraction = 0.4 * 0.145 / $my_density;
    $mat{"name"} = "solidND3";
    $mat{"description"} = "solid ND3 target";
    $mat{"density"} = $my_density;
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "ND3 $ND3_mass_fraction lHe $lHe_mass_fraction";
    print_mat(\%configuration, \%mat);

}

1;
