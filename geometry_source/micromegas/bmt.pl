# use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

$pi = 3.141592653589793238;

my $envelope = 'BMT';

# All dimensions in mm


# Declare global variables
our ($bmt_ir, $bmt_or, $bmt_dz, $bmt_z, $bmt_zpcb);
our ($nlayer, $ntile);
our @radius;
our @starting_point;
our @Dz_halflength;
our @starting_theta;
our ($Coverlay_Width, $CuGround_Width, $PCB_Width, $CuStrips_Width, $KaptonStrips_Width);
our ($ResistStrips_Width, $Gas1_Width, $Mesh_Width, $Gas2_Width);
our ($DriftCuElectrode_Width, $DriftCuElectrode6C_Width, $DriftKapton_Width, $DriftCuGround_Width);
our $Dtheta;

our @SL_ir;
our @SL_or;
our $SL_dz;
our $SL_z;

sub load_parameters_bmt {

    $bmt_ir = $parameters{"BMT_mothervol_InnerRadius"};   # 140
    $bmt_or = $parameters{"BMT_mothervol_OutRadius"};     # 240
    $bmt_dz = $parameters{"BMT_mothervol_HalfLength"};    # 385
    $bmt_z = $parameters{"FMT_mothervol_zmin"} - $bmt_dz; # = 298.3 - 385  = -86.7 mm, MV center relative to CLAS center
    $bmt_zpcb = $parameters{"BMT_endPCB_zpos"} - $bmt_z;  # = 290.3 + 86.7 = 377.0 mm, end pcb in MV frame

    $nlayer = $parameters{"BMT_nlayer"};
    $ntile = $parameters{"BMT_ntile"};

    # Initialize arrays
    @radius = (
        $parameters{"BMT_radius_layer1"},
        $parameters{"BMT_radius_layer2"},
        $parameters{"BMT_radius_layer3"},
        $parameters{"BMT_radius_layer4"},
        $parameters{"BMT_radius_layer5"},
        $parameters{"BMT_radius_layer6"}
    );

    @starting_point = (
        $parameters{"BMT_zpos_layer1"},
        $parameters{"BMT_zpos_layer2"},
        $parameters{"BMT_zpos_layer3"},
        $parameters{"BMT_zpos_layer4"},
        $parameters{"BMT_zpos_layer5"},
        $parameters{"BMT_zpos_layer6"}
    );

    @Dz_halflength = (
        0.5 * $parameters{"BMT_zlength_layer1"},
        0.5 * $parameters{"BMT_zlength_layer2"},
        0.5 * $parameters{"BMT_zlength_layer3"},
        0.5 * $parameters{"BMT_zlength_layer4"},
        0.5 * $parameters{"BMT_zlength_layer5"},
        0.5 * $parameters{"BMT_zlength_layer6"}
    );

    @starting_theta = (
        $parameters{"BMT_theta_layer1"},
        $parameters{"BMT_theta_layer2"},
        $parameters{"BMT_theta_layer3"},
        $parameters{"BMT_theta_layer4"},
        $parameters{"BMT_theta_layer5"},
        $parameters{"BMT_theta_layer6"}
    );

    # Assign material thickness values
    $Coverlay_Width = $parameters{"BMT_Coverlay_width"};
    $CuGround_Width = 0.132 * $parameters{"BMT_CuGround_width"};
    #0.082 from gerber : 1 - 4.6*4.6/(4.6+0.2)*(4.6+0.2) = 0.082 for Z-layers
    #0.056 + 0.126 (return strips) for C-layers
    #since this is a small contribution, we adopt a mean value of 0.132

    $PCB_Width = $parameters{"BMT_PCBGround_width"};
    $CuStrips_Width = $parameters{"BMT_CuStrips_width"};
    #opacity taken into account in the density of the material
    $KaptonStrips_Width = $parameters{"BMT_KaptonStrips_width"};
    $ResistStrips_Width = $parameters{"BMT_ResistStrips_width"};
    #opacity taken into account in the density of the material
    $Gas1_Width = $parameters{"BMT_Gas1_width"};
    $Mesh_Width = $parameters{"BMT_Mesh_width"};
    #opacity taken into account in the density of the material
    $Gas2_Width = $parameters{"BMT_Gas2_width"};

    $DriftCuElectrode_Width = 0.024 * $parameters{"BMT_DriftCuElectrode_width"};
    #0.024 from gerber : 1 - 10*10/(10+0.12)*(10+0.12) = 0.024

    $DriftCuElectrode6C_Width = $parameters{"BMT_DriftCuElectrode_width"};
    #for layer 6C, the Cu electrode is not a mesh

    $DriftKapton_Width = $parameters{"BMT_DriftKapton_width"};

    $DriftCuGround_Width = 0.082 * $parameters{"BMT_DriftCuGround_width"};
    #0.082 from gerber : 1 - 4.6*4.6/(4.6+0.2)*(4.6+0.2) = 0.082

    $Dtheta = 360.0 / $ntile; # rotation angle for other tiles


    for (my $l = 0; $l < $nlayer; $l++) {
        $Inactivtheta[$l] = (24.7 / $radius[$l]) * (180. / $pi);
        #  (24.7 = 120°*radius-ZA on drawings - MG notebook p. 152)
    }

    $dtheta[0] = $Dtheta - $Inactivtheta[0]; # angle covered by one tile (active area) (in degrees)
    $dtheta[1] = $Dtheta - $Inactivtheta[1];
    $dtheta[2] = $Dtheta - $Inactivtheta[2];
    $dtheta[3] = $Dtheta - $Inactivtheta[3];
    $dtheta[4] = $Dtheta - $Inactivtheta[4];
    $dtheta[5] = $Dtheta - $Inactivtheta[5];

    $dtheta_start[0] = $Inactivtheta[0] / 2.0; # slight rotation to keep symmetry.
    $dtheta_start[1] = $Inactivtheta[1] / 2.0;
    $dtheta_start[2] = $Inactivtheta[2] / 2.0;
    $dtheta_start[3] = $Inactivtheta[3] / 2.0;
    $dtheta_start[4] = $Inactivtheta[4] / 2.0;
    $dtheta_start[5] = $Inactivtheta[5] / 2.0;

    @SL_ir = ($radius[0] - 1.0, $radius[1] - 1.0, $radius[2] - 1.0, $radius[3] - 1.0, $radius[4] - 1.0, $radius[5] - 1.0);
    @SL_or = ($radius[0] + 5.0, $radius[1] + 5.0, $radius[2] + 5.0, $radius[3] + 5.0, $radius[4] + 5.0, $radius[5] + 5.0);
    #my $SL_dz = $bmt_dz;
    $SL_dz = 295.0;
    $SL_z = -$bmt_z; # center of superlayer wrt BMT  mother volume

}


#$Inactivtheta[0]	 = (20/$radius[0])*(180./3.14159265358);
# = 7.863 not in activ area (in degrees) (20 mm taken by mechanics)
#$Inactivtheta[1]	 = (20/$radius[1])*(180./3.14159265358); # = 7.129
#$Inactivtheta[2]	 = (20/$radius[2])*(180./3.14159265358); # = 6.521
#$Inactivtheta[3]	 = (20/$radius[3])*(180./3.14159265358); # = 6.008
#$Inactivtheta[4]	 = (20/$radius[4])*(180./3.14159265358); # = 5.570
#$Inactivtheta[5]	 = (20/$radius[5])*(180./3.14159265358); # = 5.191


