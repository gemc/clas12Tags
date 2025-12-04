# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

use Math::Trig;

our %configuration;
our %parameters;

our $target_zpos;
my $target_length = 256.56;

# small target
sub build_RGM_2_Sn {

    #Flag Shaft Geometry (cm/deg)
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

# small target
sub build_RGM_2_C {
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

# small target
sub build_RGM_8_Sn_S {
    #Flag Shaft Geometry (cm/deg)
    my @flag_shaft = (0.2665, 0.3175, 8.145, 0, 360, 0, 0, 0); #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle

    #Flag Pole Geometry (cm/deg)
    my @Sn_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 0, 0);  #Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the Sn flag poles.
    my @C_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, -55, 0); #Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the C flag poles.

    #Flag Geometry (cm)
    my @Sn_flag = (0.167, 0.1905, 0.0355, 0, 0, 0); #Half x, y, z dimensions and x, y, z angles for the Sn flag that holds the target foils.
    my @C_flag = (0.167, 0.1905, 0.0355, 0, 0, 55); #Half x, y, z dimensions and x, y, z angles for the C flag that holds the target foils.

    #Targets Geometry (cm)
    my @Sn_target = (0.1685, 0.405, 0.025, 0, 0, 0); #Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
    my @C_target = (0.1685, 0.405, 0.025, 0, 0, 55); #Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.


    my $separation = 0.127; #Distance the flags set the target above the end of the flag poles.

    my @flag_pole_relpos = (0.381, 1.25, 1.25, 1.25);                                                                                                                                                                                                                                                                 #Distance from end of flag_shaft to center of flag_pole 1, center of flag_pole 1 to center of flag_pole 2, center of flag_pole 2 to center of flag_pole 3, and center of flag_pole 3 to center of flag_pole 4
    my @row = ($flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2] - $flag_pole_relpos[3], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1], $flag_shaft[2] - $flag_pole_relpos[0]); #Positions of rows of the flag_poles.

    #offset to "zero" everything where I want.
    my $offset_x = 0.0;
    my $offset_y = -(2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation);
    my $offset_z = -(($row[1] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]) + ($row[2] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2])) / 2;

    #Adjusted position of the rows for the flag poles.
    my @row_pole = ($row[0] + $offset_z, $row[1] + $offset_z, $row[2] + $offset_z, $row[3] + $offset_z);

    #Adjusted positions of the rows for the target foils.
    my @row_target = ($row[0] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2], $row[1] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2], $row[2] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2], $row[3] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]);

    #Adjusted positions of the rows for the flags.
    my @row_flag = ($row[0] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[1] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[2] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[3] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2]);


    #Sn Flag Pole position (cm).
    my $Sn_p_x = 0.0 + $offset_x;
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
    my @name = ("C_p1", "C_p2", "C_p3", "C_p4"); #So that all the entires in the text file have unique names if I have to look at it.
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag Pole C";
        $detector{"pos"} = "$C_p_x*cm $C_p_y*cm $row_pole[$i]*cm";
        $detector{"rotation"} = "$C_flag_pole[5]*deg $C_flag_pole[6]*deg $C_flag_pole[7]*deg";
        $detector{"color"} = "990000";
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$C_flag_pole[0]*cm $C_flag_pole[1]*cm $C_flag_pole[2]*cm 0*deg 360*deg";
        $detector{"material"} = "G4_Al"; #Al 6061
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Sn flag poles.
    @name = ("Sn_p1", "Sn_p2", "Sn_p3", "Sn_p4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag Pole Sn";
        $detector{"pos"} = "$Sn_p_x*cm $Sn_p_y*cm $row_pole[$i]*cm";
        $detector{"rotation"} = "$Sn_flag_pole[5]*deg $Sn_flag_pole[6]*deg $Sn_flag_pole[7]*deg";
        $detector{"color"} = "990000";
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$Sn_flag_pole[0]*cm $Sn_flag_pole[1]*cm $Sn_flag_pole[2]*cm 0*deg 360*deg";
        $detector{"material"} = "G4_Al"; #Al 6061
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Carbon foil targets.
    @name = ("Carbon_t1", "Carbon_t2", "Carbon_t3", "Carbon_t4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target C";
        $detector{"pos"} = "$C_t_x*cm $C_t_y*cm $row_target[$i]*cm";
        $detector{"rotation"} = "$C_target[3]*deg $C_target[4]*deg $C_target[5]*deg";
        $detector{"color"} = "000099";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$C_target[0]*cm $C_target[1]*cm $C_target[2]*cm";
        $detector{"material"} = "G4_C";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Tin foil targets.
    @name = ("Tin_t1", "Tin_t2", "Tin_t3", "Tin_t4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Sn";
        $detector{"pos"} = "$Sn_t_x*cm $Sn_t_y*cm $row_target[$i]*cm";
        $detector{"rotation"} = "$Sn_target[3]*deg $Sn_target[4]*deg $Sn_target[5]*deg";
        $detector{"color"} = "444444";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$Sn_target[0]*cm $Sn_target[1]*cm $Sn_target[2]*cm";
        $detector{"material"} = "G4_Sn";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Carbon Flags.
    @name = ("C_flag1", "c_flag2", "C_flag3", "C_flag4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag C";
        $detector{"pos"} = "$C_f_x*cm $C_f_y*cm $row_flag[$i]*cm";
        $detector{"rotation"} = "$C_flag[3]*deg $C_flag[4]*deg $C_flag[5]*deg";
        $detector{"color"} = "009900";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$C_flag[0]*cm $C_flag[1]*cm $C_flag[2]*cm";
        $detector{"material"} = "G4_Al";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Tin Flags.
    @name = ("Sn_flag1", "Sn_flag2", "Sn_flag3", "Sn_flag4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag Sn";
        $detector{"pos"} = "$Sn_f_x*cm $Sn_f_y*cm $row_flag[$i]*cm";
        $detector{"rotation"} = "$Sn_flag[3]*deg $Sn_flag[4]*deg $Sn_flag[5]*deg";
        $detector{"color"} = "009900";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$Sn_flag[0]*cm $Sn_flag[1]*cm $Sn_flag[2]*cm";
        $detector{"material"} = "G4_Al";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}

# large target
sub build_RGM_8_Sn_L {
    #Flag Shaft Geometry (cm/deg)
    my @flag_shaft = (0.2665, 0.3175, 8.145, 0, 360, 0, 0, 0); #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle

    #Flag Pole Geometry (cm/deg)
    my @Sn_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 0, 0);  #Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the Sn flag poles.
    my @C_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, -55, 0); #Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the C flag poles.

    #Flag Geometry (cm)
    my @Sn_flag = (0.167, 0.1905, 0.0355, 0, 0, 0); #Half x, y, z dimensions and x, y, z angles for the Sn flag that holds the target foils.
    my @C_flag = (0.167, 0.1905, 0.0355, 0, 0, 55); #Half x, y, z dimensions and x, y, z angles for the C flag that holds the target foils.

    #Targets Geometry (cm)
    my @Sn_target = (0.2397, 0.455, 0.025, 0, 0, 0); #Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
    my @C_target = (0.2397, 0.455, 0.025, 0, 0, 55); #Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.


    my $separation = 0.127; #Distance the flags set the target above the end of the flag poles.

    my @flag_pole_relpos = (0.381, 1.25, 1.25, 1.25);                                                                                                                                                                                                                                                                 #Distance from end of flag_shaft to center of flag_pole 1, center of flag_pole 1 to center of flag_pole 2, center of flag_pole 2 to center of flag_pole 3, and center of flag_pole 3 to center of flag_pole 4
    my @row = ($flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2] - $flag_pole_relpos[3], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1], $flag_shaft[2] - $flag_pole_relpos[0]); #Positions of rows of the flag_poles.

    #offset to "zero" everything where I want.
    my $offset_x = 0.0;
    my $offset_y = -(2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation);
    my $offset_z = -(($row[1] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]) + ($row[2] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2])) / 2;

    #Adjusted position of the rows for the flag poles.
    my @row_pole = ($row[0] + $offset_z, $row[1] + $offset_z, $row[2] + $offset_z, $row[3] + $offset_z);

    #Adjusted positions of the rows for the target foils.
    my @row_target = ($row[0] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2], $row[1] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2], $row[2] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2], $row[3] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]);

    #Adjusted positions of the rows for the flags.
    my @row_flag = ($row[0] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[1] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[2] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[3] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2]);


    #Sn Flag Pole position (cm).
    my $Sn_p_x = 0.0 + $offset_x;
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
    $detector{"pos"} = "0*mm 0*mm $target_zpos*mm";
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
    my @name = ("C_p1", "C_p2", "C_p3", "C_p4"); #So that all the entires in the text file have unique names if I have to look at it.
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag Pole C";
        $detector{"pos"} = "$C_p_x*cm $C_p_y*cm $row_pole[$i]*cm";
        $detector{"rotation"} = "$C_flag_pole[5]*deg $C_flag_pole[6]*deg $C_flag_pole[7]*deg";
        $detector{"color"} = "990000";
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$C_flag_pole[0]*cm $C_flag_pole[1]*cm $C_flag_pole[2]*cm 0*deg 360*deg";
        $detector{"material"} = "G4_Al"; #Al 6061
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Sn flag poles.
    @name = ("Sn_p1", "Sn_p2", "Sn_p3", "Sn_p4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag Pole Sn";
        $detector{"pos"} = "$Sn_p_x*cm $Sn_p_y*cm $row_pole[$i]*cm";
        $detector{"rotation"} = "$Sn_flag_pole[5]*deg $Sn_flag_pole[6]*deg $Sn_flag_pole[7]*deg";
        $detector{"color"} = "990000";
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$Sn_flag_pole[0]*cm $Sn_flag_pole[1]*cm $Sn_flag_pole[2]*cm 0*deg 360*deg";
        $detector{"material"} = "G4_Al"; #Al 6061
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Carbon foil targets.
    @name = ("Carbon_t1", "Carbon_t2", "Carbon_t3", "Carbon_t4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target C";
        $detector{"pos"} = "$C_t_x*cm $C_t_y*cm $row_target[$i]*cm";
        $detector{"rotation"} = "$C_target[3]*deg $C_target[4]*deg $C_target[5]*deg";
        $detector{"color"} = "000099";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$C_target[0]*cm $C_target[1]*cm $C_target[2]*cm";
        $detector{"material"} = "G4_C";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Tin foil targets.
    @name = ("Tin_t1", "Tin_t2", "Tin_t3", "Tin_t4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Sn";
        $detector{"pos"} = "$Sn_t_x*cm $Sn_t_y*cm $row_target[$i]*cm";
        $detector{"rotation"} = "$Sn_target[3]*deg $Sn_target[4]*deg $Sn_target[5]*deg";
        $detector{"color"} = "444444";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$Sn_target[0]*cm $Sn_target[1]*cm $Sn_target[2]*cm";
        $detector{"material"} = "G4_Sn";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Carbon Flags.
    @name = ("C_flag1", "c_flag2", "C_flag3", "C_flag4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag C";
        $detector{"pos"} = "$C_f_x*cm $C_f_y*cm $row_flag[$i]*cm";
        $detector{"rotation"} = "$C_flag[3]*deg $C_flag[4]*deg $C_flag[5]*deg";
        $detector{"color"} = "009900";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$C_flag[0]*cm $C_flag[1]*cm $C_flag[2]*cm";
        $detector{"material"} = "G4_Al";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Tin Flags.
    @name = ("Sn_flag1", "Sn_flag2", "Sn_flag3", "Sn_flag4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag Sn";
        $detector{"pos"} = "$Sn_f_x*cm $Sn_f_y*cm $row_flag[$i]*cm";
        $detector{"rotation"} = "$Sn_flag[3]*deg $Sn_flag[4]*deg $Sn_flag[5]*deg";
        $detector{"color"} = "009900";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$Sn_flag[0]*cm $Sn_flag[1]*cm $Sn_flag[2]*cm";
        $detector{"material"} = "G4_Al";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}

# small target
sub build_RGM_8_C_S {
    #Flag Shaft Geometry (cm/deg)
    my @flag_shaft = (0.2665, 0.3175, 8.145, 0, 360, 0, 0, 0); #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle

    #Flag Pole Geometry (cm/deg)
    my @Sn_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 55, 0); #Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the Sn flag poles.
    my @C_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 0, 0);   #Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the C flag poles.

    #Flag Geometry (cm)
    my @Sn_flag = (0.167, 0.1905, 0.0355, 0, 0, -55); #Half x, y, z dimensions and x, y, z angles for the Sn flag that holds the target foils.
    my @C_flag = (0.167, 0.1905, 0.0355, 0, 0, 0);    #Half x, y, z dimensions and x, y, z angles for the C flag that holds the target foils.

    #Targets Geometry (cm)
    my @Sn_target = (0.1685, 0.405, 0.025, 0, 0, -55); #Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
    my @C_target = (0.1685, 0.405, 0.025, 0, 0, 0);    #Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.


    my $separation = 0.127; #Distance the flags set the target above the end of the flag poles.

    my @flag_pole_relpos = (0.381, 1.25, 1.25, 1.25);                                                                                                                                                                                                                                                                 #Distance from end of flag_shaft to center of flag_pole 1, center of flag_pole 1 to center of flag_pole 2, center of flag_pole 2 to center of flag_pole 3, and center of flag_pole 3 to center of flag_pole 4
    my @row = ($flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2] - $flag_pole_relpos[3], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1], $flag_shaft[2] - $flag_pole_relpos[0]); #Positions of rows of the flag_poles.

    #offset to "zero" everything where I want.
    my $offset_x = 0.0;
    my $offset_y = -(2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation);
    my $offset_z = -(($row[1] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]) + ($row[2] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2])) / 2;

    #Adjusted position of the rows for the flag poles.
    my @row_pole = ($row[0] + $offset_z, $row[1] + $offset_z, $row[2] + $offset_z, $row[3] + $offset_z);

    #Adjusted positions of the rows for the target foils.
    my @row_target = ($row[0] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2], $row[1] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2], $row[2] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2], $row[3] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]);

    #Adjusted positions of the rows for the flags.
    my @row_flag = ($row[0] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[1] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[2] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[3] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2]);


    #Sn Flag Pole position (cm).
    my $Sn_p_x = -(0.81915 * ($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_x); #Cos(35) is the decimal out front.
    my $Sn_p_y = 0.57358 * ($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_y;    #Sin(35) is the decimal out front.

    #C Flag Pole positions (cm).
    my $C_p_x = 0.0 + $offset_x;
    my $C_p_y = $C_flag_pole[2] + $flag_shaft[1] + $offset_y;

    #Sn Targets positions (cm).
    my $Sn_t_x = -(0.81915 * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_x); #Cos(35) is the decimal out front.
    my $Sn_t_y = 0.57358 * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;    #Sin(35) is the decimal out front.

    #C Targets positions (cm).
    my $C_t_x = 0.0 + $offset_x;
    my $C_t_y = (2 * $C_flag_pole[2] + $flag_shaft[1] + $C_target[1] + $separation) + $offset_y;

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
    my @name = ("C_p1", "C_p2", "C_p3", "C_p4"); #So that all the entires in the text file have unique names if I have to look at it.
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag Pole C";
        $detector{"pos"} = "$C_p_x*cm $C_p_y*cm $row_pole[$i]*cm";
        $detector{"rotation"} = "$C_flag_pole[5]*deg $C_flag_pole[6]*deg $C_flag_pole[7]*deg";
        $detector{"color"} = "990000";
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$C_flag_pole[0]*cm $C_flag_pole[1]*cm $C_flag_pole[2]*cm 0*deg 360*deg";
        $detector{"material"} = "G4_Al"; #Al 6061
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Sn flag poles.
    @name = ("Sn_p1", "Sn_p2", "Sn_p3", "Sn_p4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag Pole Sn";
        $detector{"pos"} = "$Sn_p_x*cm $Sn_p_y*cm $row_pole[$i]*cm";
        $detector{"rotation"} = "$Sn_flag_pole[5]*deg $Sn_flag_pole[6]*deg $Sn_flag_pole[7]*deg";
        $detector{"color"} = "990000";
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$Sn_flag_pole[0]*cm $Sn_flag_pole[1]*cm $Sn_flag_pole[2]*cm 0*deg 360*deg";
        $detector{"material"} = "G4_Al"; #Al 6061
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Carbon foil targets.
    @name = ("Carbon_t1", "Carbon_t2", "Carbon_t3", "Carbon_t4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target C";
        $detector{"pos"} = "$C_t_x*cm $C_t_y*cm $row_target[$i]*cm";
        $detector{"rotation"} = "$C_target[3]*deg $C_target[4]*deg $C_target[5]*deg";
        $detector{"color"} = "000099";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$C_target[0]*cm $C_target[1]*cm $C_target[2]*cm";
        $detector{"material"} = "G4_C";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Tin foil targets.
    @name = ("Tin_t1", "Tin_t2", "Tin_t3", "Tin_t4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Sn";
        $detector{"pos"} = "$Sn_t_x*cm $Sn_t_y*cm $row_target[$i]*cm";
        $detector{"rotation"} = "$Sn_target[3]*deg $Sn_target[4]*deg $Sn_target[5]*deg";
        $detector{"color"} = "444444";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$Sn_target[0]*cm $Sn_target[1]*cm $Sn_target[2]*cm";
        $detector{"material"} = "G4_Sn";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Carbon Flags.
    @name = ("C_flag1", "c_flag2", "C_flag3", "C_flag4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag C";
        $detector{"pos"} = "$C_f_x*cm $C_f_y*cm $row_flag[$i]*cm";
        $detector{"rotation"} = "$C_flag[3]*deg $C_flag[4]*deg $C_flag[5]*deg";
        $detector{"color"} = "009900";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$C_flag[0]*cm $C_flag[1]*cm $C_flag[2]*cm";
        $detector{"material"} = "G4_Al";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Tin Flags.
    @name = ("Sn_flag1", "Sn_flag2", "Sn_flag3", "Sn_flag4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag Sn";
        $detector{"pos"} = "$Sn_f_x*cm $Sn_f_y*cm $row_flag[$i]*cm";
        $detector{"rotation"} = "$Sn_flag[3]*deg $Sn_flag[4]*deg $Sn_flag[5]*deg";
        $detector{"color"} = "009900";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$Sn_flag[0]*cm $Sn_flag[1]*cm $Sn_flag[2]*cm";
        $detector{"material"} = "G4_Al";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}

# large target
sub build_RGM_8_C_L {


    print("Target_zpos for $configuration{'factory'}/$configuration{'variation'}/$configuration{'run_number'}  : $target_zpos\n");


    #Flag Shaft Geometry (cm/deg)
    my @flag_shaft = (0.2665, 0.3175, 8.145, 0, 360, 0, 0, 0); #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle

    #Flag Pole Geometry (cm/deg)
    my @Sn_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 55, 0); #Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the Sn flag poles.
    my @C_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 0, 0);   #Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the C flag poles.

    #Flag Geometry (cm)
    my @Sn_flag = (0.167, 0.1905, 0.0355, 0, 0, -55); #Half x, y, z dimensions and x, y, z angles for the Sn flag that holds the target foils.
    my @C_flag = (0.167, 0.1905, 0.0355, 0, 0, 0);    #Half x, y, z dimensions and x, y, z angles for the C flag that holds the target foils.

    #Targets Geometry (cm)
    my @Sn_target = (0.2397, 0.455, 0.025, 0, 0, -55); #Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
    my @C_target = (0.2397, 0.455, 0.025, 0, 0, 0);    #Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.


    my $separation = 0.127; #Distance the flags set the target above the end of the flag poles.

    my @flag_pole_relpos = (0.381, 1.25, 1.25, 1.25);                                                                                                                                                                                                                                                                 #Distance from end of flag_shaft to center of flag_pole 1, center of flag_pole 1 to center of flag_pole 2, center of flag_pole 2 to center of flag_pole 3, and center of flag_pole 3 to center of flag_pole 4
    my @row = ($flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2] - $flag_pole_relpos[3], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1], $flag_shaft[2] - $flag_pole_relpos[0]); #Positions of rows of the flag_poles.

    #offset to "zero" everything where I want.
    my $offset_x = 0.0;
    my $offset_y = -(2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation);
    my $offset_z = -(($row[1] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]) + ($row[2] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2])) / 2;

    #Adjusted position of the rows for the flag poles.
    my @row_pole = ($row[0] + $offset_z, $row[1] + $offset_z, $row[2] + $offset_z, $row[3] + $offset_z);

    #Adjusted positions of the rows for the target foils.
    my @row_target = ($row[0] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2], $row[1] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2], $row[2] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2], $row[3] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]);

    #Adjusted positions of the rows for the flags.
    my @row_flag = ($row[0] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[1] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[2] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[3] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2]);


    #Sn Flag Pole position (cm).
    my $Sn_p_x = -(0.81915 * ($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_x); #Cos(35) is the decimal out front.
    my $Sn_p_y = 0.57358 * ($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_y;    #Sin(35) is the decimal out front.

    #C Flag Pole positions (cm).
    my $C_p_x = 0.0 + $offset_x;
    my $C_p_y = $C_flag_pole[2] + $flag_shaft[1] + $offset_y;

    #Sn Targets positions (cm).
    my $Sn_t_x = -(0.81915 * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_x); #Cos(35) is the decimal out front.
    my $Sn_t_y = 0.57358 * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;    #Sin(35) is the decimal out front.

    #C Targets positions (cm).
    my $C_t_x = 0.0 + $offset_x;
    my $C_t_y = (2 * $C_flag_pole[2] + $flag_shaft[1] + $C_target[1] + $separation) + $offset_y;

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
    $detector{"pos"} = "0*mm 0*mm $target_zpos*mm";
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
    my @name = ("C_p1", "C_p2", "C_p3", "C_p4"); #So that all the entires in the text file have unique names if I have to look at it.
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag Pole C";
        $detector{"pos"} = "$C_p_x*cm $C_p_y*cm $row_pole[$i]*cm";
        $detector{"rotation"} = "$C_flag_pole[5]*deg $C_flag_pole[6]*deg $C_flag_pole[7]*deg";
        $detector{"color"} = "990000";
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$C_flag_pole[0]*cm $C_flag_pole[1]*cm $C_flag_pole[2]*cm 0*deg 360*deg";
        $detector{"material"} = "G4_Al"; #Al 6061
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Sn flag poles.
    @name = ("Sn_p1", "Sn_p2", "Sn_p3", "Sn_p4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag Pole Sn";
        $detector{"pos"} = "$Sn_p_x*cm $Sn_p_y*cm $row_pole[$i]*cm";
        $detector{"rotation"} = "$Sn_flag_pole[5]*deg $Sn_flag_pole[6]*deg $Sn_flag_pole[7]*deg";
        $detector{"color"} = "990000";
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$Sn_flag_pole[0]*cm $Sn_flag_pole[1]*cm $Sn_flag_pole[2]*cm 0*deg 360*deg";
        $detector{"material"} = "G4_Al"; #Al 6061
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Carbon foil targets.
    @name = ("Carbon_t1", "Carbon_t2", "Carbon_t3", "Carbon_t4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target C";
        $detector{"pos"} = "$C_t_x*cm $C_t_y*cm $row_target[$i]*cm";
        $detector{"rotation"} = "$C_target[3]*deg $C_target[4]*deg $C_target[5]*deg";
        $detector{"color"} = "000099";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$C_target[0]*cm $C_target[1]*cm $C_target[2]*cm";
        $detector{"material"} = "G4_C";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Tin foil targets.
    @name = ("Tin_t1", "Tin_t2", "Tin_t3", "Tin_t4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Sn";
        $detector{"pos"} = "$Sn_t_x*cm $Sn_t_y*cm $row_target[$i]*cm";
        $detector{"rotation"} = "$Sn_target[3]*deg $Sn_target[4]*deg $Sn_target[5]*deg";
        $detector{"color"} = "444444";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$Sn_target[0]*cm $Sn_target[1]*cm $Sn_target[2]*cm";
        $detector{"material"} = "G4_Sn";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Carbon Flags.
    @name = ("C_flag1", "c_flag2", "C_flag3", "C_flag4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag C";
        $detector{"pos"} = "$C_f_x*cm $C_f_y*cm $row_flag[$i]*cm";
        $detector{"rotation"} = "$C_flag[3]*deg $C_flag[4]*deg $C_flag[5]*deg";
        $detector{"color"} = "009900";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$C_flag[0]*cm $C_flag[1]*cm $C_flag[2]*cm";
        $detector{"material"} = "G4_Al";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }


    #Tin Flags.
    @name = ("Sn_flag1", "Sn_flag2", "Sn_flag3", "Sn_flag4");
    for (my $i = 0; $i < 4; $i++) {
        $detector{"name"} = "$name[$i]";
        $detector{"mother"} = "target";
        $detector{"description"} = "RGM Solid Target Flag Sn";
        $detector{"pos"} = "$Sn_f_x*cm $Sn_f_y*cm $row_flag[$i]*cm";
        $detector{"rotation"} = "$Sn_flag[3]*deg $Sn_flag[4]*deg $Sn_flag[5]*deg";
        $detector{"color"} = "009900";
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$Sn_flag[0]*cm $Sn_flag[1]*cm $Sn_flag[2]*cm";
        $detector{"material"} = "G4_Al";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}

sub build_RGM_Ca {
    #Cell Wall Geometry (cm/degrees)
    my @Cell_wall = (1.3875, 1.4, 10.255, 0, 360, 0, 0, 0); #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the Cell Cylinder.

    #Entrance End Caps Geometry (cm/degrees)
    my @ent_cap_1 = (1.087, 1.387, 1.6885, 0, 360, 0, 0, 0); #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.
    my @ent_cap_2 = (0.38, 1.375, 1.025, 0, 360, 0, 0, 0);   #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.
    my @ent_cap_3 = (0.38, 2.925, 0.725, 0, 360, 0, 0, 0);   #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.

    #Entrace Window Geometry (cm/degrees)
    my @cell_ent = (0.0, 0.753, 0.0015, 0, 360, 0, 0, 0); #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.

    #Exit End Caps Geometry (cm/degrees)
    my @ex_cap_1 = (1.408, 1.423, 0.47, 0, 360, 0, 0, 0);                #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.
    my @ex_cap_2 = (1.408, 1.423, 0.644, 0.659, 0.212, 0, 360, 0, 0, 0); #Inner radius 1, outer radius 1, inner radius 2, outer radius 2, half length z, initial angle, final angle, x angle, y angle, z angle for the target.

    #Entrace Window Geometry (cm/degrees)
    my @cell_ex = (0.0, 0.659, 0.0015, 0, 360, 0, 0, 0); #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.

    #Target Geometry (cm/degrees)
    my @Ca_target = (0, 0.635, 0.1, 0, 360, 0, 0, 0); #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.

    #Target Holder Geometry (cm/degrees)
    my @holder_1 = (0.5, 1.387, 0.250, 0, 360, 0, 0, 0); #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.
    my @holder_2 = (0.5, 1.387, 0.250, 0, 360, 0, 0, 0); #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.

    #Target Retainer Geometry (cm/degrees)
    my @retainer = (0.635, 1.387, 0.1, 0, 360, 0, 0, 0); #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.
    #my @retainer = (0.64, 0.3825, 0.1, 0, 0, 0);											#Half x, y (holder_1[2]-Ca_target[2])/2, z dimensions and x, y, z angles for the target retainer.


    my $Ca_tar_rel_wall = 14.385; #Distance from the beginning of the cell wall to the front of the Calcium target (cm).

    my $offset_x = 0;
    my $offset_y = 0;
    my $offset_z = ($Ca_tar_rel_wall - $Cell_wall[2] + $Ca_target[2]); #offsets so that the middle of the target is on "0".

    #Cell Wall Position (cm)
    my @Cell_wall_pos = ($offset_x, $offset_y, $offset_z); #x,y,z position

    #Exit End Cap: Part 1 Position (cm)
    my @ex_cap_1_pos = ($offset_x, $offset_y, ($Cell_wall[2] - $ex_cap_1[2] + 0.001 + $offset_z)); #x,y,z position		#0.001 from cap being pushed down on cell walls

    #Exit End Cap: Part 2 Position (cm)
    my @ex_cap_2_pos = ($offset_x, $offset_y, ($Cell_wall[2] + 0.002 + $ex_cap_2[4] + $offset_z)); #x,y,z position		#0.002 from cap being pushed down on cell walls

    #Cell Exit Window Position (cm)
    my @cell_ex_pos = ($offset_x, $offset_y, ($Cell_wall[2] + 0.002 + 2 * $ex_cap_2[4] + $cell_ex[2] + $offset_z)); #x,y,z position		#0.002 from cap being pushed down on cell walls

    #Entrance End Cap: Part 1 Position (cm)
    my @ent_cap_1_pos = ($offset_x, $offset_y, (-$Cell_wall[2] + 2 * $ent_cap_2[2] + $ent_cap_1[2] + $offset_z)); #x,y,z position

    #Entrance End Cap: Part 2 Position (cm)
    my @ent_cap_2_pos = ($offset_x, $offset_y, (-$Cell_wall[2] + $ent_cap_2[2] + $offset_z)); #x,y,z position

    #Entrance End Cap: Part 3 Position (cm)
    my @ent_cap_3_pos = ($offset_x, $offset_y, (-$Cell_wall[2] - $ent_cap_3[2] + $offset_z)); #x,y,z position

    #Cell Entrance Window Position (cm)
    my @cell_ent_pos = ($offset_x, $offset_y, (-$Cell_wall[2] + 2 * $ent_cap_2[2] + $cell_ent[2] + $offset_z)); #x,y,z position

    #Target Position (cm)
    my @Ca_target_pos = ($offset_x, $offset_y, (-$Cell_wall[2] + 2 * $ent_cap_2[2] + 2 * $ent_cap_1[2] + 2 * $holder_1[2] + $Ca_target[2] + $offset_z)); #x,y,z position
    #holder Position Part 1 (cm)
    my @holder_pos_1 = ($offset_x, $offset_y, (-$Cell_wall[2] + 2 * $ent_cap_2[2] + 2 * $ent_cap_1[2] + $holder_1[2] + $offset_z)); #x,y,z position
    #holder Position Part 2 (cm)
    my @holder_pos_2 = ($offset_x, $offset_y, (-$Cell_wall[2] + 2 * $ent_cap_2[2] + 2 * $ent_cap_1[2] + 2 * $holder_1[2] + 2 * $Ca_target[2] + $holder_2[2] + $offset_z)); #x,y,z position

    #retainer Position (cm)
    my @retainer_pos = ($offset_x, $offset_y, (-$Cell_wall[2] + 2 * $ent_cap_2[2] + 2 * $ent_cap_1[2] + 2 * $holder_1[2] + $retainer[2] + $offset_z)); #x,y,z position
    #my @retainer_pos = ($offset_x, $Ca_target[1] + $retainer[1] + $offset_y, (- $Cell_wall[2] + 2*$ent_cap_2[2] + 2*$ent_cap_1[2] + 2*$holder_1[2] + $Ca_target[2] + $offset_z) );	#x,y,z position


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
    $detector{"pos"} = "0*mm 0*mm $target_zpos*mm";
    my $dimen = "0.0*deg 360*deg $nplanes*counts";
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " 0.0*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $oradius[$i]*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $z_plane[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_Galactic";
    $detector{"style"} = 0;
    print_det(\%configuration, \%detector);


    #Cell Wall
    $detector{"name"} = "Cell_Wall";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Cell Wall";
    $detector{"pos"} = "$Cell_wall_pos[0]*cm $Cell_wall_pos[1]*cm $Cell_wall_pos[2]*cm";
    $detector{"rotation"} = "$Cell_wall[5]*deg $Cell_wall[6]*deg $Cell_wall[7]*deg";
    $detector{"color"} = "444444";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Cell_wall[0]*cm $Cell_wall[1]*cm $Cell_wall[2]*cm $Cell_wall[3]*deg $Cell_wall[4]*deg";
    $detector{"material"} = "G4_KAPTON";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    #Exit Cap: Part 1
    $detector{"name"} = "Ex_Cap_1";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Exit End Cap: Part 1";
    $detector{"pos"} = "$ex_cap_1_pos[0]*cm $ex_cap_1_pos[1]*cm $ex_cap_1_pos[2]*cm";
    $detector{"rotation"} = "$ex_cap_1[5]*deg $ex_cap_1[6]*deg $ex_cap_1[7]*deg";
    $detector{"color"} = "009900";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$ex_cap_1[0]*cm $ex_cap_1[1]*cm $ex_cap_1[2]*cm $ex_cap_1[3]*deg $ex_cap_1[4]*deg";
    $detector{"material"} = "G4_KAPTON";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    #Exit Cap: Part 2
    $detector{"name"} = "Ex_Cap_2";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Exit End Cap: Part 2";
    $detector{"pos"} = "$ex_cap_2_pos[0]*cm $ex_cap_2_pos[1]*cm $ex_cap_2_pos[2]*cm";
    $detector{"rotation"} = "$ex_cap_2[7]*deg $ex_cap_2[8]*deg $ex_cap_2[9]*deg";
    $detector{"color"} = "990000";
    $detector{"type"} = "Cons";
    $detector{"dimensions"} = "$ex_cap_2[0]*cm $ex_cap_2[1]*cm $ex_cap_2[2]*cm $ex_cap_2[3]*cm $ex_cap_2[4]*cm $ex_cap_2[5]*deg $ex_cap_2[6]*deg";
    $detector{"material"} = "G4_KAPTON";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    #Exit Window
    $detector{"name"} = "Exit_Window";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Exit Window";
    $detector{"pos"} = "$cell_ex_pos[0]*cm $cell_ex_pos[1]*cm $cell_ex_pos[2]*cm";
    $detector{"rotation"} = "$cell_ex[5]*deg $cell_ex[6]*deg $cell_ex[7]*deg";
    $detector{"color"} = "000099";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$cell_ex[0]*cm $cell_ex[1]*cm $cell_ex[2]*cm $cell_ex[3]*deg $cell_ex[4]*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    #Entrance End Cap: Part 1
    $detector{"name"} = "Ent_Cap_1";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Entrance End Cap: Part 1";
    $detector{"pos"} = "$ent_cap_1_pos[0]*cm $ent_cap_1_pos[1]*cm $ent_cap_1_pos[2]*cm";
    $detector{"rotation"} = "$ent_cap_1[5]*deg $ent_cap_1[6]*deg $ent_cap_1[7]*deg";
    $detector{"color"} = "990000";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$ent_cap_1[0]*cm $ent_cap_1[1]*cm $ent_cap_1[2]*cm $ent_cap_1[3]*deg $ent_cap_1[4]*deg";
    $detector{"material"} = "G4_KAPTON";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    #Entrance End Cap: Part 2
    $detector{"name"} = "Ent_Cap_2";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Entrance End Cap: Part 2";
    $detector{"pos"} = "$ent_cap_2_pos[0]*cm $ent_cap_2_pos[1]*cm $ent_cap_2_pos[2]*cm";
    $detector{"rotation"} = "$ent_cap_2[5]*deg $ent_cap_2[6]*deg $ent_cap_2[7]*deg";
    $detector{"color"} = "009900";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$ent_cap_2[0]*cm $ent_cap_2[1]*cm $ent_cap_2[2]*cm $ent_cap_2[3]*deg $ent_cap_2[4]*deg";
    $detector{"material"} = "G4_KAPTON";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    #Entrance End Cap: Part 3
    $detector{"name"} = "Ent_Cap_3";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Entrance End Cap: Part 2";
    $detector{"pos"} = "$ent_cap_3_pos[0]*cm $ent_cap_3_pos[1]*cm $ent_cap_3_pos[2]*cm";
    $detector{"rotation"} = "$ent_cap_3[5]*deg $ent_cap_3[6]*deg $ent_cap_3[7]*deg";
    $detector{"color"} = "990000";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$ent_cap_3[0]*cm $ent_cap_3[1]*cm $ent_cap_3[2]*cm $ent_cap_3[3]*deg $ent_cap_3[4]*deg";
    $detector{"material"} = "G4_KAPTON";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    #Entrance Window
    $detector{"name"} = "Entrance_Window";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Entrance Window";
    $detector{"pos"} = "$cell_ent_pos[0]*cm $cell_ent_pos[1]*cm $cell_ent_pos[2]*cm";
    $detector{"rotation"} = "$cell_ent[5]*deg $cell_ent[6]*deg $cell_ent[7]*deg";
    $detector{"color"} = "000099";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$cell_ent[0]*cm $cell_ent[1]*cm $cell_ent[2]*cm $cell_ent[3]*deg $cell_ent[4]*deg";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    #Ca Target
    $detector{"name"} = "Ca Target";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Ca Target";
    $detector{"pos"} = "$Ca_target_pos[0]*cm $Ca_target_pos[1]*cm $Ca_target_pos[2]*cm";
    $detector{"rotation"} = "$Ca_target[5]*deg $Ca_target[6]*deg $Ca_target[7]*deg";
    $detector{"color"} = "990000";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Ca_target[0]*cm $Ca_target[1]*cm $Ca_target[2]*cm $Ca_target[3]*deg $Ca_target[4]*deg";
    $detector{"material"} = "G4_Ca";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    #holder part 1
    $detector{"name"} = "Holder Part 1";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Holder Part 1";
    $detector{"pos"} = "$holder_pos_1[0]*cm $holder_pos_1[1]*cm $holder_pos_1[2]*cm";
    $detector{"rotation"} = "$holder_1[5]*deg $holder_1[6]*deg $holder_1[7]*deg";
    $detector{"color"} = "009900";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$holder_1[0]*cm $holder_1[1]*cm $holder_1[2]*cm $holder_1[3]*deg $holder_1[4]*deg";
    $detector{"material"} = "rohacell";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    #holder part 2
    $detector{"name"} = "Holder Part 2";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Holder Part 2";
    $detector{"pos"} = "$holder_pos_2[0]*cm $holder_pos_2[1]*cm $holder_pos_2[2]*cm";
    $detector{"rotation"} = "$holder_2[5]*deg $holder_2[6]*deg $holder_2[7]*deg";
    $detector{"color"} = "009900";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$holder_2[0]*cm $holder_2[1]*cm $holder_2[2]*cm $holder_2[3]*deg $holder_2[4]*deg";
    $detector{"material"} = "rohacell";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    #retainer
    #$detector{"name"}        = "Retainer";
    #$detector{"mother"}      = "target";
    #$detector{"description"} = "RGM Solid Target Retainer";
    #$detector{"pos"}         = "$retainer_pos[0]*cm $retainer_pos[1]*cm $retainer_pos[2]*cm";
    #$detector{"rotation"}    = "$retainer[3]*deg $retainer[4]*deg $retainer[5]*deg";
    #$detector{"color"}       = "000099";
    #$detector{"type"}        = "Box";
    #$detector{"dimensions"}  = "$retainer[0]*cm $retainer[1]*cm $retainer[2]*cm";
    #$detector{"material"}    = "rohacell";
    #$detector{"style"}       = 1;
    #print_det(\%configuration, \%detector);

    #retainer
    $detector{"name"} = "Retainer";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Retainer";
    $detector{"pos"} = "$retainer_pos[0]*cm $retainer_pos[1]*cm $retainer_pos[2]*cm";
    $detector{"rotation"} = "$retainer[3]*deg $retainer[4]*deg $retainer[5]*deg";
    $detector{"color"} = "000099";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$retainer[0]*cm $retainer[1]*cm $retainer[2]*cm $retainer[3]*deg $retainer[4]*deg";
    $detector{"material"} = "rohacell";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

# Short cryocell targets - lAr, small foils, and large foils
sub build_short_cryocell_targets {
    my ($configuration_string) = @_; #To add $configuration_string as an argument to the build_short_cryocell_targets subroutine

    # Flag Shaft Geometry (cm/deg)
    my @flag_shaft = (0.2665, 0.3175, 8.145, 0, 360, 0, 0, 0); #Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle

    my (@Sn_flag_pole, @C_flag_pole, @Sn_flag, @C_flag, @Sn_target, @C_target, @flag_pole_relpos, @row);
    my ($separation, $offset_x, $offset_y, $offset_z, $row_pole, $row_target, $row_flag, $Sn_p_x, $Sn_p_y);
    my ($C_p_x, $C_p_y, $Sn_t_x, $Sn_t_y, $C_t_x, $C_t_y, $Sn_f_x, $Sn_f_y, $C_f_x, $C_f_y);
    
    # Variables for calculating the custom foil target's z offset
    my ($cryocell_to_foil_difference, $exit_window_z_dimensions, $foil_half_thickness, $custom_foil_z_offset);

    # separation = distance the flags set the target above the end of the flag poles.
    # This distance is kept the same for small and large foils.
    $separation = 0.127;

    # Calculate the custom z offset for the foil targets within the cryocell, to fit the data up to a few mm:
    $cryocell_to_foil_difference = 3.4; # Measured in CAD drawing, conformed in the data up to a few mm.
    # $cryocell_to_foil_difference = 3.24; # Measured in CAD drawing, conformed in the data up to a few mm.
    $exit_window_z_dimensions = 0.25;    # Distance from the upstream edge of the cryocell's CAD exit window, to the CAD upstream face of the foils (cm).
    $foil_half_thickness = 0.1;          # Half thickness of the foil target (cm).
    # $custom_foil_z_offset = 0;
    $custom_foil_z_offset = 5 - $cryocell_to_foil_difference + $exit_window_z_dimensions - $foil_half_thickness;
    $flag_shaft[2] = ($flag_shaft[2]*2 - $custom_foil_z_offset)/2; # Update the flag_shaft half length to include the custom z offset, so that the shaft won't go out of the mother volume.

    print("\n\ncustom_foil_z_offset:\t\t\t\t $custom_foil_z_offset [cm]\n\n");

    @flag_pole_relpos = (0.381, 1.25, 1.25, 1.25); #Distance from end of flag_shaft to center of flag_pole 1, center of flag_pole 1 to center of flag_pole 2, center of flag_pole 2 to center of flag_pole 3, and center of flag_pole 3 to center of flag_pole 4
    @row = ($flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2] - $flag_pole_relpos[3], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1], $flag_shaft[2] - $flag_pole_relpos[0]); #Positions of rows of the flag_poles.

    # In the following, we set the parameters for the foil target setup based on the technical drawings of the system.
    # Here:
    #       - Small foils (rgm_fall2021_C_v2_S): the same dimensions as the previous implementation, rgm_fall2021_C (RGM_2_C)
    #       - Large foils (rgm_fall2021_C_v2_L): dimensions are from the technical drawings of the system, with the exception of the effective width.
    #                      The effective width is the width that a rectangular box would need to have—given the same thickness and height as the actual foil target—so that its total volume equals that of the irregularly shaped (octagonal) foil.

    if ($configuration_string eq "rgm_fall2021_C_v2_S" or $configuration_string eq "rgm_fall2021_C_v2_L") {
        # Here we set the parameters for the foil target setup based on the rgm_fall2021_C (RGM_2_C) variation:

        # Flag Pole Geometry (cm/deg)
        @Sn_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 55, 0); # Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the Sn flag poles.
        @C_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 0, 0);   # Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the C flag poles.

        if ($configuration_string eq "rgm_fall2021_C_v2_S") {
            # Flag Geometry (cm)
            @Sn_flag = (0.167, 0.1905, 0.0355, 0, 0, -55); # Half x, y, z dimensions and x, y, z angles for the Sn flag that holds the target foils.
            @C_flag = (0.167, 0.1905, 0.0355, 0, 0, 0);    # Half x, y, z dimensions and x, y, z angles for the C flag that holds the target foils.

            # Targets Geometry (cm)
            @Sn_target = (0.175, 0.405, $foil_half_thickness, 0, 0, -55); # Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
            @C_target = (0.175, 0.405, $foil_half_thickness, 0, 0, 0);    # Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
            # @Sn_target = (0.175, 0.405, 0.1, 0, 0, -55); # Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
            # @C_target = (0.175, 0.405, 0.1, 0, 0, 0);    # Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
        } elsif ($configuration_string eq "rgm_fall2021_C_v2_L") {
            # Flag Geometry (cm)
            @Sn_flag = (0.167, 0.1905, 0.0355, 0, 0, -55); # Half x, y, z dimensions and x, y, z angles for the Sn flag that holds the target foils.
            @C_flag = (0.167, 0.1905, 0.0355, 0, 0, 0);    # Half x, y, z dimensions and x, y, z angles for the C flag that holds the target foils.

            # Targets Geometry (cm)
            @Sn_target = (0.245, 0.455, $foil_half_thickness, 0, 0, -55); # Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
            @C_target = (0.245, 0.455, $foil_half_thickness, 0, 0, 0);    # Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
            # @Sn_target = (0.245, 0.455, 0.1, 0, 0, -55); # Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
            # @C_target = (0.245, 0.455, 0.1, 0, 0, 0);    # Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
        }

        # Offset to "zero" the center of the target.
        $offset_x = 0.0;
        $offset_y = -(2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation); # Set Y=0 to be center on target.
        $offset_z = (0.625 - (($row[1] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]) + ($row[2] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2])) / 2) - $custom_foil_z_offset; #0.625 from magic? (first flag is flag 0)
        # $offset_z = (0.625 - (($row[1] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]) + ($row[2] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2])) / 2); #0.625 from magic? (first flag is flag 0)

        # Adjusted position of the rows for the flag poles.
        $row_pole = ($row[3] + $offset_z);

        # Adjusted positions of the rows for the target foils.
        $row_target = ($row[3] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]);

        # Adjusted positions of the rows for the flags.
        $row_flag = ($row[3] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2]);

        # Sn Flag Pole position (cm).
        $Sn_p_x = -(0.81915 * ($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_x); # Cos(35) is the decimal out front.
        $Sn_p_y = 0.57358 * ($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_y;    # Sin(35) is the decimal out front.

        # C Flag Pole positions (cm).
        $C_p_x = 0.0 + $offset_x;
        $C_p_y = $C_flag_pole[2] + $flag_shaft[1] + $offset_y;

        # Sn Targets positions (cm).
        $Sn_t_x = -(0.81915 * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_x); # Cos(35) is the decimal out front.
        $Sn_t_y = 0.57358 * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;    # Sin(35) is the decimal out front.

        # C Targets positions (cm).
        $C_t_x = 0.0 + $offset_x;
        $C_t_y = (2 * $C_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;

        # Sn Flag positions (cm).
        $Sn_f_x = -(0.81915 * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_x); # Cos(35) is the decimal out front.
        $Sn_f_y = 0.57358 * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;    # Sin(35) is the decimal out front.

        # C Flag positions (cm).
        $C_f_x = 0.0 + $offset_x;
        $C_f_y = (2 * $C_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;

    } elsif ($configuration_string eq "rgm_fall2021_Ar") {
        # Here we set the parameters for the lAr target setup.
        # This time, the Sn and C foils are rotated to -55/2 deg and +55/2 deg, respectively.

        # Flag Pole Geometry (cm/deg)
        @Sn_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 55/2, 0); # Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the Sn flag poles.
        @C_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, -55/2, 0); # Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the C flag poles.

        # Flag Geometry (cm)
        @Sn_flag = (0.167, 0.1905, 0.0355, 0, 0, -55/2); # Half x, y, z dimensions and x, y, z angles for the Sn flag that holds the target foils.
        @C_flag = (0.167, 0.1905, 0.0355, 0, 0, 55/2);   # Half x, y, z dimensions and x, y, z angles for the C flag that holds the target foils.

        # Targets Geometry (cm)
        @Sn_target = (0.175, 0.405, $foil_half_thickness, 0, 0, -55/2); # Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
        @C_target = (0.175, 0.405, $foil_half_thickness, 0, 0, 55/2);   # Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
        # @Sn_target = (0.175, 0.405, 0.1, 0, 0, -55/2); # Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
        # @C_target = (0.175, 0.405, 0.1, 0, 0, 55/2);   # Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.

        my $Sn_rot_degrees = $Sn_target[5];
        my $C_rot_degrees = $C_target[5];

        my $Sn_rot_radians = deg2rad($Sn_rot_degrees); # Convert to radians
        my $C_rot_radians = deg2rad($C_rot_degrees);   # Convert to radians

        # Offset to "zero" the center of the target.
        $offset_x = 0.0;
        $offset_y = -(2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation); # Set Y=0 to be center on target.
        $offset_z = (0.625 - (($row[1] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]) + ($row[2] - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2])) / 2) - $custom_foil_z_offset; #0.625 from magic? (first flag is flag 0)

        # Adjusted position of the rows for the flag poles.
        $row_pole = ($row[3] + $offset_z);

        # Adjusted positions of the rows for the target foils.
        $row_target = ($row[3] + $offset_z - $Sn_flag_pole[1] + 2 * $Sn_flag[2] + $Sn_target[2]);

        # Adjusted positions of the rows for the flags.
        $row_flag = ($row[3] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2]);

        # Sn Flag Pole position (cm).
        $Sn_p_x = sin($Sn_rot_radians) * ($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_x; # Sin(-55/2) is the decimal out front.
        $Sn_p_y = cos($Sn_rot_radians) * ($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_y; # Cos(-55/2) is the decimal out front.

        # C Flag Pole positions (cm).
        $C_p_x = sin($C_rot_radians) * ($C_flag_pole[2] + $flag_shaft[1]) + $offset_x; # Sin(55/2) is the decimal out front.
        $C_p_y = cos($C_rot_radians) * ($C_flag_pole[2] + $flag_shaft[1]) + $offset_y; # Cos(55/2) is the decimal out front.

        # Sn Targets positions (cm).
        $Sn_t_x = sin($Sn_rot_radians) * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_x; # Sin(-55/2) is the decimal out front.
        $Sn_t_y = cos($Sn_rot_radians) * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y; # Cos(-55/2) is the decimal out front.

        # C Targets positions (cm).
        $C_t_x = sin($C_rot_radians) * (2 * $C_flag_pole[2] + $flag_shaft[1] + $C_target[1] + $separation) + $offset_x; # Sin(55/2) is the decimal out front.
        $C_t_y = cos($C_rot_radians) * (2 * $C_flag_pole[2] + $flag_shaft[1] + $C_target[1] + $separation) + $offset_y; # Cos(55/2) is the decimal out front.

        # Sn Flag positions (cm).
        $Sn_f_x = sin($Sn_rot_radians) * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_x; # Sin(-55/2) is the decimal out front.
        $Sn_f_y = cos($Sn_rot_radians) * (2 * $Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y; # Cos(-55/2) is the decimal out front.

        # C Flag positions (cm).
        $C_f_x = sin($C_rot_radians) * (2 * $C_flag_pole[2] + $flag_shaft[1] + $C_flag[1]) + $offset_x; # Sin(55/2) is the decimal out front.
        $C_f_y = cos($C_rot_radians) * (2 * $C_flag_pole[2] + $flag_shaft[1] + $C_flag[1]) + $offset_y; # Cos(55/2) is the decimal out front.
    }

    # Mother Volume (parameters from lD2)
    my $nplanes = 4;
    my @oradius = (50.3, 50.3, 21.1, 21.1);
    my @z_plane = (-140.0, 265.0, 280.0, 280.0);

    # Vacuum target container
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
    $detector{"pos"} = "0*mm 0*mm $target_zpos*mm"; # Mother volume offset in z direction according to the parameter file
    $detector{"style"} = 0;
    print_det(\%configuration, \%detector);

    # Flag Shaft
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

    # C flag pole
    $detector{"name"} = "Carbon_flag_pole";
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

    # Tin flag pole
    $detector{"name"} = "Tin_flag_pole";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Flag Pole Sn";
    $detector{"pos"} = "$Sn_p_x*cm $Sn_p_y*cm $row_pole*cm";
    $detector{"rotation"} = "$Sn_flag_pole[5]*deg $Sn_flag_pole[6]*deg $Sn_flag_pole[7]*deg";
    $detector{"color"} = "990000";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$Sn_flag_pole[0]*cm $Sn_flag_pole[1]*cm $Sn_flag_pole[2]*cm 0*deg 360*deg";
    $detector{"material"} = "G4_Al"; #Al 6061
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # Carbon Flag
    # C_flag = the piece that holds the target
    $detector{"name"} = "Carbon_flag";
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

    # Tin Flag
    # Sn_flag = the piece that holds the target
    $detector{"name"} = "Tin_flag";
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

    # Carbon foil target
    $detector{"name"} = "Carbon_foil_target";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target C";
    $detector{"pos"} = "$C_t_x*cm $C_t_y*cm $row_target*cm";
    $detector{"rotation"} = "$C_target[3]*deg $C_target[4]*deg $C_target[5]*deg";
    $detector{"color"} = "FF9300";
    $detector{"type"} = "Box";
    $detector{"dimensions"} = "$C_target[0]*cm $C_target[1]*cm $C_target[2]*cm";
    $detector{"material"} = "G4_C";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # Tin foil target
    $detector{"name"} = "Tin_foil_target";
    $detector{"mother"} = "target";
    $detector{"description"} = "RGM Solid Target Sn";
    $detector{"pos"} = "$Sn_t_x*cm $Sn_t_y*cm $row_target*cm";
    $detector{"rotation"} = "$Sn_target[3]*deg $Sn_target[4]*deg $Sn_target[5]*deg";
    $detector{"color"} = "0096FF";
    $detector{"type"} = "Box";
    $detector{"dimensions"} = "$Sn_target[0]*cm $Sn_target[1]*cm $Sn_target[2]*cm";
    $detector{"material"} = "G4_Sn";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # lAr target parameters
    $nplanes = 5;
    my @oradiusT = (2, 7.45, 7.425, 4.5, 1.5);             # With 0.1 mm spacing between the lAr and the windows
    my @z_planeT = (-27.37, -25.47, -25.0, -23.5, -22.63); # With 0.1 mm spacing between the lAr and the windows

    # Actual lAr target
    %detector = init_det();
    if ($configuration_string eq "rgm_fall2021_Ar") {
        $detector{"name"} = "lAr_target_cell";
    } elsif ($configuration_string eq "rgm_fall2021_C_v2_S" or $configuration_string eq "rgm_fall2021_C_v2_L") {
        $detector{"name"} = "Empty_target";
    }
    $detector{"mother"} = "target";
    $detector{"description"} = "Target Cell";
    if ($configuration_string eq "rgm_fall2021_Ar") {
        $detector{"color"} = "aa0000";
    } elsif ($configuration_string eq "rgm_fall2021_C_v2_S" or $configuration_string eq "rgm_fall2021_C_v2_L") {
        $detector{"color"} = "d9d9d9";
    }
    $detector{"type"} = "Polycone";
    $dimen = "0.0*deg 360*deg $nplanes*counts";
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " 0.0*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $oradiusT[$i]*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $z_planeT[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    if ($configuration_string eq "rgm_fall2021_Ar") {
        $detector{"material"} = "lAr_target"; # Custom material definition for liquid argon
    } elsif ($configuration_string eq "rgm_fall2021_C_v2_S" or $configuration_string eq "rgm_fall2021_C_v2_L") {
        $detector{"material"} = "G4_Galactic";
    }
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # Upstream Al window. zpos comes from engineering model, has the shift of 1273.27 mm +  30 mm due to the new engineering center
    # my $eng_shift = 1273.27; # original
    my $eng_shift = 1303.27; # original
    my $al_window_entrance_radius = 2.95; # From Bob (Entrance window diameter is 6 mm) - used smaller radius to 2.95 mm to approximate the window as flat and avoid overlap with the base tube, similar to the lD2 target
    my $al_window_entrance_thickness = 0.015; # From Bob (Entrance window thickness is 30 microns)
    my $zpos = $eng_shift - 1330.77 + $al_window_entrance_thickness; # From BM2101-02-00-0000 (8).pdf
    %detector = init_det();
    $detector{"name"} = "al_window_entrance";
    $detector{"mother"} = "target";
    $detector{"description"} = "30 mm thick aluminum window upstream";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $al_window_entrance_radius*mm $al_window_entrance_thickness*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # Downstream Al window
    $al_window_exit_radius = 5; # From Bob (Exit window diameter is 15 mm) - used smaller radius to 5 mm to approximate the window as flat, similar to the lD2 target
    $al_window_exit_thickness = 0.015; # From Bob (Exit window al_window_exit_thickness is 30 microns)
    $zpos = $eng_shift - 1325.77 - $al_window_exit_thickness; # From BM2101-02-00-0000 (8).pdf
    %detector = init_det();
    $detector{"name"} = "al_window_exit";
    $detector{"mother"} = "target";
    $detector{"description"} = "30 mm thick aluminum window downstream";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $al_window_exit_radius*mm $al_window_exit_thickness*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);

    # Scattering chambers al window, 75 microns
    # Note: the eng. position is 1017.27 - here it is placed 8mm upstream to place it within the mother scattering chamber
    $zpos = $eng_shift - 1025.27;
    $radius = 12;
    $thickness = 0.0375;
    %detector = init_det();
    $detector{"name"} = "al_window_scexit";
    $detector{"mother"} = "target";
    $detector{"description"} = "50 mm thick aluminum window downstream";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $radius*mm $thickness*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);
}

sub build_rgm_targets {

    print("Target_zpos for $configuration{'factory'}/$configuration{'variation'}/$configuration{'run_number'}  : $target_zpos\n");

    my $configuration_string = clas12_configuration_string(\%configuration);

    if ($configuration_string eq "rgm_fall2021_Sn") {
        build_RGM_2_Sn();
    }
    elsif ($configuration_string eq "rgm_fall2021_C") {
        build_RGM_2_C();
    }
    elsif ($configuration_string eq "rgm_fall2021_Cx4") {
        build_RGM_8_C_L();
    }
    elsif ($configuration_string eq "rgm_fall2021_Snx4") {
        build_RGM_8_Sn_L();
    }
    elsif ($configuration_string eq "deprecated") {
        build_RGM_8_Sn_S();
    }
    elsif ($configuration_string eq "deprecated") {
        build_RGM_8_C_S();
    }
    elsif ($configuration_string eq "rgm_fall2021_Ca") {
        build_RGM_Ca();
    }
    elsif ($configuration_string eq "rgm_fall2021_Ar"
        or $configuration_string eq "rgm_fall2021_C_v2_S"
        or $configuration_string eq "rgm_fall2021_C_v2_L") {
        build_short_cryocell_targets($configuration_string);
    }

}

1;
