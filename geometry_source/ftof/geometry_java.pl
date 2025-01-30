package coatjava;

use strict;
use warnings;

use geometry;

# volumes.pl returns the array of hashes (6 hashes)
# number of entries in each hash is equal to the number of volumes (all mothers+all daughters)
# keys of hashes consist of volume names (constructed in COATJAVA FTOF factory)
# e.g. per each volume with 'volumeName':
# mothers['volumeName'] = 'name of mothervolume'
# positions['volumeName'] = 'x y z'
# rotations['volumeName'] = 'rotationOrder: angleX angleY angleZ' (e.g. 'xyz: 90*deg 90*deg 90*deg')
# types['volumeName'] = 'name of volumeType (Trd, Box etc.)'
# dimensions['volumeName'] = 'dimensions of volume (e.g. 3 values for Box, 5 values for Trd etc.'
# ids['volumeName'] = 'sector# layer# paddle#'
my ($mothers, $positions, $rotations, $types, $dimensions, $ids);

my $panel1a_n;
my $panel1b_n;
my $panel2_n;

sub makeFTOF {

    ($mothers, $positions, $rotations, $types, $dimensions, $ids) = @main::volumes;

    $panel1a_n = $main::parameters{"ftof.panel1a.ncounters"};
    $panel1b_n = $main::parameters{"ftof.panel1b.ncounters"};
    $panel2_n = $main::parameters{"ftof.panel2.ncounters"};

    define_mothers();
    build_counters();
}

# define ftof sectors
sub define_mothers {
    for (my $s = 1; $s <= 6; $s++) {
        build_panel1a_mother($s);
        build_panel1b_mother($s);
        build_panel2_mother($s);
    }
}

sub build_panel1a_mother {
    my $sector = shift;

    my %detector = init_det();

    my $vname = "ftof_p1a_s" . $sector;
    $detector{"name"} = $vname;
    $detector{"mother"} = $mothers->{$vname};
    $detector{"pos"} = $positions->{$vname};
    $detector{"rotation"} = $rotations->{$vname};
    $detector{"type"} = $types->{$vname};
    $detector{"dimensions"} = $dimensions->{$vname};

    $detector{"description"} = "Forward TOF - Panel 1a - Sector " . $sector;
    $detector{"color"} = "000000";
    $detector{"material"} = "G4_AIR";
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = "1";
    $detector{"visible"} = 0;
    $detector{"style"} = 0;
    print_det(\%main::configuration, \%detector);
}

sub build_panel1b_mother {
    my $sector = shift;

    my %detector = init_det();

    my $vname = "ftof_p1b_s" . $sector;
    $detector{"name"} = $vname;
    $detector{"mother"} = $mothers->{$vname};
    $detector{"pos"} = $positions->{$vname};
    $detector{"rotation"} = $rotations->{$vname};
    $detector{"type"} = $types->{$vname};
    $detector{"dimensions"} = $dimensions->{$vname};

    $detector{"description"} = "Forward TOF - Panel 1b - Sector " . $sector;
    $detector{"color"} = "000000";
    $detector{"material"} = "G4_AIR";
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = "1";
    $detector{"visible"} = 0;
    $detector{"style"} = 0;
    print_det(\%main::configuration, \%detector);
}

sub build_panel2_mother {
    my $sector = shift;

    my %detector = init_det();

    my $vname = "ftof_p2_s" . $sector;
    $detector{"name"} = $vname;
    $detector{"mother"} = $mothers->{$vname};
    $detector{"pos"} = $positions->{$vname};
    $detector{"rotation"} = $rotations->{$vname};
    $detector{"type"} = $types->{$vname};
    $detector{"dimensions"} = $dimensions->{$vname};

    $detector{"description"} = "Forward TOF - Panel 2 - Sector " . $sector;
    $detector{"color"} = "000000";
    $detector{"material"} = "G4_AIR";
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = "1";
    $detector{"visible"} = 0;
    $detector{"style"} = 0;
    print_det(\%main::configuration, \%detector);
}