# materials
my $air_material = 'myAir';
my $alu_material = 'myAlu';
my $copper_material = 'myCopper';
my $pcb_material = 'myFR4';
my $bmtz4_strips_material = 'mybmtz4MMStrips'; #taking into account pitch/opacity
my $bmtz5_strips_material = 'mybmtz5MMStrips'; #taking into account pitch/opacity
my $bmtz6_strips_material = 'mybmtz6MMStrips'; #taking into account pitch/opacity
my $bmtc4_strips_material = 'mybmtc4MMStrips'; #taking into account pitch/opacity
my $bmtc5_strips_material = 'mybmtc5MMStrips'; #taking into account pitch/opacity
my $bmtc6_strips_material = 'mybmtc6MMStrips'; #taking into account pitch/opacity
my $kapton_material = 'myKapton';
my $bmtz4_resist_material = 'mybmtz4ResistPaste'; #taking into account pitch/opacity
my $bmtz5_resist_material = 'mybmtz5ResistPaste'; #taking into account pitch/opacity
my $bmtz6_resist_material = 'mybmtz6ResistPaste'; #taking into account pitch/opacity
my $bmtc4_resist_material = 'mybmtc4ResistPaste'; #taking into account pitch/opacity
my $bmtc5_resist_material = 'mybmtc5ResistPaste'; #taking into account pitch/opacity
my $bmtc6_resist_material = 'mybmtc6ResistPaste'; #taking into account pitch/opacity
my $gas_material = 'mybmtMMGas';
my $mesh_material = 'mybmtMMMesh';
my $Cfiber_material = 'myCfiber';
my $Cstraight_material = 'myCstraight';
my $inox_material = 'myInox';
my $peek_material = 'myPeek';
#define myGlue...

# G4 colors
# (colors random)
# 'rrggbb(t)' (transparency from 0 opaque to 5 fully transparent)
my $air_color = 'e200e15';
my $alu_color = '444444'; # dark grey
my $carbon_color = '004400';
my $copper_color = '666600';
my $gas_color = 'e868504';
#my $gas_color          = 'a100002';
my $inox_color = '888888';
my $kapton_color = 'fff600';
my $mesh_color = '252020';
my $pcb_color = '0000ff';
my $peek_color = '6ccecb'; # light blue
my $resist_color = '000000';
my $strips_color = '353540';
my $structure_color = 'e3e4e5';


# sub rad { $_[0]*$pi/180.0  }
# sub atan {atan2($_[0],1)}


sub segnumber {
    my $s = shift;
    my $zeros = "";
    if ($s < 9) {$zeros = "0";}
    my $segment_n = $s + 1;
    return "$zeros$segment_n";
}

sub rot {
    my $l = shift;
    my $s = shift;
    my $theta_rot = $starting_theta[$l] + $s * $Dtheta;
    return "0*deg 0*deg $theta_rot*deg";
}

sub define_bmt {
    my $configuration_string = clas12_configuration_string(\%configuration);
    if ($configuration_string eq "rgf_spring2020") {
        # do not proceed with BMT geometry
        return;
    }

    # sixth layer goes from 5mu to 9mu, layers 1-5 scaler accordingly
    if ($configuration_string eq "michel_9mmcopper") {
        # update on 2024/12/16: request to test 9microns for all layers
        $DriftCuElectrode_Width = 0.00012 * 9 / 5;
        $DriftCuElectrode_Width = 0.009;
        $DriftCuElectrode6C_Width = 0.009;
    }

    print "BMT: DriftCuElectrode_Width = $DriftCuElectrode_Width \n";
    print "BMT: DriftCuElectrode6C_Width = $DriftCuElectrode6C_Width \n";

    make_bmt();
    #	make_sl(1);
    #	make_sl(2);
    #	make_sl(3);
    #	make_sl(4);
    #	make_sl(5);
    #	make_sl(6);

    # Active zones (Remi's tables):
    for (my $l = 0; $l < $nlayer; $l++) {
        place_coverlay($l);
        place_cuGround($l);
        place_pcb($l);
        place_Strips($l);
        place_Kapton($l);
        place_Resist($l);
        place_Gas1($l);
        place_Mesh($l);
        place_Gas2($l);
        place_driftCuElectrode($l);
        place_driftKapton($l);
        place_driftCuGround($l);
    }

    # detector frame (Sedi drawings):
    place_straightC(); # drawing 6 2075 DM- 1500 201 & 202
    place_Arc1onPCB(); #                         211
    place_Arc2onPCB(); #                         211
    place_Arc3onPCB(); #                         207
    place_Arc4onPCB(); #                         207

    # supporting structure (SIS drawings):
    place_innertube();        # drawing 71 2075 DM- 1302 001
    place_stiffeners();       #                          005
    place_arcs();             #                          007
    place_cover();            #                          008
    place_rods();             #                          010 & 011
    place_overcover();        #                          013
    place_forwardinterface(); #                          003
    place_closingplate();     #                          004
}

sub make_bmt {
    # Mother volume will include detectors and support structure,
    # Not centered on CLAS12 target anymore
    my %detector = init_det();
    $detector{"name"} = $envelope;
    $detector{"mother"} = "root";
    $detector{"description"} = "Barrel Micromegas Vertex Tracker";
    $detector{"pos"} = "0*mm 0*mm $bmt_z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = "aaaaff3";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$bmt_ir*mm $bmt_or*mm $bmt_dz*mm 0*deg 360*deg";
    $detector{"material"} = $air_material;
    $detector{"visible"} = 0;
    $detector{"style"} = 0;
    print_det(\%configuration, \%detector);
}

sub make_sl {
    # Superlayers volumes still centered on CLAS12 target, hence not on mother volume
    # not used anymore (MG Sept. 2016)
    my $slnumber = shift;
    my $slindex = $slnumber - 1;

    my %detector = init_det();
    $detector{"name"} = "SL2_$slnumber";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "Super Layer $slnumber";
    $detector{"pos"} = "0*cm 0*cm $SL_z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$SL_ir[$slindex]*mm $SL_or[$slindex]*mm $SL_dz*mm 0*deg 360*deg";
    $detector{"material"} = $air_material;
    $detector{"visible"} = 0;
    $detector{"style"} = 0;
    print_det(\%configuration, \%detector);
}

sub place_coverlay {
    my $l = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;

    if ($l == 0 || $l == 3 || $l == 5) {
        $vname = "BMT_coverlay_C_Layer";
        $descriptio = "coverlay C, Layer $layer_no, ";
    }
    if ($l == 1 || $l == 2 || $l == 4) {
        $vname = "BMT_coverlay_Z_Layer";
        $descriptio = "coverlay Z, Layer $layer_no, ";
    }

    for (my $s = 0; $s < $ntile; $s++) {
        # names
        my $snumber = segnumber($s);
        my $z = $starting_point[$l] + $Dz_halflength[$l] - $bmt_z;
        my $PRMin = $radius[$l];
        my $PRMax = $PRMin + $Coverlay_Width;
        my $PDz = $Dz_halflength[$l];
        my $PSPhi = $dtheta_start[$l];
        my $PDPhi = $dtheta[$l];

        my %detector = init_det();
        $detector{"name"} = "$vname$layer_no\_Segment$snumber";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio Segment $snumber";
        $detector{"pos"} = "0*mm 0*mm $z*mm";
        $detector{"rotation"} = rot($l, $s);
        $detector{"color"} = $kapton_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"material"} = $kapton_material;
        $detector{"ncopy"} = $s + 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);

    }
}

sub place_cuGround {
    my $l = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;

    if ($l == 0 || $l == 3 || $l == 5) {
        $vname = "BMT_CuGround_C_Layer";
        $descriptio = "CuGround C, Layer $layer_no, ";
    }
    if ($l == 1 || $l == 2 || $l == 4) {
        $vname = "BMT_CuGround_Z_Layer";
        $descriptio = "CuGround Z, Layer $layer_no, ";
    }

    for (my $s = 0; $s < $ntile; $s++) {
        # names
        my $snumber = segnumber($s);
        my $z = $starting_point[$l] + $Dz_halflength[$l] - $bmt_z;
        my $PRMin = $radius[$l] + $Coverlay_Width;
        my $PRMax = $PRMin + $CuGround_Width;
        my $PDz = $Dz_halflength[$l];
        my $PSPhi = $dtheta_start[$l];
        my $PDPhi = $dtheta[$l];

        my %detector = init_det();
        $detector{"name"} = "$vname$layer_no\_Segment$snumber";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio Segment $snumber";
        $detector{"pos"} = "0*mm 0*mm $z*mm";
        $detector{"rotation"} = rot($l, $s);
        $detector{"color"} = $copper_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"material"} = $copper_material;
        $detector{"ncopy"} = $s + 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);

    }
}

