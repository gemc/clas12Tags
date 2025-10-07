use strict;
use warnings;

our %configuration;

# Assign parameters to local variables
my $NUM_LAYERS = 6;
my $NUM_BARS   = 18;
my $NUM_SHDS   = 3;

my $band_xpos  = 0; 
my $band_ypos  = 921.2;
my $band_zpos  = 655;

my $bcolor = 'aaaaaa';
my $mbar_length = 1637;  # mm
my $lbar_length = 2019;  # mm
my $sbar_length = 512;   # mm
my $vframe_x  = 3;       # inches
my $vframe_y  = 1541.33; # mm
my $vframe_z  = 6;       # inches
my @vframe    = ($vframe_x/2, $vframe_y/2, $vframe_z/2);
my @vinframe  = ($vframe_x/2-0.25, $vframe_y/2, $vframe_z/2-0.25);
my @vframepos = ($band_xpos - 1078.9, $band_xpos - 486.4, $band_xpos + 486.4, $band_xpos + 1078.9);
my $align_x = 2;               # mm
my $align_y = 0;               # mm
my $align_z = -2308.71;        # mm

# These are delta z between each layer:
# (79.4, 76.2, 79.4, 76.2, 73.0)
# But we want the cumulative delta z:
my @delta_z = (0.0, 79.4, 155.6, 235.0, 311.2, 384.2);

my $STARTcart = -462.3;

sub build_bandMother
{
	my %detector = init_det();
	$detector{"name"}        = "band";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Mother volume of BAND";
	$detector{"pos"}         = "$align_x*mm $align_y*mm $align_z*mm";
	$detector{"rotation"}    = "0*deg 180*deg 0*deg";
	$detector{"color"}       = "339999";
	$detector{"type"}        = "Pgon";
	$detector{"dimensions"}  = "-45*deg 360*deg 4*counts 3*counts 160*mm 160*mm 160*mm 1500*mm 1500*mm 1500*mm -462.3*mm 0*mm 900*mm";
	$detector{"material"}    = "G4_AIR";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

	build_scintillators();
	build_frame();
	build_shielding();
	build_cart();
}

