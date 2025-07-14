use strict;
use warnings;

our %configuration;

my $pipeFirstStep = 2413;
my $torusStart = 2754.17;
my $mediumPipeEnd = 5006; # added by hand by shooting geantino vertically to locate the point
my $bigPipeBegins = 5062; # added by hand by shooting geantino vertically to locate the point. Corrected by 1mm to match the CAD import of downstream beamline
my $connectThickness = 7; # added by hand by shooting geantino vertically to locate the point. Corrected by 1mm to match the CAD import of downstream beamline
my $pipeEnds = 5732;
my $alcovePipeStarts = 5741;
my $alcovePipeEnds = 9400;
my $mediumStarts = $pipeFirstStep + 76.5; # added by hand by shooting geantino vertically to locate the point

# apex cad model not filled with lead.
my $apexIR = 140;
my $apexOR = 190;
my $apexLength = 1000;
my $apexPos = 5372;

sub vacuumLine() {
    my $variation = clas12_configuration_string(\%configuration);


    my $shieldStart = 963; # start of vacuum pipe is 1mm downstream of target vac extension
    if ($variation eq "rgk_winter2018" || $variation eq "rgf_spring2020" || $variation eq "rgm_fall2021" || $variation eq "rge_spring2024" || $variation eq "ddvcs") {
        $shieldStart = 503; # 46 cm shift
    }


    # in "root" the first part of the pipe is straight
    # 1.651mm thick
    my $pipeLength = ($pipeFirstStep - $shieldStart) / 2.0 - 0.1;
    my $zpos = $shieldStart + $pipeLength;
    my $firstVacuumIR = 22.924;
    my $firstVacuumOR = 24.52;


    my %detector = init_det();
    $detector{"name"} = "vacuumPipe1";
    $detector{"mother"} = "root";
    $detector{"description"} = "straightVacuumPipe";
    $detector{"color"} = "aaffff";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"dimensions"} = "0*mm $firstVacuumOR*mm $pipeLength*mm 0*deg 360*deg";
    $detector{"material"} = "G4_STAINLESS-STEEL";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # vacuum inside
    %detector = init_det();
    $detector{"name"} = "vacuumInPipe1";
    $detector{"mother"} = "vacuumPipe1";
    $detector{"description"} = "straightVacuumPipe";
    $detector{"color"} = "000000";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $firstVacuumIR*mm $pipeLength*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Galactic";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    # in "root" the second part of the pipe is straight until torus
    $pipeLength = ($torusStart - $mediumStarts) / 2.0 - 0.1;
    $zpos = $mediumStarts + $pipeLength;
    my $secondVacuumIR = 24.275;
    my $secondVacuumOR = 32.925;

    %detector = init_det();
    $detector{"name"} = "vacuumPipe2";
    $detector{"mother"} = "root";
    $detector{"description"} = "straightVacuumPipe";
    $detector{"color"} = "aaffff";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"dimensions"} = "0*mm $secondVacuumOR*mm $pipeLength*mm 0*deg 360*deg";
    $detector{"material"} = "G4_STAINLESS-STEEL";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # vacuum inside
    %detector = init_det();
    $detector{"name"} = "vacuumInPipe2";
    $detector{"mother"} = "vacuumPipe2";
    $detector{"description"} = "straightVacuumPipe";
    $detector{"color"} = "000000";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $secondVacuumIR*mm $pipeLength*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Galactic";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # added SST piece on top of Al junction
    $pipeLength = ($mediumStarts - $pipeFirstStep) / 2.0 - 0.1;
    $zpos = $pipeFirstStep + $pipeLength;

    %detector = init_det();
    my $connectingIR = $secondVacuumIR + 3.1;
    $detector{"name"} = "vacuumPipe3";
    $detector{"mother"} = "root";
    $detector{"description"} = "straightVacuumPipe";
    $detector{"color"} = "aaffff";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"dimensions"} = "$connectingIR*mm $secondVacuumOR*mm $pipeLength*mm 0*deg 360*deg";
    $detector{"material"} = "G4_STAINLESS-STEEL";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);

    # vacuum inside,  this is inside ROOT
    %detector = init_det();
    $detector{"name"} = "vacuumInPipe3";
    $detector{"mother"} = "root";
    $detector{"description"} = "straightVacuumPipe";
    $detector{"color"} = "000000";
    $detector{"type"} = "Tube";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"dimensions"} = "0*mm $firstVacuumOR*mm $pipeLength*mm 0*deg 360*deg";
    $detector{"material"} = "G4_Galactic";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    # vacuum line al window
    $zpos = 962.5;
    if ($variation eq "rgk_winter2018" || $variation eq "rgf_spring2020" || $variation eq "rgm_fall2021" || $variation eq "rge_spring2024" || $variation eq "ddvcs") {
        $zpos = 502.5; # 46 cm shift
    }

    my $radius = 30;
    if ($variation eq "ddvcs") {
        $radius = 24.52;
    }

    my $thickness = 0.0375;
    %detector = init_det();
    $detector{"name"} = "al_window_vacuum_entrance";
    $detector{"mother"} = "root";
    $detector{"description"} = "50 mm thick aluminum window downstream";
    $detector{"color"} = "aaaaff";
    $detector{"type"} = "Tube";
    $detector{"dimensions"} = "0*mm $radius*mm $thickness*mm 0*deg 360*deg";
    $detector{"pos"} = "0*mm 0*mm $zpos*mm";
    $detector{"material"} = "G4_Al";
    $detector{"style"} = "1";
    print_det(\%configuration, \%detector);


    # the pipe gets bigger after the torus
    # 1.651mm thick

    my $nplanes = 7;

    # vacuum inside fc. To be extended upstream when FC is removed
    # the end of the line coordinate is eyeballed
    # b
    my @iradius_vbeam = (33.274, 33.274, 32.2, 32.2, 59.8, 59.8, 63.7);
    my @z_plane_vbeam = ($torusStart, $mediumPipeEnd, $mediumPipeEnd, $mediumPipeEnd + $connectThickness, $bigPipeBegins, $pipeEnds, 10000);

    %detector = init_det();
    $detector{"name"} = "beam_vacuum";
    $detector{"mother"} = "root";
    $detector{"description"} = "vacuum line inside torus";
    $detector{"color"} = "000000";
    $detector{"type"} = "Polycone";
    my $dimen = "0.0*deg 360*deg $nplanes*counts";
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " 0.0*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $iradius_vbeam[$i]*mm";}
    for (my $i = 0; $i < $nplanes; $i++) {$dimen = $dimen . " $z_plane_vbeam[$i]*mm";}
    $detector{"dimensions"} = $dimen;
    $detector{"material"} = "G4_Galactic";
    $detector{"style"} = 1;
    print_det(\%configuration, \%detector);


    # lead inside apex
    $zpos = $apexPos + $apexLength;

    my $gapZpos = 283;
    my $gapLength = 295;

    if ($variation eq "rgk_winter2018" || $variation eq "rgf_spring2020" || $variation eq "rgm_fall2021" || $variation eq "rge_spring2024") {
        $gapLength = 86.5;
    }

    my $gapLengthm = $gapLength + 1;
    my $ztart = $gapZpos;

    if ($variation ne "ddvcs") {
        # airpipes to account for change in volume size from target to "root" within a magnetic field
        #
        #
        my @oradius_airpipe = (20, 30);
        my @z_plane_airpipe = (0, 2 * $gapLength);

        %detector = init_det();
        $detector{"name"} = "airPipe";
        $detector{"mother"} = "root";
        $detector{"description"} = "airgap between target and shield to limit e- steps";
        $detector{"color"} = "aaffff";
        $detector{"pos"} = "0*mm 0*mm $ztart*mm";
        $detector{"type"} = "Polycone";
        $dimen = "0.0*deg 360*deg 2*counts";
        for (my $i = 0; $i < 2; $i++) {$dimen = $dimen . " 0.0*mm";}
        for (my $i = 0; $i < 2; $i++) {$dimen = $dimen . " $oradius_airpipe[$i]*mm";}
        for (my $i = 0; $i < 2; $i++) {$dimen = $dimen . " $z_plane_airpipe[$i]*mm";}
        $detector{"dimensions"} = $dimen;
        $detector{"style"} = 1;
        $detector{"material"} = "G4_AIR";
        print_det(\%configuration, \%detector);

        my $innerAirpipeDimension = $gapLength - 0.2;
        %detector = init_det();
        $detector{"name"} = "airPipe2";
        $detector{"mother"} = "airPipe";
        $detector{"description"} = "airgap between target and shield to limit e- steps";
        $detector{"color"} = "aaffff";
        $detector{"type"} = "Tube";
        $detector{"pos"} = "0*mm 0*mm  $innerAirpipeDimension*mm";
        $detector{"dimensions"} = "0*mm 10*mm $innerAirpipeDimension*mm 0*deg 360*deg";
        $detector{"style"} = 1;
        $detector{"material"} = "G4_AIR";
        print_det(\%configuration, \%detector);
    }
}