sub place_pcb {
    my $l = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;

    if ($l == 0 || $l == 3 || $l == 5) {
        $vname = "BMT_PCB_C_Layer";
        $descriptio = "PCB C, Layer $layer_no, ";
    }
    if ($l == 1 || $l == 2 || $l == 4) {
        $vname = "BMT_PCB_Z_Layer";
        $descriptio = "PCB Z, Layer $layer_no, ";
    }
    my $noPCB = (6. / $radius[$l]) * (180. / $pi); # calculated 3.7 p.153, but put 6 to avoid overlap with attStiff
    my $dthet = $Dtheta - $noPCB;                  # angle covered by one tile (PCB area) (in degrees)
    my $dthet_start = $noPCB / 2.0;                # slight rotation to keep symmetry.

    #my $z         = $starting_point[$l] + $Dz_halflength[$l] - $bmt_z;
    my $z = $bmt_zpcb - 712. / 2.; # actually whole pCB, not just active zone
    my $PRMin = $radius[$l] + $Coverlay_Width + $CuGround_Width;
    my $PRMax = $radius[$l] + $Coverlay_Width + $CuGround_Width + $PCB_Width;
    #my $PDz       = $Dz_halflength[$l];
    my $PDz = 712. / 2.; # actually whole pCB, not just active zone
    #my $PSPhi     = $dtheta_start[$l];
    #my $PDPhi     = $dtheta[$l];
    my $PSPhi = $dthet_start; # actually whole pCB, not just active zone
    my $PDPhi = $dthet;       # actually whole pCB, not just active zone

    for (my $s = 0; $s < $ntile; $s++) {
        # names
        my $snumber = segnumber($s);

        my %detector = init_det();
        $detector{"name"} = "$vname$layer_no\_Segment$snumber";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio Segment $snumber";
        $detector{"pos"} = "0*mm 0*mm $z*mm";
        $detector{"rotation"} = rot($l, $s);
        $detector{"color"} = $pcb_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"material"} = $pcb_material;
        $detector{"ncopy"} = $s + 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);

    }
}

sub place_Strips {
    my $l = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;

    if ($l == 0 || $l == 3 || $l == 5) {
        $vname = "BMT_CuStrips_C_Layer";
        $descriptio = "CuStrips C, Layer $layer_no, ";
    }
    if ($l == 1 || $l == 2 || $l == 4) {
        $vname = "BMT_CuStrips_Z_Layer";
        $descriptio = "CuStrips Z, Layer $layer_no, ";
    }
    for (my $s = 0; $s < $ntile; $s++) {
        # names
        my $snumber = segnumber($s);
        my $z = $starting_point[$l] + $Dz_halflength[$l] - $bmt_z;
        my $PRMin = $radius[$l] + $Coverlay_Width + $CuGround_Width + $PCB_Width;
        my $PRMax = $PRMin + $CuStrips_Width;
        my $PDz = $Dz_halflength[$l];
        my $PSPhi = $dtheta_start[$l];
        my $PDPhi = $dtheta[$l];

        my %detector = init_det();
        $detector{"name"} = "$vname$layer_no\_Segment$snumber";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio Segment $snumber";
        $detector{"pos"} = "0*mm 0*mm $z*mm";
        $detector{"rotation"} = rot($l, $s);
        $detector{"color"} = $strips_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        if ($l == 0) {$detector{"material"} = $bmtc4_strips_material;}
        if ($l == 3) {$detector{"material"} = $bmtc5_strips_material;}
        if ($l == 5) {$detector{"material"} = $bmtc6_strips_material;}
        if ($l == 1) {$detector{"material"} = $bmtz4_strips_material;}
        if ($l == 2) {$detector{"material"} = $bmtz5_strips_material;}
        if ($l == 4) {$detector{"material"} = $bmtz6_strips_material;}
        $detector{"ncopy"} = $s + 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);

    }
}

sub place_Kapton {
    my $l = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;

    if ($l == 0 || $l == 3 || $l == 5) {
        $vname = "BMT_KaptonStrips_C_Layer";
        $descriptio = "KaptonStrips C, Layer $layer_no, ";
    }
    if ($l == 1 || $l == 2 || $l == 4) {
        $vname = "BMT_KaptonStrips_Z_Layer";
        $descriptio = "KaptonStrips Z, Layer $layer_no, ";
    }

    for (my $s = 0; $s < $ntile; $s++) {
        # names
        my $snumber = segnumber($s);
        my $z = $starting_point[$l] + $Dz_halflength[$l] - $bmt_z;
        my $PRMin = $radius[$l] + $Coverlay_Width + $CuGround_Width + $PCB_Width + $CuStrips_Width;
        my $PRMax = $PRMin + $KaptonStrips_Width;
        my $PDz = $Dz_halflength[$l];
        my $PSPhi = $dtheta_start[$l];
        my $PDPhi = $dtheta[$l];

        my %detector = init_det();
        $detector{"name"} = "$vname$layer_no\_Segment$snumber";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio Segment $snumber";
        $detector{"pos"} = "0*mm 0*mm $z*mm";
        $detector{"rotation"} = rot($l, $s);
        $detector{"color"} = $kapton_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"material"} = $kapton_material;
        $detector{"ncopy"} = $s + 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);

    }
}

sub place_Resist {
    my $l = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;

    if ($l == 0 || $l == 3 || $l == 5) {
        $vname = "BMT_ResistStrips_C_Layer";
        $descriptio = "ResistStrips C, Layer $layer_no, ";
    }
    if ($l == 1 || $l == 2 || $l == 4) {
        $vname = "BMT_ResistStrips_Z_Layer";
        $descriptio = "ResistStrips Z, Layer $layer_no, ";
    }
    for (my $s = 0; $s < $ntile; $s++) {
        # names
        my $snumber = segnumber($s);
        my $z = $starting_point[$l] + $Dz_halflength[$l] - $bmt_z;
        my $PRMin = $radius[$l] + $Coverlay_Width + $CuGround_Width + $PCB_Width + $CuStrips_Width + $KaptonStrips_Width;
        my $PRMax = $PRMin + $ResistStrips_Width;
        my $PDz = $Dz_halflength[$l];
        my $PSPhi = $dtheta_start[$l];
        my $PDPhi = $dtheta[$l];

        my %detector = init_det();
        $detector{"name"} = "$vname$layer_no\_Segment$snumber";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio Segment $snumber";
        $detector{"pos"} = "0*mm 0*mm $z*mm";
        $detector{"rotation"} = rot($l, $s);
        $detector{"color"} = $resist_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        if ($l == 0) {$detector{"material"} = $bmtc4_resist_material;}
        if ($l == 3) {$detector{"material"} = $bmtc5_resist_material;}
        if ($l == 5) {$detector{"material"} = $bmtc6_resist_material;}
        if ($l == 1) {$detector{"material"} = $bmtz4_resist_material;}
        if ($l == 2) {$detector{"material"} = $bmtz5_resist_material;}
        if ($l == 4) {$detector{"material"} = $bmtz6_resist_material;}
        $detector{"ncopy"} = $s + 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);

    }
}

