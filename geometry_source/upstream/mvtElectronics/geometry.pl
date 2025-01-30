use strict;
use warnings;

our %configuration;

# Assign parameters to local variables
my $NUM_BOXES = 6;
my $theta0    = 360./$NUM_BOXES;
my $R         = 370.89;
my $NUM_FEUS  = 9;

sub build_mvtElectronics
{
	my %detector = init_det();
	$detector{"name"}        = "mvtElectronics";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Electronics box";
	$detector{"pos"}         = "0*cm 0*cm 270*cm";
	$detector{"rotation"}    = "180*deg 0*deg 0*deg";
	$detector{"color"}       = "339999";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "248.5*mm 510*mm 115*mm 0*deg 360*deg";
	$detector{"material"}    = "G4_AIR";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

	build_crate();
	build_panel();
}

sub build_crate
{
	for(my $i=1; $i<=$NUM_BOXES; $i++)
	{
		my $pnumber     = cnumber($i-1, 10);
		
		my %detector = init_det();
		# positioning
		# The angle $theta is defined off the y-axis (going clockwise) so $x and $y are reversed
		my $theta  = ($i-1)*$theta0;
		my $theta2 = $theta + 90;
		my $x      = sprintf("%.3f", $R*cos(rad($theta)));
		my $y      = sprintf("%.3f", $R*sin(rad($theta)));
		my $z      = "0";

		my $xpos = $x + 174.9*sin(rad($theta));
		my $ypos = $y - 174.9*cos(rad($theta));
		my $zpos = $z + 74.6;
		$detector{"name"}        = "crate_$pnumber";
		$detector{"mother"}      = "mvtElectronics";
		$detector{"description"} = "MVT Crate";
		$detector{"pos"}         = "$x*mm $y*mm $z*mm";
		$detector{"rotation"}    = "0*deg 0*deg -$theta*deg";
		$detector{"color"}       = "aaaaaa";
		$detector{"type"}        = "Box";
		$detector{"dimensions"}  = "120.64*mm 131.75*mm 114.62*mm";
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = 0;
		print_det(\%configuration, \%detector);

		$detector{"name"}        = "patch_panel_$pnumber";
		$detector{"mother"}      = "mvtElectronics";
		$detector{"description"} = "Patch panel for MVT crate";
		$detector{"pos"}         = "$xpos*mm $ypos*mm $zpos*mm";
		$detector{"rotation"}    = "0*deg 0*deg -$theta*deg";
		$detector{"color"}       = "999999";
		$detector{"type"}        = "Box";
		$detector{"dimensions"}  = "90*mm 20*mm 15*mm"; # 114*cm 114*cm 104*cm
		$detector{"material"}    = "G4_Al";
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);

		}
}
sub build_panel
{
	for(my $i=1; $i<=$NUM_BOXES; $i++)
	{
		my $qnumber     = cnumber($i-1, 10);
		
		# positioning
		# The angle $theta is defined off the y-axis (going clockwise) so $x and $y are reversed
		my $theta  = ($i-1)*$theta0;
		my $theta2 = $theta + 90;
		my $x      = sprintf("%.3f", $R*cos(rad($theta)));
		my $y      = sprintf("%.3f", $R*sin(rad($theta)));
		my $z      = "0";

		my $xp     = $x - 5*cos(rad($theta));
		my $yp     = $y - 5*sin(rad($theta));
		my $zp     = $z - 2.5;
		my %detector = init_det();
		$detector{"name"}        = "inside_$qnumber";
		$detector{"mother"}      = "crate_$qnumber";
		$detector{"description"} = "Inside of crate";
		$detector{"pos"}         = "2.5*mm 0*mm 0.05*mm";
		$detector{"rotation"}    = "0*deg 0*deg 0*deg";
		$detector{"color"}       = "eeeeee";
		$detector{"type"}        = "Box";
		$detector{"dimensions"}  = "116.89*mm 130.25*mm 110.92*mm";
		$detector{"material"}    = "G4_AIR";
		$detector{"style"}       = 0;
		print_det(\%configuration, \%detector);


		for(my $n=1; $n<=$NUM_FEUS; $n++)
		{
			my $q = $i*100;
			$q = $q + $n;
			my $xpo = ($n-1)*25.42-99.18;
			my $zpo = 112.62;
			my %detector = init_det();
			#$detector{"name"}        = "panel_$q";
			#$detector{"mother"}      = "inside_$qnumber";
			#$detector{"description"} = "Panel $q";
			#$detector{"pos"}         = "$xpo*mm 0*mm $zpo*mm";
			#$detector{"rotation"}    = "0*deg 0*deg 0*deg";
			#$detector{"color"}       = "ee5500";
			#$detector{"type"}        = "Box";
			#$detector{"dimensions"}  = "12.5*mm 131*mm 1.2*mm";
			#$detector{"material"}    = "G4_Al";
			#$detector{"style"}       = 1;
			#print_det(\%configuration, \%detector);

			$xpo = $xpo - 10.5;
			$zpo = $zpo - 113;
			$detector{"name"}        = "Lplate_$q";
			$detector{"mother"}      = "inside_$qnumber";
			$detector{"description"} = "Left plate $q";
			$detector{"pos"}         = "$xpo*mm 0*mm $zpo*mm";
			$detector{"rotation"}    = "0*deg 0*deg 0*deg";
			$detector{"color"}       = "888888";
			$detector{"type"}        = "Box";
			$detector{"dimensions"}  = "0.3*mm 116*mm 107.5*mm";
			$detector{"material"}    = "G4_Al";
			$detector{"style"}       = 1;
			print_det(\%configuration, \%detector);

			$xpo = $xpo + 21;
			$detector{"name"}        = "Rplate_$q";
			$detector{"mother"}      = "inside_$qnumber";
			$detector{"description"} = "Right plate $q";
			$detector{"pos"}         = "$xpo*mm 0*mm $zpo*mm";
			$detector{"rotation"}    = "0*deg 0*deg 0*deg";
			$detector{"color"}       = "888888";
			$detector{"type"}        = "Box";
			$detector{"dimensions"}  = "0.3*mm 116*mm 107.5*mm";
			$detector{"material"}    = "G4_Al";
			$detector{"style"}       = 1;
			print_det(\%configuration, \%detector);

			$xpo = $xpo - 6.5;
			$detector{"name"}        = "eboard_$q";
			$detector{"mother"}      = "inside_$qnumber";
			$detector{"description"} = "Electronics board $q";
			$detector{"pos"}         = "$xpo*mm 0*mm $zpo*mm";
			$detector{"rotation"}    = "0*deg 0*deg 0*deg";
			$detector{"color"}       = "9AB973";
			$detector{"type"}        = "Box";
			$detector{"dimensions"}  = "1*mm 116.75*mm 110*mm";
			$detector{"material"}    = "G10"; # pcb fiberglass
			$detector{"style"}       = 1;
			print_det(\%configuration, \%detector);
		}
	}
}
