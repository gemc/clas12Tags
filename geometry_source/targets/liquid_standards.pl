# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;

sub build_liquid_standard_container {
    my $configuration_string = clas12_configuration_string(\%configuration);

    my %detector = init_det();

    # vacuum target container
    my $nplanes = 4;
    my @oradius = (50.3, 50.3, 21.1, 21.1);
    my @z_plane = (-140.0, 265.0, 280.0, 280.0);

    if ($configuration_string eq "lH2e") {
        @z_plane = (-115.0, 365.0, 390.0, 925.0);
    }

    $detector{"name"} = "target";
    $detector{"mother"} = "root";
    $detector{"description"} = "Target Container";
    $detector{"color"} = "22ff22";
    $detector{"type"} = "Polycone";
    my $dimen = "0.0*deg 360*deg $nplanes*counts";
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " 0.0*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $oradius[$i]*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $z_plane[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_Galactic";
    $detector{"pos"} = "0*mm 0*mm $target_zpos*mm";
    $detector{"style"} = 0;
    print_det(\%configuration, \%detector);

    # upstream al window. zpos comes from engineering model, has the shift of 1273.27 mm + 30 due to the new engineering center
    my $eng_shift = 1303.27;
    my $zpos = $eng_shift - 1328.27;
    my $radius = 4.9;
    my $thickness = 0.015;
    %detector = init_det();
    $detector{"name"} = "al_window_entrance";
    $detector{"mother"} = "target";
    $detector{"description"} = "30 mm thick aluminum window upstream";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $radius*mm $thickness*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # downstream al window
    $zpos = $eng_shift - 1278.27;
    $radius = 5;
    $thickness = 0.015;
    %detector = init_det();
    $detector{"name"} = "al_window_exit";
    $detector{"mother"} = "target";
    $detector{"description"} = "30 mm thick aluminum window downstream";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $radius*mm $thickness*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # cell barrier is 15 microns
    $zpos = $eng_shift - 1248.27;
    $radius = 5;
    $thickness = 0.0075;
    %detector = init_det();
    $detector{"name"} = "al_window_mli_barrier";
    $detector{"mother"} = "target";
    $detector{"description"} = "15 mm thick aluminum mli barrier";
    $detector{"color"} = "bb99aa";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $radius*mm $thickness*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);


    # scattering chambers al window, 75 microns
    # note: the eng. position is 1017.27 - here it is placed 8mm upstream to place it within the mother scattering chamber
    $zpos = $eng_shift - 1025.27;
    $radius = 12;
    $thickness = 0.0375;
    %detector = init_det();
    $detector{"name"} = "al_window_scexit";
    $detector{"mother"} = "target";
    $detector{"description"} = "50 mm thick aluminum window downstream";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $radius*mm $thickness*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);
}

sub build_liquid_standard_cell {

    my $configuration_string = clas12_configuration_string(\%configuration);

    $nplanes = 5;
    my @oradiusT = (2.5, 10.3, 7.3, 5.0, 2.5);
    my @z_planeT = (-24.2, -21.2, 22.5, 23.5, 24.5);

    my %detector = init_det();
    $detector{"name"} = "target_cell";
    $detector{"mother"} = "target";
    $detector{"description"} = "Target Cell";
    $detector{"color"} = "aa0000";
    $detector{"type"} = "Polycone";
    $dimen = "0.0*deg 360*deg $nplanes*counts";
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " 0.0*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $oradiusT[$i]*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $z_planeT[$i]*mm";}
    $detector{"dimensions"} = $dimen;

    if ($configuration_string eq "default"
        or $configuration_string eq "rga_spring2018"
        or $configuration_string eq "rga_fall2018"
        or $configuration_string eq "rga_spring2019"
        or $configuration_string eq "lH2e") {
        $detector{"material"} = "G4_lH2";
    }
    elsif ($configuration_string eq "rgb_spring2019"
        or $configuration_string eq "rgb_fall2019"
        or $configuration_string eq "rgd_fall2023_lD2") {
        $detector{"material"} = "LD2";
    }
    elsif ($configuration_string eq "rgm_fall2021_He") {
        $detector{"material"} = "lHeTarget";
    }

    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    if ($configuration_string eq "rgm_fall2021_He") {
        build_liquid_He_mat();
    }

}

sub build_liquid_He_mat {
    # lHe target
    my %mat = init_mat();
    $mat{"name"} = "lHeTarget";
    $mat{"description"} = "liquid He target";
    $mat{"density"} = "0.125"; # 0.125 g/cm3 <—————————————
    $mat{"ncomponents"} = "1";
    $mat{"components"} = "G4_He 1";
    print_mat(\%configuration, \%mat);
}

sub build_liquid_standards {

    print("Target_zpos for $configuration{'factory'}/$configuration{'variation'}/$configuration{'run_number'}  : $target_zpos\n");

    build_liquid_standard_container();
    build_liquid_standard_cell();
}

1;
