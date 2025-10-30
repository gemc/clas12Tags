# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;

sub build_rge_liquid_LD2_target {

    my $nplanes = 4;
    my @oradius = (52, 52, 45, 21);
    my @z_plane = (-215.0, 165.0, 180.0, 200.0);

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

    # Liquid target cell upstream window
    my $thicknessU = 0.015 / 2.;
    my $zposU = -70.35;
    my $radiusU = 4.95;
    $detector{"name"} = "LD2CellWindowU";
    $detector{"mother"} = "target";
    $detector{"description"} = "Liquid target cell upstream window";
    $detector{"color"} = "848789";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0 0 $zposU*mm";
    $detector{"dimensions"} = "0*mm $radiusU*mm $thicknessU*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # Liquid target cell downstream window
    my $thicknessD = 0.015 / 2.;
    my $zposD = -50.34;
    my $radiusD = 4.95;
    $detector{"name"} = "LD2CellWindowD";
    $detector{"mother"} = "target";
    $detector{"description"} = "Liquid target cell downstream window";
    $detector{"color"} = "848789";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0 0 $zposD*mm";
    $detector{"dimensions"} = "0*mm $radiusD*mm $thicknessD*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # actual lD2 target
    $nplanes = 6;
    my @oradiusT = (2.5, 7.0, 7.8, 6.7, 5.5, 2.5);
    my @z_planeT = (-70.30, -68.0, -66.2, -52.5, -51.0, -50.40);
    %detector = init_det();
    $detector{"name"} = "lD2";
    $detector{"mother"} = "target";
    $detector{"description"} = "Target Cell";
    $detector{"color"} = "aa0000";
    $detector{"type"} = "Polycone";
    $dimen = "0.0*deg 360*deg $nplanes*counts";
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " 0.0*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $oradiusT[$i]*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $z_planeT[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "LD2"; # defined in gemc database
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # reference foil
    my $thickness = 0.01 / 2.;
    my $zpos = -30.33;
    my $radius = 10;
    $detector{"name"} = "refFoil";
    $detector{"mother"} = "target";
    $detector{"description"} = "aluminum refernence foil";
    $detector{"color"} = "848789";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0 0 $zpos*mm";
    $detector{"dimensions"} = "0*mm $radius*mm $thickness*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);
}

sub build_rge_liquid_empty_target {
    my $nplanes = 4;
    my @oradius = (52, 52, 45, 21);
    my @z_plane = (-215.0, 165.0, 180.0, 200.0);

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

    # Liquid target cell upstream window
    my $thicknessU = 0.015 / 2.;
    my $zposU = -70.35;
    my $radiusU = 4.95;
    $detector{"name"} = "LD2CellWindowU";
    $detector{"mother"} = "target";
    $detector{"description"} = "Liquid target cell upstream window";
    $detector{"color"} = "848789";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0 0 $zposU*mm";
    $detector{"dimensions"} = "0*mm $radiusU*mm $thicknessU*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # Liquid target cell upstream window
    my $thicknessD = 0.015 / 2.;
    my $zposD = -50.34;
    my $radiusD = 4.95;
    $detector{"name"} = "LD2CellWindowD";
    $detector{"mother"} = "target";
    $detector{"description"} = "Liquid target cell downstream window";
    $detector{"color"} = "848789";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0 0 $zposD*mm";
    $detector{"dimensions"} = "0*mm $radiusD*mm $thicknessD*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # reference foil
    my $thickness = 0.01 / 2.;
    my $zpos = -30.33;
    my $radius = 10;
    $detector{"name"} = "refFoil";
    $detector{"mother"} = "target";
    $detector{"description"} = "aluminum refernence foil";
    $detector{"color"} = "848789";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0 0 $zpos*mm";
    $detector{"dimensions"} = "0*mm $radius*mm $thickness*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);
}

