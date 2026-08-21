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

sub makeMUCAL {

    ($mothers, $positions, $rotations, $types, $dimensions, $ids) = @main::volumes;

    $panel1a_n = 143;#$main::parameters{"mucal.panel1a.ncounters"};
    # $panel1b_n = $main::parameters{"mucal.panel1b.ncounters"};
    # $panel2_n = $main::parameters{"mucal.panel2.ncounters"};

    define_mothers();
    build_counters();
}

# define mucal sectors
sub define_mothers {
    for (my $s = 1; $s <= 1; $s++) {
        build_panel1a_mother($s);
        # build_panel1b_mother($s);
        # build_panel2_mother($s);
    }
}

sub build_panel1a_mother {
    my $sector = shift;
#    my $dimen = "0.0*deg 360*deg 4*counts 301*mm 72.8*mm 81.5*mm 98.7*mm 301.1*mm 360.6*mm 401*mm 98.8*mm 520*mm 625*mm 696*mm 836*mm ";
   
	my %detector = init_det();
	# $detector{"name"}        = "ddvcs_ecal";
	# $detector{"mother"}      = "root";
	# $detector{"description"} = "volume containing PbWO4";
	# $detector{"color"}       = "555599";
	# $detector{"type"}        = "Polycone";
	# $detector{"dimensions"}  = $dimen;
	# $detector{"material"}    = "G4_AIR";
    # $detector{"visible"} = 0;
	# $detector{"style"}       = "1";
    my $vname = "mucalVolume";
    if($mothers->{$vname} eq "root"){
    $detector{"name"} = $vname;
    $detector{"mother"} = $mothers->{$vname};
    $detector{"pos"} = $positions->{$vname};
    $detector{"rotation"} = $rotations->{$vname};
    $detector{"type"} = $types->{$vname};
    $detector{"dimensions"} = $dimensions->{$vname};

    $detector{"description"} = "Forward MUCAL - Panel 1a - Sector " . $sector;
    $detector{"color"} = "555599";
    $detector{"material"} = "G4_AIR";
    $detector{"mfield"} = "no";
    $detector{"ncopy"} = "1";
    $detector{"visible"} = 0;
    $detector{"style"} = 0;
    print_det(\%main::configuration, \%detector);
    }
}

# Paddles
sub build_counters {
    for (my $s = 1; $s <= 1; $s++) {
        build_panel1a_counters($s);
        # build_panel1b_counters($s);
        # build_panel2_counters($s);
    }
}

sub build_panel1a_counters {
    my $sector = shift;
    my $mother = "mucalVolume";

    for (my $n = 100; $n <= $panel1a_n; $n++) {
        for(my $m = 100; $m <= $panel1a_n;$m++){
        my %detector = init_det();

        my $vname = "mucal_$n" . "_" . $m;
        if(($mothers->{$vname} // "") eq "mucalVolume"){
            $detector{"name"} = $vname;
            $detector{"mother"} = $mothers->{$vname};
            $detector{"pos"} = $positions->{$vname};
            $detector{"rotation"} = $rotations->{$vname};
            $detector{"type"} = $types->{$vname};
            $detector{"dimensions"} = $dimensions->{$vname};

            $detector{"description"} = "paddle $n - Panel 1B - Sector $sector";
            $detector{"color"} = "ff11aa";
            $detector{"material"} = "G4_PbWO4";
            $detector{"mfield"} = "no";
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            $detector{"sensitivity"} = "mucal";
            $detector{"hit_type"} = "mucal";
            $detector{"identifiers"} = "sector manual $sector panel manual 1";
            print_det(\%main::configuration, \%detector);
        }
        
        }
    }
}




1;
