use strict;
use warnings;

our %configuration;

my $shieldStart = 503; # start of vacuum pipe 
my $pipeFirstStep = 2413;
my $pipeEnds      = 5732;
my $alcovePipeStarts = 5741;
my $alcovePipeEnds   = 9400;
my $mediumStarts  = $pipeFirstStep + 76.5; # added by hand by shooting geantino vertically to locate the point

my $torusStart    = 2754.17 ;
my $mediumPipeEnd = 5006; # added by hand by shooting geantino vertically to locate the point
my $bigPipeBegins = 5062; # added by hand by shooting geantino vertically to locate the point. Corrected by 1mm to match the CAD import of downstream beamline
my $connectThickness = 7; # added by hand by shooting geantino vertically to locate the point. Corrected by 1mm to match the CAD import of downstream beamline

# apex cad model not filled with lead.
my $apexIR = 140;
my $apexOR = 190;
my $apexLength = 1000;
my $apexPos = 5372;

sub elmo7()
{

	my $nplanes_cone = 8;
	my @zplane_cone  =  (250.0, 360.0, 570.0, 1750.0, 1750.0, 2280.0, 2380.0, 2750.0);
	my @iradius_cone  = ( 21.0,  21.0,  26.1,   26.1,   26.1,   33.1,   33.1,   33.1);
	my @oradius_cone  = ( 29.0,  29.0,  41.2,  126.5,  218.0,  218.0,  111.0,  111.0);
	my %detector = init_det();
	$detector{"name"}        = "elmo7";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Tungsten Cone - elmo7 configuration";
	$detector{"color"}       = "dd8648";
	$detector{"type"}        = "Polycone";
	my $dimen = "0.0*deg 360*deg $nplanes_cone*counts";
	for(my $i = 0; $i <$nplanes_cone; $i++) {$dimen = $dimen ." $iradius_cone[$i]*mm";}
	for(my $i = 0; $i <$nplanes_cone; $i++) {$dimen = $dimen ." $oradius_cone[$i]*mm";}
	for(my $i = 0; $i <$nplanes_cone; $i++) {$dimen = $dimen ." $zplane_cone[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "beamline_W";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);



	my $nplanes_pipe = 5;
	my @zplane_pipe  =  (570.0, 2280.0, 2280.0, 2380.0, 2750.0);
	my @iradius_pipe  = ( 22.0,   22.0,   28.0,   28.0,   28.0);
	my @oradius_pipe  = ( 24.0,   24.0,   32.9,   32.9,   32.9);
        %detector = init_det();
        $detector{"name"} = "vacuumPipe1";
        $detector{"mother"} = "root";
        $detector{"description"} = "straightVacuumPipe";
        $detector{"color"} = "aaffff";
        $detector{"type"} = "Polycone";
        $detector{"pos"} = "0*mm 0*mm 0*mm";
	$dimen = "0.0*deg 360*deg $nplanes_pipe*counts";
	for(my $i = 0; $i <$nplanes_pipe; $i++) {$dimen = $dimen ." 0.0*mm";}
	for(my $i = 0; $i <$nplanes_pipe; $i++) {$dimen = $dimen ." $oradius_pipe[$i]*mm";}
	for(my $i = 0; $i <$nplanes_pipe; $i++) {$dimen = $dimen ." $zplane_pipe[$i]*mm";}
        $detector{"dimensions"} = $dimen;
        $detector{"material"} = "G4_STAINLESS-STEEL";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);

        # vacuum inside
        %detector = init_det();
        $detector{"name"} = "vacuumInPipe1";
        $detector{"mother"} = "vacuumPipe1";
        $detector{"description"} = "straightVacuumPipe";
        $detector{"color"} = "000000";
        $detector{"type"} = "Polycone";
	$dimen = "0.0*deg 360*deg $nplanes_pipe*counts";
	for(my $i = 0; $i <$nplanes_pipe; $i++) {$dimen = $dimen ." 0.0*mm";}
	for(my $i = 0; $i <$nplanes_pipe; $i++) {$dimen = $dimen ." $iradius_pipe[$i]*mm";}
	for(my $i = 0; $i <$nplanes_pipe; $i++) {$dimen = $dimen ." $zplane_pipe[$i]*mm";}
        $detector{"dimensions"} = $dimen;
        $detector{"material"} = "G4_Galactic";
        $detector{"style"} = 1;
        print_det(\%configuration, \%detector);

        my $thickness = 0.0375;
        my $radius = $oradius_pipe[0];
        my $zpos = $zplane_pipe[0] - $thickness;
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


}

