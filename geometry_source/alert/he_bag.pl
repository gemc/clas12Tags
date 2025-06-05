use warnings;
use strict;
use clas12_configuration_string;

our %configuration;
our %parameters;


# mother volume
sub make_Hebag_mother {
    my %detector = init_det();
    $detector{"name"} = "mother_Hebag";
    $detector{"mother"} = "root";
    $detector{"description"} = "ALERT He bag mother";
    $detector{"color"} = "eeeegg";
    $detector{"pos"} = "0*mm 0*mm 641.635*mm";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0.0*mm 20.0*mm 319.365*mm 0*deg 360*deg";
    $detector{"material"} = "HECO2";
    #$detector{"material"}    = "HeBagGas";
    #$detector{"visible"}     = 1;
    $detector{"visible"} = 0;
    print_det(\%configuration, \%detector);
}

# He bag
sub make_Hebag_tube {
    my $rmin = 19.0;
    my $rmax = 19.1;
    my $phistart = 0;
    my $pspan = 360;
    my %detector = init_det();

    $detector{"name"} = "Hebag";
    $detector{"mother"} = "mother_Hebag";
    $detector{"description"} = "He bag for ALERT";
    $detector{"color"} = "00ff00";
    $detector{"pos"} = "0*mm 0*mm -0.015*mm";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$rmin*mm $rmax*mm 319.35*mm $phistart*deg $pspan*deg";
    $detector{"material"} = "G4_KAPTON";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

}

sub make_Hebag_downstream_window {
    my $rmin = 0.0;
    my $rmax = 19.1;
    my $phistart = 0;
    my $pspan = 360;
    my %detector = init_det();

    $detector{"name"} = "Hebag_dnst_w";
    $detector{"mother"} = "mother_Hebag";
    $detector{"description"} = "He bag downstream window";
    $detector{"color"} = "00ff00";
    $detector{"pos"} = "0*mm 0*mm 319.35*mm";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$rmin*mm $rmax*mm 0.015*mm $phistart*deg $pspan*deg";
    $detector{"material"} = "G4_KAPTON";
    $detector{"style"} = 1;
    #$detector{"identifiers"} = $id_string;
    print_det(\%configuration, \%detector);

}

sub make_Hebag_gas {
    my $rmin = 0.0;
    my $rmax = 19.00;
    my $phistart = 0;
    my $pspan = 360;
    my %detector = init_det();

    $detector{"name"} = "Hebag_gas";
    $detector{"mother"} = "mother_Hebag";
    $detector{"description"} = "He bag gas for ALERT";
    $detector{"color"} = "ffff00";
    $detector{"pos"} = "0*mm 0*mm -0.015*mm";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$rmin*mm $rmax*mm 319.35*mm $phistart*deg $pspan*deg";
    $detector{"material"} = "HECO2";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

}

sub build_hebag {

    make_Hebag_mother();
    make_Hebag_tube();
    make_Hebag_downstream_window();
    make_Hebag_gas();

}

1;

