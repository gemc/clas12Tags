# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;

my $VolumeLength = 77;
my $TargetLength = 50;  #length of the NH3 target
my $TargetRadius = 7.5; #radius of the NH3 target
my $TargetCenter = 0;   #center of the NH3 target
my $TargetWindowThickness = 0.02;
my $VacuumRadius = 51; #XXXX
my $BeamWindowThickness = 0.13;
my $BathHalfLength = ($TargetLength + $TargetWindowThickness) / 2;
my $BathWallThickness = 0.76;
my $BathWindowThickness = 0.13;
my $BathWallZ0 = $TargetLength / 2 + $TargetWindowThickness + 4 + $BathWindowThickness;
my $BathDx = 25 / 2;
my $BathDy = 45 / 2;
my $BathDz = ($BathWallZ0 + $VolumeLength) / 2;
my $BathZ0 = ($BathWallZ0 - $VolumeLength) / 2;
my $ShimCoilsMandrelRin = 29;
my $ShimCoilsMandrelRout = 29.63;
my $ShimCoilsLength = 12;
my $ShimCoilsThickness = 0.7;
my $ShimCoilsWindow = 0.02;
my $PumpingVolumeRin = 35.5;
my $PumpingVolumeRout = 36.0;
my $PumpingVolumeWindow = 0.075;
my $HeatShieldRin = 40.75;
my $HeatShieldRout = 41.25;
my $HeatShieldWindow = 0.02;
my $VacuumCanRin = $VacuumRadius - 1.0;
my $VacuumCanRout = $VacuumRadius;
my $VacuumCanWindow = 0.075;
my $SpheresCenter = $BathWallZ0 + 3;

