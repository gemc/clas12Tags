# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;

# variations scripts
require "./pbtest.pl";
require "./ND3.pl";
require "./hdice.pl";
require "./longitudinal.pl";
require "./transverse.pl";

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
}

1;
