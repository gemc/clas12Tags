package coatjava;

use strict;
use warnings;
use geometry;

# volumes.pl returns the array of hashes (6 hashes)
# number of entries in each hash is equal to the number of volumes (all mothers+all daughters)
# keys of hashes consist of volume names (constructed in COATJAVA SVT factory)
# e.g. per each volume with 'volumeName':
# mothers['volumeName'] = 'name of mothervolume'
# positions['volumeName'] = 'x y z'
# rotations['volumeName'] = 'rotationOrder: angleX angleY angleZ' (e.g. 'xyz: 90*deg 90*deg 90*deg')
# types['volumeName'] = 'name of volumeType (Trd, Box etc.)'
# dimensions['volumeName'] = 'dimensions of volume (e.g. 3 values for Box, 5 values for Trd etc.'
# ids['volumeName'] = 'region# sector# module#'

my ($mothers, $positions, $rotations, $types, $dimensions, $ids);

# old                           -> new
# superlayer (1,2,3,4)          -> region (1,2,3,4)
# segment (1-10,1-14,1-18,1-24) -> sector (1-10,1-14,1-18,1-24)
# type (V=1,W=2)                -> module (U=1,V=2)
# module (1-3)                  -> sp (sensorPhysical) (1-3)
# strip (1)                     -> strip (1)

my $nregions;
my @nsectors;
my $nmodules;
my $nsensors;
my $npads;

my $bsensorzones;
my $bsensors;

# will move materials to CCDB later
my %materials = ("silicon", "G4_Si",
    "heatSink", "G4_Cu",
    "rohacell", "rohacell",
    "carbonFiber", "carbonFiber",
    "busCable", "BusCable",
    "pitchAdaptor", "G4_SILICON_DIOXIDE",
    "pcBoard", "pcBoardMaterial",
    "chip", "pcBoardMaterial",
    "epoxy", "tdr1100",
    "rail", "G4_Cu",
    "pad", "BusCableCopperAndNickelAndGold",
    "wirebond", "svtwirebond",
    "mylar", "G4_MYLAR",
    "rohacell110", "rohacell110",
    "neoprene", "neoprene",
    "Component", "Component");

my %colors = ("silicon", "ccffff",
    "heatSink", "ffcc00",
    "carbonFiber", "333333",
    "busCable", "666666",
    "pcBoard", "ffff99",
    "chip", "cccc00",
    "peek", "bbbbbb",
    "rohacell110", "ffffcc",
    "neoprene", "ff8888",
    "mylar", "bbbbcc");

my $btestone = 0;

sub makeBST {
    ($mothers, $positions, $rotations, $types, $dimensions, $ids) = @main::volumes;

    $nregions = $main::parameters{"nregions"};
    $nmodules = $main::parameters{"nmodules"};
    $nsensors = $main::parameters{"nsensors"};
    $npads = $main::parameters{"npads"};

    $bsensorzones = $main::parameters{"bsensorzones"};
    $bsensors = $main::parameters{"bsensors"};

    if ($btestone) {
        $nregions = 1;
        #$nmodules = 1;
        #$nsensors = 1;
    }
    else {
        # overwriting nregions as it comes out from the service as 4
        $nregions = 3;
    }

    build_mother();
    build_cage();
    for (my $r = 1; $r <= $nregions; $r++) {
        $nsectors[$r - 1] = $main::parameters{"nsectors_r" . $r};
        if ($btestone) {$nsectors[0] = 1;}

        # 3 regions
        build_region($r);
    }
}

sub build_mother {
    my $vname = "svt";
    my $vdesc = "SVT Mother";

    my %detector = init_det();
    %detector = setup_detector($vname, \%detector);
    %detector = setup_detector_passive($vdesc, \%detector);
    $detector{"mother"} = "root"; # overwrite mother from file
    $detector{"visible"} = 0;
    print_det(\%main::configuration, \%detector);
}

sub build_cage {
    my @names = ("Inner", "Outer", "Cap", "Insulation");
    my @mats = ("mylar", "carbonFiber", "rohacell110", "neoprene");
    for (my $i = 0; $i < 4; $i++) {
        my $vname = "faradayCage" . $names[$i];
        my $vdesc = "Faraday Cage " . $names[$i];
        my $mat = $mats[$i];
        build_passive($vname, $vdesc, $mat);
    }
}

