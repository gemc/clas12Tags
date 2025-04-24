# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our $target_zpos;

sub build_longitudinal {
    print("Target_zpos for $configuration{'factory'}/$configuration{'variation'}/$configuration{'run_number'}  : $target_zpos\n");
    my %detector = init_det();

    my $nplanes = 4;

    my @oradius = (50.2, 50.2, 21.0, 21.0);
    my @z_plane = (-115.0, 265.0, 290.0, 300.0);

    # vacuum target container
    $detector{"name"} = "ltarget";
    $detector{"mother"} = "root";
    $detector{"description"} = "Target Container";
    $detector{"color"} = "22ff22";
    $detector{"type"} = "Polycone";
    my $dimen = "0.0*deg 360*deg $nplanes*counts";
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " 0.0*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $oradius[$i]*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $z_plane[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_Galactic";
    $detector{"style"} = 0;
    print_det(\%configuration, \%detector);

    %detector = init_det();
    $detector{"name"} = "al_window_entrance";
    $detector{"mother"} = "ltarget";
    $detector{"description"} = "5 mm radius aluminum window upstream";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm 5*mm 0.0125*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm -24.2125*mm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    %detector = init_det();
    $detector{"name"} = "al_window_exit";
    $detector{"mother"} = "ltarget";
    $detector{"description"} = "1/8 in radius aluminum window downstream";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm 3.175*mm 0.0125*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm 173.2825*mm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

}

sub build_longitudinal_mats {
		%mat = init_mat();
		$mat{"name"}          = "polarizedHe3";
		$mat{"description"}   = "polarizedHe3 target";
		$mat{"density"}        = "0.000748";
		$mat{"ncomponents"}   = "1";
		$mat{"components"}    = "helium3Gas 1";
		print_mat(\%configuration, \%mat);
}

1;
