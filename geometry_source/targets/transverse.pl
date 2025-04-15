# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;

sub build_transverse {
    #	Length: 28.4 mm
    #	ID: 27.0 mm
    #	OD: 29.0
    #	Al foils: 25 um thick

    print("   - target_zpos for $configuration{'variation'}: $target_zpos\n");
    my %detector = init_det();

    my $ttlength = 14.2; # half length
    my $ttid = 13.5;
    my $ttod = 14.5;
    my $ttfoil = 0.0125; # half length


    # cell frame
    $detector{"name"} = "ttargetCellFrame";
    $detector{"mother"} = "root";
    $detector{"description"} = "Target Container";
    $detector{"color"} = "222222";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $ttod*mm $ttlength*mm 0*deg 360*deg";
    $detector{"material"} = "Kel-F";
    $detector{"style"} = 1;
    #print_det(\%configuration, \%detector);

    # cell
    %detector = init_det();
    $detector{"name"} = "ttargetCell";
    $detector{"mother"} = "root";
    $detector{"description"} = "Target Container";
    $detector{"color"} = "994422";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $ttid*mm $ttlength*mm 0*deg 360*deg";
    $detector{"material"} = "NH3target";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # downstream al window
    my $zpos = $ttlength + $ttfoil;
    %detector = init_det();
    $detector{"name"} = "al_window_entrance";
    $detector{"mother"} = "root";
    $detector{"description"} = "25 mm thick aluminum window upstream";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $ttid*mm $ttfoil*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # upstream al window
    $zpos = -$ttlength - $ttfoil;
    %detector = init_det();
    $detector{"name"} = "al_window_exit";
    $detector{"mother"} = "root";
    $detector{"description"} = "25 mm thick aluminum window upstream";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $ttid*mm $ttfoil*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

}

1;
