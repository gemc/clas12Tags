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
require "./liquid_standards.pl";
require "./bonus.pl";
require "./rgm.pl";

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
        or $configuration_string eq "rgm_fall2021_He") {
        build_liquid_standards();
    }
    elsif ($configuration_string eq "rgf_spring2020") {
        build_bonus_targets();
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
    else {
        print "Error: Unknown target variation: $configuration_string\n";
    }

}

1;
