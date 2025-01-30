# Written by Andrey Kim (kenjo@jlab.org)
package coatjava;

use strict;
use warnings;
use POSIX;

use geometry;

my $mothers;
my $positions;
my $rotations;
my $types;
my $dimensions;
my $ids;

my $nlayers = 15;
my $nviews = 5;

sub define_mothers {
    for (my $s = 1; $s <= 6; $s++) {
        build_mother($s);
    }
}

### PCAL Mother Volume ###
sub build_mother {
    my $sector = shift;
    my %detector = init_det();
    my $vname = "pcal_s${sector}";

    $detector{"name"} = $vname;
    $detector{"mother"} = $mothers->{$vname};
    $detector{"pos"} = $positions->{$vname};
    $detector{"rotation"} = $rotations->{$vname};
    $detector{"type"} = $types->{$vname};
    $detector{"dimensions"} = $dimensions->{$vname};

    $detector{"description"} = "Preshower Calorimeter";
    $detector{"color"} = "ff1111";
    $detector{"material"} = "G4_AIR";
    $detector{"visible"} = 0;

    print_det(\%main::configuration, \%detector);
}

sub define_leadlayers() {
    for (my $s = 1; $s <= 6; $s++) {
        build_lead($s);
    }
}


### Lead Layers ###
sub build_lead {
    my $sector = shift;
    for (my $i = 1.0; $i < $nlayers; $i++) {
        my %detector = init_det();
        my $vname = "PCAL_Lead_Layer_${i}_s${sector}";

        $detector{"name"} = $vname;
        $detector{"mother"} = $mothers->{$vname};
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"type"} = $types->{$vname};
        $detector{"dimensions"} = $dimensions->{$vname};

        $detector{"description"} = "Preshower Calorimeter lead layer ${i}";
        $detector{"color"} = "66ff33";
        $detector{"material"} = "G4_Pb";
        $detector{"ncopy"} = $i;
        $detector{"style"} = 1;

        print_det(\%main::configuration, \%detector);
    }
}

sub define_Ulayers {
    for (my $s = 1; $s <= 6; $s++) {
        build_U_mother($s);
        build_U_single_strips($s);
    }
}

# hipo:
# layer=1-3 (PCAL) 4-9 (ECAL)
# view: u,v,w = 1,2,3. This also correspond to layer number

### U Layers ###
sub build_U_mother {
    my $sector = shift;

    for (my $k = 1.0; $k <= $nlayers; $k += 3) {
        my %detector = init_det();
        my $vname = "U-view-scintillator_${k}_s${sector}";

        $detector{"name"} = $vname;
        $detector{"mother"} = $mothers->{$vname};
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"type"} = $types->{$vname};
        $detector{"dimensions"} = $dimensions->{$vname};

        $detector{"description"} = "Preshower Calorimeter";
        $detector{"color"} = "ff6633";
        $detector{"material"} = "G4_TITANIUM_DIOXIDE";
        $detector{"ncopy"} = $k;

        print_det(\%main::configuration, \%detector);
    }
}

sub build_U_single_strips {
    my $sector = shift;
    my $nsingles = 52;
    my $nstrips = 84;
    my $ndoubles = ($nstrips - $nsingles) / 2;

    for (my $iview = 1.0; $iview <= $nviews; $iview++) {
        for (my $strip = 0; $strip <= $nstrips; $strip++) {
            my %detector = init_det();
            my $vname = "U-view_single_strip_${iview}_${strip}_s${sector}";

            $detector{"name"} = $vname;
            $detector{"mother"} = $mothers->{$vname};
            $detector{"pos"} = $positions->{$vname};
            $detector{"rotation"} = $rotations->{$vname};
            $detector{"type"} = $types->{$vname};
            $detector{"dimensions"} = $dimensions->{$vname};

            $detector{"description"} = "Preshower Calorimeter scintillator layer 1 strip";
            $detector{"color"} = "ff6633";
            $detector{"material"} = "scintillator";

            if ($strip == 0) {
                $detector{"style"} = 1;
            }
            else {
                my $strip_no = ($iview - 1) * $nsingles + $strip;
                my $strip_id = $strip;
                if ($strip > $nsingles) {
                    my $idouble = ceil(($strip - $nsingles) / 2);
                    $strip_no = $ndoubles * $iview - $idouble + 1;
                    $strip_id = $idouble + $nsingles;
                }

                $detector{"sensitivity"} = "ecal";
                $detector{"hit_type"} = "ecal";
                $detector{"ncopy"} = $strip_no;
                $detector{"identifiers"} = "sector manual $sector layer manual 1 strip manual $strip_id";
            }
            print_det(\%main::configuration, \%detector);
        }
    }
}