# 3 regions 1 to 3
# build_region($r);
sub build_region {
    my $r = shift;
    my $vname = "region" . $r;
    my $vdesc = "SVT Region " . $r;

    #print "Hello from ".$vdesc."\n";

    my %detector = init_det();
    %detector = setup_detector($vname, \%detector);
    %detector = setup_detector_passive($vdesc, \%detector);
    $detector{"visible"} = 0;
    print_det(\%main::configuration, \%detector);

    # number of regions depends on sector
    # starts at 1
    for (my $s = 1; $s <= $nsectors[$r - 1]; $s++) {
        build_sector($r, $s);
    }

    build_peek_support($r);
}

# 3 regions 1 to 3
# build_region($r);
# number of sector depends on regions, starts at 1
# build_sector($r, $s)
sub build_sector {
    my $r = shift;
    my $s = shift;
    my $vname = "sector" . $s . "_r" . $r;
    my $vdesc = "SVT Sector " . $s . ", Region " . $r;

    #print "Hello from ".$vdesc."\n";

    my %detector = init_det();
    %detector = setup_detector($vname, \%detector);
    %detector = setup_detector_passive($vdesc, \%detector);
    $detector{"visible"} = 0;
    print_det(\%main::configuration, \%detector);

    for (my $m = 1; $m <= $nmodules; $m++) {
        build_module($r, $s, $m);
        build_passive_in_module($r, $s, $m, "pitchAdaptor", "SVT Pitch Adaptor");
        build_carbon_fiber($r, $s, $m);
        build_bus_cable($r, $s, $m);
        build_pc_board_and_chips($r, $s, $m);
        build_epoxy_and_rail_and_pads($r, $s, $m);
    }

    build_passive_in_sector($r, $s, "rohacell", "SVT Rohacell Support");
    build_heat_sink($r, $s);
}


# 3 regions 1 to 3
# build_region($r);
# number of sector depends on regions, starts at 1
# build_sector($r, $s)
# 2 modules $m, bottom = 1 and top = 2
# build_module($r, $s, $m);
# 3 sensors $sp = 1,2,3
sub build_module {
    my $r = shift;
    my $s = shift;
    my $m = shift;

    my $name = "module";
    my $desc = "SVT Module";
    my ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);

    build_passive($vname, $vdesc, $name, 1); # hide container volume

    for (my $sp = 1; $sp <= $nsensors; $sp++) {
        build_sensor_physical($r, $s, $m, $sp);
    }
}

# 3 regions 1 to 3
# build_region($r);
# number of sector depends on regions, starts at 1
# build_sector($r, $s)
# 2 modules $m, bottom and top
# build_module($r, $s, $m);
# 3 sensors $sp
sub build_sensor_physical {
    my $r = shift;
    my $s = shift;
    my $m = shift;
    my $sp = shift;
    my $name = "sensorPhysical";
    my $desc = "SVT Physical Sensor";
    my $vname = $name . $sp . "_m" . $m . "_s" . $s . "_r" . $r;
    my $vdesc = $desc . " " . $sp . ", Module " . $m . ", Sector " . $s . ", Region " . $r;

    my %detector = init_det();
    %detector = setup_detector($vname, \%detector);
    %detector = setup_detector_active($vdesc, \%detector);
    $detector{"identifiers"} = "region manual $r module manual $m sector manual $s sensor manual $sp strip manual 1";
    $detector{"color"} = $colors{"silicon"};
    print_det(\%main::configuration, \%detector);
}

#sub build_sensor_active
#{
#    my $r  = shift;
#    my $s  = shift;
#    my $m  = shift;
#    my $sp = shift;
#    my $vname = "sensorActive"."_sp".$sp."_m".$m."_s".$s."_r".$r;
#    my $vdesc = "SVT Sensor Active Zone ".$sp.", Module ".$m.", Sector ".$s.", Region ".$r;
#
#    #print "Hello from ".$vdesc."\n";
#
#    my %detector = init_det();
#    %detector = setup_detector( $vname, \%detector );
#    %detector = setup_detector_active( $vdesc, \%detector );
#    $detector{"identifiers"} = "superlayer manual $r type manual $m segment manual $s module manual $sp strip manual 1";
#    print_det(\%main::configuration, \%detector);
#}

