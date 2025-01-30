use strict;
use warnings;
use math;

our %configuration;

our $TorusLength;
our $TorusZpos;
our $inches;

my $microgap = 0.1;
my $vacuumJacketThickness = 12.7;   # M. Zarecky email. The walls are 12.7, the top iss 15.9.


# The torus model is:
#
# 1. a vacuum jacket: sum of hexagon + parallepid coils
# 2. vacuum inside the sst jacket: sum of hexagon + parallepid coils
# 3. aluminum + copper coils inside the vacuum coild part:  parallepid coils, mix of aluminum and copper
# 4. the cold hub is a tube inside the hexagon vacuum
#
# Since the hexagon and parallelepids are similar, they can be built in the same routines




sub makeHexagons
{
	
	# first make inner hexagon
	
	my $nzplanes = 2;
	my $nsides   = 6;

	
	# Inner radius will be used by Vacuum hexagon inside inside
	my $vacuumR = 200.0;     # estimate based on drawings
	my $jacketR = $vacuumR + $vacuumJacketThickness;
	
	my @ztorus   = (  -$TorusLength,  $TorusLength);

	
	# SST Vacuum Jacket
	my $dimen = "0.0*deg 360*deg $nsides*counts $nzplanes*counts";
	for(my $i = 0; $i < $nzplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
	for(my $i = 0; $i < $nzplanes; $i++) {$dimen = $dimen ." $jacketR*mm";}
	for(my $i = 0; $i < $nzplanes; $i++) {$dimen = $dimen ." $ztorus[$i]*mm";}
	
	my %detector = init_det();
	$detector{"name"}        = "vacuumJacketHexFrame";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Torus SST Vacuum Jacket Frame ";
	$detector{"type"}        = "Pgon";
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "Component";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	
	
	# Vacuum inside Jacket
	$dimen = "0.0*deg 360*deg $nsides*counts $nzplanes*counts";
	for(my $i = 0; $i < $nzplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
	for(my $i = 0; $i < $nzplanes; $i++) {$dimen = $dimen ." $vacuumR*mm";}
	for(my $i = 0; $i < $nzplanes; $i++) {$dimen = $dimen ." $ztorus[$i]*mm";}
	
	%detector = init_det();
	$detector{"name"}        = "vacuumHexFrame";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Torus SST Vacuum inside Vacuum Jacket Frame ";
	$detector{"type"}        = "Pgon";
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "Component";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
}


sub makeParallelepipeds
{
	my $pangle           = -25;
	my $vjacketOR        =  7.87*$inches ;

	# empirical
	my $vjacketCase_zpos = 155.0;

	# vacuum jacket fgrame
	my $vjacketCase_dx    = $TorusLength - 30;    # empirical
	my $vjacketCase_dy    = 122.6/2.0;            # M. Zarecky, 1/11/16
	my $vjacketCase_dz    = 1400.0;               # length from beampipe
	
	
	# SST Vacuum Jacket cases
	for(my $n=0; $n<6; $n++)
	{
		my $nindex      = $n+1;
		my $overlap     = 0.00;
		my $R           = $vjacketOR + $vjacketCase_dz - $overlap;

		my %detector = init_det();
		$detector{"name"}        = "vacuumCase$nindex";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Torus SST Frame Component $nindex parallelepiped part";
		$detector{"type"}        = "Parallelepiped";
		$detector{"dimensions"}  = "$vjacketCase_dx*mm $vjacketCase_dy*mm $vjacketCase_dz*mm 0*deg $pangle*deg 0*deg";
		$detector{"pos"}         = framesPos($R, $n, $vjacketCase_zpos, $vjacketCase_dz, $pangle);
		$detector{"rotation"}    = framesRot($R, $n);
		$detector{"material"}    = "Component";
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);
	}
	
	# Vacuum inside jackets
	my $coilThickness  = $vacuumJacketThickness;
	my $vacuumCase_dx  = $vjacketCase_dx - $coilThickness;
	my $vacuumCase_dy  = $vjacketCase_dy - $coilThickness;
	my $vacuumCase_dz  = $vjacketCase_dz -10;

	for(my $n=0; $n<6; $n++)
	{
		my $nindex      = $n+1;
		my $overlap     = $vacuumJacketThickness;
		my $R           = $vjacketOR + $vacuumCase_dz - $overlap;
		
		my %detector = init_det();
		$detector{"name"}        = "vacuumInsideCase$nindex";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Torus Vacuum inside Frame Component $nindex parallelepiped part";
		$detector{"type"}        = "Parallelepiped";
		$detector{"dimensions"}  = "$vacuumCase_dx*mm $vacuumCase_dy*mm $vacuumCase_dz*mm 0*deg $pangle*deg 0*deg";
		$detector{"pos"}         = framesPos($R+20, $n, $vjacketCase_zpos, $vacuumCase_dz, $pangle);
		$detector{"rotation"}    = framesRot($R, $n);
		$detector{"material"}    = "Component";
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);
	}
	

	# Aluminum Cold Mass Shield + Copper Coil themselves
	my $coilsThickness  = 74.2/2.0;     # M. Zarecky, 1/11/16
	my $coilCase_dx     = $vacuumCase_dx - 30;   # empirical
	my $coilCase_dy     = $coilsThickness;
	my $coildCaseAddLength = -20;                 # empirical: additional length of coils
	my $coilCase_dz     = $vjacketCase_dz + $coildCaseAddLength;
	
	for(my $n=0; $n<6; $n++)
	{
		my $nindex      = $n+1;
		my $distanceCoilCaseToVacJacket = 18.9;  # M. Zarecky, 1/11/16
		my $overlap     = $vacuumJacketThickness + $distanceCoilCaseToVacJacket;
		my $R           = $vjacketOR + $coilCase_dz - $overlap - 2*$coildCaseAddLength;
		
		my %detector = init_det();
		$detector{"name"}        = "coilCase$nindex";
		$detector{"mother"}      = "torusVacuumFrame";
		$detector{"description"} = "Coil Case inside Vacuum Jacket $nindex parallelepiped part";
		$detector{"type"}        = "Parallelepiped";
		$detector{"dimensions"}  = "$coilCase_dx*mm $coilCase_dy*mm $coilCase_dz*mm 0*deg $pangle*deg 0*deg";
		$detector{"pos"}         = framesPos($R, $n, $vjacketCase_zpos, $coilCase_dz, $pangle);
		$detector{"rotation"}    = framesRot($R, $n);
		$detector{"material"}    = "G4_Cu";
		$detector{"color"}       = "ffaaaa";
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);
	}
	
}


