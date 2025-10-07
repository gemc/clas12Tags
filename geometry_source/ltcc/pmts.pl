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

# All dimensions in cm

# PMTS parameters
# PMTs are tubes

#position of pmts in segment
my @x0 = ();
my @y0 = ();
# position of pmts in sector
my @x0_sec = ();
my @y0_sec = ();
my @z0_sec = ();
my @rad = ();    # pmt radius
my @tilt = ();   # Tilt angle of the PMT in the segment ref. system
my @len = ();    # length of PMT tube
my @segphi = (); # required rotation about x axis for pmts, pmts stoppers and shields
my @fangle = ();
my @segtheta = ();     # required rotation about x axis for pmts, pmts stoppers and shields

sub buildPmts {
    calculatePMTPars();
    build_pmts();

}

sub calculatePMTPars {

    for (my $n = 0; $n < $nmirrors; $n++) {
        my $s = $n + 1;

        # All variables defined below take their values from ltcc__parameters_default.txt
        # which can be rewritten by running mirrors.C after adding new variables or editing current variables
        # (one should define them in ltcc.h and io.C and also give the values in ccngeom.dat )

        $x0[$n] = $parameters{"ltcc.pmt.s$s" . "_pmt0x"};
        $y0[$n] = $parameters{"ltcc.pmt.s$s" . "_pmt0y"};
        $rad[$n] = $parameters{"ltcc.pmt.s$s" . "_radius"};
        $x0_sec[$n] = $parameters{"ltcc.pmt.s$s" . "_x"};
        $y0_sec[$n] = $parameters{"ltcc.pmt.s$s" . "_y"};
        $z0_sec[$n] = $parameters{"ltcc.pmt.s$s" . "_z"};
        $tilt[$n] = $parameters{"ltcc.wc.s$s" . "_angle"};
        # 90 - theta of center of ltcc. segment
        $segtheta[$n] = 90 - $parameters{"ltcc.s$s" . "_theta"};
        #phi rotation angle for pmts, pmt stoppers and shield in sectors ! (calculated using their phi rotation angles in segments)
        $segphi[$n] = 90 - $segtheta[$n]; #rotation of pmts in sector
        $len[$n] = 0.1;                   # Hardcoding pmt length here
        $fangle[$s] = ($s - 2) * 60;      # rotation angle of the ltcc frame for each sectors

    }

}

sub build_pmts {

    my $configuration_string = clas12_configuration_string(\%configuration);

    for (my $n = $startN; $n <= $endN; $n++) {
        for (my $s = $startS; $s <= $endS; $s++) {

            # All following geometries are in the LTCC sectors !
            # Right and Left in names correspond to the specific geometries at right side or left side of the sector's center line

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

            if ($shouldPrintDetector == 1) {

                my %detector = init_det();
                $detector{"name"} = "pmt_s$s" . "right_$n";
                $detector{"mother"} = "ltccS$s";
                $detector{"description"} = "PMT right $n";
                $detector{"pos"} = "$x0_sec[$n - 1]*cm $y0_sec[$n - 1]*cm $z0_sec[$n - 1]*cm";
                $detector{"rotation"} = "$segphi[$n - 1]*deg -$tilt[$n - 1]*deg 0*deg";
                $detector{"color"} = "800000";
                $detector{"type"} = "Tube";
                $detector{"dimensions"} = "0*cm $rad[$n - 1]*cm $len[$n - 1]*cm 0*deg 360*deg";
                $detector{"material"} = "LTCCPMTGlass";
                $detector{"style"} = 1;
                $detector{"sensitivity"} = "ltcc";
                $detector{"hit_type"} = "ltcc";
                $detector{"identifiers"} = "sector manual $s side manual 1 segment manual $n";
                print_det(\%configuration, \%detector);

                %detector = init_det();
                $detector{"name"} = "pmt_s$s" . "left_$n";
                $detector{"mother"} = "ltccS$s";
                $detector{"description"} = "PMT left $n";
                $detector{"pos"} = "-$x0_sec[$n - 1]*cm $y0_sec[$n - 1]*cm $z0_sec[$n - 1]*cm";
                $detector{"rotation"} = "$segphi[$n - 1]*deg $tilt[$n - 1]*deg 0*deg";
                $detector{"color"} = "800000";
                $detector{"type"} = "Tube";
                $detector{"dimensions"} = "0*cm $rad[$n - 1]*cm $len[$n - 1]*cm 0*deg 360*deg";
                $detector{"material"} = "LTCCPMTGlass";
                $detector{"style"} = 1;
                $detector{"sensitivity"} = "ltcc";
                $detector{"hit_type"} = "ltcc";
                $detector{"identifiers"} = "sector manual $s side manual 2 segment manual $n";
                print_det(\%configuration, \%detector);

                # To prevent photons getting trapped inside the pmts smaller cylinders (light stoppers) are placed inside the pmts.
                # These light stoppers do not have optical properties unlike pmts.
                my $stopLength = $rad[$n - 1] - 0.01;

                %detector = init_det();
                $detector{"name"} = "pmt_light_stopper_s$s" . "right_$n";
                $detector{"mother"} = "pmt_s$s" . "right_$n";
                $detector{"description"} = "PMT light stopper right $n";
                $detector{"color"} = "558844";
                $detector{"type"} = "Tube";
                $detector{"dimensions"} = "0*cm $stopLength*cm 0.5*cm 0*deg 360*deg";
                $detector{"material"} = "G4_Galactic";
                $detector{"style"} = 1;
                print_det(\%configuration, \%detector);

                %detector = init_det();
                $detector{"name"} = "pmt_light_stopper_s$s" . "left_$n";
                $detector{"mother"} = "pmt_s$s" . "left_$n";
                $detector{"description"} = "PMT light stopper left $n";
                $detector{"color"} = "558844";
                $detector{"type"} = "Tube";
                $detector{"dimensions"} = "0*cm $stopLength*cm 0.5*cm 0*deg 360*deg";
                $detector{"material"} = "G4_Galactic";
                $detector{"style"} = 1;
                print_det(\%configuration, \%detector);

            }

        }

    }

}

1;











