package coatjava;

use strict;
use warnings;

use geometry;

# volumes.pl returns the array of hashes (6 hashes)
# number of entries in each hash is equal to the number of volumes (all mothers+all daughters)
# keys of hashes consist of volume names (constructed in COATJAVA AHDC factory)
# e.g. per each volume with 'volumeName':
# mothers['volumeName'] = 'name of mothervolume'
# positions['volumeName'] = 'x y z'
# rotations['volumeName'] = 'rotationOrder: angleX angleY angleZ' (e.g. 'xyz: 90*deg 90*deg 90*deg')
# types['volumeName'] = 'name of volumeType (Trd, Box etc.)'
# dimensions['volumeName'] = 'dimensions of volume (e.g. 3 values for Box, 5 values for Trd etc.'
# ids['volumeName'] = 'sector# layer# paddle#'
my ($mothers, $positions, $rotations, $types, $dimensions, $ids);

my $ncells_0; # number of signal wires in superlayer 0
my $ncells_1; # number of signal wires in superlayer 1
my $ncells_2;
my $ncells_3;
my $ncells_4; # number of signal wires in superlayer 4

my $nlayers = 2;

sub makeAHDC {
    ($mothers, $positions, $rotations, $types, $dimensions, $ids) = @main::volumes;

    $ncells_0 = $main::parameters{"ahdc.superlayer1.layer1.ncomponents"};
    $ncells_1 = $main::parameters{"ahdc.superlayer2.layer1.ncomponents"};
    $ncells_2 = $main::parameters{"ahdc.superlayer3.layer1.ncomponents"};
    $ncells_3 = $main::parameters{"ahdc.superlayer4.layer1.ncomponents"};
    $ncells_4 = $main::parameters{"ahdc.superlayer5.layer1.ncomponents"};

    build_AHDC_mother();
    build_AHDC_superlayers();
}

sub build_AHDC_mother {

    my %detector = init_det();
    # dimension and position adjusted to englobe the whole AHDC
    my $vname = "ahdc_mother";
    $detector{"name"} = $vname;
    $detector{"mother"} = "root";
    #$detector{"pos"}         = "0.0*mm 0.0*mm 127.7*mm";
    $detector{"pos"} = "0.0*mm 0.0*mm 0.0*mm";
    $detector{"type"} = "Tube";
    #$detector{"dimensions"}  = "2.5*cm 7.3*cm 15.0*cm 0.*deg 360.*deg";
    #$detector{"dimensions"}  = "2.5*cm 21.0*cm 20.0*cm 0.*deg 360.*deg";
    $detector{"dimensions"} = "0.4*cm 23.5*cm 32.227*cm 0.*deg 360.*deg";
    $detector{"description"} = "Alert mother";
    $detector{"color"} = "aa00ff";
    $detector{"material"} = "AHDCgas";
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = "1";
    $detector{"visible"} = 1; # 0 or 1, 1 for debugging is better
    $detector{"style"} = 0;
    print_det(\%main::configuration, \%detector);
}

# Superlayers
sub build_AHDC_superlayers {
    for (my $s = 1; $s <= 1; $s++) {
        build_AHDC_ncells_0($s);
    }

    for (my $s = 1; $s <= $nlayers; $s++) {
        build_AHDC_ncells_1($s);
    }
    for (my $s = 1; $s <= $nlayers; $s++) {
        build_AHDC_ncells_2($s);
    }
    for (my $s = 1; $s <= $nlayers; $s++) {
        build_AHDC_ncells_3($s);
    }

    for (my $s = 1; $s <= 1; $s++) {
        build_AHDC_ncells_4($s);
    }
}

# Cells for each superlayer
sub build_AHDC_ncells_0 {
    my $layer = shift;
    my $mother = "ahdc_mother";

    for (my $n = 1; $n <= $ncells_0; $n++) {
        for (my $subcell = 1; $subcell <= 2; $subcell++) {
            my %detector = init_det();

            my $vname = "superlayer1_layer" . $layer . "_ahdccell" . $n . "_subcell" . $subcell;
            $detector{"name"} = $vname;
            $detector{"mother"} = $mother;
            $detector{"pos"} = "0.0*mm 0.0*mm 0.0*mm";
            $detector{"rotation"} = $rotations->{$vname};
            $detector{"type"} = $types->{$vname};
            $detector{"dimensions"} = $dimensions->{$vname};
            $detector{"description"} = "AHDCcell $n Subcell $subcell";

            if ($layer == 1) {
                $detector{"color"} = "aa00ff";
            }
            else {
                if ($layer == 2) {$detector{"color"} = "ff11aa";}
            }

            $detector{"material"} = "AHDCgas";
            $detector{"mfield"} = "no";
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            $detector{"sensitivity"} = "ahdc";
            $detector{"hit_type"} = "ahdc";
            # set the identifiers
            $detector{"identifiers"} = "superlayer manual 1 layer manual $layer ahdccell manual $n side manual 0 ";
            print_det(\%main::configuration, \%detector);
        }
    }
}