sub apollo {
    my $configuration_string = clas12_configuration_string(\%configuration);

    # mother volume
    my $Rout = $VacuumRadius;
    my $Zlength = $SpheresCenter + $VacuumRadius;
    my %detector = init_det();
    $detector{"name"} = "PolTarg";
    $detector{"mother"} = "root";
    $detector{"description"} = "PolTarg Region";
    $detector{"color"} = "123456";
    $detector{"type"} = "Polycone";
    $detector{"dimensions"} = "0.0*deg 360*deg 2*counts 0.0*mm 0.0*mm $Rout*mm $Rout*mm -$VolumeLength*mm $Zlength*mm";
    $detector{"pos"} = "0*mm 0*mm $target_zpos*mm";
    $detector{"material"} = "G4_AIR";
    $detector{"visible"} = 0;
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # vacuum volume
    %detector = init_det();
    $detector{"name"} = "VacuumVolume";
    $detector{"mother"} = "PolTarg";
    $detector{"description"} = "Vacuum cylindrical volume";
    $detector{"color"} = "ffffff";
    $detector{"type"} = "Polycone";
    $detector{"pos"} = "0*mm 0*mm $TargetCenter*mm";
    $detector{"dimensions"} = "0.0*deg 360*deg 2*counts 0.0*mm 0.0*mm $Rout*mm $Rout*mm -$VolumeLength*mm $SpheresCenter*mm";
    $detector{"material"} = "G4_Galactic";
    $detector{"visible"} = 0;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # vacuum sphere
    %detector = init_det();
    $detector{"name"} = "VacuumSphere";
    $detector{"mother"} = "PolTarg";
    $detector{"description"} = "Vacuum half sphere volume";
    $detector{"pos"} = "0 0 $SpheresCenter*mm";
    $detector{"color"} = "ffffff";
    $detector{"type"} = "Sphere";
    $detector{"dimensions"} = "0*mm $Rout*mm 0*deg 360*deg 0*deg 90*deg";
    $detector{"material"} = "G4_Galactic";
    $detector{"visible"} = 0;
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    #LHe bath walls
    my $dx = $BathDx + $BathWallThickness;
    my $dy = $BathDy + $BathWallThickness;
    %detector = init_det();
    $detector{"name"} = "HeliumBathWalls";
    $detector{"mother"} = "VacuumVolume";
    $detector{"description"} = "LHe bath walls";
    $detector{"color"} = "aaaaaa";
    $detector{"type"} = "Box";
    $detector{"pos"} = "0*mm 0*mm $BathZ0*mm";
    $detector{"dimensions"} = "$dx*mm $dy*mm $BathDz*mm";
    $detector{"material"} = "AmmoniaCellWalls";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    #LHe bath
    %detector = init_det();
    $detector{"name"} = "HeliumBath";
    $detector{"mother"} = "HeliumBathWalls";
    $detector{"description"} = "LHe bath";
    $detector{"color"} = "0099ff";
    $detector{"type"} = "Box";
    $detector{"pos"} = "0*mm 0*mm 0*mm";
    $detector{"dimensions"} = "$BathDx*mm $BathDy*mm $BathDz*mm";
    $detector{"material"} = "lHeCoolant";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    #LHe bath window
    my $z0 = $BathDz - $BathWindowThickness / 2;
    my $dz = $BathWindowThickness / 2;
    %detector = init_det();
    $detector{"name"} = "HeliumBathWindow";
    $detector{"mother"} = "HeliumBath";
    $detector{"description"} = "LHe bath window";
    $detector{"color"} = "aaaaaa";
    $detector{"type"} = "Box";
    $detector{"pos"} = "0*mm 0*mm $z0*mm";
    $detector{"dimensions"} = "$BathDx*mm $BathDy*mm $dz*mm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # NH3Targ
    my $ZCenter = -$BathZ0;              # center location of target along beam axis
    $Rout = $TargetRadius;               # radius in mm
    my $ZhalfLength = $TargetLength / 2; # half length along beam axis
    %detector = init_det();
    $detector{"name"} = "NH3Targ";
    $detector{"mother"} = "HeliumBath";
    $detector{"description"} = "NH3 target cell";
    $detector{"pos"} = "0 0 $ZCenter*mm";
    $detector{"color"} = "f000f0";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
    $detector{"material"} = "NH3target";
    if ($configuration_string eq "APOLLOnd3") {
        $detector{"name"} = "ND3Targ";
        $detector{"description"} = "ND3 target cell";
        $detector{"material"} = "ND3target";
    }
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # NH3Targ Cup
    my $Rin = $TargetRadius + 0.001;  # radius in mm
    $Rout = $TargetRadius + 0.03;     # radius in mm
    $ZhalfLength = $TargetLength / 2; # half length along beam axis
    %detector = init_det();
    $detector{"name"} = "NH3Cup";
    $detector{"mother"} = "HeliumBath";
    $detector{"description"} = "NH3 Target cup";
    $detector{"pos"} = "0 0 $ZCenter*mm";
    $detector{"color"} = "ffffff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
    $detector{"material"} = "AmmoniaCellWalls";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # NH3Targ Cup Up Stream Window
    $ZCenter = -$BathZ0 - $TargetLength / 2 - $TargetWindowThickness / 2;
    $Rin = 0.0;                                # radius in mm
    $Rout = $TargetRadius;                     # radius in mm
    $ZhalfLength = $TargetWindowThickness / 2; # half length along beam axis
    %detector = init_det();
    $detector{"name"} = "NH3USWindow";
    $detector{"mother"} = "HeliumBath";
    $detector{"description"} = "NH3 Target cup Upstream Window";
    $detector{"pos"} = "0 0 $ZCenter*mm";
    $detector{"color"} = "aaaaaa";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # NH3Targ Cup Downstream Stream Window
    $ZCenter = -$BathZ0 + $TargetLength / 2 + $TargetWindowThickness / 2;
    $Rin = 0.0;                                # radius in mm
    $Rout = $TargetRadius;                     # radius in mm
    $ZhalfLength = $TargetWindowThickness / 2; # half length along beam axis
    %detector = init_det();
    $detector{"name"} = "NH3DSWindow";
    $detector{"mother"} = "HeliumBath";
    $detector{"description"} = "NH3 Target cup Downstream Window";
    $detector{"pos"} = "0 0 $ZCenter*mm";
    $detector{"color"} = "aaaaaa";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # Beam pipe
    $Rin = 0;
    $Rout = $TargetRadius + 1;
    my $z1 = -$BathDz;
    my $z2 = -$BathZ0 - $TargetLength / 2 - $TargetWindowThickness;
    $ZhalfLength = ($z2 - $z1) / 2;
    $ZCenter = ($z2 + $z1) / 2;
    %detector = init_det();
    $detector{"name"} = "BeamEntranceVacuum";
    $detector{"mother"} = "HeliumBath";
    $detector{"description"} = "Beam Entrance Vacuum";
    $detector{"color"} = "ffffff";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm $ZCenter*mm";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Galactic";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);
    $Rin = $Rout;
    $Rout = $Rout + 1;
    %detector = init_det();
    $detector{"name"} = "BeamEntrancePipe";
    $detector{"mother"} = "HeliumBath";
    $detector{"description"} = "Beam Entrance Pipe";
    $detector{"color"} = "595959";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm $ZCenter*mm";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    #  Beam Entrance Window
    $ZCenter = $ZhalfLength - $BeamWindowThickness / 2;
    $Rin = 0.0;                              # radius in mm
    $Rout = $TargetRadius + 1;               # radius in mm
    $ZhalfLength = $BeamWindowThickness / 2; # half length along beam axis
    %detector = init_det();
    $detector{"name"} = "BeamEntrance";
    $detector{"mother"} = "BeamEntranceVacuum";
    $detector{"description"} = "Beam entrance window";
    $detector{"pos"} = "0 0 $ZCenter*mm";
    $detector{"color"} = "aaaaaa";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # Shim Up Up stream Coil
    shimcoil($BathHalfLength - $ShimCoilsLength / 2, 1);
    # Shim Up stream Coil
    shimcoil(-4.5, 2);
    # Shim Down stream Coil
    shimcoil(-22.5, 3);

    # Shim Coil Carrier
    spheretube($ShimCoilsMandrelRin, $ShimCoilsMandrelRout, $ShimCoilsWindow, "ShimCoil", "G4_Al", "aaaaaa");
    # Pumping Volume
    spheretube($PumpingVolumeRin, $PumpingVolumeRout, $PumpingVolumeWindow, "PumpingVolume", "G4_Al", "000080");
    # Heat Shield volume
    spheretube($HeatShieldRin, $HeatShieldRout, $HeatShieldWindow, "HeathShield", "G4_Al", "404040");
    # Vacuum can
    spheretube($VacuumCanRin, $VacuumCanRout, $VacuumCanWindow, "VacuumCan", "carbonFiber", "0d0d0d");
}