sub place_Gas1 {
    my $l = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;

    if ($l == 0 || $l == 3 || $l == 5) {
        $vname = "BMT_Gas1_C_Layer";
        $descriptio = "Gas1 C, Layer $layer_no, ";
    }
    if ($l == 1 || $l == 2 || $l == 4) {
        $vname = "BMT_Gas1_Z_Layer";
        $descriptio = "Gas1 Z, Layer $layer_no, ";
    }
    for (my $s = 0; $s < $ntile; $s++) {
        # names
        my $snumber = segnumber($s);
        my $z = $starting_point[$l] + $Dz_halflength[$l] - $bmt_z;
        my $PRMin = $radius[$l] + $Coverlay_Width + $CuGround_Width + $PCB_Width + $CuStrips_Width + $KaptonStrips_Width + $ResistStrips_Width;
        my $PRMax = $radius[$l] + $Coverlay_Width + $CuGround_Width + $PCB_Width + $CuStrips_Width + $KaptonStrips_Width + $ResistStrips_Width + $Gas1_Width;
        my $PDz = $Dz_halflength[$l];
        my $PSPhi = $dtheta_start[$l];
        my $PDPhi = $dtheta[$l];

        my %detector = init_det();
        $detector{"name"} = "$vname$layer_no\_Segment$snumber";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio Segment $snumber";
        $detector{"pos"} = "0*mm 0*mm $z*mm";
        $detector{"rotation"} = rot($l, $s);
        $detector{"color"} = $gas_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"material"} = $gas_material;
        $detector{"ncopy"} = $s + 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);

    }
}

sub place_Mesh {
    my $l = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;

    if ($l == 0 || $l == 3 || $l == 5) {
        $vname = "BMT_Mesh_C_Layer";
        $descriptio = "Mesh C, Layer $layer_no, ";
    }
    if ($l == 1 || $l == 2 || $l == 4) {
        $vname = "BMT_Mesh_Z_Layer";
        $descriptio = "Mesh Z, Layer $layer_no, ";
    }
    for (my $s = 0; $s < $ntile; $s++) {
        # names
        my $snumber = segnumber($s);
        my $z = $starting_point[$l] + $Dz_halflength[$l] - $bmt_z;
        my $PRMin = $radius[$l] + $Coverlay_Width + $CuGround_Width + $PCB_Width + $CuStrips_Width + $KaptonStrips_Width + $ResistStrips_Width + $Gas1_Width;
        my $PRMax = $PRMin + $Mesh_Width;
        my $PDz = $Dz_halflength[$l];
        my $PSPhi = $dtheta_start[$l];
        my $PDPhi = $dtheta[$l];

        my %detector = init_det();
        $detector{"name"} = "$vname$layer_no\_Segment$snumber";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio Segment $snumber";
        $detector{"pos"} = "0*mm 0*mm $z*mm";
        $detector{"rotation"} = rot($l, $s);
        $detector{"color"} = $mesh_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"material"} = $mesh_material;
        $detector{"mfield"} = "no";
        $detector{"ncopy"} = $s + 1;
        $detector{"pMany"} = 1;
        $detector{"exist"} = 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        $detector{"sensitivity"} = "no";
        $detector{"hit_type"} = "no";
        $detector{"identifiers"} = "no";
        print_det(\%configuration, \%detector);

    }
}

sub place_Gas2 {
    my $l = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;
    my $type = 0;

    if ($l == 0 || $l == 3 || $l == 5) {
        $vname = "BMT_Gas2_C_Layer";
        $descriptio = "Gas2 C, Layer $layer_no, ";
        $type = 1;
    }
    if ($l == 1 || $l == 2 || $l == 4) {
        $vname = "BMT_Gas2_Z_Layer";
        $descriptio = "Gas2 Z, Layer $layer_no, ";
        $type = 2;
    }
    for (my $s = 0; $s < $ntile; $s++) {
        # names
        my $snumber = segnumber($s);
        my $z = $starting_point[$l] + $Dz_halflength[$l] - $bmt_z;
        my $PRMin = $radius[$l] + $Coverlay_Width + $CuGround_Width + $PCB_Width + $CuStrips_Width + $KaptonStrips_Width + $ResistStrips_Width + $Gas1_Width + $Mesh_Width;
        my $PRMax = $PRMin + $Gas2_Width;
        my $PDz = $Dz_halflength[$l];
        my $PSPhi = $dtheta_start[$l];
        my $PDPhi = $dtheta[$l];

        my %detector = init_det();
        $detector{"name"} = "$vname$layer_no\_Segment$snumber";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio  Segment $snumber";
        $detector{"pos"} = "0*mm 0*mm $z*mm";
        $detector{"rotation"} = rot($l, $s);
        $detector{"color"} = $gas_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"material"} = $gas_material;
        $detector{"ncopy"} = $s + 1;
        $detector{"pMany"} = 1;
        $detector{"exist"} = 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        $detector{"sensitivity"} = "bmt";
        $detector{"hit_type"} = "bmt";
        $detector{"identifiers"} = "superlayer manual $layer_no type manual $type segment manual $detector{'ncopy'} strip manual 1";
        print_det(\%configuration, \%detector);

    }
}

sub place_driftCuElectrode {
    my $l = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;

    if ($l == 0 || $l == 3 || $l == 5) {
        $vname = "BMT_DriftCuElectrode_C_Layer";
        $descriptio = "DriftCuElectrode C, Layer $layer_no, ";
    }
    if ($l == 1 || $l == 2 || $l == 4) {
        $vname = "BMT_DriftCuElectrode_Z_Layer";
        $descriptio = "DriftCuElectrode Z, Layer $layer_no, ";
    }
    for (my $s = 0; $s < $ntile; $s++) {
        # names
        my $snumber = segnumber($s);

        my $z = $starting_point[$l] + $Dz_halflength[$l] - $bmt_z;
        my $PDz = $Dz_halflength[$l];
        my $PSPhi = $dtheta_start[$l];
        my $PDPhi = $dtheta[$l];
        my $PRMin = $radius[$l] + $Coverlay_Width + $CuGround_Width + $PCB_Width + $CuStrips_Width + $KaptonStrips_Width + $ResistStrips_Width + $Gas1_Width + $Mesh_Width + $Gas2_Width;
        $PRMax = $PRMin + $DriftCuElectrode_Width;

        if ($l == 5) {
            $PRMax = $PRMin + $DriftCuElectrode6C_Width;
        }

        my %detector = init_det();
        $detector{"name"} = "$vname$layer_no\_Segment$snumber";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio Segment $snumber";
        $detector{"pos"} = "0*mm 0*mm $z*mm";
        $detector{"rotation"} = rot($l, $s);
        $detector{"color"} = $copper_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"mfield"} = "no";
        $detector{"material"} = $copper_material;
        $detector{"ncopy"} = $s + 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);

    }
}

