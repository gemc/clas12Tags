use strict;
use warnings;

our %configuration;
our %parameters;

sub build_targets
{
	my $thisVariation = $configuration{"variation"} ;

	
	my %detector = init_det();
	my $TTIR = 400;
	my $TTOR = $TTIR + 1;

#	$detector{"name"}        = "targetFlux";
#	$detector{"mother"}      = "root";
#	$detector{"description"} = "Flux for testing generator";
#	$detector{"color"}       = "aa0000";
#	$detector{"type"}        = "Sphere";
#	$detector{"dimensions"}  = "$TTIR*mm $TTOR*mm 0*deg 360*deg 0*deg 180*deg";
#	$detector{"material"}    = "G4_Galactic";
#	$detector{"sensitivity"} = "flux";
#	$detector{"hit_type"}    = "flux";
#	$detector{"identifiers"} = "id manual 1";
#	print_det(\%configuration, \%detector);
#	exit;

	
	
	if($thisVariation eq "pbTest" )
	{
		# mother is a helium bag 293.26 mm long. Its center is 40.85 mm
		my $tshift     = 40.85;
		my $Rout       = 10;  #
		my $Celllength     = 293.26 / 2;
		my $zpos       = $Celllength - $tshift;
		my %detector = init_det();
		$detector{"name"}        = "targetCell";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Helium cell";
		$detector{"color"}       = "5511111";
		$detector{"type"}        = "Tube";
		$detector{"pos"}         = "0 0 $zpos*mm";
		$detector{"dimensions"}  = "0*mm $Rout*mm $Celllength*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_He";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# PB 125 microns
		$Rout       = 5;  #
		$zpos       = $tshift - $Celllength;
		my $length     = 0.0625; # (0.125 mm thick)
		%detector = init_det();
		$detector{"name"}        = "testPbTarget";
		$detector{"mother"}      = "targetCell";
		$detector{"description"} = "Pb target";
		$detector{"color"}       = "004488";
		$detector{"type"}        = "Tube";
		$detector{"pos"}         = "0 0 $zpos*mm";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Pb";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);


		# Upstream Foil 50 microns Aluminum at 24.8 cm
		my $ZCenter = 0.1 - $Celllength ;  # upstream end
		$Rout       = 5;  #
		$length     = 0.015; # (0.030 mm thick)
		%detector = init_det();
		$detector{"name"}        = "AlTargetFoilUpstream";
		$detector{"mother"}      = "targetCell";
		$detector{"description"} = "Aluminum Upstream Foil ";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# Downstream Foil 50 microns Aluminum at 24.8 cm
		$ZCenter = $Celllength - 0.1 ;  # Downstream end
		$Rout       = 5;  #
		$length     = 0.015; # (0.030 mm thick)
		%detector = init_det();
		$detector{"name"}        = "AlTargetFoilDownstream";
		$detector{"mother"}      = "targetCell";
		$detector{"description"} = "Aluminum Downstream Foil ";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# flux detector downstream of the scattering chamber
		$ZCenter = 300 ;  
		$Rout       = 45;  #
		$length     = 0.015; # (0.030 mm thick)
		%detector = init_det();
		$detector{"name"}        = "testFlux";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Flux detector";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "009900";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_AIR";
		$detector{"style"}       = "1";
		$detector{"sensitivity"} = "flux";
		$detector{"hit_type"}    = "flux";
		$detector{"identifiers"} = "id manual 1";
		print_det(\%configuration, \%detector);


	} elsif($thisVariation eq "oldlH2" || $thisVariation eq "oldlD2") {
		# vacuum container
		my $Rout       = 44;
		my $length     = 50;  # half length
		my %detector = init_det();
		$detector{"name"}        = "scatteringChamberVacuum";
		$detector{"mother"}      = "root";
		$detector{"description"} = "clas12 scattering chamber vacuum rohacell container for $thisVariation target";
		$detector{"color"}       = "aaaaaa4";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Galactic";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		
		# rohacell
		$Rout       = 43;
		$length     = 48;  # half length
		%detector = init_det();
		$detector{"name"}        = "scatteringChamber";
		$detector{"mother"}      = "scatteringChamberVacuum";
		$detector{"description"} = "clas12 rohacell scattering chamber for $thisVariation target";
		$detector{"color"}       = "ee3344";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "rohacell";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		
		# vacuum container for aluminum cell
		$Rout       = 40;
		$length     = 45;  # half length
		%detector = init_det();
		$detector{"name"}        = "aluminumCellVacuum";
		$detector{"mother"}      = "scatteringChamber";
		$detector{"description"} = "clas12 rohacell vacuum aluminum container chamber for $thisVariation target";
		$detector{"color"}       = "aaaaaa4";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Galactic";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		
		# aluminum cell
		$Rout       = 5.02;
		$length     = 25.03;  # half length
		%detector = init_det();
		$detector{"name"}        = "aluminumCell";
		$detector{"mother"}      = "aluminumCellVacuum";
		$detector{"description"} = "clas12 aluminum cell for $thisVariation target";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		# actual target
		$Rout       = 5.00;
		$length     = 25.00;  # half length
		%detector = init_det();
		$detector{"name"}        = $thisVariation;
		$detector{"mother"}      = "aluminumCell";
		$detector{"description"} = "clas12 $thisVariation target";
		$detector{"color"}       = "ee8811Q";
		$detector{"type"}        = "Tube";
		$detector{"style"}       = "1";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		

		if($thisVariation eq "oldlH2")
		{
			$detector{"material"}    = "G4_lH2";
		}
		if($thisVariation eq "oldlD2")
		{
			$detector{"material"}    = "LD2";
		}
		print_det(\%configuration, \%detector);
	}
	elsif($thisVariation eq "ND3")
	{
		# vacuum container
		my $Rout       = 44;
		my $length     = 50;  # half length
		my %detector = init_det();
		$detector{"name"}        = "scatteringChamberVacuum";
		$detector{"mother"}      = "root";
		$detector{"description"} = "clas12 scattering chamber vacuum rohacell container for $thisVariation target";
		$detector{"color"}       = "aaaaaa4";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Galactic";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		
		# rohacell
		$Rout       = 43;
		$length     = 48;  # half length
		%detector = init_det();
		$detector{"name"}        = "scatteringChamber";
		$detector{"mother"}      = "scatteringChamberVacuum";
		$detector{"description"} = "clas12 rohacell scattering chamber for $thisVariation target";
		$detector{"color"}       = "ee3344";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "rohacell";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		
		# vacuum container for plastic cell
		$Rout       = 40;
		$length     = 45;  # half length
		%detector = init_det();
		$detector{"name"}        = "plasticCellVacuum";
		$detector{"mother"}      = "scatteringChamber";
		$detector{"description"} = "clas12 rohacell vacuum aluminum container chamber for $thisVariation target";
		$detector{"color"}       = "aaaaaa4";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Galactic";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		# helium cylinder
		$Rout       = 12.62;
		$length     = 25.10;  # half length
		%detector = init_det();
		$detector{"name"}        = "HeliumCell";
		$detector{"mother"}      = "plasticCellVacuum";
		$detector{"description"} = "Helium volume for $thisVariation target";
		$detector{"color"}       = "aaaaaa3";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_He";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		# plastic cylinder cell
		$Rout       = 12.60;
		$length     = 20.10;  # half length
		%detector = init_det();
		$detector{"name"}        = "plasticCell";
		$detector{"mother"}      = "HeliumCell";
		$detector{"description"} = "clas12 plastic cell for $thisVariation target";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_TEFLON"; #using teflon which is similar to the actual cell
		print_det(\%configuration, \%detector);
		
		
		# actual target
		$Rout       = 12.50; # target has a 25mm diameter
		$length     = 20.00;  # half length (target is 4cm long)
		%detector = init_det();
		$detector{"name"}        = $thisVariation;
		$detector{"mother"}      = "plasticCell";
		$detector{"description"} = "clas12 $thisVariation target";
		$detector{"color"}       = "ee8811";
		$detector{"type"}        = "Tube";
		$detector{"style"}       = "1";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		
		$detector{"material"}    = "solidND3";
		print_det(\%configuration, \%detector);
		
	}

	if($thisVariation eq "hdIce") {
		my %detector = init_det();
		$detector{"name"}        = "hdIce_mother";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Target Container";
		$detector{"color"}       = "22ff22";
		$detector{"type"}        = "Box";
		$detector{"dimensions"}  = "160*mm 160*mm 800*mm";
		$detector{"material"}    = "G4_Galactic";
		$detector{"style"}       = 0;
		$detector{"mfield"}		 = "hdicefield";
		print_det(\%configuration, \%detector);

	}

	if($thisVariation eq "longitudinal") {

		my $nplanes = 4;

		my @oradius  =  (    50.2,   50.2,  21.0,  21.0 );
		my @z_plane  =  (  -115.0,  265.0, 290.0, 300.0 );		

		# vacuum target container
		my %detector = init_det();
		$detector{"name"}        = "ltarget";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Target Container";
		$detector{"color"}       = "22ff22";
		$detector{"type"}        = "Polycone";
		my $dimen = "0.0*deg 360*deg $nplanes*counts";
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradius[$i]*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_plane[$i]*mm";}
		$detector{"dimensions"}  = $dimen;
		$detector{"material"}    = "G4_Galactic";
		$detector{"style"}       = 0;
		print_det(\%configuration, \%detector);

		%detector = init_det();
		$detector{"name"}        = "al_window_entrance";
		$detector{"mother"}      = "ltarget";
		$detector{"description"} = "5 mm radius aluminum window upstream";
		$detector{"color"}       = "aaaaff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm 5*mm 0.0125*mm 0*deg 360*deg";
		$detector{"pos"}         = "0*mm 0*mm -24.2125*mm";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		%detector = init_det();
		$detector{"name"}        = "al_window_exit";
		$detector{"mother"}      = "ltarget";
		$detector{"description"} = "1/8 in radius aluminum window downstream" ;
		$detector{"color"}       = "aaaaff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm 3.175*mm 0.0125*mm 0*deg 360*deg";
		$detector{"pos"}         = "0*mm 0*mm 173.2825*mm";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
	}

	if($thisVariation eq "transverse") {

		#	Length: 28.4 mm
		#	ID: 27.0 mm
		#	OD: 29.0
		#	Al foils: 25 um thick

		my $ttlength = 14.2;   # half length
		my $ttid     = 13.5;
		my $ttod     = 14.5;
		my $ttfoil   = 0.0125; # half length


		# cell frame
		my %detector = init_det();
		$detector{"name"}        = "ttargetCellFrame";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Target Container";
		$detector{"color"}       = "222222";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $ttod*mm $ttlength*mm 0*deg 360*deg";
		$detector{"material"}    = "Kel-F";
		$detector{"style"}       = 1;
		#print_det(\%configuration, \%detector);

		# cell
		%detector = init_det();
		$detector{"name"}        = "ttargetCell";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Target Container";
		$detector{"color"}       = "994422";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $ttid*mm $ttlength*mm 0*deg 360*deg";
		$detector{"material"}    = "NH3target";
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);

		# downstream al window
		my $zpos = $ttlength + $ttfoil;
		%detector = init_det();
		$detector{"name"}        = "al_window_entrance";
		$detector{"mother"}      = "root";
		$detector{"description"} = "25 mm thick aluminum window upstream";
		$detector{"color"}       = "aaaaff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $ttid*mm $ttfoil*mm 0*deg 360*deg";
		$detector{"pos"}         = "0*mm 0*mm $zpos*mm";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# upstream al window
		$zpos = -$ttlength - $ttfoil;
		%detector = init_det();
		$detector{"name"}        = "al_window_exit";
		$detector{"mother"}      = "root";
		$detector{"description"} = "25 mm thick aluminum window upstream";
		$detector{"color"}       = "aaaaff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $ttid*mm $ttfoil*mm 0*deg 360*deg";
		$detector{"pos"}         = "0*mm 0*mm $zpos*mm";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
	}

	# cad variation has two volume:
	# target container
	# and inside cell
	if($thisVariation eq "lH2" || $thisVariation eq "lD2" || $thisVariation eq "lH2e" || $thisVariation eq "lHe")
	{
		my $nplanes = 4;

		my @oradius  =  (    50.3,   50.3,  21.1,  21.1 );
		my @z_plane  =  (  -140.0,  265.0, 280.0, 280.0 );


		if ($thisVariation eq "lH2e") {
			@z_plane  =  (  -115.0,  365.0, 390.0, 925.0 );
		}
		

		# vacuum target container
		my %detector = init_det();
		$detector{"name"}        = "target";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Target Container";
		$detector{"color"}       = "22ff22";
		$detector{"type"}        = "Polycone";
		my $dimen = "0.0*deg 360*deg $nplanes*counts";
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradius[$i]*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_plane[$i]*mm";}
		$detector{"dimensions"}  = $dimen;
		$detector{"material"}    = "G4_Galactic";
		$detector{"style"}       = 0;
		print_det(\%configuration, \%detector);



		$nplanes = 5;
		my @oradiusT  =  (   2.5,  10.3,  7.3,  5.0,  2.5);
		my @z_planeT  =  ( -24.2, -21.2, 22.5, 23.5, 24.5);

		# actual target
		%detector = init_det();
		$detector{"name"}        = "lh2";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Target Cell";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Polycone";
		$dimen = "0.0*deg 360*deg $nplanes*counts";
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradiusT[$i]*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_planeT[$i]*mm";}
		$detector{"dimensions"}  = $dimen;
		$detector{"material"}    = "G4_lH2";
		if($thisVariation eq "lD2") {
			$detector{"material"}    = "LD2";
		}
		if($thisVariation eq "lHe") {
			$detector{"material"}    = "lHeTarget";
		}
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);


		# upstream al window. zpos comes from engineering model, has the shift of 1273.27 mm + 30 due to the new engineering center
	    my $eng_shift = 1303.27 ;
		my $zpos = $eng_shift - 1328.27;
		my $radius = 4.9;
		my $thickness=0.015;
		%detector = init_det();
		$detector{"name"}        = "al_window_entrance";
		$detector{"mother"}      = "target";
		$detector{"description"} = "30 mm thick aluminum window upstream";
		$detector{"color"}       = "aaaaff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $radius*mm $thickness*mm 0*deg 360*deg";
		$detector{"pos"}         = "0*mm 0*mm $zpos*mm";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

	    # downstream al window
	    $zpos = $eng_shift - 1278.27;
		$radius = 5;
		$thickness=0.015;
		%detector = init_det();
		$detector{"name"}        = "al_window_exit";
		$detector{"mother"}      = "target";
		$detector{"description"} = "30 mm thick aluminum window downstream";
		$detector{"color"}       = "aaaaff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $radius*mm $thickness*mm 0*deg 360*deg";
		$detector{"pos"}         = "0*mm 0*mm $zpos*mm";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

	    # cell barrier is 15 microns
	    $zpos = $eng_shift - 1248.27;
		$radius = 5;
		$thickness=0.0075;
		%detector = init_det();
		$detector{"name"}        = "al_window_mli_barrier";
		$detector{"mother"}      = "target";
		$detector{"description"} = "15 mm thick aluminum mli barrier";
		$detector{"color"}       = "bb99aa";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $radius*mm $thickness*mm 0*deg 360*deg";
		$detector{"pos"}         = "0*mm 0*mm $zpos*mm";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);



	    # scattering chambers al window, 75 microns
	    # note: the eng. position is 1017.27 - here it is placed 8mm upstream to place it within the mother scattering chamber
	    $zpos = $eng_shift - 1025.27;
		$radius = 12;
		$thickness=0.0375;
		%detector = init_det();
		$detector{"name"}        = "al_window_scexit";
		$detector{"mother"}      = "target";
		$detector{"description"} = "50 mm thick aluminum window downstream";
		$detector{"color"}       = "aaaaff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $radius*mm $thickness*mm 0*deg 360*deg";
		$detector{"pos"}         = "0*mm 0*mm $zpos*mm";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);


		
	}
	
	# cad variation has two volume:
	# target container
	# and inside cell
	elsif($thisVariation eq "PolTarg")
	{
		# vacuum container
		my $Rout         = 44;
		my $ZhalfLength  = 130;  # half length along beam axis
		my %detector = init_det();
		$detector{"name"}        = "PolTarg";
		$detector{"mother"}      = "root";
		$detector{"description"} = "PolTarg Region";
		$detector{"color"}       = "aaaaaa9";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Galactic";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		# LHe fill between targets
		my $ZCenter = 0;  # center location of target along beam axis
		$Rout       = 10;  # radius in mm
		$ZhalfLength  = 14.97;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "LHeVoidFill";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "LHe between target cells";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "0000ff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "lHeCoolant";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		# NH3Targ
		$ZCenter = -25;  # center location of target along beam axis
		$Rout       = 10;  # radius in mm
		$ZhalfLength  = 9.96;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "NH3Targ";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Upstream NH3 target cell";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "f000f0";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "NH3target";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# NH3Targ Cup
		my $Rin       = 10.0001;  # radius in mm
		$Rout       = 10.03;  # radius in mm
		$ZhalfLength  = 9.75;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "NH3Cup";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Upstream NH3 Target cup";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "ffffff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "AmmoniaCellWalls";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# NH3Targ Cup Down Stream Ring
		$ZCenter=-35;
		$Rin       = 10.0001;  # radius in mm
		$Rout       = 11.43;  # radius in mm
		$ZhalfLength  = 0.25;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "NH3CupDSRing";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Upstream NH3 Target cup downstream Ring";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "ffffff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "AmmoniaCellWalls";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# NH3Targ Cup UP Stream Ring
		$ZCenter                 =-15;
		$Rin                     = 10.0001;  # radius in mm
		$Rout                    = 12.7;  # radius in mm
		$ZhalfLength             = 0.25;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "NH3CupUSRing";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Upstream NH3 Target cup Upstream Ring";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "ffffff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "AmmoniaCellWalls";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);


		# NH3Targ Cup Window Frame
		$ZCenter                 =-35;
		$Rin                     = 11.44;  # radius in mm
		$Rout                    = 12.7;  # radius in mm
		$ZhalfLength             = 1.5875;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "NH3CupWindowFrame_20";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Upstream NH3 Target cup Window frame";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "ffffff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "AmmoniaCellWalls";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);



		# NH3Targ Cup Up Stream Window
		$ZCenter                 =-35;
		$Rin                     = 0.0;  # radius in mm
		$Rout                    = 10;  # radius in mm
		$ZhalfLength             = 0.025;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "NH3CupUSWindow_20";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Upstream NH3 Target cup Upstream Window";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# NH3Targ Cup Downstream Stream Window
		$ZCenter                 =-15;
		$Rin                     = 0.0;  # radius in mm
		$Rout                    = 10;  # radius in mm
		$ZhalfLength             = 0.025;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "NH3CupDSWindow";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Upstream NH3 Target cup Downstream Window";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);



		# NH3Targ
		$ZCenter = 25;  # center location of target along beam axis
		$Rout       = 10;  # radius in mm
		$ZhalfLength  = 9.96;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "ND3Targ";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Downstream ND3 target cell";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "f000f0";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "ND3target";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# NH3Targ Cup
		$Rin       = 10.0001;  # radius in mm
		$Rout       = 10.03;  # radius in mm
		$ZhalfLength  = 9.75;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "ND3Cup";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Downstream ND3 Target cup";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "ffffff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "AmmoniaCellWalls";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# ND3Targ Cup Down Stream Ring
		$ZCenter=35;
		$Rin       = 10.0001;  # radius in mm
		$Rout       = 11.43;  # radius in mm
		$ZhalfLength  = 0.25;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "ND3CupDSRing";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Downstream ND3 Target cup downstream Ring";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "ffffff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "AmmoniaCellWalls";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# ND3Targ Cup UP Stream Ring
		$ZCenter                 =15;
		$Rin                     = 10.0001;  # radius in mm
		$Rout                    = 11.43;  # radius in mm
		$ZhalfLength             = 0.25;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "ND3CupUSRing";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Downstrem ND3 Target cup Upstream Ring";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "ffffff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "AmmoniaCellWalls";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);


		# ND3Targ Cup Window Frame
		$ZCenter                 =15;
		$Rin                     = 11.44;  # radius in mm
		$Rout                    = 12.7;  # radius in mm
		$ZhalfLength             = 1.5875;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "ND3CupWindowFrame_20";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Upstream NH3 Target cup Window frame";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "ffffff";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "AmmoniaCellWalls";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);



		# ND3Targ Cup Up Stream Window
		$ZCenter                 =35;
		$Rin                     = 0.0;  # radius in mm
		$Rout                    = 10.0;  # radius in mm
		$ZhalfLength             = 0.025;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "ND3CupUSWindow_20";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Downstream ND3 Target cup Upstream Window";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# ND3Targ Cup Downstream Stream Window
		$ZCenter                 =15;
		$Rin                     = 0.0;  # radius in mm
		$Rout                    = 10.0;  # radius in mm
		$ZhalfLength             = 0.025;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "ND3CupDSWindow";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Downstream ND3 Target cup Downstream Window";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# Insert Bath Entrance window part 7 a
		$ZCenter                 =-37.395;
		$Rin                     = 0.0;  # radius in mm
		$Rout                    = 11.5;  # radius in mm
		$ZhalfLength             = 0.605;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "InsertBathEntranceWindow_7a";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Insert Bath Entrence window part 7 a";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);


		# Insert Bath Entrance window part 7 b
		$ZCenter                 =-68.2;
		$Rin                     = 11.0;  # radius in mm
		$Rout                    = 11.5;  # radius in mm
		$ZhalfLength             = 30.1;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "InsertBathEntranceWindow_7b";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Insert Bath Entrence window part 7 b";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);


		# Insert Bath Entrance window part 7 c
		$ZCenter                 =-98.4;
		$Rin                     = 11.5001;  # radius in mm
		$Rout                    = 14.4;  # radius in mm
		$ZhalfLength             = 3.17;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "InsertBathEntranceWindow_7c";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Insert Bath Entrence window part 7 c";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);


		# Insert Bath Entrance window part 7 d
		$ZCenter                 =-102.23;
		$Rin                     = 11.0;  # radius in mm
		$Rout                    = 14.96;  # radius in mm
		$ZhalfLength             = 0.66;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "InsertBathEntranceWindow_7d";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Insert Bath Entrence window part 7 d";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		

		# Shim Coil Carrier
		$ZCenter                 =-19.3;
		$Rin                     = 28.8;  # radius in mm
		$Rout                    = 29.3;  # radius in mm
		$ZhalfLength             = 80.95;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "ShimCoilCarrier";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Shim Coil Carrier";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);


		# Shim Up Up stream Coil
		$ZCenter                 =43.5;
		$Rin                     = 29.3;  # radius in mm
		$Rout                    = 30.0;  # radius in mm
		$ZhalfLength             = 6.0;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "ShimUpUpS";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Shim Coil Up Up stream Coil";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "a00000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "ShimCoil";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);


		# Shim Up stream Coil
		$ZCenter                 =8.5;
		$Rin                     = 29.3;  # radius in mm
		$Rout                    = 30.0;  # radius in mm
		$ZhalfLength             = 6.0;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "ShimUpS";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Shim Coil Up stream";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "a00000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "ShimCoil";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# Shim Down stream Coil
		$ZCenter                 =-8.5;
		$Rin                     = 29.3;  # radius in mm
		$Rout                    = 30.0;  # radius in mm
		$ZhalfLength             = 6.0;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "ShimDownS";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Shim Coil Down stream";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "a00000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "ShimCoil";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);


		# Shim Down Down stream Coil
		$ZCenter                 =-43.5;
		$Rin                     = 29.3;  # radius in mm
		$Rout                    = 30.0;  # radius in mm
		$ZhalfLength             = 6.0;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "ShimDownDownS";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "Shim Coil Down Down stream";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "a00000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "ShimCoil";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		

		# Heat Shield tube
		$ZCenter                 =-34.3;
		$Rin                     = 40.3;  # radius in mm
		$Rout                    = 41.3;  # radius in mm
		$ZhalfLength             = 83.85;  # half length along beam axis
		%detector = init_det();
		$detector{"name"}        = "HeatShieldTube";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "PolTarg Heat Shield Tube";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm $ZhalfLength*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# Heat Shield Half Sphere
		$ZCenter                 = 49.55;
		$Rin                     = 40.3;  # radius in mm
		$Rout                    = 41.3;  # radius in mm
		%detector = init_det();
		$detector{"name"}        = "HeatShieldSphere";
		$detector{"mother"}      = "PolTarg";
		$detector{"description"} = "PolTarg Heat Shield Exit window Shere";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Sphere";
		$detector{"dimensions"}  = "$Rin*mm $Rout*mm 0*deg 360*deg 0*deg 90*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);


		# Heat Shield Tube Joint
		#		$ZCenter                 = -129.5;
		#		$Rin                     = 41.3;  # radius in mm
		#		$Rout                    = 42.4;  # radius in mm
		#		$ZhalfLength             = 13.9;  # half length along beam axis
		#		%detector = init_det();
		#		$detector{"name"}        = "HeatShieldTubeJoint";
		#		$detector{"mother"}      = "PolTarg";
		#		$detector{"description"} = "PolTarg Heat Tube Joint";
		#		$detector{"pos"}         = "0 0 $ZCenter*mm";
		#		$detector{"color"}       = "aaaaaa";
		#		$detector{"type"}        = "Sphere";
		#		$detector{"dimensions"}  = "$Rin*mm $Rout*mm 0*deg 360*deg 0*deg 90*deg";
		#		$detector{"material"}    = "G4_Al";
		#		$detector{"style"}       = "1";
		#		print_det(\%configuration, \%detector);

		
	}
    
    elsif($thisVariation eq "bonusD2" || $thisVariation eq "bonusH2" || $thisVariation eq "bonusHe")
    {
        # bonus root volume
		my $motherGap  = 0.00001; # unphysical gap 
		my $target_length = 256.56;
		my $targetWall_radOut = 3.063;
		  # Straw
        my $Rout_straw   = $targetWall_radOut + $motherGap;
        my $length_straw = $target_length + $motherGap;  # half length
        my %detector = init_det();
        $detector{"name"}        = "targetStraw";
        $detector{"mother"}      = "root";
        $detector{"description"} = "Target straw";
        $detector{"color"}       = "9ffbb9";
        $detector{"type"}        = "Tube";
        $detector{"dimensions"}  = "0*mm $Rout_straw*mm $length_straw*mm 0*deg 360*deg";
		$detector{"pos"}         = "0*mm 0*mm 0*mm";
        $detector{"material"}    = "Component";
        $detector{"style"}       = "1";
        $detector{"visible"}     = "1";
        print_det(\%configuration, \%detector);

		  # End cap
        my $Rout_endCap   = $targetWall_radOut + 0.1 + 0.0001 + $motherGap;
        my $length_endCap = 2.05005 + $motherGap;  # half length
        %detector = init_det();
        $detector{"name"}        = "targetEndCap";
        $detector{"mother"}      = "root";
        $detector{"description"} = "Target end cap";
        $detector{"color"}       = "a0a2fa";
        $detector{"type"}        = "Tube";
        $detector{"dimensions"}  = "0*mm $Rout_endCap*mm $length_endCap*mm 0*deg 360*deg";
		$detector{"pos"}         = "0*mm 0*mm 254.61005*mm";
        $detector{"material"}    = "Component";
        $detector{"style"}       = "1";
        $detector{"visible"}     = "1";
        print_det(\%configuration, \%detector);

		  # Final union
        %detector = init_det();
        $detector{"name"}        = "target";
        $detector{"mother"}      = "root";
        $detector{"description"} = "BONuS12 RTPC gaseous $thisVariation Target";
        $detector{"color"}       = "fad1a0";
        $detector{"type"}        = "Operation:@ targetStraw + targetEndCap";
        $detector{"dimensions"}  = "0";
        $detector{"material"}    = "G4_He";
        $detector{"style"}       = "1";
        $detector{"visible"}     = "0";
        print_det(\%configuration, \%detector);
        
        # bonus target gas volume
        my $Rin        = 0.0;
        my $Rout       = 3.0 - 0.0001;
        my $length     = $target_length;  # half length
        %detector = init_det();
        $detector{"name"}        = "TargetGas";
        $detector{"mother"}      = "target";
        $detector{"description"} = "5.6 atm $thisVariation target gas";
        $detector{"color"}       = "72d3fa";
        $detector{"type"}        = "Tube";
        $detector{"pos"}         = "0*mm 0*mm 0*mm";
        $detector{"dimensions"}  = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"style"}       = "1";

		if($thisVariation eq "bonusD2")
		{
        	$detector{"material"}    = "bonusTargetGas_D2";
		}
		if($thisVariation eq "bonusH2")
		{
        	$detector{"material"}    = "bonusTargetGas_H2";
		}
		if($thisVariation eq "bonusHe")
		{
        	$detector{"material"}    = "bonusTargetGas_He";
		}

        print_det(\%configuration, \%detector);
        
        # bonus target wall
        $Rin        = 3.0;
        %detector = init_det();
        $detector{"name"}        = "bonusTargetWall";
        $detector{"mother"}      = "target";
        $detector{"description"} = "Bonus Target wall";
        $detector{"color"}       = "330099";
        $detector{"type"}        = "Tube";
        $detector{"pos"}         = "0*mm 0*mm 0*mm";
        $detector{"dimensions"}  = "$Rin*mm $targetWall_radOut*mm $target_length*mm 0*deg 360*deg";
        $detector{"material"}    = "G4_KAPTON";
        $detector{"style"}       = "1";
        print_det(\%configuration, \%detector);
        
        # bonus target downstream aluminum end cap ring
        $Rin        = $targetWall_radOut + 0.0001;
        $Rout       = $Rin + 0.1;
        $length     = 2.0;  # half length
        my $zPos       = $target_length - $length;  # z position
        %detector = init_det();
        $detector{"name"}        = "bonusTargetEndCapRing";
        $detector{"mother"}      = "target";
        $detector{"description"} = "Bonus Target Al end cap ring";
        $detector{"color"}       = "C4C4C4";
        $detector{"type"}        = "Tube";
        $detector{"pos"}         = "0*mm 0*mm $zPos*mm";
        $detector{"dimensions"}  = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"material"}    = "G4_Al";
        $detector{"style"}       = "1";
        print_det(\%configuration, \%detector);
        
        # bonus target downstream aluminum end cap ring
        $Rin        = 0.0;
        $Rout       = $targetWall_radOut + 0.1 + 0.0001;
        $length     = 0.05;  # half length
        $zPos       = $target_length + $length + 0.0001;  # z position
        %detector = init_det();
        $detector{"name"}        = "bonusTargetEndCapPlate";
        $detector{"mother"}      = "target";
        $detector{"description"} = "Bonus Target Al end cap wall";
        $detector{"color"}       = "C4C4C4";
        $detector{"type"}        = "Tube";
        $detector{"pos"}         = "0*mm 0*mm $zPos*mm";
        $detector{"dimensions"}  = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"material"}    = "G4_Al";
        $detector{"style"}       = "1";
        print_det(\%configuration, \%detector);
        
    }
    #
    # Flag Design: lD2 cell + 2 Solid Foils Assembly
     #
        elsif($thisVariation eq "lD2CuSn")
	{	 
	 #
	 # lD2 Cell copied from lD2/lH2 variation
	 #
	 	my $nplanes = 4;

		my @oradius  =  (    50.2,   50.2,  21.0,  21.0 );
		my @z_plane  =  (  -115.0,  265.0, 290.0, 300.0 );


		if ($thisVariation eq "lH2e") {
			@z_plane  =  (  -115.0,  365.0, 390.0, 925.0 );
		}		

		# vacuum target container
		my %detector = init_det();
		$detector{"name"}        = "target";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Target Container";
		$detector{"color"}       = "22ff22";
		$detector{"type"}        = "Polycone";
		my $dimen = "0.0*deg 360*deg $nplanes*counts";
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradius[$i]*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_plane[$i]*mm";}
		$detector{"dimensions"}  = $dimen;
		$detector{"material"}    = "G4_Galactic";
		$detector{"style"}       = 0;
		print_det(\%configuration, \%detector);

		$nplanes = 5;
		my @oradiusT  =  (   2.5,  10.3,  7.3,  5.0,  2.5);
		my @z_planeT  =  ( -24.2, -21.2, 22.5, 23.5, 24.5);

		# actual target
		%detector = init_det();
		$detector{"name"}        = "lh2";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Target Cell";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Polycone";
		$dimen = "0.0*deg 360*deg $nplanes*counts";
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradiusT[$i]*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_planeT[$i]*mm";}
		$detector{"dimensions"}  = $dimen;
		$detector{"material"}    = "G4_lH2";
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);
				
		# 63Cu + 120Sn foils
		
		# Upstream Foil: 63Cu (Zcenter defined assuming z= 0 cm is the center of CLAS12.
		my $ZCenter = 75.0;  # center location of target along beam axis
		my $Rout       = 2;  #
		my $length     = 0.0465; #(0.093 mm thick)
		%detector = init_det();
		$detector{"name"}        = "1stNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "First 63Cu Foil in Flag Assembly";
		# As given by Cyril in May 2019
		$detector{"pos"}         = "0*mm 0*mm $ZCenter*mm";
		$detector{"color"}       = "aa0011";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Cu";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		# Second Foil: 120Sn
		$ZCenter = 125.0;  # center location of target along beam axis
		$Rout       = 2;  #
		$length     = 0.0855; #(0.171 mm thick)
		%detector = init_det();
		$detector{"name"}        = "2ndNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Second 120Sn Foil in Flag Assembly";
		#$detector{"pos"}         = "0 0 $ZCenter*mm";
		# As given by Cyril in May 2019
		$detector{"pos"}         = "0*mm 0*mm $ZCenter*mm";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Sn";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		# CxC foils for the 2nd Needles Set
		
		# First 12C foil
		$ZCenter = 75.0;  # center location of target along beam axis
		$Rout       = 2;  #
		# New Thickness
		$length     = 1; #(2 mm thick)
		%detector = init_det();
		$detector{"name"}        = "3rdNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "First 12C Foil in Flag Assembly";
		# From Cyril drawing for centers positions
		$detector{"pos"}         = "27.496*mm -15.875*mm $ZCenter*mm";
		$detector{"color"}       = "#ff007f";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_C";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		# Second 12C Foil
		$ZCenter = 125.0;  # center location of target along beam axis
		
		$Rout       = 2;  #
		# New Thickness
		$length     = 1; #(2 mm thick)
		%detector = init_det();
		$detector{"name"}        = "4thNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Second 12C Foil in Flag Assembly";
		# From Cyril drawing for centers positions
		$detector{"pos"}         = "27.496*mm -15.875*mm $ZCenter*mm";
		$detector{"color"}       = "#ff007f";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_C";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
	}
	 elsif($thisVariation eq "lD2CxC")
	 {
	 
	 #
	 # lD2 Cell copied from lD2/lH2 variation
	 #
	 	my $nplanes = 4;

		my @oradius  =  (    50.2,   50.2,  21.0,  21.0 );
		my @z_plane  =  (  -115.0,  265.0, 290.0, 300.0 );


		if ($thisVariation eq "lH2e") {
			@z_plane  =  (  -115.0,  365.0, 390.0, 925.0 );
		}		

		# vacuum target container
		my %detector = init_det();
		$detector{"name"}        = "target";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Target Container";
		$detector{"color"}       = "22ff22";
		$detector{"type"}        = "Polycone";
		my $dimen = "0.0*deg 360*deg $nplanes*counts";
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradius[$i]*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_plane[$i]*mm";}
		$detector{"dimensions"}  = $dimen;
		$detector{"material"}    = "G4_Galactic";
		$detector{"style"}       = 0;
		print_det(\%configuration, \%detector);

		$nplanes = 5;
		my @oradiusT  =  (   2.5,  10.3,  7.3,  5.0,  2.5);
		my @z_planeT  =  ( -24.2, -21.2, 22.5, 23.5, 24.5);

		# actual target
		%detector = init_det();
		$detector{"name"}        = "lh2";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Target Cell";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Polycone";
		$dimen = "0.0*deg 360*deg $nplanes*counts";
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradiusT[$i]*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_planeT[$i]*mm";}
		$detector{"dimensions"}  = $dimen;
		$detector{"material"}    = "G4_lH2";
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);
				
		# CxC foils		
		#Upstream Foil: 12C 
		my $ZCenter = 75.0;  # center location of target along beam axis
		my $Rout       = 2;  #
		# New Thickness
		my $length     = 1; #(2 mm thick)
		%detector = init_det();
		$detector{"name"}        = "1stNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "First 12C Foil in Flag Assembly";
		#$detector{"pos"}         = "0 0 $ZCenter*mm";
		# As given by Cyril in May 2019
		$detector{"pos"}         = "0*mm 0*mm $ZCenter*mm";
		$detector{"color"}       = "aa0011";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_C";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		#Second 12C Foil
		$ZCenter = 125.0;  # center location of target along beam axis
		$Rout       = 2;  #
		# New Thickness
		$length     = 1; #(2 mm thick)
		%detector = init_det();
		$detector{"name"}        = "2ndNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Second 12C Foil in Flag Assembly";
		# As given by Cyril in May 2019 (considering y=0 mm is the bottom edge for 4mm wide foil)
		$detector{"pos"}         = "0*mm 0*mm $ZCenter*mm";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_C";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		# 63Cu & 120Sn foils for the 2nd set of needles		
		# 63Cu Foil
		$ZCenter = 75.0;  # center location of target along beam axis
		$Rout       = 2;  #
		$length     = 0.0465; #(0.093 mm thick) 
		%detector = init_det();
		$detector{"name"}        = "3rdNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "63Cu Foil in Flag Assembly";
		# From Cyril drawing for centers positions
		$detector{"pos"}         = "27.496*mm -15.875*mm $ZCenter*mm";
		# As given by Cyril in May 2019 from bottom edge/contact point with needle (-16.876mm)
		$detector{"color"}       = "#ff007f";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Cu";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		# 120Sn
		$ZCenter = 125.0;  # center location of target along beam axis
		$Rout       = 2;  #
		$length     = 0.0855; #(0.171 mm thick)
		%detector = init_det();
		$detector{"name"}        = "4thNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "120Sn Foil in Flag Assembly";
		# From Cyril drawing for centers positions
		$detector{"pos"}         = "27.496*mm -15.875*mm $ZCenter*mm";
		# As given by Cyril in May 2019 from bottom edge/contact point with needle (-16.876mm)
		$detector{"color"}       = "#ff007f";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Sn";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
	}

    # ALERT target 
    elsif($thisVariation eq "alertD2" || $thisVariation eq "alertH2" || $thisVariation eq "alertHe")
    {
	# adapted from bonus case
        # alert tg root volume
        my $Rout       = 4;
        my $length     = 322.27;  # mm!
        my %detector = init_det();
        $detector{"name"}        = "alertTarget";
        $detector{"mother"}      = "root";
        $detector{"description"} = "ALERT Target";
        $detector{"color"}       = "eeeegg";
        $detector{"type"}        = "Tube";
        $detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"material"}    = "HECO2";
        $detector{"style"}       = "1";
        $detector{"visible"}     = 1;
        print_det(\%configuration, \%detector);
        
        # ALERT target gas volume
        # made this the mother volume instead
        my $Rin        = 0.0;
        my $Rout       = 3.0;
        my $length     = 255;  
        my %detector = init_det();
        $detector{"name"}        = "gasTargetalert";
        $detector{"mother"}      = "alertTarget";
        $detector{"description"} = "target gas";
        $detector{"color"}       = "ffff00";
        $detector{"type"}        = "Tube";
        $detector{"dimensions"}  = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"style"}       = "1";
        
		if($thisVariation eq "alertD2")
		{
		$detector{"material"} = "alertTargetGas_D2";
		}
		if($thisVariation eq "alertH2")
		{
		$detector{"material"} = "alertTargetGas_H2";
		}
		if($thisVariation eq "alertHe")
		{
		$detector{"material"} = "alertTargetGas_He";
		}

	print_det(\%configuration, \%detector);
        
        # ALERT target wall
        $Rin        = 3.0; 
        $Rout       = 3.060; 
        $length     = 255;  
        %detector = init_det();
        $detector{"name"}        = "alertTargetWall";
        $detector{"mother"}      = "alertTarget";
        $detector{"description"} = "ALERT Target wall";
        $detector{"color"}       = "0000ff";
        $detector{"type"}        = "Tube";
        $detector{"dimensions"}  = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"material"}    = "G4_KAPTON";
        $detector{"style"}       = "1";
        print_det(\%configuration, \%detector);

	# ALERT target upstream aluminum end ring and window
	$Rin        = 3.061;
        $Rout       = 3.1561;
        $length     = 2.0;  # half length
        my $zPos       = -262.3;  # mm z position
        %detector = init_det();
        $detector{"name"}        = "alertTargetUpEndCapRing";
        $detector{"mother"}      = "alertTarget";
        $detector{"description"} = "ALERT Target Al upstream end cap ring";
        $detector{"color"}       = "ff0000";
        $detector{"type"}        = "Tube";
        $detector{"pos"}         = "0*mm 0*mm $zPos*mm";
        $detector{"dimensions"}  = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"material"}    = "G4_Al";
        $detector{"style"}       = "1";
        print_det(\%configuration, \%detector);
	
	$Rin        = 0.0;
        $Rout       = 3.1561;
        $length     = 0.015;  # half length
        $zPos       = -262.315;
        %detector = init_det();
        $detector{"name"}        = "alertTargetUpEndCapPlate";
        $detector{"mother"}      = "alertTarget";
        $detector{"description"} = "ALERT Target Al upstream end cap wall";
        $detector{"color"}       = "0af131";
        $detector{"type"}        = "Tube";
        $detector{"pos"}         = "0*mm 0*mm $zPos*mm";
        $detector{"dimensions"}  = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"material"}    = "G4_Al";
        $detector{"style"}       = "1";
        print_det(\%configuration, \%detector);
	
        # ALERT target downstream aluminum end ring
        $Rin        = 3.061;
        $Rout       = 3.1561;
        $length     = 2.0;  # half length
        $zPos       = 185.67;  # mm z position
        %detector = init_det();
        $detector{"name"}        = "alertTargetEndCapRing";
        $detector{"mother"}      = "alertTarget";
        $detector{"description"} = "ALERT Target Al end cap ring";
        $detector{"color"}       = "ff0000";
        $detector{"type"}        = "Tube";
        $detector{"pos"}         = "0*mm 0*mm $zPos*mm";
        $detector{"dimensions"}  = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"material"}    = "G4_Al";
        $detector{"style"}       = "1";
        print_det(\%configuration, \%detector);
        
        # ALERT target downstream aluminum end window
        $Rin        = 0.0;
        $Rout       = 3.1561;
        $length     = 0.015;  # half length
        $zPos       = 187.685;
        %detector = init_det();
        $detector{"name"}        = "alertTargetEndCapPlate";
        $detector{"mother"}      = "alertTarget";
        $detector{"description"} = "ALERT Target Al end cap wall";
        $detector{"color"}       = "0af131";
        $detector{"type"}        = "Tube";
        $detector{"pos"}         = "0*mm 0*mm $zPos*mm";
        $detector{"dimensions"}  = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"material"}    = "G4_Al";
        $detector{"style"}       = "1";
        print_det(\%configuration, \%detector);
        
    }

    #small targets
    if($thisVariation eq "RGM_2_Sn")
    {
	#Flag Shaft Geometry (cm/deg)
	my @flag_shaft = (0.2665, 0.3175, 8.145, 0, 360, 0, 0, 0);		#Inner radius, outer radius, half length (1), initial angle, final angle, x angle, y angle, z angle
	
	#Flag Pole Geometry (cm/deg)
	my @Sn_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 0, 0);	#Inner radius, outer radius, half length (2), initial angle, final angle, x angle, y angle, z angle for the Sn flag poles.
	my @C_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, -55, 0);	#Inner radius, outer radius, half length (2), initial angle, final angle, x angle, y angle, z angle for the C flag poles.
	
	#Flag Geometry (cm)
	my @Sn_flag = (0.167, 0.1905, 0.0355, 0, 0, 0);					#Half x, y, z dimensions and x, y, z angles for the Sn flag that holds the target foils.
	my @C_flag = (0.167, 0.1905, 0.0355, 0, 0, 55);					#Half x, y, z dimensions and x, y, z angles for the C flag that holds the target foils.
	
	#Targets Geometry (cm)
	my @Sn_target = (0.1685, 0.405, 0.1, 0, 0, 0);					#Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
	my @C_target = (0.1685, 0.405, 0.1, 0, 0, 55);					#Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
	
	
	
	
	my $separation = 0.127;											#Distance the flags set the target above the end of the flag poles.		
	
	my @flag_pole_relpos = (0.381, 1.25, 1.25, 1.25);				#Distance from end of flag_shaft to center of flag_pole 1, center of flag_pole 1 to center of flag_pole 2, center of flag_pole 2 to center of flag_pole 3, and center of flag_pole 3 to center of flag_pole 4
	my @row = ($flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2] - $flag_pole_relpos[3], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1], $flag_shaft[2] - $flag_pole_relpos[0]);							#Positions of rows of the flag_poles.
	
	#offset to "zero" the center of the target.
	my $offset_x = 0.0;
	my $offset_y = -(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation); #Set Y=0 to be center on target.
	my $offset_z = (0.625 - (($row[1] - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2] ) + ($row[2] - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2] ))/2); #0.625 from magic? (first flag is flag 0)
	
	#Adjusted position of the rows for the flag poles.
	my $row_pole = ($row[3] + $offset_z);

	#Adjusted positions of the rows for the target foils.
	my $row_target = ($row[3] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2]);
	
	#Adjusted positions of the rows for the flags.
	my $row_flag = ($row[3] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2]);
	
	
	
	
	#Sn Flag Pole position (cm).
	my $sT_x2 = 0.0 + $offset_x;
	my $Sn_p_y = $Sn_flag_pole[2] + $flag_shaft[1] + $offset_y;
	
	#C Flag Pole positions (cm).
	my $C_p_x = 0.81915*($C_flag_pole[2] + $flag_shaft[1]) + $offset_x;											#Cos(35) is the decimal out front.
	my $C_p_y = 0.57358*($C_flag_pole[2] + $flag_shaft[1]) + $offset_y;											#Sin(35) is the decimal out front.

	#Sn Targets positions (cm).
	my $Sn_t_x = 0.0 + $offset_x;
	my $Sn_t_y = (2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;
	
	#C Targets positions (cm).
	my $C_t_x = 0.81915*(2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_x;			#Cos(35) is the decimal out front.
	my $C_t_y = 0.57358*(2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;			#Sin(35) is the decimal out front.
	
	#Sn Flag positions (cm).
	my $Sn_f_x = 0.0 + $offset_x;
	my $Sn_f_y = (2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;
	
	#C Flag positions (cm).
	my $C_f_x = 0.81915*(2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_x;							#Cos(35) is the decimal out front.
	my $C_f_y = 0.57358*(2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;							#Sin(35) is the decimal out front.
	
	
	
	
	#Mother Volume
	my $nplanes = 4;
	my @oradius  =  (    50.2,   50.2,  21.0,  21.0 );
	my @z_plane  =  (  -115.0,  265.0, 290.0, 300.0 );
	
	# vacuum target container
	my %detector = init_det();
	$detector{"name"}        = "target";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Target Container";
	$detector{"color"}       = "22ff22";
	$detector{"type"}        = "Polycone";
	my $dimen = "0.0*deg 360*deg $nplanes*counts";
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradius[$i]*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_plane[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "G4_Galactic";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);
	
	
	#Flag Shaft
	$detector{"name"}        = "flag shaft";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Tube Main";
	$detector{"pos"}         = "$offset_x*cm $offset_y*cm $offset_z*cm";
	$detector{"rotation"}    = "$flag_shaft[5]*deg $flag_shaft[6]*deg $flag_shaft[7]*deg";
	$detector{"color"}       = "000099";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$flag_shaft[0]*cm $flag_shaft[1]*cm $flag_shaft[2]*cm 0*deg 360*deg";
	$detector{"material"}    = "G4_Al"; #Al 6061-T6
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	

	#C flag poles.
	$detector{"name"}        = "C_p1";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Flag Pole C";
	$detector{"pos"}         = "$C_p_x*cm $C_p_y*cm $row_pole*cm";
	$detector{"rotation"}    = "$C_flag_pole[5]*deg $C_flag_pole[6]*deg $C_flag_pole[7]*deg";
	$detector{"color"}       = "990000";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$C_flag_pole[0]*cm $C_flag_pole[1]*cm $C_flag_pole[2]*cm 0*deg 360*deg";
	$detector{"material"}    = "G4_Al"; #Al 6061
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	
	#Sn flag poles. 
	$detector{"name"}        = "Sn_p1";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Flag Pole Sn";
	$detector{"pos"}         = "$sT_x2*cm $Sn_p_y*cm $row_pole*cm";
	$detector{"rotation"}    = "$Sn_flag_pole[5]*deg $Sn_flag_pole[6]*deg $Sn_flag_pole[7]*deg";
	$detector{"color"}       = "990000";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$Sn_flag_pole[0]*cm $Sn_flag_pole[1]*cm $Sn_flag_pole[2]*cm 0*deg 360*deg";
	$detector{"material"}    = "G4_Al";#Al 6061
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	
	#Carbon foil targets.
	$detector{"name"}        = "Carbon_t1";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target C";
	$detector{"pos"}         = "$C_t_x*cm $C_t_y*cm $row_target*cm";
	$detector{"rotation"}    = "$C_target[3]*deg $C_target[4]*deg $C_target[5]*deg";
	$detector{"color"}       = "000099";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "$C_target[0]*cm $C_target[1]*cm $C_target[2]*cm";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	
	#Tin foil targets.
	$detector{"name"}        = "Tin_t1";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Sn";
	$detector{"pos"}         = "$Sn_t_x*cm $Sn_t_y*cm $row_target*cm";
	$detector{"rotation"}    = "$Sn_target[3]*deg $Sn_target[4]*deg $Sn_target[5]*deg";
	$detector{"color"}       = "444444";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "$Sn_target[0]*cm $Sn_target[1]*cm $Sn_target[2]*cm";
	$detector{"material"}    = "G4_Sn";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	
	#Carbon Flag.
	$detector{"name"}        = "C_flag";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Flag C";
	$detector{"pos"}         = "$C_f_x*cm $C_f_y*cm $row_flag*cm";
	$detector{"rotation"}    = "$C_flag[3]*deg $C_flag[4]*deg $C_flag[5]*deg";
	$detector{"color"}       = "009900";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "$C_flag[0]*cm $C_flag[1]*cm $C_flag[2]*cm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	
	#Tin Flag.
	$detector{"name"}        = "Sn_flag";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Flag Sn";
	$detector{"pos"}         = "$Sn_f_x*cm $Sn_f_y*cm $row_flag*cm";
	$detector{"rotation"}    = "$Sn_flag[3]*deg $Sn_flag[4]*deg $Sn_flag[5]*deg";
	$detector{"color"}       = "009900";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "$Sn_flag[0]*cm $Sn_flag[1]*cm $Sn_flag[2]*cm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
    }





    #small targets
    if($thisVariation eq "RGM_2_C")
    {
	#Flag Shaft Geometry (cm/deg)
	my @flag_shaft = (0.2665, 0.3175, 8.145, 0, 360, 0, 0, 0);		#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle

	#Flag Pole Geometry (cm/deg)
	my @Sn_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 55, 0);	#Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the Sn flag poles.
	my @C_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 0, 0);	#Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the C flag poles.

	#Flag Geometry (cm)
	my @Sn_flag = (0.167, 0.1905, 0.0355, 0, 0, -55);				#Half x, y, z dimensions and x, y, z angles for the Sn flag that holds the target foils.
	my @C_flag = (0.167, 0.1905, 0.0355, 0, 0, 0);					#Half x, y, z dimensions and x, y, z angles for the C flag that holds the target foils.
	
	#Targets Geometry (cm)
	my @Sn_target = (0.1685, 0.405, 0.1, 0, 0, -55);				#Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
	my @C_target = (0.1685, 0.405, 0.1, 0, 0, 0);					#Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.




	my $separation = 0.127;											#Distance the flags set the target above the end of the flag poles.		
	
	my @flag_pole_relpos = (0.381, 1.25, 1.25, 1.25);				#Distance from end of flag_shaft to center of flag_pole 1, center of flag_pole 1 to center of flag_pole 2, center of flag_pole 2 to center of flag_pole 3, and center of flag_pole 3 to center of flag_pole 4
	my @row = ($flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2] - $flag_pole_relpos[3], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1], $flag_shaft[2] - $flag_pole_relpos[0]);							#Positions of rows of the flag_poles.

	#offset to "zero" the center of the target.
	my $offset_x = 0.0;
	my $offset_y = -(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation); #Set Y=0 to be center on target.
	my $offset_z = (0.625 - (($row[1] - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2] ) + ($row[2] - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2] ))/2); #0.625 from magic? (first flag is flag 0)
	
	#Adjusted position of the rows for the flag poles.
	my $row_pole = ($row[3] + $offset_z);

	#Adjusted positions of the rows for the target foils.
	my $row_target = ($row[3] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2]);

	#Adjusted positions of the rows for the flags.
	my $row_flag = ($row[3] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2]);





	#Sn Flag Pole position (cm).
	my $sT_x2 = -(0.81915*($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_x);										#Cos(35) is the decimal out front.
	my $Sn_p_y = 0.57358*($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_y;										#Sin(35) is the decimal out front.

	#C Flag Pole positions (cm).
	my $C_p_x = 0.0 + $offset_x;
	my $C_p_y = $C_flag_pole[2] + $flag_shaft[1] + $offset_y;

	#Sn Targets positions (cm).
	my $Sn_t_x = -(0.81915*(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_x);		#Cos(35) is the decimal out front.
	my $Sn_t_y = 0.57358*(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;		#Sin(35) is the decimal out front.		

	#C Targets positions (cm).
	my $C_t_x = 0.0 + $offset_x;
	my $C_t_y = (2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;

	#Sn Flag positions (cm).
	my $Sn_f_x = -(0.81915*(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_x);						#Cos(35) is the decimal out front.
	my $Sn_f_y = 0.57358*(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;						#Sin(35) is the decimal out front.
	
	#C Flag positions (cm).
	my $C_f_x = 0.0 + $offset_x;
	my $C_f_y = (2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;




	#Mother Volume
	my $nplanes = 4;
	my @oradius  =  (    50.2,   50.2,  21.0,  21.0 );
	my @z_plane  =  (  -115.0,  265.0, 290.0, 300.0 );

	# vacuum target container
	my %detector = init_det();
	$detector{"name"}        = "target";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Target Container";
	$detector{"color"}       = "22ff22";
	$detector{"type"}        = "Polycone";
	my $dimen = "0.0*deg 360*deg $nplanes*counts";
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradius[$i]*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_plane[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "G4_Galactic";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);
	

	#Flag Shaft
	$detector{"name"}        = "flag shaft";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Tube Main";
	$detector{"pos"}         = "$offset_x*cm $offset_y*cm $offset_z*cm";
	$detector{"rotation"}    = "$flag_shaft[5]*deg $flag_shaft[6]*deg $flag_shaft[7]*deg";
	$detector{"color"}       = "000099";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$flag_shaft[0]*cm $flag_shaft[1]*cm $flag_shaft[2]*cm 0*deg 360*deg";
	$detector{"material"}    = "G4_Al"; #Al 6061-T6
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	

	#C flag poles.
	$detector{"name"}        = "C_p1";
	$detector{"mother"}      = "target"; #Carbon
	$detector{"description"} = "RGM Solid Target Flag Pole C";
	$detector{"pos"}         = "$C_p_x*cm $C_p_y*cm $row_pole*cm";
	$detector{"rotation"}    = "$C_flag_pole[5]*deg $C_flag_pole[6]*deg $C_flag_pole[7]*deg";
	$detector{"color"}       = "990000";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$C_flag_pole[0]*cm $C_flag_pole[1]*cm $C_flag_pole[2]*cm 0*deg 360*deg";
	$detector{"material"}    = "G4_Al"; #Al 6061
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	

	#Sn flag poles. 
	$detector{"name"}        = "Sn_p1";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Flag Pole Sn";
	$detector{"pos"}         = "$sT_x2*cm $Sn_p_y*cm $row_pole*cm";
	$detector{"rotation"}    = "$Sn_flag_pole[5]*deg $Sn_flag_pole[6]*deg $Sn_flag_pole[7]*deg";
	$detector{"color"}       = "990000";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$Sn_flag_pole[0]*cm $Sn_flag_pole[1]*cm $Sn_flag_pole[2]*cm 0*deg 360*deg";
	$detector{"material"}    = "G4_Al";#Al 6061
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);


	#Carbon foil targets.
	$detector{"name"}        = "Carbon_t1";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target C";
	$detector{"pos"}         = "$C_t_x*cm $C_t_y*cm $row_target*cm";
	$detector{"rotation"}    = "$C_target[3]*deg $C_target[4]*deg $C_target[5]*deg";
	$detector{"color"}       = "000099";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "$C_target[0]*cm $C_target[1]*cm $C_target[2]*cm";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);


	#Tin foil targets.
	$detector{"name"}        = "Tin_t1";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Sn";
	$detector{"pos"}         = "$Sn_t_x*cm $Sn_t_y*cm $row_target*cm";
	$detector{"rotation"}    = "$Sn_target[3]*deg $Sn_target[4]*deg $Sn_target[5]*deg";
	$detector{"color"}       = "444444";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "$Sn_target[0]*cm $Sn_target[1]*cm $Sn_target[2]*cm";
	$detector{"material"}    = "G4_Sn";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);


	#Carbon Flag.
	$detector{"name"}        = "C_flag";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Flag C";
	$detector{"pos"}         = "$C_f_x*cm $C_f_y*cm $row_flag*cm";
	$detector{"rotation"}    = "$C_flag[3]*deg $C_flag[4]*deg $C_flag[5]*deg";
	$detector{"color"}       = "009900";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "$C_flag[0]*cm $C_flag[1]*cm $C_flag[2]*cm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	

	#Tin Flag.
	$detector{"name"}        = "Sn_flag";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Flag Sn";
	$detector{"pos"}         = "$Sn_f_x*cm $Sn_f_y*cm $row_flag*cm";
	$detector{"rotation"}    = "$Sn_flag[3]*deg $Sn_flag[4]*deg $Sn_flag[5]*deg";
	$detector{"color"}       = "009900";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "$Sn_flag[0]*cm $Sn_flag[1]*cm $Sn_flag[2]*cm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
    }




    #small targets
    if($thisVariation eq "RGM_8_Sn_S")
    {
	#Flag Shaft Geometry (cm/deg)
	my @flag_shaft = (0.2665, 0.3175, 8.145, 0, 360, 0, 0, 0);		#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle

	#Flag Pole Geometry (cm/deg)
	my @Sn_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 0, 0);	#Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the Sn flag poles.
	my @C_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, -55, 0);	#Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the C flag poles.

	#Flag Geometry (cm)
	my @Sn_flag = (0.167, 0.1905, 0.0355, 0, 0, 0);					#Half x, y, z dimensions and x, y, z angles for the Sn flag that holds the target foils.
	my @C_flag = (0.167, 0.1905, 0.0355, 0, 0, 55);					#Half x, y, z dimensions and x, y, z angles for the C flag that holds the target foils.
	
	#Targets Geometry (cm)
	my @Sn_target = (0.1685, 0.405, 0.025, 0, 0, 0);				#Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
	my @C_target = (0.1685, 0.405, 0.025, 0, 0, 55);				#Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.




	my $separation = 0.127;											#Distance the flags set the target above the end of the flag poles.		
	
	my @flag_pole_relpos = (0.381, 1.25, 1.25, 1.25);				#Distance from end of flag_shaft to center of flag_pole 1, center of flag_pole 1 to center of flag_pole 2, center of flag_pole 2 to center of flag_pole 3, and center of flag_pole 3 to center of flag_pole 4
	my @row = ($flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2] - $flag_pole_relpos[3], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1], $flag_shaft[2] - $flag_pole_relpos[0]);							#Positions of rows of the flag_poles.

	#offset to "zero" everything where I want.
	my $offset_x = 0.0;
	my $offset_y = -(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation);
	my $offset_z = -(($row[1] - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2] ) + ($row[2] - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2] ))/2;
	
	#Adjusted position of the rows for the flag poles.
	my @row_pole = ($row[0] + $offset_z, $row[1] + $offset_z, $row[2] + $offset_z, $row[3] + $offset_z);

	#Adjusted positions of the rows for the target foils.
	my @row_target = ($row[0] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2], $row[1] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2], $row[2] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2], $row[3] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2]);

	#Adjusted positions of the rows for the flags.
	my @row_flag = ($row[0] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[1] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[2] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[3] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2]);




	#Sn Flag Pole position (cm).
	my $Sn_p_x = 0.0 + $offset_x;
	my $Sn_p_y = $Sn_flag_pole[2] + $flag_shaft[1] + $offset_y;

	#C Flag Pole positions (cm).
	my $C_p_x = 0.81915*($C_flag_pole[2] + $flag_shaft[1]) + $offset_x;											#Cos(35) is the decimal out front.
	my $C_p_y = 0.57358*($C_flag_pole[2] + $flag_shaft[1]) + $offset_y;											#Sin(35) is the decimal out front.

	#Sn Targets positions (cm).
	my $Sn_t_x = 0.0 + $offset_x;
	my $Sn_t_y = (2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;

	#C Targets positions (cm).
	my $C_t_x = 0.81915*(2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_x;			#Cos(35) is the decimal out front.
	my $C_t_y = 0.57358*(2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;			#Sin(35) is the decimal out front.

	#Sn Flag positions (cm).
	my $Sn_f_x = 0.0 + $offset_x;
	my $Sn_f_y = (2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;
	
	#C Flag positions (cm).
	my $C_f_x = 0.81915*(2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_x;							#Cos(35) is the decimal out front.
	my $C_f_y = 0.57358*(2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;							#Sin(35) is the decimal out front.




	#Mother Volume
	my $nplanes = 4;
	my @oradius  =  (    50.2,   50.2,  21.0,  21.0 );
	my @z_plane  =  (  -115.0,  265.0, 290.0, 300.0 );

	# vacuum target container
	my %detector = init_det();
	$detector{"name"}        = "target";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Target Container";
	$detector{"color"}       = "22ff22";
	$detector{"type"}        = "Polycone";
	my $dimen = "0.0*deg 360*deg $nplanes*counts";
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradius[$i]*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_plane[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "G4_Galactic";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);
	

	#Flag Shaft
	$detector{"name"}        = "flag shaft";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Tube Main";
	$detector{"pos"}         = "$offset_x*cm $offset_y*cm $offset_z*cm";
	$detector{"rotation"}    = "$flag_shaft[5]*deg $flag_shaft[6]*deg $flag_shaft[7]*deg";
	$detector{"color"}       = "000099";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$flag_shaft[0]*cm $flag_shaft[1]*cm $flag_shaft[2]*cm 0*deg 360*deg";
	$detector{"material"}    = "G4_Al"; #Al 6061-T6
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	

	#C flag poles.
	my @name = ("C_p1", "C_p2", "C_p3", "C_p4");#So that all the entires in the text file have unique names if I have to look at it.
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag Pole C";
	    $detector{"pos"}         = "$C_p_x*cm $C_p_y*cm $row_pole[$i]*cm";
	    $detector{"rotation"}    = "$C_flag_pole[5]*deg $C_flag_pole[6]*deg $C_flag_pole[7]*deg";
	    $detector{"color"}       = "990000";
	    $detector{"type"}        = "Tube";
	    $detector{"dimensions"}  = "$C_flag_pole[0]*cm $C_flag_pole[1]*cm $C_flag_pole[2]*cm 0*deg 360*deg";
	    $detector{"material"}    = "G4_Al"; #Al 6061
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}
	

	#Sn flag poles. 
	@name = ("Sn_p1", "Sn_p2", "Sn_p3", "Sn_p4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag Pole Sn";
	    $detector{"pos"}         = "$Sn_p_x*cm $Sn_p_y*cm $row_pole[$i]*cm";
	    $detector{"rotation"}    = "$Sn_flag_pole[5]*deg $Sn_flag_pole[6]*deg $Sn_flag_pole[7]*deg";
	    $detector{"color"}       = "990000";
	    $detector{"type"}        = "Tube";
	    $detector{"dimensions"}  = "$Sn_flag_pole[0]*cm $Sn_flag_pole[1]*cm $Sn_flag_pole[2]*cm 0*deg 360*deg";
	    $detector{"material"}    = "G4_Al"; #Al 6061
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}


	#Carbon foil targets.
	@name = ("Carbon_t1", "Carbon_t2", "Carbon_t3", "Carbon_t4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target C";
	    $detector{"pos"}         = "$C_t_x*cm $C_t_y*cm $row_target[$i]*cm";
	    $detector{"rotation"}    = "$C_target[3]*deg $C_target[4]*deg $C_target[5]*deg";
	    $detector{"color"}       = "000099";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$C_target[0]*cm $C_target[1]*cm $C_target[2]*cm";
	    $detector{"material"}    = "G4_C";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}


	#Tin foil targets.
	@name = ("Tin_t1", "Tin_t2", "Tin_t3", "Tin_t4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Sn";
	    $detector{"pos"}         = "$Sn_t_x*cm $Sn_t_y*cm $row_target[$i]*cm";
	    $detector{"rotation"}    = "$Sn_target[3]*deg $Sn_target[4]*deg $Sn_target[5]*deg";
	    $detector{"color"}       = "444444";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$Sn_target[0]*cm $Sn_target[1]*cm $Sn_target[2]*cm";
	    $detector{"material"}    = "G4_Sn";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}


	#Carbon Flags.
	@name = ("C_flag1", "c_flag2", "C_flag3", "C_flag4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag C";
	    $detector{"pos"}         = "$C_f_x*cm $C_f_y*cm $row_flag[$i]*cm";
	    $detector{"rotation"}    = "$C_flag[3]*deg $C_flag[4]*deg $C_flag[5]*deg";
	    $detector{"color"}       = "009900";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$C_flag[0]*cm $C_flag[1]*cm $C_flag[2]*cm";
	    $detector{"material"}    = "G4_Al";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}
	

	#Tin Flags.
	@name = ("Sn_flag1", "Sn_flag2", "Sn_flag3", "Sn_flag4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag Sn";
	    $detector{"pos"}         = "$Sn_f_x*cm $Sn_f_y*cm $row_flag[$i]*cm";
	    $detector{"rotation"}    = "$Sn_flag[3]*deg $Sn_flag[4]*deg $Sn_flag[5]*deg";
	    $detector{"color"}       = "009900";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$Sn_flag[0]*cm $Sn_flag[1]*cm $Sn_flag[2]*cm";
	    $detector{"material"}    = "G4_Al";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}
    }





    #large targets
    if($thisVariation eq "RGM_8_Sn_L")
    {
	#Flag Shaft Geometry (cm/deg)
	my @flag_shaft = (0.2665, 0.3175, 8.145, 0, 360, 0, 0, 0);		#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle

	#Flag Pole Geometry (cm/deg)
	my @Sn_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 0, 0);	#Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the Sn flag poles.
	my @C_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, -55, 0);	#Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the C flag poles.
   
	#Flag Geometry (cm)
	my @Sn_flag = (0.167, 0.1905, 0.0355, 0, 0, 0);					#Half x, y, z dimensions and x, y, z angles for the Sn flag that holds the target foils.
	my @C_flag = (0.167, 0.1905, 0.0355, 0, 0, 55);					#Half x, y, z dimensions and x, y, z angles for the C flag that holds the target foils.
	
	#Targets Geometry (cm)
	my @Sn_target = (0.2397, 0.455, 0.025, 0, 0, 0);				#Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
	my @C_target = (0.2397, 0.455, 0.025, 0, 0, 55);				#Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.

  


	my $separation = 0.127;											#Distance the flags set the target above the end of the flag poles.		
	
	my @flag_pole_relpos = (0.381, 1.25, 1.25, 1.25);				#Distance from end of flag_shaft to center of flag_pole 1, center of flag_pole 1 to center of flag_pole 2, center of flag_pole 2 to center of flag_pole 3, and center of flag_pole 3 to center of flag_pole 4
	my @row = ($flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2] - $flag_pole_relpos[3], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1], $flag_shaft[2] - $flag_pole_relpos[0]);							#Positions of rows of the flag_poles.

	#offset to "zero" everything where I want.
	my $offset_x = 0.0;
	my $offset_y = -(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation);
	my $offset_z = -(($row[1] - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2] ) + ($row[2] - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2] ))/2;
	
	#Adjusted position of the rows for the flag poles.
	my @row_pole = ($row[0] + $offset_z, $row[1] + $offset_z, $row[2] + $offset_z, $row[3] + $offset_z);

	#Adjusted positions of the rows for the target foils.
	my @row_target = ($row[0] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2], $row[1] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2], $row[2] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2], $row[3] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2]);
    
	#Adjusted positions of the rows for the flags.
	my @row_flag = ($row[0] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[1] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[2] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[3] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2]);
    
 

   
	#Sn Flag Pole position (cm).
	my $Sn_p_x = 0.0 + $offset_x;
	my $Sn_p_y = $Sn_flag_pole[2] + $flag_shaft[1] + $offset_y;

	#C Flag Pole positions (cm).
	my $C_p_x = 0.81915*($C_flag_pole[2] + $flag_shaft[1]) + $offset_x;											#Cos(35) is the decimal out front.
	my $C_p_y = 0.57358*($C_flag_pole[2] + $flag_shaft[1]) + $offset_y;											#Sin(35) is the decimal out front.

	#Sn Targets positions (cm).
	my $Sn_t_x = 0.0 + $offset_x;
	my $Sn_t_y = (2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;

	#C Targets positions (cm).
	my $C_t_x = 0.81915*(2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_x;			#Cos(35) is the decimal out front.
	my $C_t_y = 0.57358*(2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;			#Sin(35) is the decimal out front.

	#Sn Flag positions (cm).
	my $Sn_f_x = 0.0 + $offset_x;
	my $Sn_f_y = (2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;
	
	#C Flag positions (cm).
	my $C_f_x = 0.81915*(2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_x;							#Cos(35) is the decimal out front.
	my $C_f_y = 0.57358*(2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;							#Sin(35) is the decimal out front.




	#Mother Volume
	my $nplanes = 4;
	my @oradius  =  (    50.2,   50.2,  21.0,  21.0 );
	my @z_plane  =  (  -115.0,  265.0, 290.0, 300.0 );

	# vacuum target container
	my %detector = init_det();
	$detector{"name"}        = "target";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Target Container";
	$detector{"color"}       = "22ff22";
	$detector{"type"}        = "Polycone";
	my $dimen = "0.0*deg 360*deg $nplanes*counts";
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradius[$i]*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_plane[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "G4_Galactic";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);
	

	#Flag Shaft
	$detector{"name"}        = "flag shaft";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Tube Main";
	$detector{"pos"}         = "$offset_x*cm $offset_y*cm $offset_z*cm";
	$detector{"rotation"}    = "$flag_shaft[5]*deg $flag_shaft[6]*deg $flag_shaft[7]*deg";
	$detector{"color"}       = "000099";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$flag_shaft[0]*cm $flag_shaft[1]*cm $flag_shaft[2]*cm 0*deg 360*deg";
	$detector{"material"}    = "G4_Al"; #Al 6061-T6
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	

	#C flag poles.
	my @name = ("C_p1", "C_p2", "C_p3", "C_p4");#So that all the entires in the text file have unique names if I have to look at it.
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag Pole C";
	    $detector{"pos"}         = "$C_p_x*cm $C_p_y*cm $row_pole[$i]*cm";
	    $detector{"rotation"}    = "$C_flag_pole[5]*deg $C_flag_pole[6]*deg $C_flag_pole[7]*deg";
	    $detector{"color"}       = "990000";
	    $detector{"type"}        = "Tube";
	    $detector{"dimensions"}  = "$C_flag_pole[0]*cm $C_flag_pole[1]*cm $C_flag_pole[2]*cm 0*deg 360*deg";
	    $detector{"material"}    = "G4_Al"; #Al 6061
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}
	

	#Sn flag poles. 
	@name = ("Sn_p1", "Sn_p2", "Sn_p3", "Sn_p4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag Pole Sn";
	    $detector{"pos"}         = "$Sn_p_x*cm $Sn_p_y*cm $row_pole[$i]*cm";
	    $detector{"rotation"}    = "$Sn_flag_pole[5]*deg $Sn_flag_pole[6]*deg $Sn_flag_pole[7]*deg";
	    $detector{"color"}       = "990000";
	    $detector{"type"}        = "Tube";
	    $detector{"dimensions"}  = "$Sn_flag_pole[0]*cm $Sn_flag_pole[1]*cm $Sn_flag_pole[2]*cm 0*deg 360*deg";
	    $detector{"material"}    = "G4_Al"; #Al 6061
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}


	#Carbon foil targets.
	@name = ("Carbon_t1", "Carbon_t2", "Carbon_t3", "Carbon_t4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target C";
	    $detector{"pos"}         = "$C_t_x*cm $C_t_y*cm $row_target[$i]*cm";
	    $detector{"rotation"}    = "$C_target[3]*deg $C_target[4]*deg $C_target[5]*deg";
	    $detector{"color"}       = "000099";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$C_target[0]*cm $C_target[1]*cm $C_target[2]*cm";
	    $detector{"material"}    = "G4_C";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}


	#Tin foil targets.
	@name = ("Tin_t1", "Tin_t2", "Tin_t3", "Tin_t4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Sn";
	    $detector{"pos"}         = "$Sn_t_x*cm $Sn_t_y*cm $row_target[$i]*cm";
	    $detector{"rotation"}    = "$Sn_target[3]*deg $Sn_target[4]*deg $Sn_target[5]*deg";
	    $detector{"color"}       = "444444";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$Sn_target[0]*cm $Sn_target[1]*cm $Sn_target[2]*cm";
	    $detector{"material"}    = "G4_Sn";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}


	#Carbon Flags.
	@name = ("C_flag1", "c_flag2", "C_flag3", "C_flag4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag C";
	    $detector{"pos"}         = "$C_f_x*cm $C_f_y*cm $row_flag[$i]*cm";
	    $detector{"rotation"}    = "$C_flag[3]*deg $C_flag[4]*deg $C_flag[5]*deg";
	    $detector{"color"}       = "009900";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$C_flag[0]*cm $C_flag[1]*cm $C_flag[2]*cm";
	    $detector{"material"}    = "G4_Al";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}
	

	#Tin Flags.
	@name = ("Sn_flag1", "Sn_flag2", "Sn_flag3", "Sn_flag4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag Sn";
	    $detector{"pos"}         = "$Sn_f_x*cm $Sn_f_y*cm $row_flag[$i]*cm";
	    $detector{"rotation"}    = "$Sn_flag[3]*deg $Sn_flag[4]*deg $Sn_flag[5]*deg";
	    $detector{"color"}       = "009900";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$Sn_flag[0]*cm $Sn_flag[1]*cm $Sn_flag[2]*cm";
	    $detector{"material"}    = "G4_Al";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}
    }



    #small targets
    if($thisVariation eq "RGM_8_C_S")
    {
	#Flag Shaft Geometry (cm/deg)
	my @flag_shaft = (0.2665, 0.3175, 8.145, 0, 360, 0, 0, 0);		#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle

	#Flag Pole Geometry (cm/deg)
	my @Sn_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 55, 0);	#Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the Sn flag poles.
	my @C_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 0, 0);	#Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the C flag poles.

	#Flag Geometry (cm)
	my @Sn_flag = (0.167, 0.1905, 0.0355, 0, 0, -55);				#Half x, y, z dimensions and x, y, z angles for the Sn flag that holds the target foils.
	my @C_flag = (0.167, 0.1905, 0.0355, 0, 0, 0);					#Half x, y, z dimensions and x, y, z angles for the C flag that holds the target foils.
	
	#Targets Geometry (cm)
	my @Sn_target = (0.1685, 0.405, 0.025, 0, 0, -55);				#Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
	my @C_target = (0.1685, 0.405, 0.025, 0, 0, 0);					#Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.




	my $separation = 0.127;											#Distance the flags set the target above the end of the flag poles.		
	
	my @flag_pole_relpos = (0.381, 1.25, 1.25, 1.25);				#Distance from end of flag_shaft to center of flag_pole 1, center of flag_pole 1 to center of flag_pole 2, center of flag_pole 2 to center of flag_pole 3, and center of flag_pole 3 to center of flag_pole 4
	my @row = ($flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2] - $flag_pole_relpos[3], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1], $flag_shaft[2] - $flag_pole_relpos[0]);							#Positions of rows of the flag_poles.

	#offset to "zero" everything where I want.
	my $offset_x = 0.0;
	my $offset_y = -(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation);
	my $offset_z = -(($row[1] - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2] ) + ($row[2] - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2] ))/2;
	
	#Adjusted position of the rows for the flag poles.
	my @row_pole = ($row[0] + $offset_z, $row[1] + $offset_z, $row[2] + $offset_z, $row[3] + $offset_z);

	#Adjusted positions of the rows for the target foils.
	my @row_target = ($row[0] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2], $row[1] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2], $row[2] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2], $row[3] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2]);

	#Adjusted positions of the rows for the flags.
	my @row_flag = ($row[0] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[1] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[2] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[3] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2]);




	#Sn Flag Pole position (cm).
	my $Sn_p_x = -(0.81915*($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_x);								#Cos(35) is the decimal out front.
	my $Sn_p_y = 0.57358*($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_y;									#Sin(35) is the decimal out front.

	#C Flag Pole positions (cm).
	my $C_p_x = 0.0 + $offset_x;
	my $C_p_y = $C_flag_pole[2] + $flag_shaft[1] + $offset_y;

	#Sn Targets positions (cm).
	my $Sn_t_x = -(0.81915*(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_x);#Cos(35) is the decimal out front.
	my $Sn_t_y = 0.57358*(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;	#Sin(35) is the decimal out front.

	#C Targets positions (cm).
	my $C_t_x = 0.0 + $offset_x;
	my $C_t_y = (2*$C_flag_pole[2] + $flag_shaft[1] + $C_target[1] + $separation) + $offset_y;

	#Sn Flag positions (cm).
	my $Sn_f_x = -(0.81915*(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_x);				#Cos(35) is the decimal out front.
	my $Sn_f_y = 0.57358*(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;					#Sin(35) is the decimal out front.
	
	#C Flag positions (cm).
	my $C_f_x = 0.0 + $offset_x;
	my $C_f_y = (2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;





	#Mother Volume
	my $nplanes = 4;
	my @oradius  =  (    50.2,   50.2,  21.0,  21.0 );
	my @z_plane  =  (  -115.0,  265.0, 290.0, 300.0 );

	# vacuum target container
	my %detector = init_det();
	$detector{"name"}        = "target";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Target Container";
	$detector{"color"}       = "22ff22";
	$detector{"type"}        = "Polycone";
	my $dimen = "0.0*deg 360*deg $nplanes*counts";
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradius[$i]*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_plane[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "G4_Galactic";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);
	

	#Flag Shaft
	$detector{"name"}        = "flag shaft";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Tube Main";
	$detector{"pos"}         = "$offset_x*cm $offset_y*cm $offset_z*cm";
	$detector{"rotation"}    = "$flag_shaft[5]*deg $flag_shaft[6]*deg $flag_shaft[7]*deg";
	$detector{"color"}       = "000099";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$flag_shaft[0]*cm $flag_shaft[1]*cm $flag_shaft[2]*cm 0*deg 360*deg";
	$detector{"material"}    = "G4_Al"; #Al 6061-T6
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	

	#C flag poles.
	my @name = ("C_p1", "C_p2", "C_p3", "C_p4");#So that all the entires in the text file have unique names if I have to look at it.
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag Pole C";
	    $detector{"pos"}         = "$C_p_x*cm $C_p_y*cm $row_pole[$i]*cm";
	    $detector{"rotation"}    = "$C_flag_pole[5]*deg $C_flag_pole[6]*deg $C_flag_pole[7]*deg";
	    $detector{"color"}       = "990000";
	    $detector{"type"}        = "Tube";
	    $detector{"dimensions"}  = "$C_flag_pole[0]*cm $C_flag_pole[1]*cm $C_flag_pole[2]*cm 0*deg 360*deg";
	    $detector{"material"}    = "G4_Al"; #Al 6061
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}
	

	#Sn flag poles. 
	@name = ("Sn_p1", "Sn_p2", "Sn_p3", "Sn_p4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag Pole Sn";
	    $detector{"pos"}         = "$Sn_p_x*cm $Sn_p_y*cm $row_pole[$i]*cm";
	    $detector{"rotation"}    = "$Sn_flag_pole[5]*deg $Sn_flag_pole[6]*deg $Sn_flag_pole[7]*deg";
	    $detector{"color"}       = "990000";
	    $detector{"type"}        = "Tube";
	    $detector{"dimensions"}  = "$Sn_flag_pole[0]*cm $Sn_flag_pole[1]*cm $Sn_flag_pole[2]*cm 0*deg 360*deg";
	    $detector{"material"}    = "G4_Al"; #Al 6061
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}


	#Carbon foil targets.
	@name = ("Carbon_t1", "Carbon_t2", "Carbon_t3", "Carbon_t4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target C";
	    $detector{"pos"}         = "$C_t_x*cm $C_t_y*cm $row_target[$i]*cm";
	    $detector{"rotation"}    = "$C_target[3]*deg $C_target[4]*deg $C_target[5]*deg";
	    $detector{"color"}       = "000099";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$C_target[0]*cm $C_target[1]*cm $C_target[2]*cm";
	    $detector{"material"}    = "G4_C";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}


	#Tin foil targets.
	@name = ("Tin_t1", "Tin_t2", "Tin_t3", "Tin_t4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Sn";
	    $detector{"pos"}         = "$Sn_t_x*cm $Sn_t_y*cm $row_target[$i]*cm";
	    $detector{"rotation"}    = "$Sn_target[3]*deg $Sn_target[4]*deg $Sn_target[5]*deg";
	    $detector{"color"}       = "444444";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$Sn_target[0]*cm $Sn_target[1]*cm $Sn_target[2]*cm";
	    $detector{"material"}    = "G4_Sn";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}


	#Carbon Flags.
	@name = ("C_flag1", "c_flag2", "C_flag3", "C_flag4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag C";
	    $detector{"pos"}         = "$C_f_x*cm $C_f_y*cm $row_flag[$i]*cm";
	    $detector{"rotation"}    = "$C_flag[3]*deg $C_flag[4]*deg $C_flag[5]*deg";
	    $detector{"color"}       = "009900";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$C_flag[0]*cm $C_flag[1]*cm $C_flag[2]*cm";
	    $detector{"material"}    = "G4_Al";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}
	

	#Tin Flags.
	@name = ("Sn_flag1", "Sn_flag2", "Sn_flag3", "Sn_flag4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag Sn";
	    $detector{"pos"}         = "$Sn_f_x*cm $Sn_f_y*cm $row_flag[$i]*cm";
	    $detector{"rotation"}    = "$Sn_flag[3]*deg $Sn_flag[4]*deg $Sn_flag[5]*deg";
	    $detector{"color"}       = "009900";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$Sn_flag[0]*cm $Sn_flag[1]*cm $Sn_flag[2]*cm";
	    $detector{"material"}    = "G4_Al";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}
    }





    #Large targets
    if($thisVariation eq "RGM_8_C_L")
    {
	#Flag Shaft Geometry (cm/deg)
	my @flag_shaft = (0.2665, 0.3175, 8.145, 0, 360, 0, 0, 0);		#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle

	#Flag Pole Geometry (cm/deg)
	my @Sn_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 55, 0);	#Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the Sn flag poles.
	my @C_flag_pole = (0.084, 0.1195, 1.0605, 0, 360, 90, 0, 0);	#Inner radius, outer radius, half length (outside of flag_shaft to end of flag_pole), initial angle, final angle, x angle, y angle, z angle for the C flag poles.

	#Flag Geometry (cm)
	my @Sn_flag = (0.167, 0.1905, 0.0355, 0, 0, -55);				#Half x, y, z dimensions and x, y, z angles for the Sn flag that holds the target foils.
	my @C_flag = (0.167, 0.1905, 0.0355, 0, 0, 0);					#Half x, y, z dimensions and x, y, z angles for the C flag that holds the target foils.
	
	#Targets Geometry (cm)
	my @Sn_target = (0.2397, 0.455, 0.025, 0, 0, -55);				#Half x, y, z dimensions and x, y, z angles for the Sn target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.
	my @C_target = (0.2397, 0.455, 0.025, 0, 0, 0);					#Half x, y, z dimensions and x, y, z angles for the C target foils. I did a lot of geometry to try and keep the thickness & over all volume the same as in the CAD file.




	my $separation = 0.127;											#Distance the flags set the target above the end of the flag poles.		
	
	my @flag_pole_relpos = (0.381, 1.25, 1.25, 1.25);				#Distance from end of flag_shaft to center of flag_pole 1, center of flag_pole 1 to center of flag_pole 2, center of flag_pole 2 to center of flag_pole 3, and center of flag_pole 3 to center of flag_pole 4
	my @row = ($flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2] - $flag_pole_relpos[3], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1] - $flag_pole_relpos[2], $flag_shaft[2] - $flag_pole_relpos[0] - $flag_pole_relpos[1], $flag_shaft[2] - $flag_pole_relpos[0]);							#Positions of rows of the flag_poles.

	#offset to "zero" everything where I want.
	my $offset_x = 0.0;
	my $offset_y = -(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation);
	my $offset_z = -(($row[1] - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2] ) + ($row[2] - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2] ))/2;
	
	#Adjusted position of the rows for the flag poles.
	my @row_pole = ($row[0] + $offset_z, $row[1] + $offset_z, $row[2] + $offset_z, $row[3] + $offset_z);

	#Adjusted positions of the rows for the target foils.
	my @row_target = ($row[0] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2], $row[1] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2], $row[2] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2], $row[3] + $offset_z - $Sn_flag_pole[1] + 2*$Sn_flag[2] + $Sn_target[2]);

	#Adjusted positions of the rows for the flags.
	my @row_flag = ($row[0] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[1] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[2] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2], $row[3] + $offset_z - $Sn_flag_pole[1] + $Sn_flag[2]);




	#Sn Flag Pole position (cm).
	my $Sn_p_x = -(0.81915*($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_x);								#Cos(35) is the decimal out front.
	my $Sn_p_y = 0.57358*($Sn_flag_pole[2] + $flag_shaft[1]) + $offset_y;									#Sin(35) is the decimal out front.

	#C Flag Pole positions (cm).
	my $C_p_x = 0.0 + $offset_x;
	my $C_p_y = $C_flag_pole[2] + $flag_shaft[1] + $offset_y;

	#Sn Targets positions (cm).
	my $Sn_t_x = -(0.81915*(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_x);#Cos(35) is the decimal out front.
	my $Sn_t_y = 0.57358*(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_target[1] + $separation) + $offset_y;	#Sin(35) is the decimal out front.

	#C Targets positions (cm).
	my $C_t_x = 0.0 + $offset_x;
	my $C_t_y = (2*$C_flag_pole[2] + $flag_shaft[1] + $C_target[1] + $separation) + $offset_y;

	#Sn Flag positions (cm).
	my $Sn_f_x = -(0.81915*(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_x);				#Cos(35) is the decimal out front.
	my $Sn_f_y = 0.57358*(2*$Sn_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;					#Sin(35) is the decimal out front.
	
	#C Flag positions (cm).
	my $C_f_x = 0.0 + $offset_x;
	my $C_f_y = (2*$C_flag_pole[2] + $flag_shaft[1] + $Sn_flag[1]) + $offset_y;





	#Mother Volume
	my $nplanes = 4;
	my @oradius  =  (    50.2,   50.2,  21.0,  21.0 );
	my @z_plane  =  (  -115.0,  265.0, 290.0, 300.0 );

	# vacuum target container
	my %detector = init_det();
	$detector{"name"}        = "target";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Target Container";
	$detector{"color"}       = "22ff22";
	$detector{"type"}        = "Polycone";
	my $dimen = "0.0*deg 360*deg $nplanes*counts";
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradius[$i]*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_plane[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "G4_Galactic";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);
	

	#Flag Shaft
	$detector{"name"}        = "flag shaft";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Tube Main";
	$detector{"pos"}         = "$offset_x*cm $offset_y*cm $offset_z*cm";
	$detector{"rotation"}    = "$flag_shaft[5]*deg $flag_shaft[6]*deg $flag_shaft[7]*deg";
	$detector{"color"}       = "000099";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$flag_shaft[0]*cm $flag_shaft[1]*cm $flag_shaft[2]*cm 0*deg 360*deg";
	$detector{"material"}    = "G4_Al"; #Al 6061-T6
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	

	#C flag poles.
	my @name = ("C_p1", "C_p2", "C_p3", "C_p4");#So that all the entires in the text file have unique names if I have to look at it.
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag Pole C";
	    $detector{"pos"}         = "$C_p_x*cm $C_p_y*cm $row_pole[$i]*cm";
	    $detector{"rotation"}    = "$C_flag_pole[5]*deg $C_flag_pole[6]*deg $C_flag_pole[7]*deg";
	    $detector{"color"}       = "990000";
	    $detector{"type"}        = "Tube";
	    $detector{"dimensions"}  = "$C_flag_pole[0]*cm $C_flag_pole[1]*cm $C_flag_pole[2]*cm 0*deg 360*deg";
	    $detector{"material"}    = "G4_Al"; #Al 6061
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}
	

	#Sn flag poles. 
	@name = ("Sn_p1", "Sn_p2", "Sn_p3", "Sn_p4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag Pole Sn";
	    $detector{"pos"}         = "$Sn_p_x*cm $Sn_p_y*cm $row_pole[$i]*cm";
	    $detector{"rotation"}    = "$Sn_flag_pole[5]*deg $Sn_flag_pole[6]*deg $Sn_flag_pole[7]*deg";
	    $detector{"color"}       = "990000";
	    $detector{"type"}        = "Tube";
	    $detector{"dimensions"}  = "$Sn_flag_pole[0]*cm $Sn_flag_pole[1]*cm $Sn_flag_pole[2]*cm 0*deg 360*deg";
	    $detector{"material"}    = "G4_Al"; #Al 6061
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}


	#Carbon foil targets.
	@name = ("Carbon_t1", "Carbon_t2", "Carbon_t3", "Carbon_t4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target C";
	    $detector{"pos"}         = "$C_t_x*cm $C_t_y*cm $row_target[$i]*cm";
	    $detector{"rotation"}    = "$C_target[3]*deg $C_target[4]*deg $C_target[5]*deg";
	    $detector{"color"}       = "000099";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$C_target[0]*cm $C_target[1]*cm $C_target[2]*cm";
	    $detector{"material"}    = "G4_C";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}


	#Tin foil targets.
	@name = ("Tin_t1", "Tin_t2", "Tin_t3", "Tin_t4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Sn";
	    $detector{"pos"}         = "$Sn_t_x*cm $Sn_t_y*cm $row_target[$i]*cm";
	    $detector{"rotation"}    = "$Sn_target[3]*deg $Sn_target[4]*deg $Sn_target[5]*deg";
	    $detector{"color"}       = "444444";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$Sn_target[0]*cm $Sn_target[1]*cm $Sn_target[2]*cm";
	    $detector{"material"}    = "G4_Sn";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}


	#Carbon Flags.
	@name = ("C_flag1", "c_flag2", "C_flag3", "C_flag4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag C";
	    $detector{"pos"}         = "$C_f_x*cm $C_f_y*cm $row_flag[$i]*cm";
	    $detector{"rotation"}    = "$C_flag[3]*deg $C_flag[4]*deg $C_flag[5]*deg";
	    $detector{"color"}       = "009900";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$C_flag[0]*cm $C_flag[1]*cm $C_flag[2]*cm";
	    $detector{"material"}    = "G4_Al";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}
	

	#Tin Flags.
	@name = ("Sn_flag1", "Sn_flag2", "Sn_flag3", "Sn_flag4");
	for(my $i = 0; $i < 4; $i++) 
	{
	    $detector{"name"}        = "$name[$i]";
	    $detector{"mother"}      = "target";
	    $detector{"description"} = "RGM Solid Target Flag Sn";
	    $detector{"pos"}         = "$Sn_f_x*cm $Sn_f_y*cm $row_flag[$i]*cm";
	    $detector{"rotation"}    = "$Sn_flag[3]*deg $Sn_flag[4]*deg $Sn_flag[5]*deg";
	    $detector{"color"}       = "009900";
	    $detector{"type"}        = "Box";
	    $detector{"dimensions"}  = "$Sn_flag[0]*cm $Sn_flag[1]*cm $Sn_flag[2]*cm";
	    $detector{"material"}    = "G4_Al";
	    $detector{"style"}       = 1;
	    print_det(\%configuration, \%detector);
	}
    }





    #add variations for flag size
    if($thisVariation eq "RGM_Ca")
    {
	#Cell Wall Geometry (cm/degrees)
	my @Cell_wall = (1.3875, 1.4, 10.255, 0, 360, 0, 0, 0);									#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the Cell Cylinder.
	
	#Entrance End Caps Geometry (cm/degrees)
	my @ent_cap_1 = (1.087, 1.387, 1.6885, 0, 360, 0, 0, 0);								#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.
	my @ent_cap_2 = (0.38, 1.375, 1.025, 0, 360, 0, 0, 0);									#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.
	my @ent_cap_3 = (0.38, 2.925, 0.725, 0, 360, 0, 0, 0);									#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.
	
	#Entrace Window Geometry (cm/degrees)
	my @cell_ent = (0.0, 0.753, 0.0015, 0, 360, 0, 0, 0);									#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.
	
	#Exit End Caps Geometry (cm/degrees)
	my @ex_cap_1 = (1.408, 1.423, 0.47, 0, 360, 0, 0, 0);									#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.
	my @ex_cap_2 = (1.408, 1.423, 0.644, 0.659, 0.212, 0, 360, 0, 0, 0);					#Inner radius 1, outer radius 1, inner radius 2, outer radius 2, half length z, initial angle, final angle, x angle, y angle, z angle for the target.
	
	#Entrace Window Geometry (cm/degrees)
	my @cell_ex = (0.0, 0.659, 0.0015, 0, 360, 0, 0, 0);									#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.

	#Target Geometry (cm/degrees)
	my @Ca_target = (0, 0.635, 0.1, 0, 360, 0, 0, 0);										#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.
	
	#Target Holder Geometry (cm/degrees)
	my @holder_1 = (0.5, 1.387, 0.250, 0, 360, 0, 0, 0);									#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.
	my @holder_2 = (0.5, 1.387, 0.250, 0, 360, 0, 0, 0);									#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.
	
	#Target Retainer Geometry (cm/degrees)
	my @retainer = (0.635, 1.387, 0.1, 0, 360, 0, 0, 0);									#Inner radius, outer radius, half length, initial angle, final angle, x angle, y angle, z angle for the target.
	#my @retainer = (0.64, 0.3825, 0.1, 0, 0, 0);											#Half x, y (holder_1[2]-Ca_target[2])/2, z dimensions and x, y, z angles for the target retainer.

	
	

	my $Ca_tar_rel_wall = 14.385;#Distance from the beginning of the cell wall to the front of the Calcium target (cm).

	my $offset_x = 0;
	my $offset_y = 0;
	my $offset_z = ($Ca_tar_rel_wall - $Cell_wall[2] + $Ca_target[2]); #offsets so that the middle of the target is on "0".

	#Cell Wall Position (cm)
	my @Cell_wall_pos = ($offset_x, $offset_y, $offset_z);																															#x,y,z position

	#Exit End Cap: Part 1 Position (cm)
	my @ex_cap_1_pos = ($offset_x, $offset_y, ($Cell_wall[2] - $ex_cap_1[2] + 0.001 + $offset_z));																					#x,y,z position		#0.001 from cap being pushed down on cell walls
	
	#Exit End Cap: Part 2 Position (cm)
	my @ex_cap_2_pos = ($offset_x, $offset_y, ($Cell_wall[2] + 0.002 + $ex_cap_2[4] + $offset_z));																					#x,y,z position		#0.002 from cap being pushed down on cell walls

	#Cell Exit Window Position (cm)
	my @cell_ex_pos = ($offset_x, $offset_y, ($Cell_wall[2] + 0.002 + 2*$ex_cap_2[4] + $cell_ex[2] + $offset_z));																	#x,y,z position		#0.002 from cap being pushed down on cell walls

	#Entrance End Cap: Part 1 Position (cm)
	my @ent_cap_1_pos = ($offset_x, $offset_y, (- $Cell_wall[2] + 2*$ent_cap_2[2] + $ent_cap_1[2] + $offset_z) );																	#x,y,z position

	#Entrance End Cap: Part 2 Position (cm)
	my @ent_cap_2_pos = ($offset_x, $offset_y, (- $Cell_wall[2] + $ent_cap_2[2] + $offset_z) );																						#x,y,z position

	#Entrance End Cap: Part 3 Position (cm)
	my @ent_cap_3_pos = ($offset_x, $offset_y, (- $Cell_wall[2] - $ent_cap_3[2] + $offset_z) );																						#x,y,z position

	#Cell Entrance Window Position (cm)
	my @cell_ent_pos = ($offset_x, $offset_y, (- $Cell_wall[2] + 2*$ent_cap_2[2] + $cell_ent[2] + $offset_z) );																		#x,y,z position

	#Target Position (cm)
	my @Ca_target_pos = ($offset_x, $offset_y, (- $Cell_wall[2] + 2*$ent_cap_2[2] + 2*$ent_cap_1[2] + 2*$holder_1[2] +$Ca_target[2] + $offset_z));									#x,y,z position
	#holder Position Part 1 (cm)
	my @holder_pos_1 = ($offset_x, $offset_y, (- $Cell_wall[2] + 2*$ent_cap_2[2] + 2*$ent_cap_1[2] + $holder_1[2] + $offset_z) );													#x,y,z position
	#holder Position Part 2 (cm)
	my @holder_pos_2 = ($offset_x, $offset_y, (- $Cell_wall[2] + 2*$ent_cap_2[2] + 2*$ent_cap_1[2] + 2*$holder_1[2] + 2*$Ca_target[2] + $holder_2[2] + $offset_z) );				#x,y,z position
	
	#retainer Position (cm)
	my @retainer_pos = ($offset_x, $offset_y, (- $Cell_wall[2] + 2*$ent_cap_2[2] + 2*$ent_cap_1[2] + 2*$holder_1[2] + $retainer[2] + $offset_z) );									#x,y,z position
	#my @retainer_pos = ($offset_x, $Ca_target[1] + $retainer[1] + $offset_y, (- $Cell_wall[2] + 2*$ent_cap_2[2] + 2*$ent_cap_1[2] + 2*$holder_1[2] + $Ca_target[2] + $offset_z) );	#x,y,z position




	#Mother Volume
	my $nplanes = 4;
	my @oradius  =  (    50.2,   50.2,  21.0,  21.0 );
	my @z_plane  =  (  -115.0,  265.0, 290.0, 300.0 );

	# vacuum target container
	my %detector = init_det();
	$detector{"name"}        = "target";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Target Container";
	$detector{"color"}       = "22ff22";
	$detector{"type"}        = "Polycone";
	my $dimen = "0.0*deg 360*deg $nplanes*counts";
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradius[$i]*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_plane[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "G4_Galactic";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);
	



	#Cell Wall
	$detector{"name"}        = "Cell_Wall";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Cell Wall";
	$detector{"pos"}         = "$Cell_wall_pos[0]*cm $Cell_wall_pos[1]*cm $Cell_wall_pos[2]*cm";
	$detector{"rotation"}    = "$Cell_wall[5]*deg $Cell_wall[6]*deg $Cell_wall[7]*deg";
	$detector{"color"}       = "444444";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$Cell_wall[0]*cm $Cell_wall[1]*cm $Cell_wall[2]*cm $Cell_wall[3]*deg $Cell_wall[4]*deg";
	$detector{"material"}    = "G4_KAPTON";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	#Exit Cap: Part 1
	$detector{"name"}        = "Ex_Cap_1";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Exit End Cap: Part 1";
	$detector{"pos"}         = "$ex_cap_1_pos[0]*cm $ex_cap_1_pos[1]*cm $ex_cap_1_pos[2]*cm";
	$detector{"rotation"}    = "$ex_cap_1[5]*deg $ex_cap_1[6]*deg $ex_cap_1[7]*deg";
	$detector{"color"}       = "009900";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$ex_cap_1[0]*cm $ex_cap_1[1]*cm $ex_cap_1[2]*cm $ex_cap_1[3]*deg $ex_cap_1[4]*deg";
	$detector{"material"}    = "G4_KAPTON";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	#Exit Cap: Part 2
	$detector{"name"}        = "Ex_Cap_2";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Exit End Cap: Part 2";
	$detector{"pos"}         = "$ex_cap_2_pos[0]*cm $ex_cap_2_pos[1]*cm $ex_cap_2_pos[2]*cm";
	$detector{"rotation"}    = "$ex_cap_2[7]*deg $ex_cap_2[8]*deg $ex_cap_2[9]*deg";
	$detector{"color"}       = "990000";
	$detector{"type"}        = "Cons";
	$detector{"dimensions"}  = "$ex_cap_2[0]*cm $ex_cap_2[1]*cm $ex_cap_2[2]*cm $ex_cap_2[3]*cm $ex_cap_2[4]*cm $ex_cap_2[5]*deg $ex_cap_2[6]*deg";
	$detector{"material"}    = "G4_KAPTON";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	#Exit Window
	$detector{"name"}        = "Exit_Window";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Exit Window";
	$detector{"pos"}         = "$cell_ex_pos[0]*cm $cell_ex_pos[1]*cm $cell_ex_pos[2]*cm";
	$detector{"rotation"}    = "$cell_ex[5]*deg $cell_ex[6]*deg $cell_ex[7]*deg";
	$detector{"color"}       = "000099";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$cell_ex[0]*cm $cell_ex[1]*cm $cell_ex[2]*cm $cell_ex[3]*deg $cell_ex[4]*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	#Entrance End Cap: Part 1
	$detector{"name"}        = "Ent_Cap_1";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Entrance End Cap: Part 1";
	$detector{"pos"}         = "$ent_cap_1_pos[0]*cm $ent_cap_1_pos[1]*cm $ent_cap_1_pos[2]*cm";
	$detector{"rotation"}    = "$ent_cap_1[5]*deg $ent_cap_1[6]*deg $ent_cap_1[7]*deg";
	$detector{"color"}       = "990000";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$ent_cap_1[0]*cm $ent_cap_1[1]*cm $ent_cap_1[2]*cm $ent_cap_1[3]*deg $ent_cap_1[4]*deg";
	$detector{"material"}    = "G4_KAPTON";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	#Entrance End Cap: Part 2
	$detector{"name"}        = "Ent_Cap_2";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Entrance End Cap: Part 2";
	$detector{"pos"}         = "$ent_cap_2_pos[0]*cm $ent_cap_2_pos[1]*cm $ent_cap_2_pos[2]*cm";
	$detector{"rotation"}    = "$ent_cap_2[5]*deg $ent_cap_2[6]*deg $ent_cap_2[7]*deg";
	$detector{"color"}       = "009900";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$ent_cap_2[0]*cm $ent_cap_2[1]*cm $ent_cap_2[2]*cm $ent_cap_2[3]*deg $ent_cap_2[4]*deg";
	$detector{"material"}    = "G4_KAPTON";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	#Entrance End Cap: Part 3
	$detector{"name"}        = "Ent_Cap_3";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Entrance End Cap: Part 2";
	$detector{"pos"}         = "$ent_cap_3_pos[0]*cm $ent_cap_3_pos[1]*cm $ent_cap_3_pos[2]*cm";
	$detector{"rotation"}    = "$ent_cap_3[5]*deg $ent_cap_3[6]*deg $ent_cap_3[7]*deg";
	$detector{"color"}       = "990000";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$ent_cap_3[0]*cm $ent_cap_3[1]*cm $ent_cap_3[2]*cm $ent_cap_3[3]*deg $ent_cap_3[4]*deg";
	$detector{"material"}    = "G4_KAPTON";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	#Entrance Window
	$detector{"name"}        = "Entrance_Window";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Entrance Window";
	$detector{"pos"}         = "$cell_ent_pos[0]*cm $cell_ent_pos[1]*cm $cell_ent_pos[2]*cm";
	$detector{"rotation"}    = "$cell_ent[5]*deg $cell_ent[6]*deg $cell_ent[7]*deg";
	$detector{"color"}       = "000099";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$cell_ent[0]*cm $cell_ent[1]*cm $cell_ent[2]*cm $cell_ent[3]*deg $cell_ent[4]*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	#Ca Target
	$detector{"name"}        = "Ca Target";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Ca Target";
	$detector{"pos"}         = "$Ca_target_pos[0]*cm $Ca_target_pos[1]*cm $Ca_target_pos[2]*cm";
	$detector{"rotation"}    = "$Ca_target[5]*deg $Ca_target[6]*deg $Ca_target[7]*deg";
	$detector{"color"}       = "990000";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$Ca_target[0]*cm $Ca_target[1]*cm $Ca_target[2]*cm $Ca_target[3]*deg $Ca_target[4]*deg";
	$detector{"material"}    = "G4_Ca";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	#holder part 1
	$detector{"name"}        = "Holder Part 1";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Holder Part 1";
	$detector{"pos"}         = "$holder_pos_1[0]*cm $holder_pos_1[1]*cm $holder_pos_1[2]*cm";
	$detector{"rotation"}    = "$holder_1[5]*deg $holder_1[6]*deg $holder_1[7]*deg";
	$detector{"color"}       = "009900";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$holder_1[0]*cm $holder_1[1]*cm $holder_1[2]*cm $holder_1[3]*deg $holder_1[4]*deg";
	$detector{"material"}    = "rohacell";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	#holder part 2
	$detector{"name"}        = "Holder Part 2";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Holder Part 2";
	$detector{"pos"}         = "$holder_pos_2[0]*cm $holder_pos_2[1]*cm $holder_pos_2[2]*cm";
	$detector{"rotation"}    = "$holder_2[5]*deg $holder_2[6]*deg $holder_2[7]*deg";
	$detector{"color"}       = "009900";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$holder_2[0]*cm $holder_2[1]*cm $holder_2[2]*cm $holder_2[3]*deg $holder_2[4]*deg";
	$detector{"material"}    = "rohacell";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	#retainer
	#$detector{"name"}        = "Retainer";
	#$detector{"mother"}      = "target";
	#$detector{"description"} = "RGM Solid Target Retainer";
	#$detector{"pos"}         = "$retainer_pos[0]*cm $retainer_pos[1]*cm $retainer_pos[2]*cm";
	#$detector{"rotation"}    = "$retainer[3]*deg $retainer[4]*deg $retainer[5]*deg";
	#$detector{"color"}       = "000099";
	#$detector{"type"}        = "Box";
	#$detector{"dimensions"}  = "$retainer[0]*cm $retainer[1]*cm $retainer[2]*cm";
	#$detector{"material"}    = "rohacell";
	#$detector{"style"}       = 1;
	#print_det(\%configuration, \%detector);

	#retainer
	$detector{"name"}        = "Retainer";
	$detector{"mother"}      = "target";
	$detector{"description"} = "RGM Solid Target Retainer";
	$detector{"pos"}         = "$retainer_pos[0]*cm $retainer_pos[1]*cm $retainer_pos[2]*cm";
	$detector{"rotation"}    = "$retainer[3]*deg $retainer[4]*deg $retainer[5]*deg";
	$detector{"color"}       = "000099";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$retainer[0]*cm $retainer[1]*cm $retainer[2]*cm $retainer[3]*deg $retainer[4]*deg";
	$detector{"material"}    = "rohacell";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
    }

if($thisVariation eq "2cm-lD2")
	{

		my $nplanes = 4;
		my @oradius  =  (    52,   52,  45,  21 );
		my @z_plane  =  (  -215.0,  165.0, 180.0, 200.0 );

		# vacuum target container
		my %detector = init_det();
		$detector{"name"}        = "target";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Target Container";
		$detector{"color"}       = "22ff22";
		$detector{"type"}        = "Polycone";
		my $dimen = "0.0*deg 360*deg $nplanes*counts";
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradius[$i]*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_plane[$i]*mm";}
		$detector{"dimensions"}  = $dimen;
		$detector{"material"}    = "G4_Galactic";
		$detector{"style"}       = 0;
		print_det(\%configuration, \%detector);

		# Liquid target cell upstream window
		my $thicknessU  = 0.015/2.;
		my $zposU       = -70.35;
		my $radiusU     = 4.95;
		$detector{"name"}        = "LD2CellWindowU";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Liquid target cell upstream window";
		$detector{"color"}       = "848789";
		$detector{"type"}        = "Tube";
		$detector{"pos"}         = "0 0 $zposU*mm";
		$detector{"dimensions"}  = "0*mm $radiusU*mm $thicknessU*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# Liquid target cell downstream window
		my $thicknessD  = 0.015/2.;
		my $zposD       = -50.34;
		my $radiusD     = 4.95;
		$detector{"name"}        = "LD2CellWindowD";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Liquid target cell downstream window";
		$detector{"color"}       = "848789";
		$detector{"type"}        = "Tube";
		$detector{"pos"}         = "0 0 $zposD*mm";
		$detector{"dimensions"}  = "0*mm $radiusD*mm $thicknessD*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# actual lD2 target
		$nplanes = 6;
		my @oradiusT  =  (   2.5, 7.0,  7.8,  6.7, 5.5,  2.5);
		my @z_planeT  =  ( -70.30, -68.0, -66.2, -52.5, -51.0, -50.40);
		%detector = init_det();
		$detector{"name"}        = "lD2";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Target Cell";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Polycone";
		$dimen = "0.0*deg 360*deg $nplanes*counts";
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradiusT[$i]*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_planeT[$i]*mm";}
		$detector{"dimensions"}  = $dimen;
		$detector{"material"}    = "LD2"; # defined in gemc database
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);

		# reference foil
		my $thickness  = 0.01/2.;
		my $zpos       = -30.33;
		my $radius     = 10;
		$detector{"name"}        = "refFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "aluminum refernence foil";
		$detector{"color"}       = "848789";
		$detector{"type"}        = "Tube";
		$detector{"pos"}         = "0 0 $zpos*mm";
		$detector{"dimensions"}  = "0*mm $radius*mm $thickness*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
	}

if($thisVariation eq "2cm-lD2-empty")
	{
		my $nplanes = 4;
		my @oradius  =  (    52,   52,  45,  21 );
		my @z_plane  =  (  -215.0,  165.0, 180.0, 200.0 );

		# vacuum target container
		my %detector = init_det();
		$detector{"name"}        = "target";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Target Container";
		$detector{"color"}       = "22ff22";
		$detector{"type"}        = "Polycone";
		my $dimen = "0.0*deg 360*deg $nplanes*counts";
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradius[$i]*mm";}
		for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_plane[$i]*mm";}
		$detector{"dimensions"}  = $dimen;
		$detector{"material"}    = "G4_Galactic";
		$detector{"style"}       = 0;
		print_det(\%configuration, \%detector);

		# Liquid target cell upstream window
		my $thicknessU  = 0.015/2.;
		my $zposU       = -70.35;
		my $radiusU     = 4.95;
		$detector{"name"}        = "LD2CellWindowU";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Liquid target cell upstream window";
		$detector{"color"}       = "848789";
		$detector{"type"}        = "Tube";
		$detector{"pos"}         = "0 0 $zposU*mm";
		$detector{"dimensions"}  = "0*mm $radiusU*mm $thicknessU*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# Liquid target cell upstream window
		my $thicknessD  = 0.015/2.;
		my $zposD       = -50.34;
		my $radiusD     = 4.95;
		$detector{"name"}        = "LD2CellWindowD";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Liquid target cell downstream window";
		$detector{"color"}       = "848789";
		$detector{"type"}        = "Tube";
		$detector{"pos"}         = "0 0 $zposD*mm";
		$detector{"dimensions"}  = "0*mm $radiusD*mm $thicknessD*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

		# reference foil
		my $thickness  = 0.01/2.;
		my $zpos       = -30.33;
		my $radius     = 10;
		$detector{"name"}        = "refFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "aluminum refernence foil";
		$detector{"color"}       = "848789";
		$detector{"type"}        = "Tube";
		$detector{"pos"}         = "0 0 $zpos*mm";
		$detector{"dimensions"}  = "0*mm $radius*mm $thickness*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
	}


}

1;

