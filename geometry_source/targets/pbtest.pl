# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;

sub build_pbtest {
    print("   - target_zpos for $configuration{'variation'}: $target_zpos\n");
    my %detector = init_det();

    # mother is a helium bag 293.26 mm long. Its center is 40.85 mm
    my $tshift = 40.85;
    my $Rout = 10; #
    my $Celllength = 293.26 / 2;
    my $zpos = $Celllength - $tshift;
    $detector{"name"} = "targetCell";
    $detector{"mother"} = "root";
    $detector{"description"} = "Helium cell";
    $detector{"color"} = "5511111";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0 0 $zpos*mm";
    $detector{"dimensions"} = "0*mm $Rout*mm $Celllength*mm 0*deg 360*deg";
    $detector{"material"} = "G4_He";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # PB 125 microns
    $Rout = 5; #
    $zpos = $tshift - $Celllength;
    my $length = 0.0625; # (0.125 mm thick)
    %detector = init_det();
    $detector{"name"} = "testPbTarget";
    $detector{"mother"} = "targetCell";
    $detector{"description"} = "Pb target";
    $detector{"color"} = "004488";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0 0 $zpos*mm";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Pb";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);


    # Upstream Foil 50 microns Aluminum at 24.8 cm
    my $ZCenter = 0.1 - $Celllength; # upstream end
    $Rout = 5;                       #
    $length = 0.015;                 # (0.030 mm thick)
    %detector = init_det();
    $detector{"name"} = "AlTargetFoilUpstream";
    $detector{"mother"} = "targetCell";
    $detector{"description"} = "Aluminum Upstream Foil ";
    $detector{"pos"} = "0 0 $ZCenter*mm";
    $detector{"color"} = "aaaaaa";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # Downstream Foil 50 microns Aluminum at 24.8 cm
    $ZCenter = $Celllength - 0.1; # Downstream end
    $Rout = 5;                    #
    $length = 0.015;              # (0.030 mm thick)
    %detector = init_det();
    $detector{"name"} = "AlTargetFoilDownstream";
    $detector{"mother"} = "targetCell";
    $detector{"description"} = "Aluminum Downstream Foil ";
    $detector{"pos"} = "0 0 $ZCenter*mm";
    $detector{"color"} = "aaaaaa";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # flux detector downstream of the scattering chamber
    $ZCenter = 300;
    $Rout = 45;      #
    $length = 0.015; # (0.030 mm thick)
    %detector = init_det();
    $detector{"name"} = "testFlux";
    $detector{"mother"} = "root";
    $detector{"description"} = "Flux detector";
    $detector{"pos"} = "0 0 $ZCenter*mm";
    $detector{"color"} = "009900";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_AIR";
    $detector{"style"} = "1";
    $detector{"sensitivity"} = "flux";
    $detector{"hit_type"} = "flux";
    $detector{"identifiers"} = "id manual 1";
    print_det(\%configuration, \%detector);

}

1;