sub build_AHDC_ncells_1 {
    my $layer = shift;
    my $mother = "ahdc_mother";

    for (my $n = 1; $n <= $ncells_1; $n++) {
        for (my $subcell = 1; $subcell <= 2; $subcell++) {
            my %detector = init_det();

            my $vname = "superlayer2_layer" . $layer . "_ahdccell" . $n . "_subcell" . $subcell;
            $detector{"name"} = $vname;
            $detector{"mother"} = $mother;
            $detector{"pos"} = "0.0*mm 0.0*mm 0.0*mm";
            $detector{"rotation"} = $rotations->{$vname};
            $detector{"type"} = $types->{$vname};
            $detector{"dimensions"} = $dimensions->{$vname};
            $detector{"description"} = "AHDCcell $n Subcell $subcell";

            if ($layer == 1) {
                $detector{"color"} = "aa00ff";
            }
            else {
                if ($layer == 2) {$detector{"color"} = "ff11aa";}
            }

            $detector{"material"} = "AHDCgas";
            $detector{"mfield"} = "no";
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            $detector{"sensitivity"} = "ahdc";
            $detector{"hit_type"} = "ahdc";
            # set the identifiers
            $detector{"identifiers"} = "superlayer manual 2 layer manual $layer ahdccell manual $n side manual 0 ";
            print_det(\%main::configuration, \%detector);
        }
    }
}

sub build_AHDC_ncells_2 {
    my $layer = shift;
    my $mother = "ahdc_mother";

    for (my $n = 1; $n <= $ncells_2; $n++) {
        for (my $subcell = 1; $subcell <= 2; $subcell++) {
            my %detector = init_det();

            my $vname = "superlayer3_layer" . $layer . "_ahdccell" . $n . "_subcell" . $subcell;
            $detector{"name"} = $vname;
            $detector{"mother"} = $mother;
            $detector{"pos"} = "0.0*mm 0.0*mm 0.0*mm";
            $detector{"rotation"} = $rotations->{$vname};
            $detector{"type"} = $types->{$vname};
            $detector{"dimensions"} = $dimensions->{$vname};
            $detector{"description"} = "AHDCcell $n Subcell $subcell";

            if ($layer == 1) {
                $detector{"color"} = "aa00ff";
            }
            else {
                if ($layer == 2) {$detector{"color"} = "ff11aa";}
            }

            $detector{"material"} = "AHDCgas";
            $detector{"mfield"} = "no";
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            $detector{"sensitivity"} = "ahdc";
            $detector{"hit_type"} = "ahdc";
            # set the identifiers
            $detector{"identifiers"} = "superlayer manual 3 layer manual $layer ahdccell manual $n side manual 0 ";
            print_det(\%main::configuration, \%detector);
        }
    }
}

sub build_AHDC_ncells_3 {
    my $layer = shift;
    my $mother = "ahdc_mother";

    for (my $n = 1; $n <= $ncells_3; $n++) {
        for (my $subcell = 1; $subcell <= 2; $subcell++) {
            my %detector = init_det();

            my $vname = "superlayer4_layer" . $layer . "_ahdccell" . $n . "_subcell" . $subcell;
            $detector{"name"} = $vname;
            $detector{"mother"} = $mother;
            $detector{"pos"} = "0.0*mm 0.0*mm 0.0*mm";
            $detector{"rotation"} = $rotations->{$vname};
            $detector{"type"} = $types->{$vname};
            $detector{"dimensions"} = $dimensions->{$vname};
            $detector{"description"} = "AHDCcell $n Subcell $subcell";

            if ($layer == 1) {
                $detector{"color"} = "aa00ff";
            }
            else {
                if ($layer == 2) {$detector{"color"} = "ff11aa";}
            }

            $detector{"material"} = "AHDCgas";
            $detector{"mfield"} = "no";
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            $detector{"sensitivity"} = "ahdc";
            $detector{"hit_type"} = "ahdc";
            # set the identifiers
            $detector{"identifiers"} = "superlayer manual 4 layer manual $layer ahdccell manual $n side manual 0 ";
            print_det(\%main::configuration, \%detector);
        }
    }
}

sub build_AHDC_ncells_4 {
    my $layer = shift;
    my $mother = "ahdc_mother";

    for (my $n = 1; $n <= $ncells_4; $n++) {
        for (my $subcell = 1; $subcell <= 2; $subcell++) {
            my %detector = init_det();

            my $vname = "superlayer5_layer" . $layer . "_ahdccell" . $n . "_subcell" . $subcell;
            $detector{"name"} = $vname;
            $detector{"mother"} = $mother;
            $detector{"pos"} = "0.0*mm 0.0*mm 0.0*mm";
            $detector{"rotation"} = $rotations->{$vname};
            $detector{"type"} = $types->{$vname};
            $detector{"dimensions"} = $dimensions->{$vname};
            $detector{"description"} = "AHDCcell $n Subcell $subcell";

            if ($layer == 1) {
                $detector{"color"} = "aa00ff";
            }
            else {
                if ($layer == 2) {$detector{"color"} = "ff11aa";}
            }

            $detector{"material"} = "AHDCgas";
            $detector{"mfield"} = "no";
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            $detector{"sensitivity"} = "ahdc";
            $detector{"hit_type"} = "ahdc";
            # set the identifiers
            $detector{"identifiers"} = "superlayer manual 5 layer manual $layer ahdccell manual $n side manual 0 ";
            print_det(\%main::configuration, \%detector);
        }
    }
}

1;
