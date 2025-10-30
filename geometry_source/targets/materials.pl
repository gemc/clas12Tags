use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

sub build_materials {

    my $configuration_string = clas12_configuration_string(\%configuration);

    if ($configuration_string eq "ND3") {
        build_ND3_mats();
    }
    elsif ($configuration_string eq "hdice") {
        build_hdice_mats();
    }
    elsif ($configuration_string eq "transverse") {
        build_transverse_mats();
    }

    # common to all

    my %mat = init_mat();
    $mat{"name"} = "rohacell";
    $mat{"description"} = "target rohacell scattering chamber material";
    $mat{"density"} = "0.1"; # 100 mg/cm3
    $mat{"ncomponents"} = "4";
    $mat{"components"} = "G4_C 0.6465 G4_H 0.0784 G4_N 0.0839 G4_O 0.1912";
    print_mat(\%configuration, \%mat);

    %mat = init_mat();
    $mat{"name"} = "epoxy";
    $mat{"description"} = "epoxy glue 1.16 g/cm3";
    $mat{"density"} = "1.16";
    $mat{"ncomponents"} = "4";
    $mat{"components"} = "H 32 N 2 O 4 C 15";
    print_mat(\%configuration, \%mat);

    %mat = init_mat();
    $mat{"name"} = "carbonFiber";
    $mat{"description"} = "ft carbon fiber material is epoxy and carbon - 1.75g/cm3";
    $mat{"density"} = "1.75";
    $mat{"ncomponents"} = "2";
    $mat{"components"} = "G4_C 0.745 epoxy 0.255";
    print_mat(\%configuration, \%mat);

}

1;
