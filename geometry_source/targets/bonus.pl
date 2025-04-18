# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;
my $target_length = 256.56;

sub build_bonus_container {
    my %detector = init_det();

    # bonus root volume
    my $motherGap = 0.00001; # unphysical gap
    my $targetWall_radOut = 3.063;
    # Straw
    my $Rout_straw = $targetWall_radOut + $motherGap;
    my $length_straw = $target_length + $motherGap; # half length
    %detector = init_det();
    $detector{"name"} = "targetStraw";
    $detector{"mother"} = "root";
    $detector{"description"} = "Target straw";
    $detector{"color"} = "9ffbb9";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout_straw*mm $length_straw*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm 0*mm";
    $detector{"material"} = "Component";
    $detector{"style"} = "1";
    $detector{"visible"} = "1";
    print_det(\%configuration, \%detector);

    # End cap
    my $Rout_endCap = $targetWall_radOut + 0.1 + 0.0001 + $motherGap;
    my $length_endCap = 2.05005 + $motherGap; # half length
    %detector = init_det();
    $detector{"name"} = "targetEndCap";
    $detector{"mother"} = "root";
    $detector{"description"} = "Target end cap";
    $detector{"color"} = "a0a2fa";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout_endCap*mm $length_endCap*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm 254.61005*mm";
    $detector{"material"} = "Component";
    $detector{"style"} = "1";
    $detector{"visible"} = "1";
    print_det(\%configuration, \%detector);

    # Final union
    %detector = init_det();
    $detector{"name"} = "target";
    $detector{"mother"} = "root";
    $detector{"description"} = "BONuS12 RTPC gaseous $thisVariation Target";
    $detector{"color"} = "fad1a0";
    $detector{"type"} = "Operation:@ targetStraw + targetEndCap";
    $detector{"dimensions"} = "0";
    $detector{"material"} = "G4_He";
    $detector{"pos"} = "0*mm 0*mm $target_zpos*mm";
    $detector{"style"} = "1";
    $detector{"visible"} = "0";
    print_det(\%configuration, \%detector);

    # bonus target wall
    $Rin = 3.0;
    %detector = init_det();
    $detector{"name"} = "bonusTargetWall";
    $detector{"mother"} = "target";
    $detector{"description"} = "Bonus Target wall";
    $detector{"color"} = "330099";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm 0*mm";
    $detector{"dimensions"} = "$Rin*mm $targetWall_radOut*mm $target_length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_KAPTON";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # bonus target downstream aluminum end cap ring
    $Rin = $targetWall_radOut + 0.0001;
    $Rout = $Rin + 0.1;
    $length = 2.0;                       # half length
    my $zPos = $target_length - $length; # z position
    %detector = init_det();
    $detector{"name"} = "bonusTargetEndCapRing";
    $detector{"mother"} = "target";
    $detector{"description"} = "Bonus Target Al end cap ring";
    $detector{"color"} = "C4C4C4";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm $zPos*mm";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # bonus target downstream aluminum end cap ring
    $Rin = 0.0;
    $Rout = $targetWall_radOut + 0.1 + 0.0001;
    $length = 0.05;                            # half length
    $zPos = $target_length + $length + 0.0001; # z position
    %detector = init_det();
    $detector{"name"} = "bonusTargetEndCapPlate";
    $detector{"mother"} = "target";
    $detector{"description"} = "Bonus Target Al end cap wall";
    $detector{"color"} = "C4C4C4";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm $zPos*mm";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);
}

sub build_bonus_cell_gas_volume {

    my $configuration_string = clas12_configuration_string(\%configuration);

    # bonus target gas volume
    my $Rin = 0.0;
    my $Rout = 3.0 - 0.0001;
    my $length = $target_length; # half length
    %detector = init_det();
    $detector{"name"} = "TargetGas";
    $detector{"mother"} = "target";
    $detector{"description"} = "5.6 atm $thisVariation target gas";
    $detector{"color"} = "72d3fa";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm 0*mm";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"style"} = "1";

    if ($configuration_string eq "rgf_spring2020") {
        $detector{"material"} = "bonusTargetGas_D2";
    }
    if ($configuration_string eq "tbd") {
        $detector{"material"} = "bonusTargetGas_H2";
    }
    if ($configuration_string eq "tbd") {
        $detector{"material"} = "bonusTargetGas_He";
    }

    print_det(\%configuration, \%detector);
}

sub build_bonus_mats {
    my %mat = init_mat();
    $mat{"name"} = "bonusTargetGas_D2";
    $mat{"description"} = "5.6 atm deuterium gas";
    $mat{"density"} = "0.000937"; # in g/cm3
    $mat{"ncomponents"} = "1";
    $mat{"components"} = "deuteriumGas 1";
    print_mat(\%configuration, \%mat);

    %mat = init_mat();
    $mat{"name"} = "bonusTargetGas_H2";
    $mat{"description"} = "5.6 atm hydrogen gas";
    $mat{"density"} = "0.000469"; # in g/cm3
    $mat{"ncomponents"} = "1";
    $mat{"components"} = "Hgas 1";
    print_mat(\%configuration, \%mat);

    # TargetbonusGas
    %mat = init_mat();
    $mat{"name"} = "bonusTargetGas_He";
    $mat{"description"} = "5.6 atm helium gas";
    $mat{"density"} = "0.000931"; # in g/cm3
    $mat{"ncomponents"} = "1";
    $mat{"components"} = "G4_He 1";
    print_mat(\%configuration, \%mat);
}

sub build_bonus_targets {

    print("   - target_zpos for $configuration{'variation'}: $target_zpos\n");

    build_bonus_container();
    build_bonus_cell_gas_volume();
    build_bonus_mats();
}

1;
