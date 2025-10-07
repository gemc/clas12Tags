use strict;
use warnings;
use Getopt::Long;
use Math::Trig;
use lib ("../");
use clas12_configuration_string;

our %configuration;

sub make_BigGasVolume {
    my %detector = init_det();
    $detector{"name"} = "htccBigGasVolume";
    $detector{"mother"} = "root";
    $detector{"description"} = "volume containing cherenkov gas";
    $detector{"color"} = "ee99ff5";
    $detector{"type"} = "Polycone";
    $detector{"dimensions"} = "0*deg 360*deg 4*counts 0*mm 15.8*mm 91.5*mm 150*mm 1742*mm 2300*mm 2300*mm 1589*mm -275*mm 181*mm 1046*mm 1740*mm";
    $detector{"material"} = "Component";
    print_det(\%configuration, \%detector);
}

sub make_ExitWindow {
    # these dimensions are from the NIM paper
    # thickness is 38 + 75 + 38 microns tedlar mylar tedlar = 151 microns = 0.151 mm
    my $windowThickness = 0.151 / 2.0;
    # inner radius 10.93'' = 277.622 mm
    # outer radius 9.5'    = 2895.6 mm
    # 2 mm added to avoid overlaps
    my $inner_radius = 277.622 / 2.0 + 1.5;
    my $outer_Radius = 2895.6 / 2.0;
    my $zpos = 1750;

    my $configuration_string = clas12_configuration_string(\%configuration);
    if ($configuration_string eq "rga_spring2018") {
        $zpos = $zpos - 10;
    }
    elsif ($configuration_string eq "rga_fall2018") {
        $zpos = $zpos - 19.4;
    }

    my %detector = init_det();
    $detector{"name"} = "htccExitWindow";
    $detector{"mother"} = "root";
    $detector{"description"} = "htcc Exit Window";
    $detector{"color"} = "666655";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm  $zpos*mm";
    $detector{"dimensions"} = "$inner_radius*mm $outer_Radius*mm $windowThickness*mm 0*deg 360*deg";
    $detector{"material"} = "HTCCCompositeWindow";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);
}

sub make_EntryWindow {

    # these dimensions are from the NIM paper
    # thickness is 38 + 75 + 38 microns tedlar mylar tedlar = 151 microns = 0.151 mm
    my $windowThickness = 0.151 / 2;
    # inner radius 1.75'' = 44.45 mm
    # outer radius 2.5'   = 762 mm
    # however the 2 dimenions above do not match the htcc cone
    # so they are adjusted by hand below
    my $inner_radius = 33;
    my $outer_Radius = 278;
    my $zpos = 380;

    my $configuration_string = clas12_configuration_string(\%configuration);
    if ($configuration_string eq "rga_spring2018") {
        $zpos = $zpos - 10;
    }
    elsif ($configuration_string eq "rga_fall2018") {
        $zpos = $zpos - 19.4;
    }

    my %detector = init_det();
    $detector{"name"} = "htccEntryWindow";
    $detector{"mother"} = "root";
    $detector{"description"} = "htcc Entry Window";
    $detector{"color"} = "666655";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm  $zpos*mm";
    $detector{"dimensions"} = "$inner_radius*mm $outer_Radius*mm $windowThickness*mm 0*deg 360*deg";
    $detector{"material"} = "HTCCCompositeWindow";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);
}


# Entry Dish Volume
my $entrydishNumZplanes = 17;
my @entrydishZplanes = (-276.4122, -178.6222, -87.1822, 4.2578, 95.6978,
    187.1378, 278.5778, 370.0178, 461.4578,
    552.8978, 644.3378, 735.7778, 827.2178,
    918.6578, 991.378, 1080.278, 1107.71);

my $entrydishRinner = 0;

my @entrydishRouter = (1416.05, 1410.081, 1404.493, 1398.905,
    1393.317, 1387.729, 1387.729, 1363.4466,
    1339.1388, 1305.8648, 1272.5908, 1239.3168,
    1206.0174, 1158.24, 1105.408, 996.0356,
    945.896);