sub build_scintillators
{
	for(my $j=1; $j<=$NUM_LAYERS; $j++)
	{
		for(my $i=1; $i<=$NUM_BARS; $i++)
		{
			my $barnum      = 100*$j + $i;

			my %detector125 = init_det();
			# positioning
			my $x      = $band_xpos;
			my $y      = $band_ypos;
			my $z      = $band_zpos;
			my $xpos = $x;
			my $ypos = $y - 73.0*($i-1);
			#my $zpos = $z - 76.75*($j-1);
			my $zpos = $z - $delta_z[$j-1];
			my $xdim = $lbar_length/2;
			my $ydim = 36;
			my $zdim = 36;
			my $sector = 0;
			my $component = 0;
			my $layer = $j;
			$bcolor  = '007fff';

			if($i<=10 || $i>=17) # long bars
			{
				if($j==$NUM_LAYERS)
				{
					$zdim = 10;
					$zpos = $zpos - 2;
					$bcolor = '800080';
				}
				if($i<=3) # medium bars
				{
					$xdim = $mbar_length/2;
					$bcolor = 'ff00ff';
					$sector = 1;
					$component = $i;
					if($j==$NUM_LAYERS)
						{$bcolor = '008000';}
				}

				if($i>3 && $i<=10)
				{
					$sector = 2;
					$component = $i-3;
				}
				if($i>16)
				{
					$sector = 5;
					$component = $i-16;
				}

				if($j==5 && $i>=16) {next;}
				if($j==$NUM_LAYERS && $i>=16) {$zpos = $zpos + 72;}
				$detector125{"name"}        = "scintillator_$barnum";
				$detector125{"mother"}      = "band";
				$detector125{"description"} = "Scintillator $barnum";
				$detector125{"pos"}         = "$x*mm $ypos*mm $zpos*mm";
				$detector125{"rotation"}    = "0*deg 0*deg 0*deg";
				$detector125{"color"}       = $bcolor;
				$detector125{"type"}        = "Box";
				$detector125{"dimensions"}  = "$xdim*mm $ydim*mm $zdim*mm";
				$detector125{"material"}    = "ej200";
				$detector125{"style"}       = 1;
				#$detector125{"ncopy"}       = $barnum;
				$detector125{"sensitivity"} = "band";
				$detector125{"hit_type"}    = "band";
				my $id_string = join('','sector manual ',$sector,' layer manual ',$layer,' component manual ',$component, ' side manual 0');
				$detector125{"identifiers"} = $id_string;
				print_det(\%configuration, \%detector125);

				for(my $k=1; $k<=2; $k++) # pmt shields
				{
					my $dx = 1138.74;
					if($i<=3)
						{$dx = 947.4;}
					my $xp = $x - $dx;

					my %detectors1      = init_det();
					$detectors1{"name"}        = "pmtshield_$barnum L";
					my $colour               = "111111";
					if($k==2)
					{
						if($j==$NUM_LAYERS) {last;}
						$xp = $x + $dx;
						$detectors1{"name"}        = "pmtshield_$barnum R";
						$colour                  = "771111";
					}
					$detectors1{"mother"}      = "band";
					$detectors1{"description"} = "Mu metal shield for pmt $barnum";
					$detectors1{"pos"}         = "$xp*mm $ypos*mm $zpos*mm";
					$detectors1{"rotation"}    = "0*deg 90*deg 0*deg";
					$detectors1{"color"}       = $colour;
					$detectors1{"type"}        = "Tube";
					$detectors1{"dimensions"}  = "30.035*mm 32.725*mm 88.9*mm 0*deg 360*deg";
					$detectors1{"material"}    = "mushield";
					$detectors1{"style"}       = 1;
					print_det(\%configuration, \%detectors1);
				} # pmt shields

			} # long bars
			if($i>10 && $i<=16) # short bars
			{
				$bcolor = '4cbb17';
				if($j==$NUM_LAYERS)
				{
					$zdim = 10;
					$zpos = $zpos - 2;
					$bcolor = '007fff';
				}
				if($j==5 && $i>=16) {next;}
				if($j==$NUM_LAYERS && $i>=16) {$zpos = $zpos + 72;}
				# Short Bars
				my $xpo = "753.5";
				$sector = 4;
				$component = $i-10;;
				my %detector3 = init_det();
				$detector3{"name"}        = "scintillator_$barnum B";
				$detector3{"mother"}      = "band";
				$detector3{"description"} = "Short Bars $barnum B";
				$detector3{"pos"}         = "$xpo*mm $ypos*mm $zpos*mm";
				$detector3{"rotation"}    = "0*deg 0*deg 0*deg";
				$detector3{"color"}       = "$bcolor";
				$detector3{"type"}        = "Box";
				$detector3{"dimensions"}  = "255*mm 36*mm $zdim*mm";
				$detector3{"material"}    = "ej200";
				$detector3{"style"}       = 1;
				$detector3{"sensitivity"} = "band";
				$detector3{"hit_type"}    = "band";
				my $id_string = join('','sector manual ',$sector,' layer manual ',$layer,' component manual ',$component, ' side manual 0');
				$detector3{"identifiers"} = $id_string;
				print_det(\%configuration, \%detector3);

				$bcolor = '32cd32';
				if($j==$NUM_LAYERS)
					{$bcolor = '007fff';}
				# Short Bars
				$xpo = "-753.5";
				$sector = 3;
				$component = $i-10;;
				my %detector4 = init_det();
				$detector4{"name"}        = "scintillator_$barnum A";
				$detector4{"mother"}      = "band";
				$detector4{"description"} = "Short Bars $barnum A";
				$detector4{"pos"}         = "$xpo*mm $ypos*mm $zpos*mm";
				$detector4{"rotation"}    = "0*deg 0*deg 0*deg";
				$detector4{"color"}       = "$bcolor";
				$detector4{"type"}        = "Box";
				$detector4{"dimensions"}  = "255*mm 36*mm $zdim*mm";
				$detector4{"material"}    = "ej200";
				$detector4{"style"}       = 1;
				$detector4{"sensitivity"} = "band";
				$detector4{"hit_type"}    = "band";
				$id_string = join('','sector manual ',$sector,' layer manual ',$layer,' component manual ',$component, ' side manual 0');
				$detector4{"identifiers"} = $id_string;
				print_det(\%configuration, \%detector4);

				for(my $k=1; $k<=4; $k++) # pmt shields
				{
					if($k>=3 && $j==$NUM_LAYERS){last;}
					my $xp = $x - 1138.74;
					my %detectors2 = init_det();
					$detectors2{"name"}        = "pmtshield_$barnum Lout";
					my $colour               = "111111";
					if($k==2)
					{
						$xp = $x + 1138.74;
						$detectors2{"name"}        = "pmtshield_$barnum Rout";
						$colour                  = "771111";
					}
					if($k==3)
					{
						$xp = $x - 368.263;
						$detectors2{"name"}        = "pmtshield_$barnum Rin";
						$colour                  = "771111";
					}
					if($k==4)
					{
						$xp = $x + 368.263;
						$detectors2{"name"}        = "pmtshield_$barnum Lin";
						$colour                  = "111111";
					}
					$detectors2{"mother"}      = "band";
					$detectors2{"description"} = "Mu metal shield for pmt $barnum";
					$detectors2{"pos"}         = "$xp*mm $ypos*mm $zpos*mm";
					$detectors2{"rotation"}    = "0*deg 90*deg 0*deg";
					$detectors2{"color"}       = $colour;
					$detectors2{"type"}        = "Tube";
					$detectors2{"dimensions"}  = "30.035*mm 32.725*mm 88.9*mm 0*deg 360*deg";
					$detectors2{"material"}    = "mushield";
					$detectors2{"style"}       = 1;
					print_det(\%configuration, \%detectors2);
				} # pmt shields

			} # short bars

		} # NUM_BARS
	} # NUM_LAYERS
}
sub build_frame
{
	for(my $i=1; $i<=4; $i++)
	{
		my $qnumber     = cnumber($i-1, 10);

		# positioning
		my $yp     = $band_ypos - 575.715;
		my $zp     = $band_zpos - 533;

		my %detector = init_det();
		$detector{"name"}        = "support_$qnumber";
		$detector{"mother"}      = "band";
		$detector{"description"} = "Vertical support beam of BAND frame $qnumber";
		$detector{"pos"}         = "$vframepos[$i-1]*mm $yp*mm $zp*mm";
		$detector{"rotation"}    = "0*deg 0*deg 0*deg";
		$detector{"color"}       = "777777";
		$detector{"type"}        = "Box";
		$detector{"dimensions"}  = "$vframe[0]*inches $vframe[1]*mm $vframe[2]*inches";
		$detector{"material"}    = "G4_STAINLESS-STEEL";
		$detector{"style"}       = 0;
		print_det(\%configuration, \%detector);

		# Inside of support beam
		my %detector2 = init_det();
		$detector2{"name"}        = "support_inside_$qnumber";
		$detector2{"mother"}      = "support_$qnumber";
		$detector2{"description"} = "Inside of support beam";
		$detector2{"pos"}         = "0*mm 0*mm 0*mm";
		$detector2{"rotation"}    = "0*deg 0*deg 0*deg";
		$detector2{"color"}       = "eeeeee";
		$detector2{"type"}        = "Box";
		$detector2{"dimensions"}  = "$vinframe[0]*inches $vinframe[1]*mm $vinframe[2]*inches";
		$detector2{"material"}    = "G4_AIR";
		$detector2{"style"}       = 1;
		print_det(\%configuration, \%detector2);
	}
}

