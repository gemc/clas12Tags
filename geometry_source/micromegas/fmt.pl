# use strict;
use warnings;

our %configuration;
our %parameters;

# FMT is a Tube containing all SLs
my $envelope = 'FMT';

# All dimensions in mm

my @starting_point = ();

my $fmt_ir = $parameters{"FMT_mothervol_InnerRadius"};
my $fmt_or = $parameters{"FMT_mothervol_OutRadius"};
my $nlayer = $parameters{"FMT_nlayer"};
$starting_point[0] = $parameters{"FMT_zpos_layer1"};
$starting_point[1] = $parameters{"FMT_zpos_layer2"};
$starting_point[2] = $parameters{"FMT_zpos_layer3"};
$starting_point[3] = $parameters{"FMT_zpos_layer4"};
$starting_point[4] = $parameters{"FMT_zpos_layer5"};
$starting_point[5] = $parameters{"FMT_zpos_layer6"};

# should be FMT_mothervol_zmin + 2 mm (FMT support thickness upstream of D1)
# then nominally, interdisks space = 11.9 mm except between D3 and D4 13.9 mm.



# Mother volume zmin = BMT MV zmax = end of BMT closing plate
# Mother volume zmax to take into account innerscrews extension downstream D6 (about 3.5 mm) >= FMT_zpos_layer6 + 7.6 + 3.5
# Mother volume half-length and middle position: 
my $fmt_dz = ($parameters{"FMT_mothervol_zmax"} - $parameters{"FMT_mothervol_zmin"}) / 2.0 + 1.9;
my $fmt_starting = ($parameters{"FMT_mothervol_zmax"} + $parameters{"FMT_mothervol_zmin"}) / 2.0;
my $fmt_zmin = $parameters{"FMT_mothervol_zmin"};

#my $Dtheta              = 60.0; # rotation angle of each disk wrt to the preceding one


my $Det_RMin = $parameters{"FMT_DetInnerRadius"};
my $Det_RMax = $parameters{"FMT_DetOuterRadius"};
my $Act_RMin = $parameters{"FMT_ActInnerRadius"};
my $Act_RMax = $parameters{"FMT_ActOuterRadius"};
my $innerFR4_RMax = $parameters{"FMT_innerFR4OuterRadius"};
my $outerFR4_RMin = $parameters{"FMT_outerFR4InnerRadius"};
my $innerPhRes_RMax = $parameters{"FMT_innerPhResistOuterRadius"};
my $outerPhRes_RMin = $parameters{"FMT_outerPhResistInnerRadius"};
my $innerPeek_RMin = $parameters{"FMT_innerPEEKInnerRadius"};
my $innerPeek_RMax = $parameters{"FMT_innerPEEKOuterRadius"};
my $outerPeek_RMin = $parameters{"FMT_outerPEEKInnerRadius"};
my $outerPeek_RMax = $parameters{"FMT_outerPEEKOuterRadius"};

my $innerRohacell_RMin = 0.0;
my $innerRohacell_RMax = 0.0;
my $outerRohacell_RMin = 0.0;
my $outerRohacell_RMax = 0.0;

my $CuGround_Dz = 0.5 * $parameters{"FMT_CuGround_Dz"};         # half width
my $PCBGround_Dz = 0.5 * $parameters{"FMT_PCBGround_Dz"};       # half width
my $Rohacell_Dz = 0.5 * $parameters{"FMT_Rohacell_Dz"};         # half width
my $PCBDetector_Dz = 0.5 * $parameters{"FMT_PCBDetector_Dz"};   # half width
my $Strips_Dz = 0.5 * $parameters{"FMT_Strips_Dz"};             # half width
my $Kapton_Dz = 0.5 * $parameters{"FMT_Kapton_Dz"};             # half width
my $ResistStrips_Dz = 0.5 * $parameters{"FMT_ResistStrips_Dz"}; # half width
# my $Gas1_Dz 		= 0.5*$parameters{"FMT_Gas1_Dz"}; # = $PhRes128_Dz
my $PhRes128_Dz = 0.5 * $parameters{"FMT_PhotoResist128_Dz"}; # half width
my $Mesh_Dz = 0.5 * $parameters{"FMT_Mesh_Dz"};               # half width
my $PhRes64_Dz = 0.5 * $parameters{"FMT_PhotoResist64_Dz"};   # half width
# my $Gas2_Dz 		= 0.5*$parameters{"FMT_Gas2_Dz"}; # = $Peek_Dz
my $Peek_Dz = 0.5 * $parameters{"FMT_Peek_Dz"};                         # half width
my $DriftCuElectrode_Dz = 0.5 * $parameters{"FMT_DriftCuElectrode_Dz"}; # half width
my $DriftPCB_Dz = 0.5 * $parameters{"FMT_DriftPCB_Dz"};                 # half width
my $DriftCuGround_Dz = 0.5 * $parameters{"FMT_DriftCuGround_Dz"};       # half width

my $RotDisks = $parameters{"FMT_overall_disks_rotation"};     # nominal = 60°;
my $RotSpacers = $parameters{"FMT_overall_spacers_rotation"}; # nominal = 0°; if not 0, alignment with BMT interface to be revised