sub build_rge_materials {
		# epoxy
		my %mat = init_mat();
		$mat{"name"}          = "epoxy";
		$mat{"description"}   = "epoxy glue 1.16 g/cm3";
		$mat{"density"}       = "1.16";
		$mat{"ncomponents"}   = "4";
		$mat{"components"}    = "H 32 N 2 O 4 C 15";
		print_mat(\%configuration, \%mat);

		# fiberglass
		%mat = init_mat();
		$mat{"name"}          = "fiberglass";
		$mat{"description"}   = "fiberglass in fr4 g/cm3";
		$mat{"density"}       = "2.61";
		$mat{"ncomponents"}   = "4";
		$mat{"components"}    = "G4_SILICON_DIOXIDE 0.57 G4_CALCIUM_OXIDE 0.21 G4_ALUMINUM_OXIDE 0.14 G4_BORON_OXIDE 0.08";
		print_mat(\%configuration, \%mat);

		# FR4
		%mat = init_mat();
		$mat{"name"}          = "FR4";
		$mat{"description"}   = "FR4 for circuit boards g/cm3";
		$mat{"density"}       = "1.80";
		$mat{"ncomponents"}   = "2";
		$mat{"components"}    = "fiberglass 0.60 epoxy 0.40";
		print_mat(\%configuration, \%mat);

		# band
		%mat = init_mat();
		$mat{"name"}          = "band";
		$mat{"description"}   = "Band made of fiberglass and cu similar to circuit board but different proportions g/cm3";
		$mat{"density"}       = "2.99";
		$mat{"ncomponents"}   = "2";
		$mat{"components"}    = "FR4 0.50 G4_Cu 0.50";
		print_mat(\%configuration, \%mat);

		# carbon fiber
		%mat = init_mat();
		$mat{"name"}          = "carbonFiber";
		$mat{"description"}   = "carbon fiber material is epoxy and carbon - 1.75g/cm3";
		$mat{"density"}       = "1.75";
		$mat{"ncomponents"}   = "2";
		$mat{"components"}    = "G4_C 0.745 epoxy 0.255";
		print_mat(\%configuration, \%mat);

		# torlon4435
		%mat = init_mat();
		$mat{"name"}          = "torlon4435";
		$mat{"description"}   = "torlon4435 - black (my guess) g/cm3";
		$mat{"density"}       = "1.59";
		$mat{"ncomponents"}   = "5";
		$mat{"components"}    = "H 4 N 2 O 3 C 9 Ar 1";
		print_mat(\%configuration, \%mat);

		# torlon4203
		%mat = init_mat();
		$mat{"name"}          = "torlon4203";
		$mat{"description"}   = "torlon4203 - yellow (my guess) g/cm3";
		$mat{"density"}       = "1.41";
		$mat{"ncomponents"}   = "5";
		$mat{"components"}    = "H 4 N 2 O 3 C 9 Ar 1";
		print_mat(\%configuration, \%mat);
}

sub build_rge_liquid_targets {

    print("Target_zpos for $configuration{'factory'}/$configuration{'variation'}/$configuration{'run_number'}  : $target_zpos\n");
    my $configuration_string = clas12_configuration_string(\%configuration);

    if ($configuration_string eq "rge_spring2024_LD2_Al" ||
        $configuration_string eq "rge_spring2024_LD2_C" ||
        $configuration_string eq "rge_spring2024_LD2_Cu" ||
        $configuration_string eq "rge_spring2024_LD2_Pb" ||
        $configuration_string eq "rge_spring2024_LD2_Sn") {
        build_rge_liquid_LD2_target();
    } elsif ($configuration_string eq "rge_spring2024_Empty_Al" ||
             $configuration_string eq "rge_spring2024_Empty_C" ||
             $configuration_string eq "rge_spring2024_Empty_Empty" ||
             $configuration_string eq "rge_spring2024_Empty_Pb") {
        build_rge_liquid_empty_target();
    } else {
        print "Target not found in the database: $configuration_string\n";
        exit;
    }

    build_rge_materials();
}

1;
