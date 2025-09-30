# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;

sub build_alert_container {

    my $configuration_string = clas12_configuration_string(\%configuration);

    my %detector = init_det();

    my $Rout = 4;
    my $length = 322.27; # mm!
    $detector{"name"} = "alertTarget";
    $detector{"mother"} = "root";
    $detector{"description"} = "ALERT $configuration_string target container";
    $detector{"color"} = "eeeegg";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "HECO2";
    $detector{"style"} = "1";
    $detector{"visible"} = 1;
    print_det(\%configuration, \%detector);

    # ALERT target wall
    $Rin = 3.0;
    $Rout = 3.060;
    $length = 255;
    %detector = init_det();
    $detector{"name"} = "alertTargetWall";
    $detector{"mother"} = "alertTarget";
    $detector{"description"} = "ALERT Target wall";
    $detector{"color"} = "0000ff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_KAPTON";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # ALERT target upstream aluminum end ring and window
    $Rin = 3.061;
    $Rout = 3.1561;
    $length = 2.0;     # half length
    my $zPos = -262.3; # mm z position
    %detector = init_det();
    $detector{"name"} = "alertTargetUpEndCapRing";
    $detector{"mother"} = "alertTarget";
    $detector{"description"} = "ALERT Target Al upstream end cap ring";
    $detector{"color"} = "ff0000";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm $zPos*mm";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    $Rin = 0.0;
    $Rout = 3.1561;
    $length = 0.015; # half length
    $zPos = -262.315;
    %detector = init_det();
    $detector{"name"} = "alertTargetUpEndCapPlate";
    $detector{"mother"} = "alertTarget";
    $detector{"description"} = "ALERT Target Al upstream end cap wall";
    $detector{"color"} = "0af131";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm $zPos*mm";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # ALERT target downstream aluminum end ring
    $Rin = 3.061;
    $Rout = 3.1561;
    $length = 2.0;  # half length
    $zPos = 185.67; # mm z position
    %detector = init_det();
    $detector{"name"} = "alertTargetEndCapRing";
    $detector{"mother"} = "alertTarget";
    $detector{"description"} = "ALERT Target Al end cap ring";
    $detector{"color"} = "ff0000";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm $zPos*mm";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # ALERT target downstream aluminum end window
    $Rin = 0.0;
    $Rout = 3.1561;
    $length = 0.015; # half length
    $zPos = 187.685;
    %detector = init_det();
    $detector{"name"} = "alertTargetEndCapPlate";
    $detector{"mother"} = "alertTarget";
    $detector{"description"} = "ALERT Target Al end cap wall";
    $detector{"color"} = "0af131";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm $zPos*mm";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

}

sub build_alert_cell_gas_volume {

    my $configuration_string = clas12_configuration_string(\%configuration);

    # ALERT target gas volume
    # made this the mother volume instead
    my $Rin = 0.0;
    my $Rout = 3.0;
    my $length = 255;
    my %detector = init_det();
    $detector{"name"} = "gasTargetalert";
    $detector{"mother"} = "alertTarget";
    $detector{"description"} = "target gas";
    $detector{"color"} = "ffff00";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"style"} = "1";

    if ($configuration_string eq "rgl_spring2025_D2") {
        $detector{"material"} = "alertTargetGas_D2";
    }
    if ($configuration_string eq "rgl_spring2025_H2") {
        $detector{"material"} = "alertTargetGas_H2";
    }
    if ($configuration_string eq "rgl_spring2025_He") {
        $detector{"material"} = "alertTargetGas_He";
    }

    print_det(\%configuration, \%detector);
}

sub build_alert_mats {

    my $configuration_string = clas12_configuration_string(\%configuration);

    # HECO2
    my %mat = init_mat();
    $mat{"name"} = "HECO2";
    $mat{"description"} = "Mother gas";
    $mat{"density"} = "0.000487"; # in g/cm3
    $mat{"ncomponents"} = "3";
    $mat{"components"} = "He 1 C 1 O 2";

    if ($configuration_string eq "rgl_spring2025_D2") {
        %mat = init_mat();
        $mat{"name"} = "alertTargetGas_D2";
        $mat{"description"} = "5.6 atm deuterium gas";
        $mat{"density"} = "0.000937"; # in g/cm3
        $mat{"ncomponents"} = "1";
        $mat{"components"} = "deuteriumGas 1";
        print_mat(\%configuration, \%mat);
    }
    if ($configuration_string eq "rgl_spring2025_H2") {
        $mat{"name"} = "alertTargetGas_H2";
        $mat{"description"} = "5.6 atm hydrogen gas";
        $mat{"density"} = "0.000469"; # in g/cm3
        $mat{"ncomponents"} = "1";
        $mat{"components"} = "Hgas 1";
        print_mat(\%configuration, \%mat);
    }
    if ($configuration_string eq "rgl_spring2025_He") {
        %mat = init_mat();
        $mat{"name"} = "alertTargetGas_He";
        $mat{"description"} = "5.6 atm helium gas";
        $mat{"density"} = "0.000931"; # in g/cm3
        $mat{"ncomponents"} = "1";
        $mat{"components"} = "deuteriumGas 1";
        print_mat(\%configuration, \%mat);
    }

}

sub build_alert_targets {

    print("Target_zpos for $configuration{'factory'}/$configuration{'variation'}/$configuration{'run_number'}  : $target_zpos\n");

    build_alert_container();
    build_alert_cell_gas_volume();
    build_alert_mats();
}

1;
