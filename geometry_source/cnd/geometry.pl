use strict;
use warnings;
use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;


## Assign parameters to local variables. These do not change based on the variations

my $sectors = $parameters{"sectors"};
my $layers = $parameters{"layers"};   # per sector
my $paddles = $parameters{"paddles"}; # per layer

my $length1 = $parameters{"paddles_length1"}; # length of paddles in each layer, numbered outwards from center
my $length2 = $parameters{"paddles_length2"};
my $length3 = $parameters{"paddles_length3"};

my $r0 = $parameters{"inner_radius"}; # doesn't include the wrapping
my $r1 = $parameters{"outer_radius"};

my $z_offset1 = $parameters{"z0_layer1"}; # offset of center of paddles in layer 1 from center of mother volume
my $z_offset2 = $parameters{"z0_layer2"};
my $z_offset3 = $parameters{"z0_layer3"};

my $mother_clearance = $parameters{"mothervol_z_gap"}; # cm, clearance at either end of mother volume
my $mother_gap1 = $parameters{"mothervol_gap_in"};     # cm, clearance on the inside of mother volume (just to fit in wrapping)
my $mother_gap2 = $parameters{"mothervol_gap_out"};    # cm, clearance on outside of mother volume (to allow for the corners of the trapezoid paddles)
my $mother_offset = $parameters{"z0_mothervol"};       # offset of center of mother volume from magnet center

my $layer_gap = $parameters{"layer_gap"};
my $paddle_gap = $parameters{"paddle_gap"};
my $block_gap = $parameters{"sector_gap"}; # gap either side of each sector

my $wrap_thickness = $parameters{"wrap_thickness"}; # total thickness of wrapping material

my $uturn_r_1 = $parameters{"uturn_i_radius"}; # larger radius of uturn for inner layer
my $uturn_r_2 = $parameters{"uturn_m_radius"}; # larger radius of uturn for middle layer
my $uturn_r_3 = $parameters{"uturn_o_radius"}; # larger radius of uturn for outer layer

my @length = ($length1, $length2, $length3);                   # full length of the paddles
my @uturn_r = ($uturn_r_1, $uturn_r_2, $uturn_r_3);            # uturn radius values
my @z_offset = ($z_offset1, $z_offset2, $z_offset3);           # offset of center of each paddle wrt center of magnet
my $angle_slice = 360.0 / ($paddles * $sectors);               # degrees, angle corresponding to one segment in phi
my $dR = ($r1 - $r0 - (($layers - 1) * $layer_gap)) / $layers; # thickness of one layer (assuming all layers are equally thick)

my @pcolor = ('33dd66', '239a47', '145828'); # paddle colors by layer
my $wcolor = 'af3cff';                       # wrapping color
my $ucolor = '3c78ff';                       # u-turn color

my $half_diff = 0;


####################################################################################
=pod

Hierarchy:	24 sectors, 3 layers, 2 components (paddles).
			Each layer of each sector has one u-turn associated with it.

The CND consists of 24 sectors (blocks), each with 3 layers of 2 paddles coupled
at the downstream end by a lightguide u-turn.