sub define_Vlayers {
    for (my $s = 1; $s <= 6; $s++) {
        build_V_mother($s);
        build_V_single_strips($s);
    }
}

sub build_V_single_strips {
    my $sector = shift;
    my $nsingles = 47;
    my $nstrips = 77;
    my $ndoubles = $nstrips - $nsingles;
    my $ncouples = $ndoubles / 2;

    for (my $iview = 1.0; $iview <= $nviews; $iview++) {
        for (my $strip = 0; $strip <= $nstrips; $strip++) {
            my %detector = init_det();
            my $vname = "V-view_single_strip_${iview}_${strip}_s${sector}";

            $detector{"name"} = $vname;
            $detector{"mother"} = $mothers->{$vname};
            $detector{"pos"} = $positions->{$vname};
            $detector{"rotation"} = $rotations->{$vname};
            $detector{"type"} = $types->{$vname};
            $detector{"dimensions"} = $dimensions->{$vname};

            $detector{"description"} = "Preshower Calorimeter scintillator layer 2 strip";
            $detector{"color"} = "6600ff";
            $detector{"material"} = "scintillator";

            if ($strip == 0) {
                $detector{"style"} = 1;
            }
            else {
                my $idouble = ceil($strip / 2);
                my $strip_no = $ncouples * ($iview - 1) + $idouble;
                my $strip_id = $idouble;

                if ($strip > $ndoubles) {
                    $strip_no = ($iview - 1) * $nsingles + ($strip - $ndoubles);
                    $strip_id = $strip - $ncouples;
                }

                $detector{"sensitivity"} = "ecal";
                $detector{"hit_type"} = "ecal";
                $detector{"ncopy"} = $strip_no;
                $detector{"identifiers"} = "sector manual $sector layer manual 2 strip manual $strip_id";
            }
            print_det(\%main::configuration, \%detector);
        }
    }
}

sub build_V_mother {
    my $sector = shift;
    for (my $k = 2.0; $k <= $nlayers; $k += 3) {
        my %detector = init_det();
        my $vname = "V-view-scintillator_${k}_s${sector}";

        $detector{"name"} = $vname;
        $detector{"mother"} = $mothers->{$vname};
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"type"} = $types->{$vname};
        $detector{"dimensions"} = $dimensions->{$vname};

        $detector{"description"} = "Preshower Calorimeter";
        $detector{"color"} = "33ffcc";
        $detector{"material"} = "G4_TITANIUM_DIOXIDE";
        $detector{"ncopy"} = $k;

        print_det(\%main::configuration, \%detector);
    }
}

sub define_Wlayers {
    for (my $s = 1; $s <= 6; $s++) {
        build_W_mother($s);
        build_W_single_strips($s);
    }
}

sub build_W_single_strips {
    my $sector = shift;
    my $nsingles = 47;
    my $nstrips = 77;
    my $ndoubles = $nstrips - $nsingles;
    my $ncouples = $ndoubles / 2;

    for (my $iview = 1.0; $iview <= $nviews; $iview++) {
        for (my $strip = 0; $strip <= $nstrips; $strip++) {
            my %detector = init_det();
            my $vname = "W-view_single_strip_${iview}_${strip}_s${sector}";

            $detector{"name"} = $vname;
            $detector{"mother"} = $mothers->{$vname};
            $detector{"pos"} = $positions->{$vname};
            $detector{"rotation"} = $rotations->{$vname};
            $detector{"type"} = $types->{$vname};
            $detector{"dimensions"} = $dimensions->{$vname};

            $detector{"description"} = "Preshower Calorimeter scintillator layer 3 strip";
            $detector{"color"} = "6600ff";
            $detector{"material"} = "scintillator";

            if ($strip == 0) {
                $detector{"style"} = 1;
            }
            else {
                my $idouble = ceil($strip / 2);
                my $strip_no = $ncouples * ($iview - 1) + $idouble;
                my $strip_id = $idouble;

                if ($strip > $ndoubles) {
                    $strip_no = ($iview - 1) * $nsingles + ($strip - $ndoubles);
                    $strip_id = $strip - $ncouples;
                }

                $detector{"sensitivity"} = "ecal";
                $detector{"hit_type"} = "ecal";
                $detector{"ncopy"} = $strip_no;
                $detector{"identifiers"} = "sector manual $sector layer manual 3 strip manual $strip_id";
            }
            print_det(\%main::configuration, \%detector);
        }
    }
}

