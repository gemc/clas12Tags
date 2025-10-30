use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;
our %parameters;

our $startS;
our $endS;
our $startN;
our $endN;

our @rga_spring2018_sectorsPresence;
our @rga_spring2018_materials;

our @rga_fall2018_sectorsPresence;
our @rga_fall2018_materials;

our @rgb_winter2020_sectorsPresence;
our @rgb_winter2020_materials;

our @rgb_spring2019_sectorsPresence;
our @rgb_spring2019_materials;

our @rgm_fall2021_H_sectorsPresence;
our @rgm_fall2021_H_materials;

# number of mirrors
my $nmirrors = $parameters{"nmirrors"};

my @fangle = ();

sub buildLtccFrame {
    calculateFramePars();
    build_LtccFrame();

}

sub calculateFramePars {
    for (my $n = 0; $n < $nmirrors; $n++) {
        my $s = $n + 1;

        $fangle[$s] = ($s - 2) * 60; # rotation angle of the ltcc frame for each sectors

    }

}

sub build_LtccFrame {
    my $configuration_string = clas12_configuration_string(\%configuration);

    for (my $s = $startS; $s <= $endS; $s++) {

        my $shouldPrintDetector = 0;

            if ($configuration_string eq "default") {
                $shouldPrintDetector = 1;
            }
            elsif ($configuration_string eq "rga_spring2018") {
                if ($rga_spring2018_sectorsPresence[$s - 1] == 1) {
                    $shouldPrintDetector = 1;
                }
            }
            elsif ($configuration_string eq "rga_fall2018") {
                if ($rga_fall2018_sectorsPresence[$s - 1] == 1) {
                    $shouldPrintDetector = 1;
                }
            }
            elsif ($configuration_string eq "rgb_winter2020") {
                if ($rgb_winter2020_sectorsPresence[$s - 1] == 1) {
                    $shouldPrintDetector = 1;
                }
            }
            elsif ($configuration_string eq "rgb_spring2019") {
                if ($rgb_spring2019_sectorsPresence[$s - 1] == 1) {
                    $shouldPrintDetector = 1;
                }
            }
            elsif ($configuration_string eq "rgm_fall2021_H") {
                if ($rgm_fall2021_H_sectorsPresence[$s - 1] == 1) {
                    $shouldPrintDetector = 1;
                }
            }

        # all the hardware STL is in S3 so let's not duplicate that
        if ($s == 3) {
            $shouldPrintDetector = 0;
        }

        if ($shouldPrintDetector == 1) {

            # temp removing back panel
            my %detector = init_det();
            $detector{"name"} = "frame1_s$s";
            $detector{"mother"} = "root";
            $detector{"description"} = "ltcc frame $s";
            $detector{"pos"} = "0*cm 0*cm 1273.7*mm";
            $detector{"rotation"} = "180*deg 0*deg $fangle[$s]*deg";
            $detector{"color"} = "ccccdd";
            $detector{"type"} = "CopyOf S1-BW";
            $detector{"material"} = "G4_STAINLESS-STEEL";
            $detector{"style"} = 1;
            #print_det(\%configuration, \%detector);

            %detector = init_det();
            $detector{"name"} = "frame2_s$s";
            $detector{"mother"} = "root";
            $detector{"description"} = "ltcc frame $s";
            $detector{"pos"} = "0*cm 0*cm 1273.7*mm";
            $detector{"rotation"} = "180*deg 0*deg $fangle[$s]*deg";
            $detector{"color"} = "ccccdd";
            $detector{"type"} = "CopyOf S1-BB";
            $detector{"material"} = "G4_STAINLESS-STEEL";
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);

            %detector = init_det();
            $detector{"name"} = "frame3_s$s";
            $detector{"mother"} = "root";
            $detector{"description"} = "ltcc frame $s";
            $detector{"pos"} = "0*cm 0*cm 1273.7*mm";
            $detector{"rotation"} = "180*deg 0*deg $fangle[$s]*deg";
            $detector{"color"} = "ccccdd";
            $detector{"type"} = "CopyOf S1-BRB";
            $detector{"material"} = "G4_STAINLESS-STEEL";
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);

            # temp removing side panels
            %detector = init_det();
            $detector{"name"} = "frame4_s$s";
            $detector{"mother"} = "root";
            $detector{"description"} = "ltcc frame $s";
            $detector{"pos"} = "0*cm 0*cm 1273.7*mm";
            $detector{"rotation"} = "180*deg 0*deg $fangle[$s]*deg";
            $detector{"color"} = "ccccdd";
            $detector{"type"} = "CopyOf S1-LW ";
            $detector{"material"} = "G4_STAINLESS-STEEL";
            $detector{"style"} = 1;
            #print_det(\%configuration, \%detector);

            %detector = init_det();
            $detector{"name"} = "frame5_s$s";
            $detector{"mother"} = "root";
            $detector{"description"} = "ltcc frame $s";
            $detector{"pos"} = "0*cm 0*cm 1273.7*mm";
            $detector{"rotation"} = "180*deg 0*deg $fangle[$s]*deg";
            $detector{"color"} = "ccccdd";
            $detector{"type"} = "CopyOf S1-RW";
            $detector{"material"} = "G4_STAINLESS-STEEL";
            $detector{"style"} = 1;
            #print_det(\%configuration, \%detector);

            %detector = init_det();
            $detector{"name"} = "frame6_s$s";
            $detector{"mother"} = "root";
            $detector{"description"} = "ltcc frame $s";
            $detector{"pos"} = "0*cm 0*cm 1273.7*mm";
            $detector{"rotation"} = "180*deg 0*deg $fangle[$s]*deg";
            $detector{"color"} = "ccccdd";
            $detector{"type"} = "CopyOf S1-TB";
            $detector{"material"} = "G4_STAINLESS-STEEL";
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);

            # temp removed, giving overlaps
            %detector = init_det();
            $detector{"name"} = "frame7_s$s";
            $detector{"mother"} = "root";
            $detector{"description"} = "ltcc frame $s";
            $detector{"pos"} = "0*cm 0*cm 1273.7*mm";
            $detector{"rotation"} = "180*deg 0*deg $fangle[$s]*deg";
            $detector{"color"} = "ccccdd";
            $detector{"type"} = "CopyOf S1-TRB";
            $detector{"material"} = "G4_STAINLESS-STEEL";
            $detector{"style"} = 1;
            # print_det(\%configuration, \%detector);

            %detector = init_det();
            $detector{"name"} = "frame8_s$s";
            $detector{"mother"} = "root";
            $detector{"description"} = "ltcc frame $s";
            $detector{"pos"} = "0*cm 0*cm 1273.7*mm";
            $detector{"rotation"} = "180*deg 0*deg $fangle[$s]*deg";
            $detector{"color"} = "ccccdd";
            $detector{"type"} = "CopyOf S1-TLB";
            $detector{"material"} = "G4_STAINLESS-STEEL";
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);

            %detector = init_det();
            $detector{"name"} = "frame9_s$s";
            $detector{"mother"} = "root";
            $detector{"description"} = "ltcc frame $s";
            $detector{"pos"} = "0*cm 0*cm 1273.7*mm";
            $detector{"rotation"} = "180*deg 0*deg $fangle[$s]*deg";
            $detector{"color"} = "ccccdd";
            $detector{"type"} = "CopyOf S1-BLB";
            $detector{"material"} = "G4_STAINLESS-STEEL";
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);

        }


        # additional nose hardware
        # temp removed
        if ($shouldPrintDetector == 1 && 0) {

            my $nangle = ($s - 1) * 60; # rotation angle of the ltcc frame for each sectors

            my %detector = init_det();
            $detector{"name"} = "nose1_s$s";
            $detector{"mother"} = "root";
            $detector{"description"} = "ltcc nose piece 1 $s";
            $detector{"pos"} = "0*cm 0*cm 1273.7*mm";
            $detector{"rotation"} = "180*deg 0*deg $nangle*deg";
            $detector{"color"} = "8888aa";
            $detector{"type"} = "CopyOf NFrame";
            $detector{"material"} = "G4_Al";
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);

            %detector = init_det();
            $detector{"name"} = "nose2_s$s";
            $detector{"mother"} = "root";
            $detector{"description"} = "ltcc nose piece 1 $s";
            $detector{"pos"} = "0*cm 0*cm 1273.7*mm";
            $detector{"rotation"} = "180*deg 0*deg $nangle*deg";
            $detector{"color"} = "8888aa";
            $detector{"type"} = "CopyOf FrontPlate";
            $detector{"material"} = "G4_Al";
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);

            %detector = init_det();
            $detector{"name"} = "nose3_s$s";
            $detector{"mother"} = "root";
            $detector{"description"} = "ltcc nose piece 1 $s";
            $detector{"pos"} = "0*cm 0*cm 1273.7*mm";
            $detector{"rotation"} = "180*deg 0*deg $nangle*deg";
            $detector{"color"} = "8888aa";
            $detector{"type"} = "CopyOf Mount";
            $detector{"material"} = "G4_Al";
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);

            %detector = init_det();
            $detector{"name"} = "nose4_s$s";
            $detector{"mother"} = "root";
            $detector{"description"} = "ltcc nose piece 1 $s";
            $detector{"pos"} = "0*cm 0*cm 1273.7*mm";
            $detector{"rotation"} = "180*deg 0*deg $nangle*deg";
            $detector{"color"} = "8888aa";
            $detector{"type"} = "CopyOf Nose";
            $detector{"material"} = "G4_Al";
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);

            %detector = init_det();
            $detector{"name"} = "nose5_s$s";
            $detector{"mother"} = "root";
            $detector{"description"} = "ltcc nose piece 1 $s";
            $detector{"pos"} = "0*cm 0*cm 1273.7*mm";
            $detector{"rotation"} = "180*deg 0*deg $nangle*deg";
            $detector{"color"} = "8888aa";
            $detector{"type"} = "CopyOf BottomPlate";
            $detector{"material"} = "G4_Al";
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);

            %detector = init_det();
            $detector{"name"} = "nose6_s$s";
            $detector{"mother"} = "root";
            $detector{"description"} = "ltcc nose piece 1 $s";
            $detector{"pos"} = "0*cm 0*cm 1273.7*mm";
            $detector{"rotation"} = "180*deg 0*deg $nangle*deg";
            $detector{"color"} = "8888aa";
            $detector{"type"} = "CopyOf Epoxy";
            $detector{"material"} = "G4_CR39";
            $detector{"style"} = 1;
            print_det(\%configuration, \%detector);

        }
    }

}

1;