#sub build_sensor_dead_len
#{
#    my $r  = shift;
#    my $s  = shift;
#    my $m  = shift;
#    my $sp = shift;
#    my $dz = shift;
#    my $vname = "deadZoneLen".$dz."_sp".$sp."_m".$m."_s".$s."_r".$r;
#    my $vdesc = "SVT Sensor Dead Zone ".$dz." Along Length of Physical Sensor ".$sp.", Module ".$m.", Sector ".$s.", Region ".$r;
#
#    #print "Hello from ".$vdesc."\n";
#
#    my %detector = init_det();
#    %detector = setup_detector( $vname, \%detector );
#    %detector = setup_detector_passive( $vdesc, \%detector );
#    $detector{"material"} = $materials{"silicon"};
#    print_det(\%main::configuration, \%detector);
#}

#sub build_sensor_dead_wid
#{
#    my $r  = shift;
#    my $s  = shift;
#    my $m  = shift;
#    my $sp = shift;
#    my $dz = shift;
#    my $vname = "deadZoneWid".$dz."_sp".$sp."_m".$m."_s".$s."_r".$r;
#    my $vdesc = "SVT Sensor Dead Zone ".$dz." Along Width of Physical Sensor ".$sp.", Module ".$m.", Sector ".$s.", Region ".$r;
#
#    #print "Hello from ".$vdesc."\n";
#
#    my %detector = init_det();
#    %detector = setup_detector( $vname, \%detector );
#    %detector = setup_detector_passive( $vdesc, \%detector );
#    $detector{"material"} = $materials{"silicon"};
#    print_det(\%main::configuration, \%detector);
#}

sub build_peek_support {
    my $r = shift;

    my $vname = "peek_polyhedra_r" . $r;
    my $vdesc = "SVT Region Peek Polyhedra " . $r;
    my $mat = "Component";
    build_passive($vname, $vdesc, $mat);
    $vname = "peek_tube_r" . $r;
    $vdesc = "SVT Region Peek Tube " . $r;
    $mat = "Component";
    build_passive($vname, $vdesc, $mat);
    $vname = "peek_r" . $r;
    $vdesc = "SVT Region Peek Support " . $r;
    $mat = "peek";
    build_passive($vname, $vdesc, $mat);
}

sub build_heat_sink {
    my $r = shift;
    my $s = shift;
    my $desc = "SVT Upstream Support";

    my $mat = "heatSink";
    my $name = $mat;
    my ($vname, $vdesc) = setup_name_in_sector($r, $s, $name, $desc);
    #build_passive($vname,$vdesc,$mat,1); # hide container volume

    $name = $mat . "Cu";
    ($vname, $vdesc) = setup_name_in_sector($r, $s, $name, $desc);
    build_passive($vname, $vdesc, $mat);

    $name = $mat . "Ridge";
    ($vname, $vdesc) = setup_name_in_sector($r, $s, $name, $desc);
    build_passive($vname, $vdesc, $mat);
}

sub build_carbon_fiber {
    my $r = shift;
    my $s = shift;
    my $m = shift;
    my $desc = "SVT Carbon Fiber";

    my $mat = "carbonFiber";
    my $name = $mat;
    my ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat, 1); # hide container volume

    $name = $mat . "Cu";
    ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat);

    $name = $mat . "Pk";
    ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat);
}

sub build_bus_cable {
    my $r = shift;
    my $s = shift;
    my $m = shift;
    my $desc = "SVT Bus Cable";

    my $mat = "busCable";
    my $name = $mat;
    my ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat, 1); # hide container volume

    $name = $mat . "Cu";
    ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat);

    $name = $mat . "Pk";
    ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat);
}

sub build_pc_board_and_chips {
    my $r = shift;
    my $s = shift;
    my $m = shift;
    my $desc = "SVT HFCB"; # Hybrid Flex Circuit Board

    my $mat = "pcBoardAndChips";
    my $name = $mat;
    my ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat, 1); # hide container volume

    $mat = "pcBoard";
    $name = $mat;
    ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat);

    $mat = "chip";
    $name = $mat . "L";
    ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat);

    $name = $mat . "R";
    ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat);
}

