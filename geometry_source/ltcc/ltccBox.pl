use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;

our $startS;
our $endS;

our @rga_spring2018_sectorsPresence;
our @rga_spring2018_materials;

our @rga_fall2018_sectorsPresence;
our @rga_fall2018_materials;

our @rgb_spring2020_sectorsPresence;
our @rgb_spring2020_materials;

our @rgb_spring2019_sectorsPresence;
our @rgb_spring2019_materials;

our @rgm_fall2021_H_sectorsPresence;
our @rgm_fall2021_H_materials;

#
#  large angle side(top) -->  /\
#                             \ \
#      Side view               \ \
#                               \ \
#                                \ \
#                                 \_\   <-- small angle vertex(bottom)
#  target  o
#
# We are using the Hall B coordinate system with the origin at the target center.

# The bottom (downstream) of the CC will be dx1, dy1, the top will be dx2, dy2

# From the top, upstream:
#
#               pdx2
#       --------------------
#       \         |        /
#		   \        |       /
#	 	    \       |      /
#		 	  \      |     /
#			   \     |    /
#				 \    |   /
#				  --------
#               pdx1
#
# From the top, downstream:
#
#               pdx4
#       --------------------
#       \         |        /
#		   \        |       /
#	 	    \       |      /
#		 	  \      |     /
#			   \     |    /
#				 \    |   /
#				  --------
#               pdx3
#


# The downstream and upstream plates in the trapezoid are parallel
#
# From the side
#
#
#             ------- --- DIFF must be same for pdx1 and pdx2
#            /       \
#           /         \
#          /           \
#         --------------
#

sub build_ltcc_box() {
    my $configuration_string = clas12_configuration_string(\%configuration);

    # Coordinates are in the sector frame: x is azimuthal, y radial and z along the beam. The
    # asymmetric y half-lengths closely follow the LTCC outline, while 680 mm of normal half-depth
    # contains the native detector and CAD frame. Derive the four x half-widths from the 29.9 degree
    # sector half-angle so the G4Trap side faces remain exactly planar.
    my $half_z = 680.0;
    my $half_y_minus_z = 1930.0;
    my $half_y_plus_z = 1500.0;
    my $center_y = 1800.0;
    my $center_z = 3900.0;
    my $tilt = 25.0;
    my $sector_half_angle = 29.9;

    my $tilt_rad = $tilt * $pi / 180.0;
    my $sector_half_angle_rad = $sector_half_angle * $pi / 180.0;
    my $wedge_tangent = tan($sector_half_angle_rad);
    my $side_slope = cos($tilt_rad) * $wedge_tangent;
    my $radial_minus_z = $center_y + sin($tilt_rad) * $half_z;
    my $radial_plus_z = $center_y - sin($tilt_rad) * $half_z;
    my $dx1 = $radial_minus_z * $wedge_tangent - $half_y_minus_z * $side_slope;
    my $dx2 = $radial_minus_z * $wedge_tangent + $half_y_minus_z * $side_slope;
    my $dx3 = $radial_plus_z * $wedge_tangent - $half_y_plus_z * $side_slope;
    my $dx4 = $radial_plus_z * $wedge_tangent + $half_y_plus_z * $side_slope;

    my %detector = init_det();
    $detector{"name"} = "ltccTrap";
    $detector{"mother"} = "root";
    $detector{"description"} = "Light Threshold Cerenkov Counter sector";
    $detector{"pos"} = "0*mm $center_y*mm $center_z*mm";
    $detector{"rotation"} = "$tilt*deg 180*deg 0*deg";
    $detector{"color"} = "110088";
    $detector{"type"} = "G4Trap";
    $detector{"dimensions"} =
        "$half_z*mm 0*deg 0*deg $half_y_minus_z*mm $dx1*mm $dx2*mm 0*deg " .
        "$half_y_plus_z*mm $dx3*mm $dx4*mm 0*deg";
    $detector{"material"} = "Component";
    print_det(\%configuration, \%detector);

    %detector = init_det();
    $detector{"name"} = "ltcc_big_box";
    $detector{"mother"} = "root";
    $detector{"description"} = "Light Threshold Cerenkov Counter Box at the origin";
    $detector{"type"} = "Box";
    $detector{"dimensions"} = "3*m 5*m 6*m";
    $detector{"material"} = "Component";
    print_det(\%configuration, \%detector);

    for (my $s = $startS; $s <= $endS; $s++) {
        # this does not include the 5 cm shift for the forward carriage we observed
        my $c6toc12Z = 1973;
        #my $c6toc12Z = 0;
        my $rotPhi = 90 - ($s - 1) * 60;
        # Final box - Big Box * fitted trap
        %detector = init_det();
        $detector{"name"} = "ltccS$s";
        $detector{"mother"} = "root";
        $detector{"description"} = "ltcc sector $s";
        $detector{"pos"} = "0*mm 0*mm $c6toc12Z*mm";
        $detector{"rotation"} = "0*deg 0*deg $rotPhi*deg";
        $detector{"color"} = "110088";
        $detector{"type"} = "Operation:  ltcc_big_box * ltccTrap";
        $detector{"visible"} = 0;

        # print("ltcc configuration string = $configuration_string\n");

        my $shouldPrintDetector = 0;
        my $gasMaterial = "C4F10";

        if ($configuration_string eq "default") {
            $shouldPrintDetector = 1;
            $gasMaterial = "C4F10";
        }
        elsif ($configuration_string eq "rga_spring2018") {
            if ($rga_spring2018_sectorsPresence[$s - 1] == 1) {
                $shouldPrintDetector = 1;
                $gasMaterial = $rga_spring2018_materials[$s - 1];
            }
        }
        elsif ($configuration_string eq "rga_fall2018") {
            if ($rga_fall2018_sectorsPresence[$s - 1] == 1) {
                $shouldPrintDetector = 1;
                $gasMaterial = $rga_fall2018_materials[$s - 1];
            }
        }
        elsif ($configuration_string eq "rgb_spring2020") {
            if ($rgb_spring2020_sectorsPresence[$s - 1] == 1) {
                $shouldPrintDetector = 1;
                $gasMaterial = $rgb_spring2020_materials[$s - 1];
            }
        }
        elsif ($configuration_string eq "rgb_spring2019") {
            if ($rgb_spring2019_sectorsPresence[$s - 1] == 1) {
                $shouldPrintDetector = 1;
                $gasMaterial = $rgb_spring2019_materials[$s - 1];
            }
        }
        elsif ($configuration_string eq "rgm_fall2021_H") {
            if ($rgm_fall2021_H_sectorsPresence[$s - 1] == 1) {
                $shouldPrintDetector = 1;
                $gasMaterial = $rgm_fall2021_H_materials[$s - 1];
            }
        }
        if ($shouldPrintDetector == 1) {
            $detector{"material"} = $gasMaterial;
            print_det(\%configuration, \%detector);
        }

    }

}

return 1;