sub build_shielding
{
	my $q=0;

	#3 groups of lead shielding, shorter ones 2x18 left and right side, and longer ones 1x10 in the center top
	#lead is covered with Aluminium along x and z. Represent lead wall with two boxes of Aluminium and lead for each group
	#index 1: short ones to beam right:
	#Lead thickness x height x length: 0.79'' x 2.85'' x 20.7''
	#Aluminium: length = 21.7'' (0.5'' extra on each side compared to lead length)
	#index 1: long ones center top:
	#Lead thickness x height x length: 0.79'' x 2.85'' x 38.3''
	#Aluminium: length = 39.3'' (0.5'' extra on each side compared to lead length)
	#index 3: short ones to beam left:
	#Lead thickness x height x length: 0.79'' x 2.85'' x 20.7''
	#Aluminium: length = 21.7''	(0.5'' extra on each side compared to lead length)
	for(my $n=1; $n<=$NUM_SHDS; $n++)
	{
		$q = $q + $n;
		#xpos center [mm] for short bars: between frame 0.5*(1040.8+486.4)mm, long bars in the center
		my @lxpo = ($band_xpos - 763.6, $band_xpos - 0, $band_xpos + 763.6);
		#ypos center [mm]
		#short blocks (group 1 and 3): bottom of frame -419.1mm + 1298.4mm/2 (wall height (2.85inch*18) / 2)
		#long blocks (group 2): bottom of bar row 10: 228mm + 362mm/2 (wall height (2.85inch*10) / 2)
		my @lypo = (230.1, 590, 230.1);
		#zpos center calculated from CAD file[mm]
		my @lzpo = (102.5, 29.3, 102.5);
		#number of blocks in each group (short, long, short)
		my @lnum = (18, 10, 18);
		#0.5*Aluminium length in inch:
		my @sx   = (21.70/2, 39.30/2, 21.70/2);
		#0.5*thickness in inch of lead + aluminium from CAD drawings
		my @sz   = (1.102/2, 1.11/2, 1.102/2);
		#0.5*Height of lead in inch given by number of blocks times height
		my $sy   = 2.85*$lnum[$n-1]/2;
		#0.5* length of lead in inch, shorten by 1 inch compared to Aluminium
		my $sd   = $sx[$n-1] - 1/2;
		#1/2 thickness of blocks in inch
		my $sb   = 0.79/2;

		my %detector = init_det();
		$detector{"name"}        = "leadshield_$q";
		$detector{"mother"}      = "band";
		$detector{"description"} = "Aluminum plates for lead shield $q";
		$detector{"pos"}         = "$lxpo[$n-1]*mm $lypo[$n-1]*mm $lzpo[$n-1]*mm";
		$detector{"rotation"}    = "0*deg 0*deg 0*deg";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Box";
		$detector{"dimensions"}  = "$sx[$n-1]*inches $sy*inches $sz[$n-1]*inches";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = 0;
		print_det(\%configuration, \%detector);

		my %detector2 = init_det();
		$detector2{"name"}        = "leadblock_$q";
		$detector2{"mother"}      = "leadshield_$q";
		$detector2{"description"} = "Lead block inside shield $q";
		$detector2{"pos"}         = "0*mm 0*mm 0*mm";
		$detector2{"rotation"}    = "0*deg 0*deg 0*deg";
		$detector2{"color"}       = "555555";
		$detector2{"type"}        = "Box";
		$detector2{"dimensions"}  = "$sd*inches $sy*inches $sb*inches";
		$detector2{"material"}    = "G4_Pb";
		$detector2{"style"}       = 1;
		print_det(\%configuration, \%detector2);

	}
}