sub build_epoxy_and_rail_and_pads {
    my $r = shift;
    my $s = shift;
    my $m = shift;

    my $desc = "SVT Epoxy Glue and HV Rail and Pads"; # High Voltage
    my $mat = "epoxyAndRailAndPads";
    my $name = $mat;
    my ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat, 1); # hide container volume

    $mat = "epoxy";
    $name = $mat . "MajorCu";
    ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat);
    $name = $mat . "MinorCu";
    ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat);
    $name = $mat . "MajorPk";
    ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat);
    $name = $mat . "MinorPk";
    ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat);

    $mat = "rail";
    $name = $mat;
    ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $mat);

    $mat = "pad";
    for (my $p = 01; $p <= $npads; $p++) {
        #$name = $mat.$p;
        $name = $mat . ($p - 1);
        ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
        build_passive($vname, $vdesc, $mat);
    }
}

sub build_passive_in_module {
    my $r = shift;
    my $s = shift;
    my $m = shift;
    my $name = shift;
    my $desc = shift;
    my $invisible = shift; # optional argument
    my ($vname, $vdesc) = setup_name_in_module($r, $s, $m, $name, $desc);
    build_passive($vname, $vdesc, $name, $invisible);
}

sub build_passive_in_sector {
    my $r = shift;
    my $s = shift;
    my $name = shift;
    my $desc = shift;
    my $invisible = shift; # optional argument
    my ($vname, $vdesc) = setup_name_in_sector($r, $s, $name, $desc);
    build_passive($vname, $vdesc, $name, $invisible);
}

sub setup_name_in_sector {
    my $r = shift;
    my $s = shift;
    my $name = shift;
    my $desc = shift;
    my $vname = $name . "_s" . $s . "_r" . $r;
    my $vdesc = $desc . ", Sector " . $s . ", Region " . $r;
    return ($vname, $vdesc);
}

sub setup_name_in_module {
    my $r = shift;
    my $s = shift;
    my $m = shift;
    my $name = shift;
    my $desc = shift;
    my $vname = $name . "_m" . $m . "_s" . $s . "_r" . $r;
    my $vdesc = $desc . " " . $m . ", Sector " . $s . ", Region " . $r;
    return ($vname, $vdesc);
}

sub build_passive {
    my $vname = shift;
    my $vdesc = shift;
    my $mat = shift;
    my $invisible = shift;

    my %detector = init_det();
    %detector = setup_detector($vname, \%detector);
    %detector = setup_detector_passive($vdesc, \%detector);
    if (defined $materials{$mat}) {$detector{"material"} = $materials{$mat};}
    if (defined $colors{$mat}) {$detector{"color"} = $colors{$mat};}
    if ($invisible) {$detector{"visible"} = 0;}
    print_det(\%main::configuration, \%detector);
}

sub setup_detector_active {
    my $description = shift;
    my %detector = %{shift()};

    $detector{"description"} = $description;
    $detector{"color"} = "0000ff";
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = "1";
    $detector{"visible"} = 1;
    $detector{"style"} = 1; # 0 = wireframe, 1 = solid

    $detector{"material"} = "G4_Si";
    $detector{"sensitivity"} = "bst";
    $detector{"hit_type"} = "bst";

    return %detector;
}

sub setup_detector_passive {
    my $description = shift;
    my %detector = %{shift()};

    $detector{"description"} = $description;
    $detector{"color"} = "cccccc";
    $detector{"material"} = "G4_AIR";
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = "1";
    $detector{"visible"} = 1;
    $detector{"style"} = 1; # 0 = wireframe, 1 = solid

    return %detector;
}

sub setup_detector {
    my $vname = shift;
    my %detector = %{shift()};

    if (not defined $mothers->{$vname}) {die "unknown volume: \"" . $vname . "\"\n";}

    $detector{"name"} = $vname;
    $detector{"mother"} = $mothers->{$vname};
    $detector{"pos"} = $positions->{$vname};
    $detector{"rotation"} = $rotations->{$vname};
    $detector{"type"} = $types->{$vname};
    $detector{"dimensions"} = $dimensions->{$vname};

    return %detector;
}

1;