sub make_entrydishvolume {
    my $dimensions = "0.0*deg 360.0*deg $entrydishNumZplanes*counts";
    for (my $i = 0; $i < $entrydishNumZplanes; $i++) {$dimensions = $dimensions . " $entrydishRinner*mm";}
    for (my $i = 0; $i < $entrydishNumZplanes; $i++) {$dimensions = $dimensions . " $entrydishRouter[$i]*mm";}
    for (my $i = 0; $i < $entrydishNumZplanes; $i++) {$dimensions = $dimensions . " $entrydishZplanes[$i]*mm";}

    my %detector = init_det();
    $detector{"name"} = "htccEntryDishVolume";
    $detector{"mother"} = "root";
    $detector{"description"} = "HTCC entry dish volume";
    $detector{"color"} = "ee99ff";
    $detector{"type"} = "Polycone";
    $detector{"dimensions"} = "$dimensions";
    $detector{"material"} = "Component";
    print_det(\%configuration, \%detector);
}

# Entry Cone Volume
my $entryconeNumZplanes = 9;
my @entryconeZplanes = (400.00, 470.17, 561.61, 653.05,
    744.49, 835.93, 927.37, 1018.81, 1116.6);
my $entryconeRinner = 0;
#my @entryconeRouter  = ( 257.505, 323.952, 390.373, 456.819,
#                         525.831, 599.872, 673.913, 747.979, 827.151 );

# modified to accomodate for CTOF
my @entryconeRouter = (235, 323.952, 390.373, 456.819,
    525.831, 599.872, 673.913, 747.979, 827.151);

sub make_entryconevolume {
    my $dimensions = "0.0*deg 360.0*deg $entryconeNumZplanes*counts";
    for (my $i = 0; $i < $entryconeNumZplanes; $i++) {$dimensions = $dimensions . " $entryconeRinner*mm";}
    for (my $i = 0; $i < $entryconeNumZplanes; $i++) {$dimensions = $dimensions . " $entryconeRouter[$i]*mm";}
    for (my $i = 0; $i < $entryconeNumZplanes; $i++) {$dimensions = $dimensions . " $entryconeZplanes[$i]*mm";}

    my %detector = init_det();
    $detector{"name"} = "htccEntryConeVolume";
    $detector{"mother"} = "root";
    $detector{"description"} = "HTCC entry cone volume";
    $detector{"type"} = "Polycone";
    $detector{"dimensions"} = "$dimensions";
    $detector{"material"} = "Component";
    print_det(\%configuration, \%detector);
}

sub make_EntryDishPlusCone {
    my %detector = init_det();
    $detector{"name"} = "htccEntryDishCone";
    $detector{"mother"} = "root";
    $detector{"description"} = "subtraction entry dish - cone";
    $detector{"type"} = "Operation:@ htccEntryDishVolume - htccEntryConeVolume";
    $detector{"dimensions"} = "0";
    $detector{"material"} = "Component";
    print_det(\%configuration, \%detector);
}

sub make_GasVolumeFinal {
    my $pos = "0 0 0";
    my $thisVariation = $configuration{"variation"};
    my $runno = $configuration{"run_number"};

    my $configuration_string = clas12_configuration_string(\%configuration);
    if ($configuration_string eq "rga_spring2018") {
        $pos = "0 0 -1.0*cm";
    }
    elsif ($configuration_string eq "rga_fall2018") {
        $pos = "0 0 -1.94*cm";
    }

    my %detector = init_det();
    $detector{"name"} = "htcc";
    $detector{"mother"} = "root";
    $detector{"description"} = "gas volume for htcc";
    $detector{"color"} = "0000ff3"; # add a 4 or 5 at the end to make transparent (change visibility above too)
    $detector{"type"} = "Operation:@ htccBigGasVolume - htccEntryDishCone";
    $detector{"dimensions"} = "0";
    $detector{"pos"} = "$pos";
    $detector{"visible"} = "0";
    $detector{"material"} = "HTCCgas";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);
}

sub build_mother() {
    make_BigGasVolume();
    make_entrydishvolume();
    make_entryconevolume();
    make_EntryDishPlusCone();
    make_GasVolumeFinal();
    make_ExitWindow();
    make_EntryWindow();
}

