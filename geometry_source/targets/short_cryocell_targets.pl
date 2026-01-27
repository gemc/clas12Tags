# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;

sub build_lAr_mats {
    # lAr target
    my %mat = init_mat();
    $mat{"name"}          = "lAr_target";
    $mat{"description"}   = "lAr target 1.396 g/cm3";
    $mat{"density"}       = "1.396";
    $mat{"ncomponents"}   = "1";
    $mat{"components"}    = "G4_Ar 1";
    print_mat(\%configuration, \%mat);

}

1;
