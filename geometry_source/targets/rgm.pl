# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $target_zpos;
my $target_length = 256.56;

sub build_Sn {
    # Flag Shaft Geometry (cm/deg)
    my @flag_shaft = (0.2665, 0.3175, 8.145, 0, 360, 0, 0, 0); #Inner radius, outer radius, half length (1), initial angle, final angle, x angle, y angle, z angle

    #Flag Pole Geometry (cm/deg)
    my @Sn_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 0, 0);  #Inner radius, outer radius, half length (2), initial angle, final angle, x angle, y angle, z angle for the Sn flag poles.
    my @C_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, -55, 0); #Inner radius, outer radius, half length (2), initial angle, final angle, x angle, y angle, z angle for the C flag poles.

    #Flag Geometry (cm)
    my @Sn_flag = (0.167, 0.1905, 0.0355, 0, 0, 0); #Half x, y, z dimensions and x, y, z angles for the Sn flag that holds the target foils.
    my @C_flag = (0.167, 0.1905, 0.0355, 0, 0, 55); #Half x, y, z dimensions and x, y, z angles for the C flag that holds the target foils.

    #Targets Geometry (cm)
    my @Sn_target = (0.1685, 0.405, 0.1, 0, 0, 0); #Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
    my @C_target = (0.1685, 0.405, 0.1, 0, 0, 55); #Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.


    my $separation = 0.127; #Distance the flags set the target above the end of the flag poles.

    my @flag_pole_relpos = (0.381, 1.25, 1.25, 1.25);                                                                                                                                                                                                                                                                 #Distance from end of flag_shaft to center of flag_pole 1, center of flag_pole 1 to center of flag_pole 2, center of flag_pole 2 to center of flag_pole 3, and center of flag_pole 3 to center of flag_pole 4
    my @row = ($flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2] - $flag_pole_relpos[3], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1], $flag_shaft[2] - $flag_pole_relpos[0]); #Positions of rows of the flag_poles.

    #offset to "zero" the center of the target.
    my $offset_x = 0.0;
    my $offset_y = -(2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation);                                                                          #Set Y=0 to be center on target.
    my $offset_z = (0.625 - (($row[1] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]) + ($row[2] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2])) / 2); #0.625 from magic? (first flag is flag 0)

    #Adjusted position of the rows for the flag poles.
    my $row_pole = ($row[3] + $offset_z);

    #Adjusted positions of the rows for the target foils.
    my $row_target = ($row[3] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]);

    #Adjusted positions of the rows for the flags.
    my $row_flag = ($row[3] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2]);


    #Sn Flag Pole position (cm).
    my $sT_x2 = 0.0 + $offset_x;
    my $Sn_p_y = $Sn_flag_pole[2] + $flag_shaft[1] + $offset_y;

    #C Flag Pole positions (cm).
    my $C_p_x = 0.81915 * ($C_flag_pole[2] + $flag_shaft[1]) + $offset_x; #Cos(35) is the decimal out front.
    my $C_p_y = 0.57358 * ($C_flag_pole[2] + $flag_shaft[1]) + $offset_y; #Sin(35) is the decimal out front.

    #Sn Targets positions (cm).
    my $Sn_t_x = 0.0 + $offset_x;
    my $Sn_t_y = (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;

    #C Targets positions (cm).
    my $C_t_x = 0.81915 * (2 * $C_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_x; #Cos(35) is the decimal out front.
    my $C_t_y = 0.57358 * (2 * $C_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y; #Sin(35) is the decimal out front.

    #Sn Flag positions (cm).
    my $Sn_f_x = 0.0 + $offset_x;
    my $Sn_f_y = (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;

    #C Flag positions (cm).
    my $C_f_x = 0.81915 * (2 * $C_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_x; #Cos(35) is the decimal out front.
    my $C_f_y = 0.57358 * (2 * $C_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y; #Sin(35) is the decimal out front.


    #Mother Volume
    my $nplanes = 4;
    my @oradius = (50.2, 50.2, 21.0, 21.0);
    my @z_plane = (-115.0, 265.0, 290.0, 300.0);

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


    #Flag Shaft
    $detector{"name"} = "flag shaft";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Tube Main";
    $detector{"pos"} = "$offset_x*cm $offset_y*cm $offset_z*cm";
    $detector{"rotation"} = "$flag_shaft[5]*deg $flag_shaft[6]*deg $flag_shaft[7]*deg";
    $detector{"color"} = "000099";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$flag_shaft[0]*cm $flag_shaft[1]*cm $flag_shaft[2]*cm 0*deg 360*deg";
    $detector{"material"} = "G4_Al"; #Al 6061-T6
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    #C flag poles.
    $detector{"name"} = "C_p1";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Flag Pole C";
    $detector{"pos"} = "$C_p_x*cm $C_p_y*cm $row_pole*cm";
    $detector{"rotation"} = "$C_flag_pole[5]*deg $C_flag_pole[6]*deg $C_flag_pole[7]*deg";
    $detector{"color"} = "990000";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$C_flag_pole[0]*cm $C_flag_pole[1]*cm $C_flag_pole[2]*cm 0*deg 360*deg";
    $detector{"material"} = "G4_Al"; #Al 6061
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    #Sn flag poles.
    $detector{"name"} = "Sn_p1";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Flag Pole Sn";
    $detector{"pos"} = "$sT_x2*cm $Sn_p_y*cm $row_pole*cm";
    $detector{"rotation"} = "$Sn_flag_pole[5]*deg $Sn_flag_pole[6]*deg $Sn_flag_pole[7]*deg";
    $detector{"color"} = "990000";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Sn_flag_pole[0]*cm $Sn_flag_pole[1]*cm $Sn_flag_pole[2]*cm 0*deg 360*deg";
    $detector{"material"} = "G4_Al"; #Al 6061
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    #Carbon foil targets.
    $detector{"name"} = "Carbon_t1";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target C";
    $detector{"pos"} = "$C_t_x*cm $C_t_y*cm $row_target*cm";
    $detector{"rotation"} = "$C_target[3]*deg $C_target[4]*deg $C_target[5]*deg";
    $detector{"color"} = "000099";
    $detector{"type"} = "Box";
    $detector{"dimensions"} = "$C_target[0]*cm $C_target[1]*cm $C_target[2]*cm";
    $detector{"material"} = "G4_C";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    #Tin foil targets.
    $detector{"name"} = "Tin_t1";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Sn";
    $detector{"pos"} = "$Sn_t_x*cm $Sn_t_y*cm $row_target*cm";
    $detector{"rotation"} = "$Sn_target[3]*deg $Sn_target[4]*deg $Sn_target[5]*deg";
    $detector{"color"} = "444444";
    $detector{"type"} = "Box";
    $detector{"dimensions"} = "$Sn_target[0]*cm $Sn_target[1]*cm $Sn_target[2]*cm";
    $detector{"material"} = "G4_Sn";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    #Carbon Flag.
    $detector{"name"} = "C_flag";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Flag C";
    $detector{"pos"} = "$C_f_x*cm $C_f_y*cm $row_flag*cm";
    $detector{"rotation"} = "$C_flag[3]*deg $C_flag[4]*deg $C_flag[5]*deg";
    $detector{"color"} = "009900";
    $detector{"type"} = "Box";
    $detector{"dimensions"} = "$C_flag[0]*cm $C_flag[1]*cm $C_flag[2]*cm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    #Tin Flag.
    $detector{"name"} = "Sn_flag";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Flag Sn";
    $detector{"pos"} = "$Sn_f_x*cm $Sn_f_y*cm $row_flag*cm";
    $detector{"rotation"} = "$Sn_flag[3]*deg $Sn_flag[4]*deg $Sn_flag[5]*deg";
    $detector{"color"} = "009900";
    $detector{"type"} = "Box";
    $detector{"dimensions"} = "$Sn_flag[0]*cm $Sn_flag[1]*cm $Sn_flag[2]*cm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub build_C {
    #Flag Shaft Geometry (cm/deg)
    my @flag_shaft = (0.2665, 0.3175, 8.145, 0, 360, 0, 0, 0); #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle

    #Flag Pole Geometry (cm/deg)
    my @Sn_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 55, 0); #Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the Sn flag poles.
    my @C_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 0, 0);   #Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the C flag poles.

    #Flag Geometry (cm)
    my @Sn_flag = (0.167, 0.1905, 0.0355, 0, 0, -55); #Half x, y, z dimensions and x, y, z angles for the Sn flag that holds the target foils.
    my @C_flag = (0.167, 0.1905, 0.0355, 0, 0, 0);    #Half x, y, z dimensions and x, y, z angles for the C flag that holds the target foils.

    #Targets Geometry (cm)
    my @Sn_target = (0.1685, 0.405, 0.1, 0, 0, -55); #Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
    my @C_target = (0.1685, 0.405, 0.1, 0, 0, 0);    #Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.


    my $separation = 0.127; #Distance the flags set the target above the end of the flag poles.

    my @flag_pole_relpos = (0.381, 1.25, 1.25, 1.25);                                                                                                                                                                                                                                                                 #Distance from end of flag_shaft to center of flag_pole 1, center of flag_pole 1 to center of flag_pole 2, center of flag_pole 2 to center of flag_pole 3, and center of flag_pole 3 to center of flag_pole 4
    my @row = ($flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2] - $flag_pole_relpos[3], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1], $flag_shaft[2] - $flag_pole_relpos[0]); #Positions of rows of the flag_poles.

    #offset to "zero" the center of the target.
    my $offset_x = 0.0;
    my $offset_y = -(2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation);                                                                          #Set Y=0 to be center on target.
    my $offset_z = (0.625 - (($row[1] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]) + ($row[2] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2])) / 2); #0.625 from magic? (first flag is flag 0)

    #Adjusted position of the rows for the flag poles.
    my $row_pole = ($row[3] + $offset_z);

    #Adjusted positions of the rows for the target foils.
    my $row_target = ($row[3] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]);

    #Adjusted positions of the rows for the flags.
    my $row_flag = ($row[3] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2]);


    #Sn Flag Pole position (cm).
    my $sT_x2 = -(0.81915 * ($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_x); #Cos(35) is the decimal out front.
    my $Sn_p_y = 0.57358 * ($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_y;   #Sin(35) is the decimal out front.

    #C Flag Pole positions (cm).
    my $C_p_x = 0.0 + $offset_x;
    my $C_p_y = $C_flag_pole[2] + $flag_shaft[1] + $offset_y;

    #Sn Targets positions (cm).
    my $Sn_t_x = -(0.81915 * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_x); #Cos(35) is the decimal out front.
    my $Sn_t_y = 0.57358 * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;    #Sin(35) is the decimal out front.

    #C Targets positions (cm).
    my $C_t_x = 0.0 + $offset_x;
    my $C_t_y = (2 * $C_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;

    #Sn Flag positions (cm).
    my $Sn_f_x = -(0.81915 * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_x); #Cos(35) is the decimal out front.
    my $Sn_f_y = 0.57358 * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;    #Sin(35) is the decimal out front.

    #C Flag positions (cm).
    my $C_f_x = 0.0 + $offset_x;
    my $C_f_y = (2 * $C_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;

    #Mother Volume
    my $nplanes = 4;
    my @oradius = (50.2, 50.2, 21.0, 21.0);
    my @z_plane = (-115.0, 265.0, 290.0, 300.0);

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


    #Flag Shaft
    $detector{"name"} = "flag shaft";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Tube Main";
    $detector{"pos"} = "$offset_x*cm $offset_y*cm $offset_z*cm";
    $detector{"rotation"} = "$flag_shaft[5]*deg $flag_shaft[6]*deg $flag_shaft[7]*deg";
    $detector{"color"} = "000099";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$flag_shaft[0]*cm $flag_shaft[1]*cm $flag_shaft[2]*cm 0*deg 360*deg";
    $detector{"material"} = "G4_Al"; #Al 6061-T6
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    #C flag poles.
    $detector{"name"} = "C_p1";
    $detector{"mother"} = "target"; #Carbon
    $detector{"description"} = "RGM Solid Target Flag Pole C";
    $detector{"pos"} = "$C_p_x*cm $C_p_y*cm $row_pole*cm";
    $detector{"rotation"} = "$C_flag_pole[5]*deg $C_flag_pole[6]*deg $C_flag_pole[7]*deg";
    $detector{"color"} = "990000";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$C_flag_pole[0]*cm $C_flag_pole[1]*cm $C_flag_pole[2]*cm 0*deg 360*deg";
    $detector{"material"} = "G4_Al"; #Al 6061
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    #Sn flag poles.
    $detector{"name"} = "Sn_p1";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Flag Pole Sn";
    $detector{"pos"} = "$sT_x2*cm $Sn_p_y*cm $row_pole*cm";
    $detector{"rotation"} = "$Sn_flag_pole[5]*deg $Sn_flag_pole[6]*deg $Sn_flag_pole[7]*deg";
    $detector{"color"} = "990000";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Sn_flag_pole[0]*cm $Sn_flag_pole[1]*cm $Sn_flag_pole[2]*cm 0*deg 360*deg";
    $detector{"material"} = "G4_Al"; #Al 6061
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    #Carbon foil targets.
    $detector{"name"} = "Carbon_t1";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target C";
    $detector{"pos"} = "$C_t_x*cm $C_t_y*cm $row_target*cm";
    $detector{"rotation"} = "$C_target[3]*deg $C_target[4]*deg $C_target[5]*deg";
    $detector{"color"} = "000099";
    $detector{"type"} = "Box";
    $detector{"dimensions"} = "$C_target[0]*cm $C_target[1]*cm $C_target[2]*cm";
    $detector{"material"} = "G4_C";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    #Tin foil targets.
    $detector{"name"} = "Tin_t1";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Sn";
    $detector{"pos"} = "$Sn_t_x*cm $Sn_t_y*cm $row_target*cm";
    $detector{"rotation"} = "$Sn_target[3]*deg $Sn_target[4]*deg $Sn_target[5]*deg";
    $detector{"color"} = "444444";
    $detector{"type"} = "Box";
    $detector{"dimensions"} = "$Sn_target[0]*cm $Sn_target[1]*cm $Sn_target[2]*cm";
    $detector{"material"} = "G4_Sn";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    #Carbon Flag.
    $detector{"name"} = "C_flag";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Flag C";
    $detector{"pos"} = "$C_f_x*cm $C_f_y*cm $row_flag*cm";
    $detector{"rotation"} = "$C_flag[3]*deg $C_flag[4]*deg $C_flag[5]*deg";
    $detector{"color"} = "009900";
    $detector{"type"} = "Box";
    $detector{"dimensions"} = "$C_flag[0]*cm $C_flag[1]*cm $C_flag[2]*cm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    #Tin Flag.
    $detector{"name"} = "Sn_flag";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Flag Sn";
    $detector{"pos"} = "$Sn_f_x*cm $Sn_f_y*cm $row_flag*cm";
    $detector{"rotation"} = "$Sn_flag[3]*deg $Sn_flag[4]*deg $Sn_flag[5]*deg";
    $detector{"color"} = "009900";
    $detector{"type"} = "Box";
    $detector{"dimensions"} = "$Sn_flag[0]*cm $Sn_flag[1]*cm $Sn_flag[2]*cm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}



sub build_rgm_targets {

    print("Target_zpos for $configuration{'factory'}/$configuration{'variation'}/$configuration{'run_number'}  : $target_zpos\n");

        my $configuration_string = clas12_configuration_string(\%configuration);

    if ($configuration_string eq "rgm_fall2021_Sn") {
        build_Sn();
    }
    elsif ($configuration_string eq "rgm_fall2021_C") {
        build_C();
    }



}

1;