sub build_cart()
{
	my $zcart = $STARTcart + 381;
	my %detector = init_det();

	$detector{"name"}        = "mounting_tube_plate"; #############MOUNTING_TUBE#############################
	$detector{"mother"}      = "band";
	$detector{"description"} = "Mounting Tube Plate";
	$detector{"color"}       = "777777";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "0*mm -272.494*mm $zcart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "317.5*mm 6.35*mm 381*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$zcart = $STARTcart + 12.7;
	$detector{"name"}        = "mounting_tube_plate001";
	$detector{"mother"}      = "band";
	$detector{"description"} = "Mounting Tube Plate001";
	$detector{"color"}       = "777777";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "0*mm -221.694*mm $zcart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "177.8*mm 44.45*mm 12.7*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "mounting_tube_plate001alex";
	$detector{"mother"}      = "band";
	$detector{"description"} = "Mounting Tube Plate001";
	$detector{"color"}       = "777777";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "247.65*mm -12.144*mm $zcart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "69.85*mm 254*mm 12.7*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "mounting_tube_plate001james";
	$detector{"mother"}      = "band";
	$detector{"description"} = "Mounting Tube Plate001";
	$detector{"color"}       = "777777";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "-247.65*mm -12.144*mm $zcart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "69.85*mm 254*mm 12.7*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$zcart = $STARTcart + 393.7; #
	$detector{"name"}        = "adjustment_plate";
	$detector{"mother"}      = "band";
	$detector{"description"} = "Adjustment Plate";
	$detector{"color"}       = "777777";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "0*mm -514.35*mm $zcart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "317.5*mm 6.35*mm 368.3*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "adjustment_hole";
	$detector{"mother"}      = "adjustment_plate";
	$detector{"description"} = "Adjustment Plate hole";
	$detector{"color"}       = "eeeeee";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "0*mm 0*mm -254*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "165.1*mm 6.35*mm 114.3*mm";
	$detector{"material"}    = "G4_AIR";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$zcart = $STARTcart + 63.5;
	$detector{"name"}        = "gusset006vert"; #################GUSSET
	$detector{"mother"}      = "band";
	$detector{"description"} = "Gusset006";
	$detector{"color"}       = "555555";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "304.35*mm -12.144*mm $zcart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "13.15*mm 254*mm 38.1*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$zcart = $STARTcart + 431.8;
	$detector{"name"}        = "gusset006hori";
	$detector{"mother"}      = "band";
	$detector{"description"} = "Gusset006";
	$detector{"color"}       = "555555";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "304.35*mm -228.044*mm $zcart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "13.15*mm 38.1*mm 330.2*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$zcart = $STARTcart + 63.5;
	$detector{"name"}        = "gusset007vert";
	$detector{"mother"}      = "band";
	$detector{"description"} = "Gusset007";
	$detector{"color"}       = "555555";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "-304.35*mm -12.144*mm $zcart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "13.15*mm 254*mm 38.1*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$zcart = $STARTcart + 431.8;
	$detector{"name"}        = "gusset007hori";
	$detector{"mother"}      = "band";
	$detector{"description"} = "Gusset007";
	$detector{"color"}       = "555555";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "-304.35*mm -228.044*mm $zcart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "13.15*mm 38.1*mm 330.2*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$zcart = $STARTcart + 669.925;
	$detector{"name"}        = "shortstrut"; ###########################################SQUARETUBES======================================
	$detector{"mother"}      = "band";
	$detector{"description"} = "Short Strut";
	$detector{"color"}       = "ff00ff";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "254*mm -596.9*mm $zcart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "76.2*mm 76.2*mm 644.525*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "shortstrutair";
	$detector{"mother"}      = "shortstrut";
	$detector{"description"} = "Short Strut air";
	$detector{"color"}       = "ffc0cb";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "69.85*mm 69.85*mm 644.525*mm";
	$detector{"material"}    = "G4_AIR";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "shortstrut001";
	$detector{"mother"}      = "band";
	$detector{"description"} = "Short Strut001";
	$detector{"color"}       = "ff00ff";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "-254*mm -596.9*mm $zcart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "76.2*mm 76.2*mm 644.525*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "shortstrut001air";
	$detector{"mother"}      = "shortstrut001";
	$detector{"description"} = "Short Strut001 air";
	$detector{"color"}       = "ffc0cb";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "69.85*mm 69.85*mm 644.525*mm";
	$detector{"material"}    = "G4_AIR";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

	$zcart = $STARTcart + 736.6;
	$detector{"name"}        = "6x6x.25squaretubebrace";
	$detector{"mother"}      = "band";
	$detector{"description"} = "6x6x.25 Square Tube Brace";
	$detector{"color"}       = "ff00ff";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "0*mm -596.9*mm $zcart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "177.8*mm 76.2*mm 76.2*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "6x6x.25squaretubebraceair";
	$detector{"mother"}      = "6x6x.25squaretubebrace";
	$detector{"description"} = "6x6x.25 Square Tube Brace air";
	$detector{"color"}       = "ffc0cb";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "177.8*mm 69.85*mm 69.85*mm";
	$detector{"material"}    = "G4_AIR";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "6x6x.25squaretubebracehole";
	$detector{"mother"}      = "6x6x.25squaretubebrace";
	$detector{"description"} = "6x6x.25 Square Tube Brace hole";
	$detector{"color"}       = "eeeeee";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "0*mm 0*mm 73.025*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "127*mm 44.45*mm 3.175*mm";
	$detector{"material"}    = "G4_AIR";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

	$zcart = $STARTcart + 469.9;
	$detector{"name"}        = "6x6x.25squaretubeshort001";
	$detector{"mother"}      = "band";
	$detector{"description"} = "6x6x.25 Square Tube Short001";
	$detector{"color"}       = "ff00ff";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "0*mm -596.9*mm $zcart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "177.8*mm 76.2*mm 76.2*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "6x6x.25squaretubeshort001air";
	$detector{"mother"}      = "6x6x.25squaretubeshort001";
	$detector{"description"} = "6x6x.25 Square Tube Short001 air";
	$detector{"color"}       = "ffc0cb";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "177.8*mm 69.85*mm 69.85*mm";
	$detector{"material"}    = "G4_AIR";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "secondbeamds";
	$detector{"mother"}      = "band";
	$detector{"description"} = "second beam ds";
	$detector{"color"}       = "ff00ff";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "908.05*mm -647.7*mm $zcart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "577.85*mm 76.2*mm 76.2*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "secondbeamdsair";
	$detector{"mother"}      = "secondbeamds";
	$detector{"description"} = "second beam ds air";
	$detector{"color"}       = "ffc0cb";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "577.85*mm 69.85*mm 69.85*mm";
	$detector{"material"}    = "G4_AIR";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "secondbeamds001";
	$detector{"mother"}      = "band";
	$detector{"description"} = "second beam ds001";
	$detector{"color"}       = "ff00ff";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "-908.05*mm -647.7*mm $zcart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "577.85*mm 76.2*mm 76.2*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "secondbeamds001air";
	$detector{"mother"}      = "secondbeamds001";
	$detector{"description"} = "second beam ds001 air";
	$detector{"color"}       = "ffc0cb";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "577.85*mm 69.85*mm 69.85*mm";
	$detector{"material"}    = "G4_AIR";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

}