# G4 materials
my $peek_material = 'myPeek';
my $alu_material = 'myAlu';
my $pcb_material = 'myFR4';
my $copper_material = 'myCopper';
my $strips_material = 'myfmtMMStrips'; #copper
my $gas_material = 'myfmtMMGas';       # neon ethane CF4
my $photoresist_material = 'myPhRes';
my $mesh_material = 'myfmtMMMesh'; # inox
my $air_material = 'myAir';
my $kapton_material = 'myKapton';
my $rohacell_material = 'myRohacell';
my $epoxy_material = 'myEpoxy';
my $flangerohacell_material = 'myFlangeRohacell';
my $resist_material = 'myfmtResistPaste';    # for resistive strips
my $innerscrew_material = 'myfmtInnerScrew'; # effective screws "in" the inner peek ring
my $slimelec_material = 'myfmtSlimElecDrift';
my $slimground_material = 'myfmtSlimGroundDrift';

#define myGlue...
# pillars holding the mesh neglected
#my $drift_material   	= 'myMMMylar';

# G4 colors
# set somewhat at random 'rrggbb(t)' (transparency from 0 opaque to 5 fully transparent)
my $air_color = 'e200e15';
my $alu_color = 'b2577a'; # dark grey
my $connector_color = '40b8af';
my $copper_color = '666600'; # greenish (dark)
my $gas_color = 'ffcc004';
my $hvcover_color = '6c2d58'; # dark grey semi-transparent
my $inox_color = '888888';
my $kapton_color = 'fff600';      # yellowish transparent (active zone)
my $mesh_color = '252020';        # black
my $pcb_color = '0000ff';         # blue
my $peek_color = '6ccecb';        # light blue
my $photoresist_color = 'aa00aa'; # purple
my $resist_color = '000000';
my $rohacell_color = '00ff00'; # green
my $spacer_color = '666600';
my $strips_color = '353540';
#myGlue
#my $drift_color      = 'fff600';

$pi = 3.141592653589793238;

sub rot_hvcover {
    my $l = shift;
    my $c = shift;
    my $theta_rot = $RotDisks + $l * 60 + $c * 180;
    return "0*deg 0*deg -$theta_rot*deg";
}

sub rot_connector {
    my $l = shift;
    my $c = shift;
    my $cc = shift;
    my $theta_rot = $RotDisks + $l * 60 + $c * 15;
    if ($cc == 1) {$theta_rot = $theta_rot + 180.0;}
    return "0*deg 0*deg -$theta_rot*deg";
}

sub rot_support {
    my $c = shift;
    my $theta_rot = $RotSpacers + $c * 180;
    return "0*deg 0*deg -$theta_rot*deg";
}

sub define_fmt {

    print "Number of layers: ", $nlayer, " ", $configuration{"variation"}, " First Layer zstart: ", $starting_point[0], "\n";

    if ($configuration{"variation"} eq "michel"
        || $configuration{"variation"} eq "slim"
        || $configuration{"variation"} eq "michel_9mmcopper"
        || $configuration{"variation"} eq "michel_200umcopper"
        || $configuration{"variation"} eq "michel_600umcopper") {

        make_fmt();

        for (my $l = 0; $l < $nlayer; $l++) {
            place_cuground($l);
            place_pcbground($l);
            place_innerFR4($l);
            place_rohacell($l);
            place_outerFR4($l);
            place_pcbdetector($l);
            place_strips($l);
            place_kapton($l);
            place_resist($l);
            place_innerPhRes128($l);
            place_gas1($l);
            place_outerPhRes128($l);
            place_mesh($l);
            place_innerPhRes64($l);
            place_outerPhRes64($l);
            place_innerpeek($l);
            place_gas2($l);
            place_outerpeek($l);
            place_driftcuelectrode($l);
            place_driftpcb($l);
            place_driftcuground($l);
            place_hvcovers($l);
            place_connectors($l);
            place_cables($l);
            place_innerscrews($l);
            if ($l == 2 || $l == 5) {place_supports36($l);}
            if ($l == 0 || $l == 1 || $l == 3 || $l == 4) {place_supports1245($l);}
            if ($l < 5) {place_spacers($l);}
        }

    }
    elsif ($configuration{"variation"} eq "rgf_spring2020" || $configuration{"variation"} eq "slim") {
        $DriftCuElectrode_Dz = 0.5 * $parameters{"FMTSlim_DriftCuElectrode_Dz"}; # half width of slim version
        $DriftCuGround_Dz = 0.5 * $parameters{"FMTSlim_DriftCuElectrode_Dz"};    # half width of slim version
        $DriftPCB_Dz = 0.5 * $parameters{"FMTSlim_DriftKapton_Dz"};              # half width of slim version

        $innerRohacell_RMin = $parameters{"FMT_innerROHACELLInnerRadius"};
        $innerRohacell_RMax = $parameters{"FMT_innerROHACELLOuterRadius"};
        $outerRohacell_RMin = $parameters{"FMT_outerROHACELLInnerRadius"};
        $outerRohacell_RMax = $parameters{"FMT_outerROHACELLOuterRadius"};

        make_fmt();

        for ($l = 0; $l < $nlayer; $l++) {
            place_cuground($l);
            place_pcbground($l);
            place_innerFR4($l);
            place_rohacell($l);
            place_outerFR4($l);
            place_pcbdetector($l);
            place_strips($l);
            place_kapton($l);
            place_resist($l);
            place_innerPhRes128($l);
            place_gas1($l);
            place_outerPhRes128($l);
            place_mesh($l);
            place_innerPhRes64($l);
            place_outerPhRes64($l);
            place_innerpeek($l);
            place_gas2($l);
            place_outerpeek($l);
            place_driftcuelectrode($l);
            place_driftpcb($l);
            place_driftcuground($l);
            place_hvcovers($l);
            place_connectors($l);
            place_cables($l);
            place_innerscrews($l);
            if ($l == 2) {place_supports36($l);}
            if ($l == 0 || $l == 1) {place_supports1245($l);}
            if ($l < 2) {place_spacers($l);}
        }

    }

}

