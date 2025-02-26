use strict;
use warnings;

our %configuration;

my $rmin = 51;
my $rmin_rge = 52.1;
my $length = 180;
my $pos = "0*mm 0*mm -50*mm";

# Adding the neoprene insulation Heat Shield

my $HSrmin = 130.0;
my $HSlength = 270.0;
my $HSpos = "0*mm 0*mm -10*mm";

sub make_bst_shield() {
    my $variation = clas12_configuration_string(\%configuration);

    my %detector = init_det();

    $detector{"name"} = "bstShield";
    $detector{"mother"} = "root";
    $detector{"description"} = "bst shielding";
    $detector{"color"} = "88aaff";
    $detector{"type"} = "Tube";
    $detector{"pos"} = $pos;

    my $rmax = 0;

    if ($variation ne "rge_spring2024") {
        $rmax = $rmin + 0.051;
        $detector{"material"} = "beamline_W";
    }
    else {
        $rmin = $rmin_rge;
        $rmax = $rmin + 0.051;
        $detector{"material"} = "beamline_W";
    }

    my $dimen = "$rmin*mm $rmax*mm $length*mm 0*deg 360*deg";

    $detector{"dimensions"} = $dimen;
    $detector{"visible"} = 1;
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

}