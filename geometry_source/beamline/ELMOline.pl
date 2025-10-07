use strict;
use warnings;

our %configuration;

my $shieldStart = 787.41; # start of vacuum pipe is 1mm downstream of target vac extension
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

sub ELMOline()
{

	# in "root" the first part of the pipe is straight
	my $pipeLength = ($pipeFirstStep - $shieldStart) / 2.0 - 0.1;
	my $zpos = $shieldStart + $pipeLength ;
	my $firstVacuumIR = 33.275;
	my $firstVacuumOR = 34.925;
	my %detector = init_det();
	$detector{"name"}        = "vacuumPipe1";
	$detector{"mother"}      = "root";
	$detector{"description"} = "straightVacuumPipe 2.75 inch OD 0.065 thick ";
	$detector{"color"}       = "aaffff";
	$detector{"type"}        = "Tube";
	$detector{"pos"}         = "0*mm 0*mm $zpos*mm";
	$detector{"dimensions"}  = "0*mm $firstVacuumOR*mm $pipeLength*mm 0*deg 360*deg";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	%detector = init_det();
	$detector{"name"}        = "vacuumInPipe1";
	$detector{"mother"}      = "vacuumPipe1";
	$detector{"description"} = "straightVacuumPipe";
	$detector{"color"}       = "000000";
	$detector{"type"}        = "Tube";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*mm $firstVacuumIR*mm $pipeLength*mm 0*deg 360*deg";
	$detector{"material"}    = "G4_Galactic";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	# in "root" the second part of the pipe is straight until torus
	$pipeLength = ($torusStart - $mediumStarts) / 2.0 - 0.1;
	$zpos = $mediumStarts + $pipeLength ;
	%detector = init_det();
	$detector{"name"}        = "vacuumPipe2";
	$detector{"mother"}      = "root";
	$detector{"description"} = "straightVacuumPipe";
	$detector{"color"}       = "aaffff";
	$detector{"type"}        = "Tube";
	$detector{"pos"}         = "0*mm 0*mm $zpos*mm";
	$detector{"dimensions"}  = "0*mm $firstVacuumOR*mm $pipeLength*mm 0*deg 360*deg";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	%detector = init_det();
	$detector{"name"}        = "vacuumInPipe2";
	$detector{"mother"}      = "vacuumPipe2";
	$detector{"description"} = "straightVacuumPipe";
	$detector{"color"}       = "000000";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "0*mm $firstVacuumIR*mm $pipeLength*mm 0*deg 360*deg";
	$detector{"material"}    = "G4_Galactic";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	# added SST piece on top of Al junction
	$pipeLength = ($mediumStarts - $pipeFirstStep) / 2.0 - 0.1;
	$zpos = $pipeFirstStep + $pipeLength ;
	my $connectingIR = $firstVacuumIR + 0.1;
	%detector = init_det();
	$detector{"name"}        = "vacuumPipe3";
	$detector{"mother"}      = "root";
	$detector{"description"} = "straightVacuumPipe";
	$detector{"color"}       = "aaffff";
	$detector{"type"}        = "Tube";
	$detector{"pos"}         = "0*mm 0*mm $zpos*mm";
	$detector{"dimensions"}  = "$firstVacuumIR*mm $firstVacuumOR*mm $pipeLength*mm 0*deg 360*deg";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	%detector = init_det();
	$detector{"name"}        = "vacuumInPipe3";
	$detector{"mother"}      = "root";
	$detector{"description"} = "straightVacuumPipe";
	$detector{"color"}       = "000000";
	$detector{"type"}        = "Tube";
	$detector{"pos"}         = "0*mm 0*mm $zpos*mm";
	$detector{"dimensions"}  = "0*mm $firstVacuumIR*mm $pipeLength*mm 0*deg 360*deg";
	$detector{"material"}    = "G4_Galactic";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);


	my $nplanes = 7;

	# vacuum inside torus. To be extended upstream
	# the end of the line coordinate is eyeballed
	# b
	my @iradius_vbeam  =  (  33.274     , 33.274        , 32.2            , 32.2                                ,  59.8         ,  59.8     ,  63.7);
	my @z_plane_vbeam  =  (  $torusStart, $mediumPipeEnd, $mediumPipeEnd, $mediumPipeEnd + $connectThickness,  $bigPipeBegins, $pipeEnds, 13900);

	%detector = init_det();
	$detector{"name"}        = "beam_vacuum";
	$detector{"mother"}      = "root";
	$detector{"description"} = "vacuum line inside torus";
	$detector{"color"}       = "000000";
	$detector{"type"}        = "Polycone";
	my $dimen = "0.0*deg 360*deg $nplanes*counts";
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $iradius_vbeam[$i]*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_plane_vbeam[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "G4_Galactic";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	# shield is a tapered pipe (G4 polycone)
	my $nplanes_tcone = 4;
	my @zplane_tcone  =  (716.42, 1249.40, 1249.40, 1351.00);
	my @iradius_tcone  = ( 38.10,   38.10,   47.62,   47.62);
	my $or1_tcone = 53.28;
	my $or2_tcone = 105.78;
	my $orm_tcone = $or1_tcone + ($or2_tcone - $or1_tcone) * ($zplane_tcone[1] - $zplane_tcone[0])
	/ ($zplane_tcone[3] - $zplane_tcone[0]);
	my @oradius_tcone  = ($or1_tcone, $orm_tcone, $orm_tcone, $or2_tcone);
	%detector = init_det();
	$detector{"name"}        = "ElmoTungstenCone";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Tungsten moller shield - ELMO configuration";
	$detector{"color"}       = "dd8648";
	$detector{"type"}        = "Polycone";
	$dimen = "0.0*deg 360*deg $nplanes_tcone*counts";
	for(my $i = 0; $i <$nplanes_tcone; $i++) {$dimen = $dimen ." $iradius_tcone[$i]*mm";}
	for(my $i = 0; $i <$nplanes_tcone; $i++) {$dimen = $dimen ." $oradius_tcone[$i]*mm";}
	for(my $i = 0; $i <$nplanes_tcone; $i++) {$dimen = $dimen ." $zplane_tcone[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "beamline_W";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	my $nplanes_ttip = 2;
	my @zplane_ttip  =  (570.0, $zplane_tcone[0]);
	my @iradius_ttip  = ( 39.0, $iradius_tcone[0]);
	my @oradius_ttip  = ( 41.2, $oradius_tcone[0]);
	%detector = init_det();
	$detector{"name"}        = "ElmoTungstenTip";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Tungsten Tip - ELMO configuration";
	$detector{"color"}       = "dd8648";
	$detector{"type"}        = "Polycone";
	$dimen = "0.0*deg 360*deg $nplanes_ttip*counts";
	for(my $i = 0; $i <$nplanes_ttip; $i++) {$dimen = $dimen ." $iradius_ttip[$i]*mm";}
	for(my $i = 0; $i <$nplanes_ttip; $i++) {$dimen = $dimen ." $oradius_ttip[$i]*mm";}
	for(my $i = 0; $i <$nplanes_ttip; $i++) {$dimen = $dimen ." $zplane_ttip[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "beamline_W";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	my $nplanes_pb = 2;
	my @zplane_pb1  =  (1357.35, 1802.71);
	%detector = init_det();
	$detector{"name"}        = "ElmoPbCylinder1";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Lead Cylinder 1 - ELMO configuration";
	$detector{"color"}       = "999966";
	$detector{"type"}        = "Polycone";
	$dimen = "0.0*deg 360*deg $nplanes_pb*counts";
	for(my $i = 0; $i <$nplanes_ttip; $i++) {$dimen = $dimen ." $iradius_tcone[3]*mm";}
	for(my $i = 0; $i <$nplanes_ttip; $i++) {$dimen = $dimen ." $oradius_tcone[3]*mm";}
	for(my $i = 0; $i <$nplanes_ttip; $i++) {$dimen = $dimen ." $zplane_pb1[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "G4_Pb";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	my @zplane_pb2  =  (1809.06, 2240.86);
	%detector = init_det();
	$detector{"name"}        = "ElmoPbCylinder2";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Lead Cylinder 2 - ELMO configuration";
	$detector{"color"}       = "999966";
	$detector{"type"}        = "Polycone";
	$dimen = "0.0*deg 360*deg $nplanes_pb*counts";
	for(my $i = 0; $i <$nplanes_ttip; $i++) {$dimen = $dimen ." $iradius_tcone[3]*mm";}
	for(my $i = 0; $i <$nplanes_ttip; $i++) {$dimen = $dimen ." $oradius_tcone[3]*mm";}
	for(my $i = 0; $i <$nplanes_ttip; $i++) {$dimen = $dimen ." $zplane_pb2[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "G4_Pb";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	my @zplane_steel  =  ($zplane_pb1[0]-5,$zplane_pb2[1]+15);
	my $iradius_steel = $oradius_tcone[3];
	my $oradius_steel = 109.54;
	%detector = init_det();
	$detector{"name"}        = "ElmoSteelCase";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Steel Case - ELMO configuration";
	$detector{"color"}       = "666666";
	$detector{"type"}        = "Polycone";
	$dimen = "0.0*deg 360*deg $nplanes_pb*counts";
	for(my $i = 0; $i <$nplanes_ttip; $i++) {$dimen = $dimen ." $iradius_steel*mm";}
	for(my $i = 0; $i <$nplanes_ttip; $i++) {$dimen = $dimen ." $oradius_steel*mm";}
	for(my $i = 0; $i <$nplanes_ttip; $i++) {$dimen = $dimen ." $zplane_steel[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	

	my $nplanes_stube = 4;
	my $zm_stube = $zplane_pb2[1];
	my $zf_stube = $zm_stube + 27.5;
	my @zplane_stube  =  ($zplane_tcone[2], $zm_stube, $zm_stube, $zf_stube);
	my @iradius_stube  = ($iradius_tcone[0], $iradius_tcone[0], $iradius_tcone[0], $iradius_tcone[0]);
	my @oradius_stube  = ($iradius_tcone[2], $iradius_tcone[2], $oradius_tcone[3], $oradius_tcone[3]);
	%detector = init_det();
	$detector{"name"}        = "ElmoSupportPipe";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Steel support pipe - ELMO configuration";
	$detector{"color"}       = "669966";
	$detector{"type"}        = "Polycone";
	$dimen = "0.0*deg 360*deg $nplanes_stube*counts";
	for(my $i = 0; $i <$nplanes_stube; $i++) {$dimen = $dimen ." $iradius_stube[$i]*mm";}
	for(my $i = 0; $i <$nplanes_stube; $i++) {$dimen = $dimen ." $oradius_stube[$i]*mm";}
	for(my $i = 0; $i <$nplanes_stube; $i++) {$dimen = $dimen ." $zplane_stube[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	my $nplanes_apipe = 4;
	my @zplane_apipe  =  ( 54, 385, 385, $zplane_ttip[0]);
	my @iradius_apipe  = (  0,   0,   0, 0);
#	my @oradius_apipe  = ( 30,  30,  25.46, $oradius_ttip[0]);
	my @oradius_apipe  = ( 10,  10,  25.46, $oradius_ttip[0]);
	%detector = init_det();
	$detector{"name"}        = "ElmoAirPipe";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Air pipe - ELMO configuration";
	$detector{"color"}       = "aaffff";
	$detector{"type"}        = "Polycone";
	$dimen = "0.0*deg 360*deg $nplanes_apipe*counts";
	for(my $i = 0; $i <$nplanes_apipe; $i++) {$dimen = $dimen ." $iradius_apipe[$i]*mm";}
	for(my $i = 0; $i <$nplanes_apipe; $i++) {$dimen = $dimen ." $oradius_apipe[$i]*mm";}
	for(my $i = 0; $i <$nplanes_apipe; $i++) {$dimen = $dimen ." $zplane_apipe[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "G4_AIR";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$zpos = 2300.0;
	%detector = init_det();
	$detector{"name"}        = "FTflangeShieldCylinder";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Shield around beam puipe flange";
	$detector{"color"}       = "999966";
	$detector{"type"}        = "Cons";
	$detector{"pos"}         = "0*mm 0*mm $zpos*mm";
	$detector{"dimensions"}  = "125.4*mm 130*mm 125.4*mm 130.*mm 41.3*mm 0.0*deg 360*deg";
	$detector{"material"}    = "G4_Pb";
	$detector{"style"}       = 1;
	#	print_det(\%configuration, \%detector);

	$zpos = 2550.0;
	%detector = init_det();
	$detector{"name"}        = "TorusConnector";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Shield around Shield support before FT on beamline";
	$detector{"color"}       = "999966";
	$detector{"type"}        = "Cons";
	$detector{"pos"}         = "0*mm 0*mm $zpos*mm";
	$detector{"dimensions"}  = "97*mm 104*mm 97*mm 104.*mm 101.3*mm 0.0*deg 360*deg";
	$detector{"material"}    = "G4_Pb";
	$detector{"style"}       = 1;
	#	print_det(\%configuration, \%detector);

}