sub sumVacuumJacket()
{
	# summing Jacket Parallelepiped to hexagons
	for(my $n=0; $n<6; $n++)
	{
		my $nindex = $n+1;
		
		my %detector = init_det();
		$detector{"name"}        = "torusSteelFrame$nindex";
		$detector{"mother"}      = "root";
		$detector{"description"} = "Torus SST Frame Component $nindex parallelepiped part + hexagon core";
		$detector{"color"}       = "dd99663";
		$detector{"type"}        = "Operation: torusSteelFrame$n + vacuumCase$nindex";
		if($n == 0)
		{
			$detector{"type"}        = "Operation: vacuumJacketHexFrame + vacuumCase$nindex";
		}
		$detector{"material"}    = "Component";
		
		if($n == 5)
		{
			$detector{"name"}     = "torusSteelFrame";
		}
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);
	}

	# need to subtract the inner part so the beamline can go through
	# and the torus can be put inside fc
	my $WarmBoreIR  = 123.8/2.0 - $microgap;        # taken from new drawing by D. Kashy
	my $dummylength = 5000;
	
	my %detector = init_det();
	$detector{"name"}        = "beamHole";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Hole to be subtracted from torusSteelFrame";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "0*mm $WarmBoreIR*mm $dummylength*mm 0*deg 360*deg";
	$detector{"material"}    = "Component";
	$detector{"color"}       = "aaffff";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	%detector = init_det();
	$detector{"name"}        = "torus";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Torus is torusSteelFrame - hole for beampipe";
	$detector{"color"}       = "dd99663";
	$detector{"type"}        = "Operation: torusSteelFrame - beamHole";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"rotation"}    = "0*deg 180*deg 0*deg";
	$detector{"pos"}         = "0*mm 0*mm $TorusZpos*mm";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

}

sub sumVacuum()
{
	# summing Vacuum inside Jackets Parallelepiped to vacuum hexagon
	for(my $n=0; $n<6; $n++)
	{
		my $nindex = $n+1;
		
		my %detector = init_det();
		$detector{"name"}        = "torusVacuumFrame$nindex";
		$detector{"mother"}      = "torus";
		$detector{"description"} = "Torus Vacuum inside Frame Component $nindex parallelepiped part + hexagon core";
		$detector{"color"}       = "0000004";
		$detector{"type"}        = "Operation: torusVacuumFrame$n + vacuumInsideCase$nindex";
		if($n == 0)
		{
			$detector{"type"}        = "Operation: vacuumHexFrame + vacuumInsideCase$nindex";
		}
		$detector{"material"}    = "Component";
		if($n == 5)
		{
			$detector{"name"}     = "torusVacuumFrame";
			$detector{"material"} = "G4_Galactic";
		}
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);
	}
	

}


sub torusCoils()
{
	makeHexagons();
	makeParallelepipeds();
	sumVacuumJacket();
	sumVacuum();
}



sub framesPos
{
	my $R     = shift;
	my $i     = shift;
	my $zpos  = shift;
	my $dz    = shift;
	my $angle = shift;
	# warning: empirical
	my $z     = $zpos + $dz*tan(abs(rad($angle))) - 135.0;
	
	$R = $R+230;
	
	my $theta     = 30.0 + $i*60.0;
	my $x         = sprintf("%.3f", $R*cos(rad($theta)));
	my $y         = sprintf("%.3f", $R*sin(rad($theta)));
	return "$x*mm $y*mm $z*mm";
}

sub framesRot
{
	my $R = shift;
	my $i = shift;
	
	my $theta     = 30.0 + $i*60.0;
	
	return "ordered: yxz -90*deg $theta*deg 0*deg";
}