sub spheretube {

    my $Rin = $_[0];
    my $Rout = $_[1];
    my $name = $_[3];
    my $mat = $_[4];
    my $col = $_[5];
    my %detector = init_det();
    $detector{"name"} = "${name}Tube";
    $detector{"mother"} = "VacuumVolume";
    $detector{"description"} = "$name tube";
    $detector{"color"} = $col;
    $detector{"type"} = "Polycone";
    $detector{"pos"} = "0*mm 0*mm $TargetCenter*mm";
    $detector{"dimensions"} = "0.0*deg 360*deg 2*counts $Rin*mm $Rin*mm $Rout*mm $Rout*mm -$VolumeLength*mm $SpheresCenter*mm";
    $detector{"material"} = $mat;
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    my $theta = int(atan(($TargetRadius + 1) / $Rin) * 180 / 3.1415) + 1;
    my $dtheta = 90 - $theta;
    %detector = init_det();
    $detector{"name"} = "${name}Sphere";
    $detector{"mother"} = "VacuumSphere";
    $detector{"description"} = "$name sphere";
    $detector{"pos"} = "0 0 0*mm";
    $detector{"color"} = $col;
    $detector{"type"} = "Sphere";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm 0*deg 360*deg $theta*deg $dtheta*deg";
    $detector{"material"} = $mat;
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    $Rout = $_[0] + $_[2];
    %detector = init_det();
    $detector{"name"} = "${name}Window";
    $detector{"mother"} = "VacuumSphere";
    $detector{"description"} = "$name Window";
    $detector{"pos"} = "0 0 0*mm";
    $detector{"color"} = $col;
    $detector{"type"} = "Sphere";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm 0*deg 360*deg 0*deg $theta*deg";
    $detector{"material"} = $mat;
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);
}

sub shimcoil {
    my $pos = $_[0];
    my $num = $_[1];
    my $Rin = $ShimCoilsMandrelRout;
    my $Rout = $ShimCoilsMandrelRout + $ShimCoilsThickness;
    my $length = $ShimCoilsLength / 2;
    my %detector = init_det();
    $detector{"name"} = "ShimCoil$num";
    $detector{"mother"} = "VacuumVolume";
    $detector{"description"} = "Shim Coil $num";
    $detector{"pos"} = "0 0 $pos*mm";
    $detector{"color"} = "a00000";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "ShimCoil";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);
}

