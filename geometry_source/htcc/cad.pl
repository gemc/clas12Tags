use strict;
use warnings;

our %configuration;

sub define_cads {

    my $zpos = 0.0;
    my $dzpos = 0.1;

    my $runno = $configuration{"run_number"};

    if ($runno eq 3029) {
        $zpos = -1.0;
    }
    elsif ($runno eq 4763) {
        $zpos = -1.94;
    }

    my $zpos1 = $zpos + $dzpos;

    my %cad = init_cad();
    $cad{"name"} = "htccMollerConeExt";
    $cad{"color"} = "888888";
    $cad{"material"} = "rohacell31";
    $cad{"position"} = "0*cm 0*cm $zpos1*cm";
    $cad{"rotation"} = "0*deg 180*deg 0*deg";
    print_cad(\%configuration, \%cad);

    %cad = init_cad();
    $cad{"name"} = "htccMollerCone";
    $cad{"color"} = "888888";
    $cad{"material"} = "rohacell31";
    $cad{"position"} = "0*cm 0*cm $zpos*cm";
    $cad{"rotation"} = "0*deg 180*deg 0*deg";
    print_cad(\%configuration, \%cad);

    %cad = init_cad();
    $cad{"name"} = "htccCone";
    $cad{"color"} = "888888";
    $cad{"material"} = "rohacell31";
    $cad{"position"} = "0*cm 0*cm $zpos*cm";
    $cad{"rotation"} = "0*deg 180*deg 0*deg";
    print_cad(\%configuration, \%cad);
}