sub place_driftKapton {
    my $l = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;
    my @drift_dz = (449.0, 449.0, 478.82, 478.82, 491.0, 491.0);

    if ($l == 0 || $l == 3) {
        $vname = "BMT_DriftKapton_C_Layer";
        $descriptio = "DriftKapton C, Layer $layer_no, ";

        $PRMin = $radius[$l] + $Coverlay_Width + $CuGround_Width + $PCB_Width + $CuStrips_Width + $KaptonStrips_Width + $ResistStrips_Width + $Gas1_Width + $Mesh_Width + $Gas2_Width + $DriftCuElectrode_Width;
        $PRMax = $PRMin + $DriftKapton_Width;
    }

    if ($l == 5) {
        $vname = "BMT_DriftKapton_C_Layer";
        $descriptio = "DriftKapton C, Layer $layer_no, ";

        $PRMin = $radius[$l] + $Coverlay_Width + $CuGround_Width + $PCB_Width + $CuStrips_Width + $KaptonStrips_Width + $ResistStrips_Width + $Gas1_Width + $Mesh_Width + $Gas2_Width + $DriftCuElectrode6C_Width;
        $PRMax = $PRMin + $DriftKapton_Width;
    }

    if ($l == 1 || $l == 2 || $l == 4) {
        $vname = "BMT_DriftKapton_Z_Layer";
        $descriptio = "DriftKapton Z, Layer $layer_no, ";

        $PRMin = $radius[$l] + $Coverlay_Width + $CuGround_Width + $PCB_Width + $CuStrips_Width + $KaptonStrips_Width + $ResistStrips_Width + $Gas1_Width + $Mesh_Width + $Gas2_Width + $DriftCuElectrode_Width;
        $PRMax = $PRMin + $DriftKapton_Width;
    }

    #my $z         = $starting_point[$l] + $Dz_halflength[$l] - $bmt_z;
    #my $PDz       = $Dz_halflength[$l];
    #my $PSPhi     = $dtheta_start[$l];
    #my $PDPhi     = $dtheta[$l];

    my $noDrift = (6. / $PRMin) * (180. / $pi); # calculated 3.8 p.153, but put 6 to avoid overlap with attStiff
    my $dthet = $Dtheta - $noDrift;             # angle covered by one tile (Drift kapton area) (in degrees)
    my $dthet_start = $noDrift / 2.0;           # slight rotation to keep symmetry.

    my $PDz = $drift_dz[$l] / 2.; # actually whole Drift z-length, not just active zone
    my $z = $bmt_zpcb - $PDz;
    my $PSPhi = $dthet_start;
    my $PDPhi = $dthet;

    for (my $s = 0; $s < $ntile; $s++) {
        # names
        my $snumber = segnumber($s);

        my %detector = init_det();
        $detector{"name"} = "$vname$layer_no\_Segment$snumber";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio Segment $snumber";
        $detector{"pos"} = "0*mm 0*mm $z*mm";
        $detector{"rotation"} = rot($l, $s);
        $detector{"color"} = $kapton_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"mfield"} = "no";
        $detector{"material"} = $kapton_material;
        $detector{"ncopy"} = $s + 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);

    }
}

sub place_driftCuGround {
    my $l = shift;
    my $layer_no = $l + 1;
    my $vname = 0;
    my $descriptio = 0;

    if ($l == 0 || $l == 3 || $l == 5) {
        $vname = "BMT_DriftCuGround_C_Layer";
        $descriptio = "DriftCuGround C, Layer $layer_no, ";
    }
    if ($l == 1 || $l == 2 || $l == 4) {
        $vname = "BMT_DriftCuGround_Z_Layer";
        $descriptio = "DriftCuGround Z, Layer $layer_no, ";
    }
    for (my $s = 0; $s < $ntile; $s++) {
        # names
        my $snumber = segnumber($s);
        my $z = $starting_point[$l] + $Dz_halflength[$l] - $bmt_z;

        if ($l == 5) {
            $PRMin = $radius[$l] + $Coverlay_Width + $CuGround_Width + $PCB_Width + $CuStrips_Width + $KaptonStrips_Width + $ResistStrips_Width + $Gas1_Width + $Mesh_Width + $Gas2_Width + $DriftCuElectrode6C_Width + $DriftKapton_Width;
            $PRMax = $PRMin + $DriftCuGround_Width;
        }

        if ($l == 0 || $l == 3 || $l == 1 || $l == 2 || $l == 4) {
            $PRMin = $radius[$l] + $Coverlay_Width + $CuGround_Width + $PCB_Width + $CuStrips_Width + $KaptonStrips_Width + $ResistStrips_Width + $Gas1_Width + $Mesh_Width + $Gas2_Width + $DriftCuElectrode_Width + $DriftKapton_Width;
            $PRMax = $PRMin + $DriftCuGround_Width;
        }

        my $PDz = $Dz_halflength[$l];
        my $PSPhi = $dtheta_start[$l];
        my $PDPhi = $dtheta[$l];

        my %detector = init_det();
        $detector{"name"} = "$vname$layer_no\_Segment$snumber";
        $detector{"mother"} = $envelope;;
        $detector{"description"} = "$descriptio Segment $snumber";
        $detector{"pos"} = "0*mm 0*mm $z*mm";
        $detector{"rotation"} = rot($l, $s);
        $detector{"color"} = $copper_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"mfield"} = "no";
        $detector{"material"} = $copper_material;
        $detector{"ncopy"} = $s + 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}

sub place_straightC {
    my $vname = "BMT_straightC";
    my $descriptio = "BMT_straightC";

    my $Px = 3.0 / 2.0;
    my $Py = 3.0 / 2.0;
    my $Pz = 710.0 / 2.0;
    my $z = $bmt_zpcb - $Pz;
    @radii = (146.0, 161.0, 176.0, 191.0, 206.1, 221.1);
    for (my $l = 0; $l < $nlayer; $l++) {
        my $layer_no = $l + 1;
        for (my $s = 0; $s < $ntile; $s++) {
            my $tile_no = $s + 1;
            my $sphi = ((3.0 + $Px) / $radii[$l]) * 180.0 / $pi; # 3.0 to double check; impacts PDPhi and PSPhi in ArcnonPCB
            my $dphi = $Dtheta - 2.0 * $sphi;
            for (my $r = 0; $r < 2; $r++) {
                my $rod_no = $r + 1;

                my $theta_rot = 30.0 + $sphi + $s * 120. + $r * $dphi;
                my $x = ($radii[$l] + $Px) * cos($theta_rot * $pi / 180.0);
                my $y = ($radii[$l] + $Px) * sin($theta_rot * $pi / 180.0);
                my %detector = init_det();
                $detector{"name"} = "$vname\_$layer_no\_$tile_no\_$rod_no";
                $detector{"mother"} = $envelope;
                $detector{"description"} = "$descriptio";
                $detector{"pos"} = "$x*mm $y*mm $z*mm";
                $detector{"rotation"} = "0*deg 0*deg -$theta_rot*deg";
                $detector{"color"} = $carbon_color;
                $detector{"type"} = "Box";
                $detector{"dimensions"} = "$Px*mm $Py*mm $Pz*mm";
                $detector{"material"} = $Cstraight_material;
                $detector{"ncopy"} = 1;
                $detector{"visible"} = 1;
                $detector{"style"} = 1;
                print_det(\%configuration, \%detector);
            }
        }
    }
}

sub place_Arc1onPCB {
    my $vname = "BMT_Arc1onPCB";
    my $descriptio = "BMT_Arc1onPCB";

    my @radii = (146.0, 161.0, 176.0, 191.0, 206.1, 221.1);
    my @distPCB = (1.0, 1.0, 1.0, 1.0, 1.0, 1.0);
    my $PDz = 3.0 / 2.0;

    for (my $l = 0; $l < $nlayer; $l++) {
        my $layer_no = $l + 1;
        my $z = $bmt_zpcb - $distPCB[$l] - $PDz;
        my $PRMin = $radii[$l];
        my $PRMax = $PRMin + 3.0;
        my $PDPhi = $Dtheta - (180. / $pi) * 2. * 6.0 / $PRMin;
        for (my $s = 0; $s < $ntile; $s++) {
            my $tile_no = $s + 1;
            my $element_no = $s + 1;
            my $PSPhi = 30.0 + (180. / $pi) * 6.0 / $PRMin + $s * $Dtheta;

            my %detector = init_det();
            $detector{"name"} = "$vname\_$layer_no\_$element_no";
            $detector{"mother"} = $envelope;
            $detector{"description"} = "$descriptio";
            $detector{"pos"} = "0*mm 0*mm $z*mm";
            $detector{"rotation"} = "0*deg 0*deg 0*deg";
            $detector{"color"} = $carbon_color;
            $detector{"type"} = "Tube";
            $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
            $detector{"material"} = $Cfiber_material;
            $detector{"ncopy"} = 1;
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);
        }
    }
}

