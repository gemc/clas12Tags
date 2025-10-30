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

my $npaddles; # number of paddles in one sector

my $nsectors = 15;
my $nsuperlayers = 2;
my $nlayers;

sub makeATOF {
    ($mothers, $positions, $rotations, $types, $dimensions, $ids) = @main::volumes;

    #$npaddles = $main::parameters{"atof.sector0.superlayer0.layer0.ncomponents"};
    #$npaddles = 4;

    #build_mother();
    build_ATOF_sectors();
}


#sub build_mother
#{

#	my %detector = init_det();
# dimension and position adjusted to englobe the whole ATOF
#	my $vname                = "atof_mother";
#	$detector{"name"}        = $vname;
#	$detector{"mother"}      = "root";
#	$detector{"pos"}         = "0.0*mm 0.0*mm 127.7*mm";
#	$detector{"type"}        = "Tube";
#	$detector{"dimensions"}  = "7.6*cm 10.7*cm 14.0*cm 0.*deg 360.*deg";
#	$detector{"description"} = "Alert Time of flight mother";
#	$detector{"color"}       = "aa00ff";
#	$detector{"material"}    = "G4_AIR";
#	$detector{"mfield"}      = "no";
#	$detector{"ncopy"}       = "1";
#	$detector{"visible"}     = 1; # 0 or 1, 1 for debugging is better
#	$detector{"style"}       = 0;
#	print_det(\%main::configuration, \%detector);
#}


# Sectors/superlayers/layers
sub build_ATOF_sectors {
    # loop for sectors
    for (my $s = 0; $s < $nsectors; $s++) {
        # loop for superlayers in Z
        for (my $z = 0; $z < $nsuperlayers; $z++) {
            $nlayers = 4;
            # loop for layers in XY
            for (my $l = 0; $l < $nlayers; $l++) {
                #$npaddles = $main::parameters{"atof.sector$s.superlayer$z.layer$l.ncomponents"};
                build_ATOF_paddles($s, $z, $l);
            }
        }
    }
}

# Paddles for each sector/superlayer/layer
sub build_ATOF_paddles {
    my $sector = shift;
    my $superlayer = shift;
    my $layer = shift;
    #my $mother = "atof_mother";
    my $mother = "ahdc_mother"; ##???

    my $ncomponents = 10;
    if ($superlayer == 0) {
        $ncomponents = 1;
    }

    for (my $n = 0; $n < $ncomponents; $n++) {
        my %detector = init_det();

        my $component = $n;
        if ($superlayer == 0) {
            $component = 10;
        }

        #print "Sector: $sector\n";
        #print "SL: $superlayer\n";
        #print "Layer: $layer\n";
        #print "Component: $component\n";

        my $vname = "sector" . $sector . "_superlayer" . $superlayer . "_layer" . $layer . "_paddle" . $component;
        $detector{"name"} = $vname;
        $detector{"mother"} = $mother;
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"type"} = $types->{$vname};
        $detector{"dimensions"} = $dimensions->{$vname};
        $detector{"description"} = "ATOFpaddle$component sector$sector superlayer$superlayer layer$layer";

        if ($superlayer == 0) {
            $detector{"color"} = "ff11aa";
        }
        else {
            if ($superlayer == 1) {$detector{"color"} = "00aa00";}
        }

        $detector{"material"} = "atof_scintillator";
        $detector{"mfield"} = "no";
        $detector{"visible"} = 1;
        $detector{"style"} = 1;
        $detector{"sensitivity"} = "atof";
        $detector{"hit_type"} = "atof";
        # set the identifiers
        $detector{"identifiers"} = "sector manual $sector superlayer manual $superlayer layer manual $layer paddle manual $component order manual 0";
        print_det(\%main::configuration, \%detector);
    }
}

1;