sub build_W_mother {
    my $sector = shift;
    for (my $k = 3.0; $k <= $nlayers; $k += 3) {
        my %detector = init_det();
        my $vname = "W-view-scintillator_${k}_s${sector}";

        $detector{"name"} = $vname;
        $detector{"mother"} = $mothers->{$vname};
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"type"} = $types->{$vname};
        $detector{"dimensions"} = $dimensions->{$vname};

        $detector{"description"} = "Preshower Calorimeter";
        $detector{"color"} = "33ffcc";
        $detector{"material"} = "G4_TITANIUM_DIOXIDE";
        $detector{"ncopy"} = $k;

        print_det(\%main::configuration, \%detector);
    }
}

sub define_frontback_components {
    for (my $s = 1; $s <= 6; $s++) {
        build_front_steel($s);
        build_back_steel($s);

        build_front_foam($s);
        build_back_foam($s);
    }
}

### Front Stainless Steel Window ###
sub build_front_steel {
    my $sector = shift;
    for (my $k = 1.0; $k <= 2; $k++) {
        my %detector = init_det();
        my $vname = "Stainless_Steel_Front_${k}_s${sector}";

        $detector{"name"} = $vname;
        $detector{"mother"} = $mothers->{$vname};
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"type"} = $types->{$vname};
        $detector{"dimensions"} = $dimensions->{$vname};

        $detector{"description"} = "Front Window";
        $detector{"color"} = "D4E3EE";
        $detector{"material"} = "G4_STAINLESS-STEEL";
        $detector{"ncopy"} = $k;
        $detector{"style"} = 1;

        print_det(\%main::configuration, \%detector);
    }
}

### Back Stainless Steel Window ###
sub build_back_steel {
    my $sector = shift;
    for (my $k = 1.0; $k <= 2; $k++) {
        my %detector = init_det();
        my $vname = "Stainless_Steel_Back_${k}_s${sector}";

        $detector{"name"} = $vname;
        $detector{"mother"} = $mothers->{$vname};
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"type"} = $types->{$vname};
        $detector{"dimensions"} = $dimensions->{$vname};

        $detector{"description"} = "Back Window";
        $detector{"color"} = "D4E3EE";
        $detector{"material"} = "G4_STAINLESS-STEEL";
        $detector{"ncopy"} = $k;
        $detector{"style"} = 1;

        print_det(\%main::configuration, \%detector);
    }
}


### Front Last-a-Foam Window ###
sub build_front_foam {
    my $sector = shift;

    my %detector = init_det();
    my $vname = "Last-a-Foam_Front_s${sector}";

    $detector{"name"} = $vname;
    $detector{"mother"} = $mothers->{$vname};
    $detector{"pos"} = $positions->{$vname};
    $detector{"rotation"} = $rotations->{$vname};
    $detector{"type"} = $types->{$vname};
    $detector{"dimensions"} = $dimensions->{$vname};

    $detector{"description"} = "Front Foam";
    $detector{"color"} = "EED18C";
    $detector{"material"} = "LastaFoam";
    $detector{"style"} = 1;

    print_det(\%main::configuration, \%detector);

}


### Back Last-a-Foam Window ###
sub build_back_foam {
    my $sector = shift;

    my %detector = init_det();
    my $vname = "Last-a-Foam_Back_s${sector}";

    $detector{"name"} = $vname;
    $detector{"mother"} = $mothers->{$vname};
    $detector{"pos"} = $positions->{$vname};
    $detector{"rotation"} = $rotations->{$vname};
    $detector{"type"} = $types->{$vname};
    $detector{"dimensions"} = $dimensions->{$vname};

    $detector{"description"} = "Back Foam";
    $detector{"color"} = "EED18C";
    $detector{"material"} = "LastaFoam";
    $detector{"style"} = 1;

    print_det(\%main::configuration, \%detector);
}

sub makePCAL {
    ($mothers, $positions, $rotations, $types, $dimensions, $ids) = @main::volumes;

    define_mothers();
    define_leadlayers();
    define_Ulayers();
    define_Vlayers();
    define_Wlayers();
    define_frontback_components();
}

1;
