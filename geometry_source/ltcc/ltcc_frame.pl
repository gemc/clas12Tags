use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;

our $startS;
our $endS;

our @rga_spring2018_sectorsPresence;
our @rga_fall2018_sectorsPresence;
our @rgb_spring2020_sectorsPresence;
our @rgb_spring2019_sectorsPresence;
our @rgm_fall2021_H_sectorsPresence;


sub buildLtccFrame {
    my $configuration_string = clas12_configuration_string(\%configuration);

    my @frame_parts = (
        ["backwall",  "G4_Al",     "ccccdd", "180*deg 0*deg 30*deg"],
        ["rightwall", "G4_Al",     "ccddcc", "180*deg 0*deg 30*deg"],
        ["leftwall",  "G4_Al",     "ccddee", "180*deg 0*deg 30*deg"],
        ["nose",      "ltcc_nose", "cc8844", "180*deg 0*deg 90*deg"],
    );

    for (my $sector = $startS; $sector <= $endS; $sector++) {
        my $sector_present = 0;

        if ($configuration_string eq "default") {
            $sector_present = 1;
        }
        elsif ($configuration_string eq "rga_spring2018") {
            $sector_present = $rga_spring2018_sectorsPresence[$sector - 1];
        }
        elsif ($configuration_string eq "rga_fall2018") {
            $sector_present = $rga_fall2018_sectorsPresence[$sector - 1];
        }
        elsif ($configuration_string eq "rgb_spring2020") {
            $sector_present = $rgb_spring2020_sectorsPresence[$sector - 1];
        }
        elsif ($configuration_string eq "rgb_spring2019") {
            $sector_present = $rgb_spring2019_sectorsPresence[$sector - 1];
        }
        elsif ($configuration_string eq "rgm_fall2021_H") {
            $sector_present = $rgm_fall2021_H_sectorsPresence[$sector - 1];
        }

        # The mesh-backed source volumes are placed in sector 3 by cad_<variation>.gxml.
        next if !$sector_present || $sector == 3;

        foreach my $part (@frame_parts) {
            my ($source, $material, $color, $rotation) = @{$part};

            my %detector = init_det();
            $detector{"name"} = "${source}_s$sector";
            $detector{"mother"} = "ltccS$sector";
            $detector{"description"} = "LTCC sector $sector $source CAD copy";
            $detector{"pos"} = "0*mm 0*mm -699.3*mm";
            $detector{"rotation"} = $rotation;
            $detector{"color"} = $color;
            $detector{"type"} = "CopyOf $source";
            $detector{"material"} = $material;
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);
        }
    }
}

1;
