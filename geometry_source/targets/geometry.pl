use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;

# various targets
require "./pbtest.pl";
require "./ND3.pl";
require "./hdice.pl";
require "./longitudinal.pl";
require "./transverse.pl";
require "./liquid_standards.pl"; # rga, rgb, rgf, rgm
require "./bonus.pl";
require "./rgm.pl";
require "./apollo.pl"; # rgc
require "./alert.pl";  # rgl
require "./rgd_solid.pl"; # rgd
require "./rge.pl";  # rge

sub load_target_parameters {
    $target_zpos = $parameters{"target_zpos"};
}

sub build_target {
    load_target_parameters();

    my $configuration_string = clas12_configuration_string(\%configuration);

    if ($configuration_string eq "pbtest") {
        build_pbtest();
    }
    elsif ($configuration_string eq "ND3") {
        build_ND3();
    }
    elsif ($configuration_string eq "hdice") {
        build_hdice();
    }
    elsif ($configuration_string eq "longitudinal") {
        build_longitudinal();
    }
    elsif ($configuration_string eq "transverse") {
        build_transverse();
    }
    elsif ($configuration_string eq "default"
        or $configuration_string eq "rga_spring2018"
        or $configuration_string eq "rga_fall2018"
        or $configuration_string eq "rgb_spring2019"
        or $configuration_string eq "rga_spring2019"
        or $configuration_string eq "rgb_fall2019"
        or $configuration_string eq "rgm_fall2021_He"
        or $configuration_string eq "lH2e"
        or $configuration_string eq "rgd_fall2023_lD2"
        or $configuration_string eq "rgd_fall2023_empty") {
        build_liquid_standards();
    }
    elsif ($configuration_string eq "rgf_spring2020" ||
        $configuration_string eq "bonusH2" ||
        $configuration_string eq "bonusHe") {
        build_bonus_targets();
    }
    elsif ($configuration_string eq "rgl_spring2025_H2" ||
        $configuration_string eq "rgl_spring2025_D2" ||
        $configuration_string eq "rgl_spring2025_He") {
        build_alert_targets();
    }
    elsif ($configuration_string eq "rgc_summer2022"
        or $configuration_string eq "APOLLOnd3") {
        build_apollo_targets();
    }
    elsif ($configuration_string eq "rgm_fall2021_H"
        or $configuration_string eq "rgm_fall2021_D"
        or $configuration_string eq "rgm_fall2021_He"
        or $configuration_string eq "rgm_fall2021_C"
        or $configuration_string eq "rgm_fall2021_Cx4"
        or $configuration_string eq "rgm_fall2021_Ca"
        or $configuration_string eq "rgm_fall2021_Sn"
        or $configuration_string eq "rgm_fall2021_Snx4") {
        build_rgm_targets();
    }
    elsif ($configuration_string eq "rgd_fall2023_CxC") {
        build_rgd_CxC();
    }
    elsif ($configuration_string eq "rgd_fall2023_CuSn") {
        build_rgd_CuSn();
    }
    elsif ($configuration_string eq "rge_spring2024_Empty_Al"
        or $configuration_string eq "rge_spring2024_Empty_C"
        or $configuration_string eq "rge_spring2024_Empty_Empty"
        or $configuration_string eq "rge_spring2024_Empty_Pb"
        or $configuration_string eq "rge_spring2024_LD2_Al"
        or $configuration_string eq "rge_spring2024_LD2_C"
        or $configuration_string eq "rge_spring2024_LD2_Cu"
        or $configuration_string eq "rge_spring2024_LD2_Pb"
        or $configuration_string eq "rge_spring2024_LD2_Sn") {
        build_rge_liquid_targets();
    }
    else {
        print "Error: Unknown target variation: $configuration_string\n";
    }

}

1;