Looking downstream, one sector:
	                    ____  ____
	Upper layer  (#3)   \___||___/
	Middle layer (#2)    \__||__/
	Lower layer  (#1)     \_||_/

	Left paddle (#1), right paddle (#2).

Looking downstream, the x-axis (phi=0) is to the left (9 o'clock) and the y-axis
points upwards (12 o'clock).

Sector numbering increases clockwise from 1-24.

=cut
####################################################################################


sub makeCND {
    make_cndMother();
    make_paddlesNEW();
    make_uturnNEW();
}


# Mother Volume
sub make_cndMother {

    my $longest_half1 = 0.;
    my $longest_half2 = 0.;

    for (my $j = 0; $j < $layers; $j++) {
        my $temp_dz1 = 0.5 * $length[$j] - $z_offset[$j];                #upstream half
        my $temp_dz2 = 0.5 * $length[$j] + $z_offset[$j] + $uturn_r[$j]; #downstream half

        if ($longest_half1 < $temp_dz1) {
            $longest_half1 = $temp_dz1;
        }
        if ($longest_half2 < $temp_dz2) {
            $longest_half2 = $temp_dz2;
        }
    }

    my $mother_dz = ($longest_half1 + $longest_half2) * 0.5 + $mother_clearance;
    my $mother_mid = $mother_dz - ($length3 - $length2) * 2.2;
    $half_diff = 0.5 * ($longest_half2 - $longest_half1);

    my $IR = $r0 - $mother_gap1;
    my $OR = $r1 + $mother_gap2;
    my $MR = $OR - $dR;
    my $zpos = $mother_offset + $half_diff;

    my $configuration_string = clas12_configuration_string(\%configuration);
    if ($configuration_string eq "rga_spring2018") {
        $zpos = $zpos - 1.94;
    }
    elsif ($configuration_string eq "rga_fall2018") {
        $zpos = $zpos - 3.0;
    }

    if ($mother_dz < 0) {
        print("Mother volume half-length is negative: $mother_dz\n");
        exit;
    }
    my $nplanes = 3;
    my @z_plane = (-$mother_dz, $mother_mid, $mother_dz);
    my @oradius = ($OR, $OR, $OR);
    my @iradius = ($IR, $IR, $MR);

    my %detector = init_det();
    $detector{"name"} = "cnd";
    $detector{"mother"} = "root";
    $detector{"description"} = "Central Neutron Detector";
    $detector{"pos"} = "0*cm 0*cm $zpos*cm";
    $detector{"color"} = "33bb99";
    $detector{"type"} = "Polycone";
    my $dimen = "0.0*deg 360*deg $nplanes*counts";
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $iradius[$i]*cm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $oradius[$i]*cm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $z_plane[$i]*cm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_AIR";
    $detector{"visible"} = 0;
    $detector{"style"} = 0;
    print_det(\%configuration, \%detector);

    %detector = init_det();
    $detector{"name"} = "cdFlux";
    $detector{"mother"} = "root";
    $detector{"description"} = "Flux for Central Detector";
    $detector{"color"} = "33bb99";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*cm 0*cm -30*cm";
    $detector{"dimensions"} = "388*mm 389*mm 700*mm 0*deg 360*deg";
    $detector{"material"} = "G4_AIR";
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    $detector{"sensitivity"} = "flux";
    $detector{"hit_type"} = "flux";
    $detector{"identifiers"} = "id manual 42";
    #	print_det(\%configuration, \%detector);

}

# Paddles
sub make_paddlesNEW {

    for (my $i = 1; $i <= $sectors; $i++) {

        for (my $j = 1; $j <= $layers; $j++) {

            my $innerRadius = $r0 + ($j - 1) * $dR + ($j - 1) * $layer_gap;
            my $outerRadius = $innerRadius + $dR;

            my $dz = $length[$j - 1] / 2.0;
            my $z = sprintf("%.3f", $z_offset[$j - 1]);

            ########################################
=pod

Consider the two paddles for one layer:

	.____  ____.
 	 \___||___/
 	 ^        ^

"." represents the top x-position 
"^" represents the bottom x-position 

=cut
            ########################################

            # x-positions of paddle's angled side's bottom and top vertices

            my $bottom_x = $innerRadius * tan(rad($angle_slice)) - (0.5 * $block_gap) / (cos(rad($angle_slice)));
            my $top_x = $outerRadius * tan(rad($angle_slice)) - (0.5 * $block_gap) / (cos(rad($angle_slice)));

            for (my $k = 1; $k <= $paddles; $k++) {

                # increment sector angle by 15 deg for every sector
                # start position is at 9 o'clock when looking downstream!

                my $theta = -(($i - 1) * (2 * $angle_slice)) - $angle_slice + 90.0;


                ########################################
=pod

Vertex positions to use in paddle creation.

Note that this view is upstream:

	,____. ,____.
 	 \___| |___/
 	 *   ^ *   ^

ver1 = "*"
ver2 = ","
ver3 = "."
ver4 = "^"

=cut
                ########################################

                #odd (left) paddles
                if ($k % 2 == 1) {
                    #required vertices
                    my $ver1x = (0.5) * $paddle_gap;
                    my $ver1y = $innerRadius;
                    my $ver2x = (0.5) * $paddle_gap;
                    my $ver2y = $outerRadius;
                    my $ver3x = $top_x;
                    my $ver3y = $outerRadius;
                    my $ver4x = $bottom_x;
                    my $ver4y = $innerRadius;

                    my $z_final = $z - $half_diff;

                    my $name_string = join('', 'CND_S', $i, '_L', $j, '_C', $k);
                    my $desc_string = join('', 'Central Neutron Detector, S ', $i, ', L ', $j, ', C ', $k);
                    my $id_string = join('', 'sector manual ', $i, ' layer manual ', $j, ' component manual ', $k, ' direct manual 0');

                    my %detector = init_det();
                    $detector{"name"} = $name_string;
                    $detector{"mother"} = "cnd";
                    $detector{"description"} = $desc_string;
                    $detector{"pos"} = "0*cm 0*cm $z_final*cm";
                    $detector{"color"} = $pcolor[$j - 1];
                    $detector{"rotation"} = "0*deg 0*deg $theta*deg";
                    $detector{"type"} = "G4GenericTrap";
                    $detector{"dimensions"} = "$dz*cm $ver1x*cm $ver1y*cm $ver2x*cm $ver2y*cm $ver3x*cm $ver3y*cm $ver4x*cm $ver4y*cm $ver1x*cm $ver1y*cm $ver2x*cm $ver2y*cm $ver3x*cm $ver3y*cm $ver4x*cm $ver4y*cm";
                    $detector{"material"} = "ScintillatorB";
                    $detector{"style"} = 1;
                    $detector{"ncopy"} = $i;
                    $detector{"sensitivity"} = "cnd";
                    $detector{"hit_type"} = "cnd";
                    $detector{"identifiers"} = $id_string;
                    print_det(\%configuration, \%detector);
                }
                else {
                    #required vertices
                    my $ver1x = -$bottom_x;
                    my $ver1y = $innerRadius;
                    my $ver2x = -$top_x;
                    my $ver2y = $outerRadius;
                    my $ver3x = -(0.5) * $paddle_gap;
                    my $ver3y = $outerRadius;
                    my $ver4x = -(0.5) * $paddle_gap;
                    my $ver4y = $innerRadius;

                    my $z_final = $z - $half_diff;

                    my $name_string = join('', 'CND_S', $i, '_L', $j, '_C', $k);
                    my $desc_string = join('', 'Central Neutron Detector, S ', $i, ', L ', $j, ', C ', $k);
                    my $id_string = join('', 'sector manual ', $i, ' layer manual ', $j, ' component manual ', $k, ' direct manual 0');

                    my %detector = init_det();
                    $detector{"name"} = $name_string;
                    $detector{"mother"} = "cnd";
                    $detector{"description"} = $desc_string;
                    $detector{"pos"} = "0*cm 0*cm $z_final*cm";
                    $detector{"color"} = $pcolor[$j - 1];
                    $detector{"rotation"} = "0*deg 0*deg $theta*deg";
                    $detector{"type"} = "G4GenericTrap";
                    $detector{"dimensions"} = "$dz*cm $ver1x*cm $ver1y*cm $ver2x*cm $ver2y*cm $ver3x*cm $ver3y*cm $ver4x*cm $ver4y*cm $ver1x*cm $ver1y*cm $ver2x*cm $ver2y*cm $ver3x*cm $ver3y*cm $ver4x*cm $ver4y*cm";
                    $detector{"material"} = "ScintillatorB";
                    $detector{"style"} = 1;
                    $detector{"ncopy"} = $i;
                    $detector{"sensitivity"} = "cnd";
                    $detector{"hit_type"} = "cnd";
                    $detector{"identifiers"} = $id_string;
                    print_det(\%configuration, \%detector);
                }
            }
        }
    }
}

# U-Turn
sub make_uturnNEW {

    for (my $i = 1; $i <= $sectors; $i++) {

        for (my $j = 1; $j <= $layers; $j++) {

            my $innerRadius = $r0 + ($j - 1) * $dR + ($j - 1) * $layer_gap;
            my $outerRadius = $innerRadius + $dR;

            my $dz = $length[$j - 1] / 2.0;
            my $dy = $dR / 2.0;
            my $z = sprintf("%.3f", ($dz + $z_offset[$j - 1]));

            ########################################
=pod

Consider the u-turn for one layer:

	________.
 	\______/
 	       ^

"." represents the top x-position 
"^" represents the bottom x-position 

=cut
            ########################################

            # x-positions of paddle's angled side's bottom and top vertices
            my $bottom_x = $innerRadius * tan(rad($angle_slice)) - 0.5 * $block_gap / (cos(rad($angle_slice)));
            my $top_x = $outerRadius * tan(rad($angle_slice)) - 0.5 * $block_gap / (cos(rad($angle_slice)));

            # only 1 u-turn per layer
            my $k = 1;

            # increment sector angle by 15 deg for every sector
            # start position is at 9 o'clock when looking downstream!

            my $theta = -(($i - 1) * (2 * $angle_slice)) - $angle_slice + 90.0;

            # rotations
            my $rotZ = 0.;
            my $rotX = 270.;
            my $rotY = 270. - $theta;

            # positions
            my $x = sprintf("%.11f", ($innerRadius + $dy) * (cos(rad($theta))));
            my $y = sprintf("%.11f", ($innerRadius + $dy) * (sin(rad($theta))));

            my $z_final = $z - $half_diff;

            my $name_string = join('', 'CND_S', $i, '_L', $j, '_U-Turn', $k);
            my $desc_string = join('', 'Central Neutron Detector, S ', $i, ', L ', $j, ', U-Turn ', $k);
            my $id_string = join('', 'sector manual ', $i, ' layer manual ', $j, ' u-turn manual ', $k);

            my %detector = init_det();
            $detector{"name"} = $name_string;
            $detector{"mother"} = "cnd";
            $detector{"description"} = $desc_string;
            $detector{"pos"} = "$x*cm $y*cm $z_final*cm";
            $detector{"color"} = $ucolor;
            $detector{"rotation"} = "$rotX*deg $rotY*deg $rotZ*deg";
            $detector{"type"} = "Cons";
            $detector{"dimensions"} = "0*cm $bottom_x*cm 0*cm $top_x*cm $dy*cm 0*deg 180.*deg";
            $detector{"material"} = "G4_PLEXIGLASS";
            $detector{"style"} = 1;
            $detector{"ncopy"} = $k;
            $detector{"identifiers"} = $id_string;
            print_det(\%configuration, \%detector);
        }
    }
}

1;
