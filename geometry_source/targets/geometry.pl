# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;

sub load_target_parameters {

    $target_zpos = $parameters{"target_zpos"};

    print("target_zpos for $configuration{'variation'}: $target_zpos\n")
}

sub build_target {
    load_target_parameters();
}

1;
