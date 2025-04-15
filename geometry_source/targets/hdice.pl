# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;

sub build_hdice {
    print("   - target_zpos for $configuration{'variation'}: $target_zpos\n");
    my %detector = init_det();

    $detector{"name"} = "hdIce_mother";
    $detector{"mother"} = "root";
    $detector{"description"} = "Target Container";
    $detector{"color"} = "22ff22";
    $detector{"type"} = "Box";
    $detector{"dimensions"} = "160*mm 160*mm 800*mm";
    $detector{"material"} = "G4_Galactic";
    $detector{"style"} = 0;
    $detector{"mfield"} = "hdicefield";
    print_det(\%configuration, \%detector);
}

1;