sub make_fmt {
    my $zpos = $fmt_starting;

    my %detector = init_det();
    $detector{"name"} = $envelope;
    $detector{"mother"} = "root";
    $detector{"description"} = "Forward Micromegas Vertex Tracker";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$fmt_ir*mm $fmt_or*mm $fmt_dz*mm 0*deg 360*deg";
    $detector{"material"} = $air_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 0;
    $detector{"style"} = 0;

    print_det(\%configuration, \%detector);

    if ($configuration{"variation"} eq "rgf_spring2020" || $configuration{"variation"} eq "slim") {

        my $pvc_supportIR = 240; # mm
        my $pvc_supportOR = 245; # mm
        my $pvc_supportDZ = 280; # mm

        %detector = init_det();
        $detector{"name"} = "fmt_pvcSupport";
        $detector{"mother"} = "root";
        $detector{"description"} = "Forward Micromegas Vertex Tracker";
        $detector{"color"} = "aaaaff";
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$pvc_supportIR*mm $pvc_supportOR*mm $pvc_supportDZ*mm 0*deg 360*deg";
        $detector{"material"} = "G4_POLYVINYL_CHLORIDE";
        $detector{"color"} = "bbbbff";
        $detector{"mfield"} = "no";
        $detector{"style"} = 1;

        print_det(\%configuration, \%detector);
    }

}

sub place_cuground {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + $CuGround_Dz;
    my $vname = "FMT_CuGround";
    my $descriptio = "Cu Ground, Layer $layer_no, ";

    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $Det_RMin;
    my $PRMax = $Det_RMax;
    my $PDz = $CuGround_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $copper_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $copper_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;

    print_det(\%configuration, \%detector);

}