# Paddles
sub build_counters {
    for (my $s = 1; $s <= 6; $s++) {
        build_panel1a_counters($s);
        build_panel1b_counters($s);
        build_panel2_counters($s);
    }
}

sub build_panel1a_counters {
    my $sector = shift;
    my $mother = "ftof_p1a_s" . $sector;

    for (my $n = 1; $n <= $panel1a_n; $n++) {
        my %detector = init_det();

        my $vname = "panel1a_sector$sector" . "_paddle_" . $n;
        $detector{"name"} = $vname;
        $detector{"mother"} = $mothers->{$vname};
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"type"} = $types->{$vname};
        $detector{"dimensions"} = $dimensions->{$vname};

        $detector{"description"} = "paddle $n - Panel 1B - Sector $sector";
        $detector{"color"} = "ff11aa";
        $detector{"material"} = "scintillator";
        $detector{"mfield"} = "no";
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        $detector{"sensitivity"} = "ftof";
        $detector{"hit_type"} = "ftof";
        $detector{"identifiers"} = "sector manual $sector panel manual 1 paddle manual $n side manual 0";
        print_det(\%main::configuration, \%detector);
    }
}

sub build_panel1b_counters {
    my $sector = shift;
    my $mother = "ftof_p1b_s" . $sector;

    for (my $n = 1; $n <= $panel1b_n; $n++) {
        my %detector = init_det();

        my $vname = "panel1b_sector$sector" . "_paddle_" . $n;
        $detector{"name"} = $vname;
        $detector{"mother"} = $mothers->{$vname};
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"type"} = $types->{$vname};
        $detector{"dimensions"} = $dimensions->{$vname};

        $detector{"description"} = "paddle $n - Panel 1B - Sector $sector";
        $detector{"color"} = "11ffaa";
        $detector{"material"} = "scintillator";
        $detector{"mfield"} = "no";
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        $detector{"sensitivity"} = "ftof";
        $detector{"hit_type"} = "ftof";
        $detector{"identifiers"} = "sector manual $sector panel manual 2 paddle manual $n side manual 0";
        print_det(\%main::configuration, \%detector);
    }
}

sub build_panel2_counters {
    my $sector = shift;
    my $mother = "ftof_p2_s" . $sector;

    for (my $n = 1; $n <= $panel2_n; $n++) {
        my %detector = init_det();

        my $vname = "panel2_sector$sector" . "_paddle_" . $n;
        $detector{"name"} = $vname;
        $detector{"mother"} = $mothers->{$vname};
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"type"} = $types->{$vname};
        $detector{"dimensions"} = $dimensions->{$vname};

        $detector{"description"} = "paddle $n - Panel 2 - Sector $sector";
        $detector{"color"} = "ff11aa";
        $detector{"material"} = "scintillator";
        $detector{"mfield"} = "no";
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        $detector{"sensitivity"} = "ftof";
        $detector{"hit_type"} = "ftof";
        $detector{"identifiers"} = "sector manual $sector  panel manual 3  paddle manual $n side manual 0";
        print_det(\%main::configuration, \%detector);
    }
}

sub make_pb {
    # loop over sectors
    for (my $isect = 0; $isect < 6; $isect++) {
        my $sector = $isect + 1;

        my @panels = ("1a", "2");
        foreach my $pan (@panels) {
            my %detector = init_det();

            my $vname = "ftof_shield_p$pan" . "_sector$sector";
            $detector{"name"} = $vname;
            $detector{"mother"} = $mothers->{$vname};
            $detector{"pos"} = $positions->{$vname};
            $detector{"rotation"} = $rotations->{$vname};
            $detector{"type"} = $types->{$vname};
            $detector{"dimensions"} = $dimensions->{$vname};

            $detector{"description"} = "Layer of lead - layer $pan - Sector $sector";
            $detector{"color"} = "dc143c";
            $detector{"material"} = "G4_Pb";
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            print_det(\%main::configuration, \%detector);
        }
    }
}

1;
