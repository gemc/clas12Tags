package coatjava;

use strict;
use warnings;

use geometry;

my $mothers;
my $positions;
my $rotations;
my $types;
my $dimensions;
my $ids;

my $nstrips = 36;

# define ec sector. The definition is independendt so that misalignment between sectors can be implemented if needed
sub define_mothers {
    for (my $s = 1; $s <= 6; $s++) {
        build_mother($s);
    }
}

sub build_mother {
    # generate red mother volume wireframe box, and write to a file.
    my $sector = shift;

    my %detector = init_det();
    my $vname = "ec_s" . $sector;

    $detector{"name"} = $vname;
    $detector{"mother"} = $mothers->{$vname};
    $detector{"pos"} = $positions->{$vname};
    $detector{"rotation"} = $rotations->{$vname};
    $detector{"type"} = $types->{$vname};
    $detector{"dimensions"} = $dimensions->{$vname};

    $detector{"description"} = "Forward Calorimeter - Sector " . $sector;
    $detector{"color"} = "ff1111";
    $detector{"material"} = "G4_AIR";
    $detector{"visible"} = 0;

    print_det(\%main::configuration, \%detector);
}

sub define_lids {
    for (my $s = 1; $s <= 6; $s++) {
        build_lids($s);
    }
}

sub build_lids {
    # Generate first stainless cover using first scintillator dimensions
    my $sector = shift;

    my %detector = init_det();
    my $vname = "eclid1_s" . $sector;

    $detector{"name"} = $vname;
    $detector{"mother"} = $mothers->{$vname};
    $detector{"pos"} = $positions->{$vname};
    $detector{"rotation"} = $rotations->{$vname};
    $detector{"type"} = $types->{$vname};
    $detector{"dimensions"} = $dimensions->{$vname};

    $detector{"description"} = "Stainless Steel Skin 1";
    $detector{"color"} = "FCFFF0";
    $detector{"material"} = "G4_STAINLESS-STEEL";
    $detector{"style"} = 1;
    print_det(\%main::configuration, \%detector);

    # Generate Last-a-Foam layer using first scintillator dimensions

    %detector = init_det();
    $vname = "eclid2_s" . $sector;

    $detector{"name"} = $vname;
    $detector{"mother"} = $mothers->{$vname};
    $detector{"pos"} = $positions->{$vname};
    $detector{"rotation"} = $rotations->{$vname};
    $detector{"type"} = $types->{$vname};
    $detector{"dimensions"} = $dimensions->{$vname};

    $detector{"description"} = "Last-a-Foam";
    $detector{"color"} = "EED18C";
    $detector{"material"} = "LastaFoam";
    $detector{"style"} = 1;
    print_det(\%main::configuration, \%detector);


    # Second stainless steel cover using first scintillator dimensions

    %detector = init_det();
    $vname = "eclid3_s" . $sector;

    $detector{"name"} = $vname;
    $detector{"mother"} = $mothers->{$vname};
    $detector{"pos"} = $positions->{$vname};
    $detector{"rotation"} = $rotations->{$vname};
    $detector{"type"} = $types->{$vname};
    $detector{"dimensions"} = $dimensions->{$vname};

    $detector{"description"} = "Stainless Steel Skin 2";
    $detector{"color"} = "FCFFF0";
    $detector{"material"} = "G4_STAINLESS-STEEL";
    $detector{"style"} = 1;
    print_det(\%main::configuration, \%detector);

}

sub define_layers {
    for (my $s = 1; $s <= 6; $s++) {
        build_leadlayers($s);
        build_scintlayers($s);
    }
}

sub build_leadlayers {
    my $sector = shift;
    my $nlayers = 39;
    my $istack = 1;

    for (my $ilayer = 2; $ilayer <= $nlayers; $ilayer++) {
        if ($ilayer > 15) {
            $istack = 2;
        }
        my $iview = ($ilayer - 1) % 3 + 1;

        my %detector = init_det();
        my $vname = "lead_$ilayer" . "_s" . $sector . "_view_$iview" . "_stack_$istack";

        $detector{"name"} = $vname;
        $detector{"mother"} = $mothers->{$vname};
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"type"} = $types->{$vname};
        $detector{"dimensions"} = $dimensions->{$vname};

        $detector{"description"} = "Forward Calorimeter lead layer ${ilayer}";
        $detector{"color"} = "7CFC00";
        $detector{"material"} = "G4_Pb";
        $detector{"style"} = 1;
        print_det(\%main::configuration, \%detector);
    }
}

sub build_scintlayers {
    my $sector = shift;
    my $nlayers = 39;

    #array of colors for layer mother volumes of U, V, W views respectively
    my @colors = ("ff6633", "33ffcc", "33ffcc");

    for (my $ilayer = 1; $ilayer <= $nlayers; $ilayer++) {
        my $istack = ($ilayer < 16) ? 1 : 2;

        my $iview = ($ilayer - 1) % 3 + 1;
        my $uvw = substr("UVW", $iview - 1, 1);

        my %detector = init_det();
        my $vname = "$uvw-scintillator_$ilayer" . "_s" . $sector . "_view_$iview" . "_stack_$istack";

        $detector{"name"} = $vname;
        $detector{"mother"} = $mothers->{$vname};
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"type"} = $types->{$vname};
        $detector{"dimensions"} = $dimensions->{$vname};

        $detector{"description"} = "Forward Calorimeter scintillator layer ${ilayer}";
        $detector{"color"} = $colors[$iview - 1];
        $detector{"material"} = "G4_AIR";

        print_det(\%main::configuration, \%detector);

        build_strips($sector, $ilayer);
    }
}

sub build_strips {
    my $sector = shift;
    my $ilayer = shift;

    my $istack = ($ilayer < 16) ? 1 : 2;
    my $iview = ($ilayer - 1) % 3 + 1;
    my $uvw = substr("UVW", $iview - 1, 1);

    # Notice:
    # $ilayer is the scintillator layer, goes from 1 to 39
    # Original identifier:
    # $detector{"identifiers"} = "sector manual $sector stack manual $istack view manual $iview strip manual $istrip";

    #
    # hipo:
    # layer=1-3 (PCAL) 4-9 (ECAL)
    # hipoADC.setByte("layer", counter, (byte) (view+stack*3));
    # view: u,v,w = 1,2,3
    # stack: Inner / Outer = 1,2

    my $hipoLayer = $iview + $istack * 3;

    #array of colors for strip volumes of U, V, W views respectively
    my @colors = ("ff6633", "6600ff", "6600ff");

    for (my $istrip = 1; $istrip <= $nstrips; $istrip++) {
        my %detector = init_det();
        my $vname = "${uvw}_strip_${ilayer}_${istrip}_s${sector}_stack_${istack}";

        $detector{"name"} = $vname;
        $detector{"mother"} = $mothers->{$vname};
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"type"} = $types->{$vname};
        $detector{"dimensions"} = $dimensions->{$vname};

        $detector{"description"} = "Forward Calorimeter scintillator layer ${ilayer} strip ${istrip} view ${iview}";
        $detector{"color"} = $colors[$iview - 1];
        $detector{"material"} = "scintillator";
        $detector{"style"} = 1;
        $detector{"sensitivity"} = "ecal";
        $detector{"hit_type"} = "ecal";
        $detector{"identifiers"} = "sector manual $sector layer manual $hipoLayer strip manual $istrip";

        print_det(\%main::configuration, \%detector);
    }
}

sub makeEC {
    ($mothers, $positions, $rotations, $types, $dimensions, $ids) = @main::volumes;

    define_mothers();
    define_lids();
    define_layers();
}

1;