sub place_pcbground {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + $PCBGround_Dz;
    my $vname = "FMT_PCB_Ground";
    my $descriptio = "PCB Ground, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $Det_RMin;
    my $PRMax = $Det_RMax;
    my $PDz = $PCBGround_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $pcb_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $pcb_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_innerFR4 {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + $Rohacell_Dz;
    my $vname = "FMT_innerFR4";
    my $descriptio = "Inner FR4, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $Det_RMin;
    my $PRMax = $innerFR4_RMax;
    my $PDz = $Rohacell_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $pcb_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $pcb_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_rohacell {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + $Rohacell_Dz;
    my $vname = "FMT_Rohacell";
    my $descriptio = "Rohacell, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $innerFR4_RMax;
    my $PRMax = $outerFR4_RMin;
    my $PDz = $Rohacell_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $rohacell_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $rohacell_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_outerFR4 {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + $Rohacell_Dz;
    my $vname = "FMT_outerFR4";
    my $descriptio = "Outer FR4, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $outerFR4_RMin;
    my $PRMax = $Det_RMax;
    my $PDz = $Rohacell_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $pcb_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $pcb_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_pcbdetector {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + $PCBDetector_Dz;
    my $vname = "FMT_PCB_Detector";
    my $descriptio = "PCB Detector, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $Det_RMin;
    my $PRMax = $Det_RMax;
    my $PDz = $PCBDetector_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $pcb_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $pcb_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_strips {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + $Strips_Dz;
    my $vname = "FMT_Strips";
    my $descriptio = "Strips, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $Act_RMin;
    my $PRMax = $Act_RMax;
    my $PDz = $Strips_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $strips_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $strips_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_kapton {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + $Kapton_Dz;
    my $vname = "FMT_Kapton";
    my $descriptio = "Kapton, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $Act_RMin;
    my $PRMax = $Act_RMax;
    my $PDz = $Kapton_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $kapton_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $kapton_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_resist {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + $ResistStrips_Dz;
    my $vname = "FMT_Resistiv_Strips";
    my $descriptio = "Resistiv Strips, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $Act_RMin;
    my $PRMax = $Act_RMax;
    my $PDz = $ResistStrips_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $resist_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $resist_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_innerPhRes128 {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + $PhRes128_Dz;
    my $vname = "FMT_innerPhRes128";
    my $descriptio = "innerPhotoResist128, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $Det_RMin;
    my $PRMax = $innerPhRes_RMax;
    my $PDz = $PhRes128_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $photoresist_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $photoresist_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_gas1 {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + $PhRes128_Dz;
    my $vname = "FMT_Gas1";
    my $descriptio = "Gas1, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $innerPhRes_RMax;
    my $PRMax = $outerPhRes_RMin;
    my $PDz = $PhRes128_Dz + 0.001;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $gas_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $gas_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_outerPhRes128 {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + $PhRes128_Dz;
    my $vname = "FMT_outerPhRes128";
    my $descriptio = "outerPhotoResist128, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $outerPhRes_RMin;
    my $PRMax = $Det_RMax;
    my $PDz = $PhRes128_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $photoresist_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $photoresist_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_mesh {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + 2 * $PhRes128_Dz + $Mesh_Dz;
    my $vname = "FMT_Mesh";
    my $descriptio = "Mesh, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $innerPeek_RMax; # 4 mm of extension below peek ring neglected
    my $PRMax = $outerPeek_RMax;
    my $PDz = $Mesh_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $mesh_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $mesh_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_innerPhRes64 {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + 2 * $PhRes128_Dz + 2 * $Mesh_Dz + $PhRes64_Dz;
    my $vname = "FMT_innerPhRes64";
    my $descriptio = "innerPhotoResist64, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $Det_RMin;
    my $PRMax = $innerPhRes_RMax;
    my $PDz = $PhRes64_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $photoresist_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $photoresist_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_outerPhRes64 {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + 2 * $PhRes128_Dz + 2 * $Mesh_Dz + $PhRes64_Dz;
    my $vname = "FMT_outerPhRes64";
    my $descriptio = "outerPhotoResist64, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $outerPhRes_RMin;
    my $PRMax = $outerPeek_RMax;
    my $PDz = $PhRes64_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $photoresist_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $photoresist_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_innerpeek {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + 2 * $PhRes128_Dz + 2 * $Mesh_Dz + 2 * $PhRes64_Dz + $Peek_Dz;
    my $vname = "FMT_innerPeek";
    my $descriptio = "inner PEEK, Layer $layer_no, ";

    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $innerPeek_RMin;
    my $PRMax = $innerPeek_RMax;
    if ($configuration{"variation"} eq "rgf_spring2020" || $configuration{"variation"} eq "slim") {
        $PRMax = $innerRohacell_RMax;
    }
    my $PDz = $Peek_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $peek_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $peek_material;
    if ($configuration{"variation"} eq "rgf_spring2020" || $configuration{"variation"} eq "slim") {
        $detector{"material"} = $flangerohacell_material;
    }
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

}

sub place_gas2 {
    my $l = shift;
    my $type = 1;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + 2 * $PhRes128_Dz + 2 * $Mesh_Dz + +2 * $PhRes64_Dz + $Peek_Dz;
    my $vname = "FMT_Gas2";
    my $descriptio = "Gas2, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $innerPeek_RMax;
    my $PRMax = $outerPeek_RMin;
    my $PDz = $Peek_Dz + 0.001;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $gas_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $gas_material;
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    $detector{"sensitivity"} = "fmt";
    $detector{"hit_type"} = "fmt";
    $detector{"identifiers"} = "disk manual $layer_no type manual $type segment manual $detector{'ncopy'} strip manual 1";
    print_det(\%configuration, \%detector);
}

sub place_outerpeek {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + 2 * $PhRes128_Dz + 2 * $Mesh_Dz + 2 * $PhRes64_Dz + $Peek_Dz;
    my $vname = "FMT_outerPeek";
    my $descriptio = "outer PEEK, Layer $layer_no, ";

    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $outerPeek_RMin;
    my $PRMax = $outerPeek_RMax;
    if ($configuration{"variation"} eq "rgf_spring2020" || $configuration{"variation"} eq "slim") {
        $PRMin = $outerRohacell_RMin;
    }
    my $PDz = $Peek_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $alu_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $alu_material;
    if ($configuration{"variation"} eq "rgf_spring2020" || $configuration{"variation"} eq "slim") {
        $detector{"material"} = $flangerohacell_material;
    }
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;

    print_det(\%configuration, \%detector);

}

sub place_driftcuelectrode {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + 2 * $PhRes128_Dz + 2 * $Mesh_Dz + 2 * $PhRes64_Dz + 2 * $Peek_Dz + $DriftCuElectrode_Dz;
    my $vname = "FMT_Drift_Cu_Electrode";
    my $descriptio = "Drift Cu Electrode, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $Act_RMin;
    my $PRMax = $Act_RMax;
    my $PDz = $DriftCuElectrode_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $copper_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $copper_material;
    if ($configuration{"variation"} eq "rgf_spring2020" || $configuration{"variation"} eq "slim") {
        $detector{"material"} = $slimelec_material;
    }
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_driftpcb {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + 2 * $PhRes128_Dz + 2 * $Mesh_Dz + 2 * $PhRes64_Dz + 2 * $Peek_Dz + 2 * $DriftCuElectrode_Dz + $DriftPCB_Dz;
    my $vname = "FMT_Drift_PCB";
    my $descriptio = "Drift PCB, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $Det_RMin;
    my $PRMax = $outerPeek_RMax;
    my $PDz = $DriftPCB_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $pcb_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $pcb_material;
    if ($configuration{"variation"} eq "rgf_spring2020" || $configuration{"variation"} eq "slim") {
        $detector{"material"} = $kapton_material;
    }
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_driftcuground {
    my $l = shift;
    my $layer_no = $l + 1;

    my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + 2 * $PhRes128_Dz + 2 * $Mesh_Dz + 2 * $PhRes64_Dz + 2 * $Peek_Dz + 2 * $DriftCuElectrode_Dz + 2 * $DriftPCB_Dz + $DriftCuGround_Dz;
    my $vname = "FMT_Drift_Cu_Ground";
    my $descriptio = "Drift Cu Ground, Layer $layer_no, ";


    # names
    my $tpos = "0*mm 0*mm";
    my $PRMin = $Det_RMin;
    my $PRMax = $outerPeek_RMax;
    my $PDz = $DriftCuGround_Dz;

    my %detector = init_det();
    $detector{"name"} = "$vname$layer_no";
    $detector{"mother"} = $envelope;
    $detector{"description"} = "$descriptio";
    $detector{"pos"} = "$tpos $z*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"color"} = $copper_color;
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm 0*deg 360*deg";
    $detector{"material"} = $copper_material;
    if ($configuration{"variation"} eq "rgf_spring2020" || $configuration{"variation"} eq "slim") {
        $detector{"material"} = $slimground_material;
    }
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = 1;
    $detector{"pMany"} = 1;
    $detector{"exist"} = 1;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);
}

sub place_hvcovers {
    my $l = shift;
    my $layer_no = $l + 1;

    #units = mm, deg. ; element 1 = flat top; 2 and 3 = lateral edges; 4 = external edge.
    my @rmin = (200.0, 204.0, 204.0, 223.8);
    my @rmax = (224.8, 223.8, 223.8, 224.8);
    my @dz = (1.0, 6.5, 6.5, 6.5); # full thickness
    my @stheta = (-13.755, -13.755, 13.5, -13.755);
    # for initial angular position (HV covers and connectors sym/y-axis); then corrected via RotDisks parameter
    my @dtheta = (27.51, 0.255, 0.255, 27.51);

    my $vname = "FMT_HVcover";

    for (my $c = 0; $c < 2; $c++) # 2 HV cover per disk
    {
        my $cover_no = $c + 1;
        for (my $e = 0; $e < 4; $e++) # 4 elements compose a HV cover
        {
            my $element_no = $e + 1;
            my $descriptio = "HVcover$cover_no, Layer$layer_no, Element$element_no";
            my $PRMin = $rmin[$e];
            my $PRMax = $rmax[$e];
            my $PDz = 0.5 * $dz[$e];
            my $Stheta = $stheta[$e];
            my $Dtheta = $dtheta[$e];

            my $tpos = "0*mm 0*mm";
            my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + 2 * $PhRes128_Dz + $PDz; # starts 2.615 mm after starting point
            if ($element_no == 1) {$z = $z + $dz[2];}

            my %detector = init_det();
            $detector{"name"} = "$vname$layer_no\_$cover_no\_$element_no";
            $detector{"mother"} = $envelope;
            $detector{"description"} = "$descriptio";
            $detector{"pos"} = "$tpos $z*mm";
            $detector{"rotation"} = rot_hvcover($l, $c);
            $detector{"color"} = $hvcover_color;
            $detector{"type"} = "Tube";
            $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $Stheta*deg $Dtheta*deg";
            $detector{"material"} = $alu_material;
            if ($configuration{"variation"} eq "rgf_spring2020" || $configuration{"variation"} eq "slim") {
                $detector{"material"} = $peek_material;
            }
            $detector{"mfield"} = "no";
            $detector{"ncopy"} = 1;
            $detector{"pMany"} = 1;
            $detector{"exist"} = 1;
            $detector{"visible"} = 1;
            $detector{"style"} = 1;

            print_det(\%configuration, \%detector);
        }
    }
}

sub place_connectors
# this includes the radial part of the cables right after the connectors
{
    my $l = shift;
    my $layer_no = $l + 1;

    # units = mm, deg.
    # element 1 = connector (plastic part)
    # element 2 = connector (metallic part placed on top of 1 instead of in the middle)
    # element 3 = flat cable end (PCB part placed beyond 1 in radius)
    # element 4 = flat cable end (metallic part placed on top of 3 instead of in the middle)
    # element 5 = radial part of FMT cable (Cu) - same as in bmt.pl, except approximated by angular sector
    # element 6 = radial part of FMT cable (polyester) - same as in bmt.pl, except approximated by angular sector


    my @rmin = (205.9, 205.9, 213.3, 216.5, 225.3, 225.3);
    my @rmax = (213.3, 213.3, 225.3, 224.0, 241.2, 241.2);
    my @dz = (3.0, 0.5, 2.0, 0.7, 0.0876, 1.054); # full thickness * effective density, approximate !
    my @stheta = (33.2, 33.6, 33.0, 34.7, 35.305, 35.305);
    # for initial angular position (HV-covers and connectors sym/y-axis); then corrected via RotDisks parameter
    my @dtheta = (8.6, 7.8, 9.6, 5.6, 4.390, 4.390); # 4.39 degrees = 18 mm cable width / 235 mm average radius
    my @mat = ($pcb_material, $alu_material, $pcb_material, $alu_material, $copper_material, $peek_material);
    my @col = ($connector_color, $hvcover_color, $connector_color, $hvcover_color, $copper_color, $peek_color);

    my $vname = "FMT_connector";

    for (my $c = 0; $c < 8; $c++) # 2*8 connectors per disk
    {
        my $connector_no = 8 - $c;
        for (my $cc = 0; $cc < 2; $cc++) {
            if ($cc == 1) {$connector_no = $connector_no + 8;}
            for (my $e = 0; $e < 6; $e++) # 4 elements (female + male, plastic + metal each) compose a connector
            # and 2 elements (copper and polyester approximated by peek) compose a cable
            {
                my $element_no = $e + 1;
                my $descriptio = "Connector Layer $layer_no, Conn. $connector_no, Element $element_no";
                my $PRMin = $rmin[$e];
                my $PRMax = $rmax[$e];
                if ($element_no == 5 || $element_no == 6) {$PRMax = $PRMax + $l * 1.7;}
                my $PDz = 0.5 * $dz[$e];
                my $Stheta = $stheta[$e];
                my $Dtheta = $dtheta[$e];

                my $tpos = "0*mm 0*mm";
                my $z = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + 2 * $PhRes128_Dz + $PDz;
                if ($element_no == 2) {$z = $z + $dz[0];}
                if ($element_no == 3) {$z = $z + 0.5 * $dz[0];}
                if ($element_no == 4) {$z = $z + 0.5 * $dz[0] + $dz[2];}
                if ($element_no == 5) {$z = $z + 0.5 * $dz[0];}
                if ($element_no == 6) {$z = $z + 0.5 * $dz[0] + $dz[4];}

                my %detector = init_det();
                $detector{"name"} = "$vname$layer_no\_$connector_no\_$element_no";
                $detector{"mother"} = $envelope;
                $detector{"description"} = "$descriptio";
                $detector{"pos"} = "$tpos $z*mm";
                $detector{"rotation"} = rot_connector($l, $c, $cc);
                $detector{"color"} = $col[$e];
                $detector{"type"} = "Tube";
                $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $Stheta*deg $Dtheta*deg";
                $detector{"material"} = $mat[$e];
                $detector{"mfield"} = "no";
                $detector{"ncopy"} = 1;
                $detector{"pMany"} = 1;
                $detector{"exist"} = 1;
                $detector{"visible"} = 1;
                $detector{"style"} = 1;

                print_det(\%configuration, \%detector);
            }
        }
    }
}
sub place_cables

# this is the longitudinal part of the cables, modeled by 
# 6 (disks) x 2 (at 180 degrees from each other) x 2 (Copper and polyester parts) homogeneous 120 degrees sectors,
# each sector having the same amount of material as 8 cables

{
    my $l = shift;
    my $layer_no = $l + 1;

    # element 1 = long. part of FMT cable (Cu) - same as in bmt.pl, except approximated by angular sector
    # element 2 = long. part of FMT cable (polyester) - same as in bmt.pl, except approximated by angular sector

    my $zmin = $fmt_zmin - $fmt_starting;
    my $zmax = $starting_point[$l] - $fmt_starting + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + 2 * $PhRes128_Dz + 1.5;

    my $z = 0.5 * ($zmin + $zmax);
    my $PDz = 0.5 * ($zmax - $zmin);
    my @thickness = (0.0876 * 0.281, 1.054 * 0.281); # 0.281 = (18 mm cable width / 245 mm average radius)/15 degrees

    my $Stheta = 30.0;
    # for initial angular position (HV-covers and connectors sym/y-axis); then corrected via RotDisks parameter
    my $Dtheta = 120.0;

    my @mat = ($copper_material, $peek_material);
    my @col = ($copper_color, $peek_color);

    my $vname = "FMT_cable";

    for (my $s = 0; $s < 2; $s++) {
        my $sector_no = $s + 1;
        for (my $e = 0; $e < 2; $e++) # 2 elements (copper and polyester approximated by peek) compose a cable
        {
            my $element_no = $e + 1;
            my $descriptio = "Cable, Layer $layer_no, Sector $sector_no, Element $element_no";

            my $PRMax = 241.2 + $l * 1.7;
            my $PRMin = $PRMax - $thickness[1];
            if ($element_no == 1) {
                $PRMax = $PRMin;
                $PRMin = $PRMax - $thickness[0];
            }

            my $tpos = "0*mm 0*mm";

            my %detector = init_det();
            $detector{"name"} = "$vname$layer_no\_$sector_no\_$element_no";
            $detector{"mother"} = $envelope;
            $detector{"description"} = "$descriptio";
            $detector{"pos"} = "$tpos $z*mm";
            $detector{"rotation"} = rot_connector($l, 0, $s);
            $detector{"color"} = $col[$e];
            $detector{"type"} = "Tube";
            $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $Stheta*deg $Dtheta*deg";
            $detector{"material"} = $mat[$e];
            $detector{"mfield"} = "no";
            $detector{"ncopy"} = 1;
            $detector{"pMany"} = 1;
            $detector{"exist"} = 1;
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);
        }
    }
}
sub place_innerscrews {
    my $l = shift;
    my $layer_no = $l + 1;

    # Screws are divided into head and body, placed respectively upstream and downstream the detector in order to avoid overlaps.

    my $vname = "FMT_InnerScrew";
    my $descriptio = "InnerScrew";
    my @dz = (1.5, 3.0); # half real length compensated by double density
    my @radius = (2.5, 1.25);
    my $z0 = $starting_point[$l] - $fmt_starting;
    my $z = $z0;

    for (my $s = 0; $s < 9; $s++) # 9 screws per layer
    {
        my $screw_no = $s + 1;
        for (my $e = 0; $e < 2; $e++) # 2 elements (head and body) per screw
        {
            my $element_no = $e + 1;
            my $PRadius = $radius[$e];
            my $PDz = 0.5 * $dz[$e];
            if ($element_no == 1) {
                $z = $z0 - $PDz;
                $descriptio = "InnerScrewHead Layer $layer_no, $screw_no";
            }
            if ($element_no == 2) {
                $z = $z0 + 2 * $CuGround_Dz + 2 * $PCBGround_Dz + 2 * $Rohacell_Dz + 2 * $PCBDetector_Dz + 2 * $Strips_Dz + 2 * $Kapton_Dz + 2 * $ResistStrips_Dz + 2 * $PhRes128_Dz + 2 * $Mesh_Dz + 2 * $PhRes64_Dz + 2 * $Peek_Dz + 2 * $DriftCuElectrode_Dz + 2 * $DriftPCB_Dz + 2 * $DriftCuGround_Dz + $PDz;
                $descriptio = "InnerScrewBody Layer $layer_no, $screw_no";
            }
            my $theta_rot = 3.6 + $RotDisks + $l * 60 + $s * 40;
            # 3.6° read approximately on paper on Sedi drawing 6 2075 DM 1240 013 (for above defined initial angular position); temp ?
            my $xpos = 30.0 * cos($theta_rot * $pi / 180.0);
            my $ypos = 30.0 * sin($theta_rot * $pi / 180.0);
            # 30 mm on Sedi drawing 6 2075 DM 1240 133

            my %detector = init_det();
            $detector{"name"} = "$vname$layer_no\_$screw_no\_$element_no";;
            $detector{"mother"} = $envelope;
            $detector{"description"} = "$descriptio";
            $detector{"pos"} = "$xpos*mm $ypos*mm $z*mm";
            $detector{"color"} = $inox_color;
            $detector{"type"} = "Tube";
            $detector{"dimensions"} = "0.0*mm $PRadius*mm $PDz*mm 0.0*deg 360.0*deg";
            $detector{"material"} = $innerscrew_material;
            if ($configuration{"variation"} eq "rgf_spring2020" || $configuration{"variation"} eq "slim") {
                $detector{"material"} = $epoxy_material;
            }
            $detector{"mfield"} = "no";
            $detector{"ncopy"} = 1;
            $detector{"pMany"} = 1;
            $detector{"exist"} = 1;
            $detector{"visible"} = 1;
            $detector{"style"} = 1;

            print_det(\%configuration, \%detector);
        }
    }
}

sub place_supports36 {
    my $l = shift;
    my $layer_no = $l + 1;

    # units = mm, deg.
    # element 1 = flat 2mm-thick sector
    # 2 to 4 = 5mm-thick attachment parts

    my @rmin = (205.0, 225.0, 225.0, 225.0);
    my @rmax = (225.0, 240.0, 240.0, 240.0);
    my @dz = (2.0, 5.0, 5.0, 5.0);         # full thickness
    my @stheta = (-2.0, -2.0, 28.0, 58.0); # nominal position
    my @dtheta = (64.0, 4.0, 4.0, 4.0);

    my $vname = "FMT_support";

    for (my $c = 0; $c < 2; $c++) # 2 supports per disk
    {
        my $support_no = $c + 1;
        for (my $e = 0; $e < 4; $e++) # 4 elements compose supports 3 and 6
        {
            my $element_no = $e + 1;
            my $descriptio = "Support$support_no, Layer $layer_no, Element $element_no";
            my $PRMin = $rmin[$e];
            my $PRMax = $rmax[$e];
            my $PDz = 0.5 * $dz[$e];
            my $Stheta = $stheta[$e];
            my $Dtheta = $dtheta[$e];

            my $tpos = "0*mm 0*mm";
            my $z = $starting_point[$l] - $fmt_starting - $dz[0] + $PDz;
            if ($element_no == 1) {my $z = $starting_point[$l] - $fmt_starting - $PDz;}

            my %detector = init_det();
            $detector{"name"} = "$vname$layer_no\_$support_no\_$element_no";
            $detector{"mother"} = $envelope;
            $detector{"description"} = "$descriptio";
            $detector{"pos"} = "$tpos $z*mm";
            $detector{"rotation"} = rot_support($c);
            $detector{"color"} = $alu_color;
            $detector{"type"} = "Tube";
            $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $Stheta*deg $Dtheta*deg";
            $detector{"material"} = $alu_material;
            if ($configuration{"variation"} eq "rgf_spring2020" || $configuration{"variation"} eq "slim") {
                $detector{"material"} = $peek_material;
            }
            $detector{"mfield"} = "no";
            $detector{"ncopy"} = 1;
            $detector{"pMany"} = 1;
            $detector{"exist"} = 1;
            $detector{"visible"} = 1;
            $detector{"style"} = 1;

            print_det(\%configuration, \%detector);
        }
    }
}

sub place_supports1245 {
    my $l = shift;
    my $layer_no = $l + 1;

    # units = mm, deg.
    # element 1 = flat 2mm-thick sector
    # 2 to 3 = 5mm-thick attachment parts

    my @rmin = (205.0, 225.0, 225.0);
    my @rmax = (225.0, 240.0, 240.0);
    my @dz = (2.0, 5.0, 5.0);        # full thickness
    my @stheta = (-2.0, -2.0, 28.0); # nominal position
    my @dtheta = (34.0, 4.0, 4.0);
    if ($l == 0) {
        $dtheta[1] = 5.5;
        $dtheta[2] = 5.5;
        #$stheta[2] = 11.5 ;
        $stheta[2] = 26.5;
    }

    my $vname = "FMT_support";

    for (my $c = 0; $c < 2; $c++) # 2 supports per disk
    {
        my $support_no = $c + 1;
        for (my $e = 0; $e < 3; $e++) # 3 elements compose supports 1, 2, 4 and 5
        {
            my $element_no = $e + 1;
            my $descriptio = "Support$support_no, Layer $layer_no, Element $element_no";
            my $PRMin = $rmin[$e];
            my $PRMax = $rmax[$e];
            my $PDz = 0.5 * $dz[$e];
            my $Stheta = $stheta[$e];
            my $Dtheta = $dtheta[$e];

            my $tpos = "0*mm 0*mm";
            my $z = $starting_point[$l] - $fmt_starting - $dz[0] + $PDz;
            if ($element_no == 1) {my $z = $starting_point[$l] - $fmt_starting - $PDz;}

            my %detector = init_det();
            $detector{"name"} = "$vname$layer_no\_$support_no\_$element_no";
            $detector{"mother"} = $envelope;
            $detector{"description"} = "$descriptio";
            $detector{"pos"} = "$tpos $z*mm";
            $detector{"rotation"} = rot_support($c);
            $detector{"color"} = $alu_color;
            $detector{"type"} = "Tube";
            $detector{"dimensions"} = "$PRMin*mm $PRMax*mm $PDz*mm $Stheta*deg $Dtheta*deg";
            $detector{"material"} = $alu_material;
            if ($configuration{"variation"} eq "rgf_spring2020" || $configuration{"variation"} eq "slim") {
                $detector{"material"} = $peek_material;
            }
            $detector{"mfield"} = "no";
            $detector{"ncopy"} = 1;
            $detector{"pMany"} = 1;
            $detector{"exist"} = 1;
            $detector{"visible"} = 1;
            $detector{"style"} = 1;

            print_det(\%configuration, \%detector);
        }
    }
}

sub place_spacers {
    my $l = shift;
    my $layer_no = $l + 1;

    # units = mm, deg. ;
    # these spacers ("entretoises") are screwed on the supports;
    # their length is such as to fill the available space between 2 supports = 11.9 - 5 = 6.9 mm (13.9 - 5 = 8.9 mm between D3 and D4 because of extra bolt)
    # they are placed on top of support elements 2 and 3, which extend 3 mm beyond disk entrance.
    # 4 identical tubes per layer: 4.6 mm diameter as an average between threaded part at 3 mm and hexagonal head at 6mm ( + 1mm long cylinder at 5mm diameter)
    # approximate brass by copper

    my $vname = "FMT_Spacer";

    for (my $c = 0; $c < 2; $c++) # 2 supports per disk
    {
        my $support_no = $c + 1;
        for (my $e = 0; $e < 2; $e++) # 2 spacers per support
        {
            my $element_no = $e + 1;
            my $descriptio = "Support$support_no, Layer$layer_no, Spacer$element_no";

            my $theta_rot = $e * 32.0 + $c * 180.0 - 1.0; # +0.75 (axis offset wrt H) - 1.75 (hole offset wrt axis) = -1.
            # 0.75° nominal position for these spacers; if changed here, should also be changed in rot_support.
            my $xpos = 236.0 * cos($theta_rot * $pi / 180.0);
            my $ypos = 236.0 * sin($theta_rot * $pi / 180.0);
            my $dz = ($starting_point[$l + 1] - 2.0) - ($starting_point[$l] + 3.0);
            my $PDz = 0.5 * $dz;
            my $z = $starting_point[$l] - $fmt_starting + 3.0 + $PDz;

            my %detector = init_det();
            $detector{"name"} = "$vname$support_no\_$layer_no\_$element_no";
            $detector{"mother"} = $envelope;
            $detector{"description"} = "$descriptio";
            $detector{"pos"} = "$xpos*mm $ypos*mm $z*mm";
            $detector{"color"} = $spacer_color;
            $detector{"type"} = "Tube";
            $detector{"dimensions"} = "0.0*mm 2.3*mm $PDz*mm 0.0*deg 360.0*deg";
            $detector{"material"} = $copper_material;
            $detector{"mfield"} = "no";
            $detector{"ncopy"} = 1;
            $detector{"pMany"} = 1;
            $detector{"exist"} = 1;
            $detector{"visible"} = 1;
            $detector{"style"} = 1;

            print_det(\%configuration, \%detector);
        }
    }
}

1;
