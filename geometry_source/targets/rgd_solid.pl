# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;

sub build_rgd_CxC {
    print("Target_zpos for $configuration{'factory'}/$configuration{'variation'}/$configuration{'run_number'}  : $target_zpos\n");

    my $nplanes = 4;

    my @oradius = (50.2, 50.2, 21.0, 21.0);
    my @z_plane = (-115.0, 265.0, 290.0, 300.0);

    if ($configuration{'variation'} eq "lH2e") {
        @z_plane = (-115.0, 365.0, 390.0, 925.0);
    }

    # vacuum target container
    my %detector = init_det();
    $detector{"name"} = "target";
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

    $nplanes = 5;
    my @oradiusT = (2.5, 10.3, 7.3, 5.0, 2.5);
    my @z_planeT = (-24.2, -21.2, 22.5, 23.5, 24.5);

    # actual target
    %detector = init_det();
    $detector{"name"} = "lh2";
    $detector{"mother"} = "target";
    $detector{"description"} = "Target Cell";
    $detector{"color"} = "aa0000";
    $detector{"type"} = "Polycone";
    $dimen = "0.0*deg 360*deg $nplanes*counts";
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " 0.0*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $oradiusT[$i]*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $z_planeT[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_lH2";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # CxC foils
    #Upstream Foil: 12C
    my $ZCenter = 75.0; # center location of target along beam axis
    my $Rout = 2;       #
    # New Thickness
    my $length = 1; #(2 mm thick)
    %detector = init_det();
    $detector{"name"} = "1stNuclearTargFoil";
    $detector{"mother"} = "target";
    $detector{"description"} = "First 12C Foil in Flag Assembly";
    #$detector{"pos"}         = "0 0 $ZCenter*mm";
    # As given by Cyril in May 2019
    $detector{"pos"} = "0*mm 0*mm $ZCenter*mm";
    $detector{"color"} = "aa0011";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_C";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    #Second 12C Foil
    $ZCenter = 125.0; # center location of target along beam axis
    $Rout = 2;        #
    # New Thickness
    $length = 1; #(2 mm thick)
    %detector = init_det();
    $detector{"name"} = "2ndNuclearTargFoil";
    $detector{"mother"} = "target";
    $detector{"description"} = "Second 12C Foil in Flag Assembly";
    # As given by Cyril in May 2019 (considering y=0 mm is the bottom edge for 4mm wide foil)
    $detector{"pos"} = "0*mm 0*mm $ZCenter*mm";
    $detector{"color"} = "aa0000";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_C";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # 63Cu & 120Sn foils for the 2nd set of needles
    # 63Cu Foil
    $ZCenter = 75.0;  # center location of target along beam axis
    $Rout = 2;        #
    $length = 0.0465; #(0.093 mm thick)
    %detector = init_det();
    $detector{"name"} = "3rdNuclearTargFoil";
    $detector{"mother"} = "target";
    $detector{"description"} = "63Cu Foil in Flag Assembly";
    # From Cyril drawing for centers positions
    $detector{"pos"} = "27.496*mm -15.875*mm $ZCenter*mm";
    # As given by Cyril in May 2019 from bottom edge/contact point with needle (-16.876mm)
    $detector{"color"} = "#ff007f";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Cu";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # 120Sn
    $ZCenter = 125.0; # center location of target along beam axis
    $Rout = 2;        #
    $length = 0.0855; #(0.171 mm thick)
    %detector = init_det();
    $detector{"name"} = "4thNuclearTargFoil";
    $detector{"mother"} = "target";
    $detector{"description"} = "120Sn Foil in Flag Assembly";
    # From Cyril drawing for centers positions
    $detector{"pos"} = "27.496*mm -15.875*mm $ZCenter*mm";
    # As given by Cyril in May 2019 from bottom edge/contact point with needle (-16.876mm)
    $detector{"color"} = "#ff007f";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Sn";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);
}

sub build_rgd_CuSn {
    print("Target_zpos for $configuration{'factory'}/$configuration{'variation'}/$configuration{'run_number'}  : $target_zpos\n");

    my $nplanes = 4;

    my @oradius = (50.2, 50.2, 21.0, 21.0);
    my @z_plane = (-115.0, 265.0, 290.0, 300.0);

    if ($configuration{'variation'} eq "lH2e") {
        @z_plane = (-115.0, 365.0, 390.0, 925.0);
    }

    # vacuum target container
    my %detector = init_det();
    $detector{"name"} = "target";
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

    $nplanes = 5;
    my @oradiusT = (2.5, 10.3, 7.3, 5.0, 2.5);
    my @z_planeT = (-24.2, -21.2, 22.5, 23.5, 24.5);

    # actual target
    %detector = init_det();
    $detector{"name"} = "lh2";
    $detector{"mother"} = "target";
    $detector{"description"} = "Target Cell";
    $detector{"color"} = "aa0000";
    $detector{"type"} = "Polycone";
    $dimen = "0.0*deg 360*deg $nplanes*counts";
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " 0.0*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $oradiusT[$i]*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $z_planeT[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_lH2";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # 63Cu + 120Sn foils

    # Upstream Foil: 63Cu (Zcenter defined assuming z= 0 cm is the center of CLAS12.
    my $ZCenter = 75.0;  # center location of target along beam axis
    my $Rout = 2;        #
    my $length = 0.0465; #(0.093 mm thick)
    %detector = init_det();
    $detector{"name"} = "1stNuclearTargFoil";
    $detector{"mother"} = "target";
    $detector{"description"} = "First 63Cu Foil in Flag Assembly";
    # As given by Cyril in May 2019
    $detector{"pos"} = "0*mm 0*mm $ZCenter*mm";
    $detector{"color"} = "aa0011";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Cu";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # Second Foil: 120Sn
    $ZCenter = 125.0; # center location of target along beam axis
    $Rout = 2;        #
    $length = 0.0855; #(0.171 mm thick)
    %detector = init_det();
    $detector{"name"} = "2ndNuclearTargFoil";
    $detector{"mother"} = "target";
    $detector{"description"} = "Second 120Sn Foil in Flag Assembly";
    #$detector{"pos"}         = "0 0 $ZCenter*mm";
    # As given by Cyril in May 2019
    $detector{"pos"} = "0*mm 0*mm $ZCenter*mm";
    $detector{"color"} = "aa0000";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Sn";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # CxC foils for the 2nd Needles Set

    # First 12C foil
    $ZCenter = 75.0; # center location of target along beam axis
    $Rout = 2;       #
    # New Thickness
    $length = 1; #(2 mm thick)
    %detector = init_det();
    $detector{"name"} = "3rdNuclearTargFoil";
    $detector{"mother"} = "target";
    $detector{"description"} = "First 12C Foil in Flag Assembly";
    # From Cyril drawing for centers positions
    $detector{"pos"} = "27.496*mm -15.875*mm $ZCenter*mm";
    $detector{"color"} = "#ff007f";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_C";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # Second 12C Foil
    $ZCenter = 125.0; # center location of target along beam axis

    $Rout = 2; #
    # New Thickness
    $length = 1; #(2 mm thick)
    %detector = init_det();
    $detector{"name"} = "4thNuclearTargFoil";
    $detector{"mother"} = "target";
    $detector{"description"} = "Second 12C Foil in Flag Assembly";
    # From Cyril drawing for centers positions
    $detector{"pos"} = "27.496*mm -15.875*mm $ZCenter*mm";
    $detector{"color"} = "#ff007f";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
    $detector{"material"} = "G4_C";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);
}

1;