sub apollo_materials {
    my $configuration_string = clas12_configuration_string(\%configuration);

    # carbon fiber
    %mat = init_mat();
    $mat{"name"} = "carbonFiber";
    $mat{"description"} = "carbon fiber material is epoxy and carbon - 1.75g/cm3";
    $mat{"density"} = "1.75";
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "G4_C 0.745 epoxy 0.255";
    print_mat(\%configuration, \%mat);


    # G10 fiberglass
    %mat = init_mat();
    $mat{"name"} = "G10";
    $mat{"description"} = "G10 - 1.70 g/cm3";
    $mat{"density"} = "1.70";
    $mat{"ncomponents"} = "4"; # 1 Si atom, 2 Oxygen, 3 Carbon, and 3 Hydrogen
    $mat{"components"} = "G4_Si 0.283 G4_O 0.323  G4_C 0.364  G4_H 0.030";
    print_mat(\%configuration, \%mat);

    # lHe gas
    %mat = init_mat();
    $mat{"name"} = "HeGas";
    $mat{"description"} = "Upstream He gas ";
    $mat{"density"} = "0.000164"; # 0.164 kg/m3 <—————————————
    $mat{"ncomponents"} = "1";
    $mat{"components"} = "G4_He 1";
    print_mat(\%configuration, \%mat);

    # Al target cell(s)
    %mat = init_mat();
    $mat{"name"} = "AlCell";
    $mat{"description"} = "Aluminum for target cells ";
    $mat{"density"} = "2.70"; # 2.7 g/cm3 <—————————————
    $mat{"ncomponents"} = "1";
    $mat{"components"} = "G4_Al 1";
    print_mat(\%configuration, \%mat);

    # Shim coils, need to confirm mass fractions and density
    %mat = init_mat();
    my %mat = init_mat();
    my $NbTi_density = 6.63;
    #my $NbTi_density=(0.475*8.57+0.525*4.54);

    my $ShimCoil_density = (1.3 * 8.96 + $NbTi_density) / 2.3;
    my $Cu_mass_fraction = 29 / (29 + 41 + 22);
    my $Nb_mass_fraction = 41 / (29 + 41 + 22);
    my $Ti_mass_fraction = 22 / (29 + 41 + 22);
    $mat{"name"} = "ShimCoil";
    $mat{"description"} = "Cu/NbTi correction coils ratio is 1.3 Cu  to 1 NbTi ";
    $mat{"density"} = $ShimCoil_density; #Cu=8.96 g/cm3 NbTi= 4.5 g/cm3 = Nb-47.5 wt % Ti 47.5% of the materials weight is Nb <—————————————
    $mat{"ncomponents"} = "3";
    $mat{"components"} = "G4_Cu $Cu_mass_fraction G4_Nb $Nb_mass_fraction G4_Ti $Ti_mass_fraction";
    print_mat(\%configuration, \%mat);

    # Target cup walls with holes, need to confirm mass ratios
    #my %mat = init_mat();
    my $my_density = 2.135; # 2 C, 3 F, 1 Cl
    my $C_mass_fraction = 2 * 12 / (2 * 12 + 3 * 19 + 35);
    my $F_mass_fraction = 3 * 19 / (2 * 12 + 3 * 19 + 35);
    my $Cl_mass_fraction = 35 / (2 * 12 + 3 * 19 + 35);
    $mat{"name"} = "AmmoniaCellWalls";
    $mat{"description"} = "PCTFE target cell walls with holes C_2ClF_3";
    $mat{"density"} = $my_density; #2.10-2.17 g/cm3  has a dipole moment <—————————————
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
    #my %mat = init_mat();
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
    #my %mat = init_mat();
    my $NH3trg_density = 0.6 * 0.867 + 0.4 * 0.145; # 60% of ND3 and 40% of liquid-helium
    my $NH3_mass_fraction = 0.6 * 0.867 / $NH3trg_density;
    my $lHe_mass_fraction = 0.4 * 0.145 / $NH3trg_density;
    $mat{"name"} = "NH3target";
    $mat{"description"} = "solid NH3 target";
    $mat{"density"} = $NH3trg_density;
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "NH3 $NH3_mass_fraction lHeCoolant $lHe_mass_fraction";
    print_mat(\%configuration, \%mat);

    # ND3 , not sure if G4 has H2 material so used H for now
    #my %mat = init_mat();
    my $ND3_density = 1.007;
    my $NN_mass_fraction = 15 / 21;
    my $H2_mass_fraction = 6 / 21;
    $mat{"name"} = "ND3";
    $mat{"description"} = "ND3 material";
    $mat{"density"} = $ND3_density;
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "G4_N $NN_mass_fraction G4_H $H2_mass_fraction";
    print_mat(\%configuration, \%mat);

    # ND3 target with lHe3 coolant
    #my %mat = init_mat();
    my $ND3targ_density = 0.6 * 1.007 + 0.4 * 0.145; # 60% of ND3 and 40% of liquid-helium
    my $ND3_mass_fraction = 0.6 * 1.007 / $ND3targ_density;
    my $llHe_mass_fraction = 0.4 * 0.145 / $ND3targ_density;
    $mat{"name"} = "ND3target";
    $mat{"description"} = "solid ND3 target";
    $mat{"density"} = $ND3targ_density;
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "ND3 $ND3_mass_fraction lHeCoolant $llHe_mass_fraction";
    print_mat(\%configuration, \%mat);

}

sub build_apollo_targets {

    print("Target_zpos for $configuration{'factory'}/$configuration{'variation'}/$configuration{'run_number'}  : $target_zpos\n");

    apollo();

    apollo_materials();
}

1;