sub place_Arc2onPCB {
    my $vname = "BMT_Arc2onPCB";
    my $descriptio = "BMT_Arc2onPCB";

    my @radii = (146.0, 161.0, 176.0, 191.0, 206.1, 221.1);
    my @distPCB = (32.0, 32.0, 9.4, 9.4, 7.0, 7.0);
    my $PDz = 3.0 / 2.0;

    for (my $l = 0; $l < $nlayer; $l++) {
        my $layer_no = $l + 1;
        my $z = $bmt_zpcb - $distPCB[$l] - $PDz;
        my $PRMin = $radii[$l];
        my $PRMax = $PRMin + 3.0;
        my $PDPhi = $Dtheta - (180. / $pi) * 2. * 6.0 / $PRMin;
        for (my $s = 0; $s < $ntile; $s++) {
            my $tile_no = $s + 1;
            my $element_no = $s + 1;
            my $PSPhi = 30.0 + (180. / $pi) * 6.0 / $PRMin + $s * $Dtheta;

            my %detector = init_det();
            $detector{"name"} = "$vname\_$layer_no\_$element_no";
            $detector{"mother"} = $envelope;
            $detector{"description"} = "$descriptio";
            $detector{"pos"} = "0*mm 0*mm $z*mm";
            $detector{"rotation"} = "0*deg 0*deg 0*deg";
            $detector{"color"} = $carbon_color;
            $detector{"type"} = "Tube";
            $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
            $detector{"material"} = $Cfiber_material;
            $detector{"ncopy"} = 1;
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);
        }
    }
}

sub place_Arc3onPCB {
    my $vname = "BMT_Arc3onPCB";
    my $descriptio = "BMT_Arc3onPCB";

    my @radii = (146.0, 161.0, 176.0, 191.0, 206.1, 221.1);
    my @distPCB = (437.0, 437.0, 466.82, 466.82, 479.0, 479.0);
    my $PDz = 3.0 / 2.0;

    for (my $l = 0; $l < $nlayer; $l++) {
        my $layer_no = $l + 1;
        my $z = $bmt_zpcb - $distPCB[$l] - $PDz;
        my $PRMin = $radii[$l];
        my $PRMax = $PRMin + 3.0;
        my $PDPhi = $Dtheta - (180. / $pi) * 2. * 6.0 / $PRMin;
        for (my $s = 0; $s < $ntile; $s++) {
            my $tile_no = $s + 1;
            my $element_no = $s + 1;
            my $PSPhi = 30.0 + (180. / $pi) * 6.0 / $PRMin + $s * $Dtheta;

            my %detector = init_det();
            $detector{"name"} = "$vname\_$layer_no\_$element_no";
            $detector{"mother"} = $envelope;
            $detector{"description"} = "$descriptio";
            $detector{"pos"} = "0*mm 0*mm $z*mm";
            $detector{"rotation"} = "0*deg 0*deg 0*deg";
            $detector{"color"} = $alu_color;
            $detector{"type"} = "Tube";
            $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
            $detector{"material"} = $alu_material;
            $detector{"ncopy"} = 1;
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);
        }
    }
}

sub place_Arc4onPCB {
    my $vname = "BMT_Arc4onPCB";
    my $descriptio = "BMT_Arc4onPCB";

    my @radii = (146.0, 161.0, 176.0, 191.0, 206.1, 221.1);
    my @distPCB = (445.0, 445.0, 474.82, 474.82, 487.0, 487.0);
    my $PDz = 3.0 / 2.0;

    for (my $l = 0; $l < $nlayer; $l++) {
        my $layer_no = $l + 1;
        my $z = $bmt_zpcb - $distPCB[$l] - $PDz;
        my $PRMin = $radii[$l];
        my $PRMax = $PRMin + 3.0;
        my $PDPhi = $Dtheta - (180. / $pi) * 2. * 6.0 / $PRMin;
        for (my $s = 0; $s < $ntile; $s++) {
            my $tile_no = $s + 1;
            my $element_no = $s + 1;
            my $PSPhi = 30.0 + (180. / $pi) * 6.0 / $PRMin + $s * $Dtheta;

            my %detector = init_det();
            $detector{"name"} = "$vname\_$layer_no\_$element_no";
            $detector{"mother"} = $envelope;
            $detector{"description"} = "$descriptio";
            $detector{"pos"} = "0*mm 0*mm $z*mm";
            $detector{"rotation"} = "0*deg 0*deg 0*deg";
            $detector{"color"} = $alu_color;
            $detector{"type"} = "Tube";
            $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
            $detector{"material"} = $alu_material;
            $detector{"ncopy"} = 1;
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);
        }
    }
}

