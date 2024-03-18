use strict;
use warnings;

our %configuration;
our %parameters;

sub build_targets
{
	my $thisVariation = $configuration{"variation"} ;
	
	if($thisVariation eq "oldlH2" || $thisVariation eq "oldlD2")
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
		

		if($thisVariation eq "lH2")
		{
			$detector{"material"}    = "G4_lH2";
		}
		if($thisVariation eq "lD2")
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
		#$detector{"material"}    = "G4_He";
		$detector{"material"}    = "G4_Galactic";#temporaly replacing with vacuum
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
		$detector{"color"}       = "ee8811Q";
		$detector{"type"}        = "Tube";
		$detector{"style"}       = "1";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		
		$detector{"material"}    = "solidND3";
		print_det(\%configuration, \%detector);
		
	}
	#
	# EG2p Nuclear Targets Assembly
	#
	elsif($thisVariation eq "12C")
	{
		
		#Vacuum Target Container
		my $nplanes = 4;

		my @oradius  =  (    50.2,   50.2,  21.0,  21.0 );
		my @z_plane  =  ( -145.0,  235.0, 260.0, 370.0);

		my %detector = init_det();
		$detector{"name"}        = "target";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Vacuum Container";
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

		#Upstream Foil
		my $ZCenter = -25.86;  # center location of target along beam axis
		my $Rout       = 5;  #
		my $length     = 0.86; #(1.72 mm thick)
		%detector = init_det();
		$detector{"name"}        = "1stNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "First 12C foil for EG2p Nuclear Targets Assembly";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aa0011";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_C";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		#Second Foil
		$ZCenter = 24.14;  # center location of target along beam axis
		$Rout       = 5;  #
		$length     = 0.86; #(1.72 mm thick)
		%detector = init_det();
		$detector{"name"}        = "2ndNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Second 12C foil for EG2p Nuclear Targets Assembly";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_C";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		#Downstream Foil
		$ZCenter = 74.14;  # center location of target along beam axis
		$Rout       = 5;  #
		$length     = 0.86; #(1.72 mm thick)
		%detector = init_det();
		$detector{"name"}        = "3rdNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Third 12C foil for EG2p Nuclear Targets Assembly";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_C";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

	}
	elsif($thisVariation eq "27Al")
	{
		
		#Vacuum Target Container
		my $nplanes = 4;

		my @oradius  =  (    50.2,   50.2,  21.0,  21.0 );
		my @z_plane  =  ( -115.0,  265.0, 290.0, 373.0);

		my %detector = init_det();
		$detector{"name"}        = "target";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Vacuum Container";
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

		#Upstream Foil
		my $ZCenter = -25.29;  # center location of target along beam axis
		my $Rout       = 5;  #
		my $length     = 0.29; #(0.58 mm thick)
		%detector = init_det();
		$detector{"name"}        = "1stNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "First 27Al foil for EG2p Nuclear Targets Assembly";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aa0011";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		#Second Foil
		$ZCenter = 24.71;  # center location of target along beam axis
		$Rout       = 5;  #
		$length     = 0.29; #(0.58 mm thick)
		%detector = init_det();
		$detector{"name"}        = "2ndNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Second 27Al foil for EG2p Nuclear Targets Assembly";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		#Downstream Foil
		$ZCenter = 74.71;  # center location of target along beam axis
		$Rout       = 5;  #
		$length     = 0.29; #(0.58 mm thick)
		%detector = init_det();
		$detector{"name"}        = "3rdNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Third 27Al foil for EG2p Nuclear Targets Assembly";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

	}
	elsif($thisVariation eq "63Cu")
	{
		#Vacuum Target Container
		my $nplanes = 4;

		my @oradius  =  (    50.2,   50.2,  21.0,  21.0 );
		my @z_plane  =  ( -115.0,  265.0, 290.0, 373.0);

		my %detector = init_det();
		$detector{"name"}        = "target";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Vacuum Container";
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
		
		#Upstream Foil
		my $ZCenter = -25.2;  # center location of target along beam axis
		my $Rout       = 5;  #
		my $length     = 0.2; #(0.4 mm thick)
		%detector = init_det();
		$detector{"name"}        = "1stNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "First 63Cu Foil for EG2p Nuclear Targets Assembly";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aa0011";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Cu";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		#Second Foil
		$ZCenter = 24.8;  # center location of target along beam axis
		$Rout       = 5;  #
		$length     = 0.2; #(0.4 mm thick)
		%detector = init_det();
		$detector{"name"}        = "2ndNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Second 63Cu Foil for EG2p Nuclear Targets Assembly";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Cu";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		#Downstream Foil
		$ZCenter = 74.8;  # center location of target along beam axis
		$Rout       = 5;  #
		$length     = 0.2; #(0.4 mm thick)
		%detector = init_det();
		$detector{"name"}        = "3rdNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Third 63Cu Foil for EG2p Nuclear Targets Assembly";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Cu";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
	}
	elsif($thisVariation eq "118Sn")
	{
		#Vacuum Target Container
		my $nplanes = 4;

		my @oradius  =  (    50.2,   50.2,  21.0,  21.0 );
		my @z_plane  =  ( -115.0,  265.0, 290.0, 373.0);

		my %detector = init_det();
		$detector{"name"}        = "target";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Vacuum Container";
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
		
		#Upstream Foil
		my $ZCenter = -25.15;  # center location of target along beam axis
		my $Rout       = 5;  #
		my $length     = 0.15; #(0.3 mm thick)
		%detector = init_det();
		$detector{"name"}        = "1stNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "First 118Sn Foil for EG2p Nuclear Targets Assembly";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aa0011";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Sn";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		#Second Foil
		$ZCenter = 24.85;  # center location of target along beam axis
		$Rout       = 5;  #
		$length     = 0.2; #(0.4 mm thick)
		%detector = init_det();
		$detector{"name"}        = "2ndNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Second 118Sn Foil for EG2p Nuclear Targets Assembly";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Sn";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		#Downstream Foil
		$ZCenter = 74.85;  # center location of target along beam axis
		$Rout       = 5;  #
		$length     = 0.2; #(0.4 mm thick)
		%detector = init_det();
		$detector{"name"}        = "3rdNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Third 118Sn Foil for EG2p Nuclear Targets Assembly";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Sn";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
	}
	elsif($thisVariation eq "208Pb")
	{
		#Vacuum Target Container
		my $nplanes = 4;

		my @oradius  =  (    50.2,   50.2,  21.0,  21.0 );
		my @z_plane  =  ( -115.0,  265.0, 290.0, 373.0);

		my %detector = init_det();
		$detector{"name"}        = "target";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Vacuum Container";
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
		
		
		#Upstream Foil
		my $ZCenter = -25.07;  # center location of target along beam axis
		my $Rout       = 5;  #
		my $length     = 0.07; #(0.14 mm thick)
		%detector = init_det();
		$detector{"name"}        = "1stNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "First 208Pb Foil for EG2p Nuclear Targets Assembly";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aa0011";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Pb";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		#Second Foil
		$ZCenter = 24.93;  # center location of target along beam axis
		$Rout       = 5;  #
		$length     = 0.07; #(0.14 mm thick)
		%detector = init_det();
		$detector{"name"}        = "2ndNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Second 208Pb Foil for EG2p Nuclear Targets Assembly";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Pb";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);
		
		#Downstream Foil
		$ZCenter = 74.93;  # center location of target along beam axis
		$Rout       = 5;  #
		$length     = 0.07; #(0.14 mm thick)
		%detector = init_det();
		$detector{"name"}        = "3rdNuclearTargFoil";
		$detector{"mother"}      = "target";
		$detector{"description"} = "Third 208Pb Foil for EG2p Nuclear Targets Assembly";
		$detector{"pos"}         = "0 0 $ZCenter*mm";
		$detector{"color"}       = "aa0000";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
		$detector{"material"}    = "G4_Pb";
		$detector{"style"}       = "1";
		print_det(\%configuration, \%detector);

	}

	# cad variation has two volume:
	# target container
	# and inside cell
	if($thisVariation eq "lH2" || $thisVariation eq "lD2" || $thisVariation eq "lH2e")
	{
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
		if($thisVariation eq "lD2") {
			$detector{"material"}    = "LD2";
		}
		$detector{"style"}       = 1;
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
    
    elsif($thisVariation eq "bonus")
    {
        # bonus root volume
        my $Rout       = 4;
        my $length     = 225.0;  # 225 half length
        my %detector = init_det();
        $detector{"name"}        = "bonusTarget";
        $detector{"mother"}      = "root";
        $detector{"description"} = "BONuS12 RTPC gaseous D2 Target";
        $detector{"color"}       = "eeeegg";
        $detector{"type"}        = "Tube";
        $detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"material"}    = "G4_He";
        $detector{"style"}       = "1";
        $detector{"visible"}     = 0;
        print_det(\%configuration, \%detector);
        
        # bonus target gas volume
        my $Rin        = 0.0;
        $Rout       = 3.0;
        $length     = 223.0;  # 223 half length
        %detector = init_det();
        $detector{"name"}        = "gasDeuteriumTarget";
        $detector{"mother"}      = "bonusTarget";
        $detector{"description"} = "7 atm deuterium target gas";
        $detector{"color"}       = "a54382";
        $detector{"type"}        = "Tube";
        $detector{"dimensions"}  = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"material"}    = "bonusTargetGas";
        $detector{"style"}       = "1";
        print_det(\%configuration, \%detector);
        
        # bonus target wall
        $Rin        = 3.01; # 3.01
        $Rout       = 3.056; # 3.056
        $length     = 223.0;  # 223 half length
        %detector = init_det();
        $detector{"name"}        = "bonusTargetWall";
        $detector{"mother"}      = "bonusTarget";
        $detector{"description"} = "Bonus Target wall";
        $detector{"color"}       = "330099";
        $detector{"type"}        = "Tube";
        $detector{"dimensions"}  = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"material"}    = "G4_KAPTON";
        $detector{"style"}       = "1";
        print_det(\%configuration, \%detector);

        # bonus target downstream aluminum end cap ring
        $Rin        = 3.0561;
        $Rout       = 3.1561;
        $length     = 2.0;  # half length
        my $zPos       = 221;  # 221 z position
        %detector = init_det();
        $detector{"name"}        = "bonusTargetEndCapRing";
        $detector{"mother"}      = "bonusTarget";
        $detector{"description"} = "Bonus Target Al end cap ring";
        $detector{"color"}       = "000000";
        $detector{"type"}        = "Tube";
        $detector{"pos"}         = "0*mm 0*mm $zPos*mm";
        $detector{"dimensions"}  = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"material"}    = "G4_Al";
        $detector{"style"}       = "1";
        print_det(\%configuration, \%detector);
        
        # bonus target downstream aluminum end cap ring
        $Rin        = 0.0;
        $Rout       = 3.1561;
        $length     = 0.05;  # half length
        $zPos       = 223.06;  # 223.06 z position
        %detector = init_det();
        $detector{"name"}        = "bonusTargetEndCapPlate";
        $detector{"mother"}      = "bonusTarget";
        $detector{"description"} = "Bonus Target Al end cap wall";
        $detector{"color"}       = "000000";
        $detector{"type"}        = "Tube";
        $detector{"pos"}         = "0*mm 0*mm $zPos*mm";
        $detector{"dimensions"}  = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"material"}    = "G4_Al";
        $detector{"style"}       = "1";
        print_det(\%configuration, \%detector);
        
    }


    # ALERT target 
    elsif($thisVariation eq "alert")
    {
	# adapted from bonus case
        # alert tg root volume
        my $Rout       = 4;
        my $length     = 155.0;  # mm!
        my %detector = init_det();
        $detector{"name"}        = "alertTarget";
        $detector{"mother"}      = "root";
        $detector{"description"} = "ALERT gaseous D2 Target";
        $detector{"color"}       = "eeeegg";
        $detector{"type"}        = "Tube";
        $detector{"dimensions"}  = "0*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"material"}    = "G4_He";
        $detector{"style"}       = "1";
        $detector{"visible"}     = 0;
        print_det(\%configuration, \%detector);
        
        # ALERT target gas volume
        my $Rin        = 0.0;
        $Rout       = 3.0;
        $length     = 150.0;  
        %detector = init_det();
        $detector{"name"}        = "gasDeuteriumTarget";
        $detector{"mother"}      = "alertTarget";
        $detector{"description"} = "5 atm deuterium target gas";
        $detector{"color"}       = "ffff00";
        $detector{"type"}        = "Tube";
        $detector{"dimensions"}  = "$Rin*mm $Rout*mm $length*mm 0*deg 360*deg";
        $detector{"material"}    = "alertTargetGas";
        $detector{"style"}       = "1";
        print_det(\%configuration, \%detector);
        
        # ALERT target wall
        $Rin        = 3.0; 
        $Rout       = 3.060; 
        $length     = 150.0;  
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
        my $zPos       = -148.0;  # mm z position
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
        $zPos       = -150.015;
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
        my $zPos       = 148;  # mm z position
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
        $zPos       = 150.015;
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


	

}

1;






