sub place_innertube {
    my $vname = "BMT_InnerTube";
    my $descriptio = "BMT_InnerTube";

    my $PRMin = 140.0;
    my $PRMax = 141.0;
    my $PDz = 732.0 / 2.0;
    my $z = $bmt_zpcb - 7.0 - $PDz;
    my $PSPhi = 0.;
    my $PDPhi = 360.;

    my %detector = init_det();
    $detector{"name"} = "$vname";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "0*mm 0*mm $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $structure_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
    $detector{"material"} = $Cfiber_material;
    $detector{"ncopy"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_stiffeners
# each stiffener is one 2mm thick rectangle 736 x 92.5,
#     ignoring holders and screws 
#     divided in ctr + downstrm to model interference with end plates
#     upstrm will have to be introduced and ctr revisited when/if introducing upstream endplate 002 -> temporary
{
    my $vname = "BMT_Stiffeners_ctr";
    my $descriptio = "BMT_Stiffeners_ctr";

    my $Px = 92.496 / 2.0; # not 92.5 to avoid overlap with cover
    my $Py = 2.0 / 2.0;
    my $Pz = 719.0 / 2.0; # 736-17(downstream)
    my $z = $bmt_zpcb - 17.0 - $Pz;

    for (my $s = 0; $s < $ntile; $s++) {
        my $element_no = $s + 1;
        my $theta_rot = 30.0 + $s * 120.0;
        my $x = (141.5 + $Px) * cos($theta_rot * $pi / 180.0);
        my $y = (141.5 + $Px) * sin($theta_rot * $pi / 180.0);

        my %detector = init_det();
        $detector{"name"} = "$vname\_$element_no";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio";
        $detector{"pos"} = "$x*mm $y*mm $z*mm";
        $detector{"rotation"} = "0*deg 0*deg -$theta_rot*deg";
        $detector{"color"} = $structure_color;
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$Px*mm $Py*mm $Pz*mm";
        $detector{"material"} = $Cfiber_material;
        $detector{"ncopy"} = 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
    $vname = "BMT_Stiffeners_dwnstrm";
    $descriptio = "BMT_Stiffeners_dwnstrm";

    $Px = 89.496 / 2.0; # 92.5 - 3, with 3 = 144.5-141.5 (see first 2 rings of forward interface)
    $Py = 2.0 / 2.0;
    #$Pz        =  7.75/2.0;   # adjusted to match the 9.25 thickness in attachment for stiffener
    #$z         =  $bmt_zpcb - 17.0 + $Pz;
    $Pz = 17.0 / 2.0; # real length
    $z = $bmt_zpcb - $Pz;

    for ($s = 0; $s < $ntile; $s++) {
        $element_no = $s + 1;
        $theta_rot = 30.0 + $s * 120.0;
        $x = (144.5 + $Px) * cos($theta_rot * $pi / 180.0);
        $y = (144.5 + $Px) * sin($theta_rot * $pi / 180.0);

        %detector = init_det();
        $detector{"name"} = "$vname\_$element_no";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio";
        $detector{"pos"} = "$x*mm $y*mm $z*mm";
        $detector{"rotation"} = "0*deg 0*deg -$theta_rot*deg";
        $detector{"color"} = $structure_color;
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$Px*mm $Py*mm $Pz*mm";
        $detector{"material"} = $Cfiber_material;
        $detector{"ncopy"} = 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}

sub place_arcs {
    my $vname = "BMT_Arcs";
    my $descriptio = "BMT_Arcs";

    my $PRMin = 229.0;
    my $PRMax = 234.0;
    my $PDz = 15.0 / 2.0;
    my $z = $bmt_zpcb - 729.0 - $PDz;
    my $PDPhi = $Dtheta - (180. / $pi) * 2. * 7.5 / $PRMin;

    for (my $s = 0; $s < $ntile; $s++) {
        my $element_no = $s + 1;
        my $PSPhi = 30.0 + (180. / $pi) * 7.5 / $PRMin + $s * $Dtheta;

        my %detector = init_det();
        $detector{"name"} = "$vname\_$element_no";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio";
        $detector{"pos"} = "0*mm 0*mm $z*mm";
        $detector{"rotation"} = "0*deg 0*deg 0*deg";
        $detector{"color"} = $inox_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"material"} = $inox_material;
        $detector{"ncopy"} = 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}

sub place_cover {
    my $vname = "BMT_Cover";
    my $descriptio = "BMT_Cover";

    my $PRMin = 234.0;
    my $PRMax = 235.0;
    my $PDz = 744.0 / 2.0;
    my $z = $bmt_zpcb - $PDz;
    my $PSPhi = 0.;
    my $PDPhi = 360.;

    my %detector = init_det();
    $detector{"name"} = "$vname";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "0*mm 0*mm $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $structure_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
    $detector{"material"} = $Cfiber_material;
    $detector{"ncopy"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_rods
# The actual placement of these rods must be measured after glueing
# The FMT cables run between these rods and are defined here as well (only the part within the BMT mother volume)
{
    # C rods
    my $vname = "BMT_Rods";
    my $descriptio = "BMT_Rods";

    my $Px = 3.0 / 2.0;
    my $Px_gas = 4.0 / 2.0;
    my $Py = 3.0 / 2.0;
    my $Py_gas = 4.0 / 2.0;
    my $Pz = 655.0 / 2.0;
    my $z = $bmt_zpcb - 69.0 - $Pz;
    my $sphi = 10.909090;
    # on drawing 000, looks like sphi~2*dphi; this yields sphi = 120°/11 , temporary
    my $dphi = ($Dtheta - 2. * $sphi) / 18.0; # = 5.45°, temporary
    #my $dphi      = 6.095;  # there must be room for the 22mm (measured) flat cables: $dphi > (22+2*Px)/235
    #my $sphi      = ($Dtheta - 18.0*$dphi - (180./$pi)*6.0/235.0)/2.; # gives 9.55
    #my $dphi      = 5.12;   # there must be room for the 18mm (nominal) flat cables: $dphi > (18+2*Px)/235
    #my $sphi      = ($Dtheta - 18.0*$dphi - (180./$pi)*6.0/235.0)/2.; # gives 27.11

    for (my $s = 0; $s < $ntile; $s++) {
        my $tile_no = $s + 1;
        for (my $r = 0; $r < 19; $r++) {
            my $rod_no = $r + 1;
            my $theta_rot = 30.0 + $sphi + $s * 120. + $r * $dphi;
            my $x = (235.0 + $Px) * cos($theta_rot * $pi / 180.0);
            my $y = (235.0 + $Px) * sin($theta_rot * $pi / 180.0);
            if ($r > 16) {
                $x = (235.0 + $Px_gas) * cos($theta_rot * $pi / 180.0);
                $y = (235.0 + $Px_gas) * sin($theta_rot * $pi / 180.0);
            }
            my %detector = init_det();
            $detector{"name"} = "$vname\_$tile_no\_$rod_no";
            $detector{"mother"} = $envelope;
            $detector{"description"} = "$descriptio";
            $detector{"pos"} = "$x*mm $y*mm $z*mm";
            $detector{"rotation"} = "0*deg 0*deg -$theta_rot*deg";
            $detector{"color"} = $structure_color;
            $detector{"type"} = "Box";
            $detector{"dimensions"} = "$Px*mm $Py*mm $Pz*mm";
            if ($r > 16) {$detector{"dimensions"} = "$Px_gas*mm $Py_gas*mm $Pz*mm";}
            $detector{"material"} = $Cfiber_material;
            $detector{"ncopy"} = 1;
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);
        }
    }
    # FMT cable (Cu)
    $vname = "BMT_FMTcableCu";
    $descriptio = "BMT_FMTcableCu";

    $Px = 0.0876;        # half-thickness equivalent to the copper content of 2 cables
    $Py = 18.0 / 2.0;    # half (nominal) width of cable
    $Pz = $bmt_dz - 6.0; # -6 to avoid overlap with BMT_attFMT
    $z = 0.0;
    $sphi = $sphi + 0.5 * $dphi;

    for (my $s = 0; $s < $ntile; $s++) {
        my $tile_no = $s + 1;
        for (my $r = 0; $r < 17; $r++) {
            my $rod_no = $r + 1;
            my $theta_rot = 30.0 + $sphi + $s * 120. + $r * $dphi;
            my $x = (235.5 + $Px) * cos($theta_rot * $pi / 180.0);
            my $y = (235.5 + $Px) * sin($theta_rot * $pi / 180.0);
            my %detector = init_det();
            $detector{"name"} = "$vname\_$tile_no\_$rod_no";
            $detector{"mother"} = $envelope;
            $detector{"description"} = "$descriptio";
            $detector{"pos"} = "$x*mm $y*mm $z*mm";
            $detector{"rotation"} = "0*deg 0*deg -$theta_rot*deg";
            $detector{"color"} = $copper_color;
            $detector{"type"} = "Box";
            $detector{"dimensions"} = "$Px*mm $Py*mm $Pz*mm";
            $detector{"material"} = $copper_material;
            $detector{"ncopy"} = 1;
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);
        }
    }
    # FMT cable (Polyester)
    $vname = "BMT_FMTcablePE";
    $descriptio = "BMT_FMTcablePE";

    $Px = 1.0538;     # half-thickness equivalent to the polyester content of 2 cables
    $Py = 18.0 / 2.0; # half (nominal) width of cable

    for (my $s = 0; $s < $ntile; $s++) {
        my $tile_no = $s + 1;
        for (my $r = 0; $r < 17; $r++) {
            my $rod_no = $r + 1;
            my $theta_rot = 30.0 + $sphi + $s * 120. + $r * $dphi;
            my $x = (236.0 + $Px) * cos($theta_rot * $pi / 180.0);
            my $y = (236.0 + $Px) * sin($theta_rot * $pi / 180.0);
            my %detector = init_det();
            $detector{"name"} = "$vname\_$tile_no\_$rod_no";
            $detector{"mother"} = $envelope;
            $detector{"description"} = "$descriptio";
            $detector{"pos"} = "$x*mm $y*mm $z*mm";
            $detector{"rotation"} = "0*deg 0*deg -$theta_rot*deg";
            $detector{"color"} = $peek_color;
            $detector{"type"} = "Box";
            $detector{"dimensions"} = "$Px*mm $Py*mm $Pz*mm";
            $detector{"material"} = $peek_material; # close enough to polyester C10H8O4 (?), 1.35 g/cm3 considering all the approximations.
            $detector{"ncopy"} = 1;
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);
        }
    }
    # FMT gas supply and return
    $vname = "BMT_FMTgas";
    $descriptio = "BMT_FMTgas";

    $PRMin = 1.0;
    $PRMax = 2.0;
    $sphi = $sphi - 0.25 * $dphi;

    for (my $s = 0; $s < $ntile; $s++) {
        my $tile_no = $s + 1;
        for (my $r = 17; $r < 19; $r++) {
            my $rod_no = $r + 1;
            for (my $e = 0; $e < 2; $e++) # 2 gas tubes per inter-rod space
            {
                my $element_no = $e + 1;
                my $theta_rot = 30.0 + $sphi + $s * 120. + $r * $dphi + 0.5 * $e * $dphi;
                my $x = (235.0 + $PRMax) * cos($theta_rot * $pi / 180.0);
                my $y = (235.0 + $PRMax) * sin($theta_rot * $pi / 180.0);
                my %detector = init_det();
                $detector{"name"} = "$vname\_$tile_no\_$rod_no\_$element_no";
                $detector{"mother"} = $envelope;
                $detector{"description"} = "$descriptio";
                $detector{"pos"} = "$x*mm $y*mm $z*mm";
                $detector{"rotation"} = "0*deg 0*deg -$theta_rot*deg";
                $detector{"color"} = $peek_color;
                $detector{"type"} = "Tube";
                $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $Pz*mm 0.0*deg 360.0*deg";
                $detector{"material"} = $peek_material; # not so close to polypropylène C3H6, 0.9 g/cm3, but considering all the approximations....
                $detector{"ncopy"} = 1;
                $detector{"visible"} = 1;
                $detector{"style"} = 1;
                print_det(\%configuration, \%detector);
            }
        }
    }
}

sub place_overcover {
    my $vname = "BMT_OverCover";
    my $descriptio = "BMT_OverCover";

    my $PRMin = 239.01;
    my $PRMax = $PRMin + 0.2;
    my $PDz = 724.0 / 2.0;
    my $z = $bmt_zpcb - $PDz;
    my $PSPhi = 0.;
    my $PDPhi = 360.;

    my %detector = init_det();
    $detector{"name"} = "$vname";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "0*mm 0*mm $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $structure_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
    $detector{"material"} = $pcb_material;
    $detector{"ncopy"} = 1;
    $detector{"visible"} = 0;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_forwardinterface {
    my $vname = "BMT_ForwardInterface";
    my $descriptio = "BMT_ForwardInterface";

    # rings :

    my $PSPhi = 0.;
    my $PDPhi = 360.;
    my @rmin = (140.0, 141.5, 144.5, 215.0, 217.0);
    my @rmax = (141.5, 144.5, 148.0, 217.0, 234.0);
    my @dz = (15.0, 25.0, 6.0, 6.0, 8.0);
    my @z = (0.5, -4.5, 3.0, 3.0, 4.0);
    for (my $r = 0; $r < 5; $r++) {
        my $ring_no = $r + 1;
        my $PRMin = $rmin[$r];
        my $PRMax = $rmax[$r];
        my $PDz = 0.5 * $dz[$r];
        $z[$r] = $bmt_zpcb + $z[$r];

        my %detector = init_det();
        $detector{"name"} = "$vname\_ring$ring_no";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio";
        $detector{"pos"} = "0*mm 0*mm $z[$r]*mm";
        $detector{"rotation"} = "0*deg 0*deg 0*deg";
        $detector{"color"} = $peek_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"material"} = $peek_material;
        $detector{"ncopy"} = 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }

    # attachments for stiffeners:
    my $Py = 3.0 / 2.0;
    my $Px = 9.0 / 2.0;
    my $Pz = 17.0 / 2.0;
    my $z = $bmt_zpcb - $Pz;
    for (my $l = 0; $l < $nlayer; $l++) {
        my $layer_no = $l + 1;
        if ($layer_no == $nlayer) {
            $Px = 7.9 / 2.0;
            $Pz = 7.0 / 2.0;
            $z = $bmt_zpcb - $Pz;
        }
        my $angle = ((1.0 + $Py) / (151.0 + $l * 15.0)) * (180.0 / $pi);
        for (my $s = 0; $s < $ntile; $s++) {
            my $branch_no = $s + 1;
            for (my $e = 0; $e < 2; $e++) {
                my $element_no = $e + 1;
                my $theta_rot = 30.0 + $s * 120.0 + (2.0 * $e - 1.0) * $angle;
                my $x = (151.0 + $l * 15.0 + $Px) * cos($theta_rot * $pi / 180.0);
                my $y = (151.0 + $l * 15.0 + $Px) * sin($theta_rot * $pi / 180.0);

                my %detector = init_det();
                $detector{"name"} = "$vname\_attStiff\_$layer_no\_$branch_no\_$element_no";
                $detector{"mother"} = $envelope;
                $detector{"description"} = "$descriptio";
                $detector{"pos"} = "$x*mm $y*mm $z*mm";
                $detector{"rotation"} = "0*deg 0*deg -$theta_rot*deg";
                $detector{"color"} = $peek_color;
                $detector{"type"} = "Box";
                $detector{"dimensions"} = "$Px*mm $Py*mm $Pz*mm";
                $detector{"material"} = $peek_material;
                $detector{"ncopy"} = 1;
                $detector{"visible"} = 1;
                $detector{"style"} = 1;
                print_det(\%configuration, \%detector);
            }
        }
    }

    # 3 branches:

    $Py = 24.0 / 2.0;
    $Px = (214.66 - 148.0) / 2.0; # not 215 in order to avoid overlap with 4th ring above;
    $Pz = 6.0 / 2.0;
    $z = $bmt_zpcb + $Pz;

    for (my $s = 0; $s < $ntile; $s++) {
        my $element_no = $s + 1;
        my $theta_rot = 30.0 + $s * 120.0;
        my $x = (148.0 + $Px) * cos($theta_rot * $pi / 180.0);
        my $y = (148.0 + $Px) * sin($theta_rot * $pi / 180.0);

        my %detector = init_det();
        $detector{"name"} = "$vname\_branch$element_no";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio";
        $detector{"pos"} = "$x*mm $y*mm $z*mm";
        $detector{"rotation"} = "0*deg 0*deg -$theta_rot*deg";
        $detector{"color"} = $peek_color;
        $detector{"type"} = "Box";
        $detector{"dimensions"} = "$Px*mm $Py*mm $Pz*mm";
        $detector{"material"} = $peek_material;
        $detector{"ncopy"} = 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }

    # attachments for FMT :
    $PRMin = 234.0;
    $PRMax = 240.0;
    $PDz = 0.5 * 6.0;
    $z = $bmt_zpcb + 8.0 - $PDz;
    my @phi = (0.75, 29.25, 180.75, 209.25);
    $PDPhi = 5.56; # 23 mm wide at R = 237 mm

    for (my $a = 0; $a < 4; $a++) {
        my $attfmt_no = $a + 1;
        $PSPhi = $phi[$a] - 0.5 * $PDPhi;

        my %detector = init_det();
        $detector{"name"} = "$vname\_attFMT$attfmt_no";
        $detector{"mother"} = $envelope;
        $detector{"description"} = "$descriptio";
        $detector{"pos"} = "0*mm 0*mm $z*mm";
        $detector{"rotation"} = "0*deg 0*deg 0*deg";
        $detector{"color"} = $peek_color;
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
        $detector{"material"} = $peek_material;
        $detector{"ncopy"} = 1;
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);
    }
}

sub place_closingplate {
    my $vname = "BMT_ClosingPlate";
    my $descriptio = "BMT_ClosingPlate";

    my $PRMin = 146.0;
    my $PRMax = 217.0;
    my $PDz = 0.5;
    my $z = $bmt_zpcb + 8.0 - $PDz;
    my $PSPhi = 0.;
    my $PDPhi = 360.;

    my %detector = init_det();
    $detector{"name"} = "$vname";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "0*mm 0*mm $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $structure_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $PSPhi*deg $PDPhi*deg";
    $detector{"material"} = $Cfiber_material;
    $detector{"ncopy"} = 1;
    $detector{"visible"} = 0;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

1;
