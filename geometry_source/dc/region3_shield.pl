use strict;
use utils;

our %configuration;

our $tilt      = 25;

our @mother_dx1=(4.9481089,3.9481089, 8.8578648);
our @mother_dx2=(98.04, 157.27, 229.84);
our @mother_dy=(91.82, 147.21, 216.109);
our @mother_dz=(9.09, 16.6, 20.9);
our @mother_xcent= (0,0,227.2394445);
our @mother_ycent= (0,0,0);
our @mother_zcent= (0,0,457.3735853);

sub make_region3_front_shield
{
	my $iregion = 2;
	my $region = $iregion+1;
		
	my $y_enlargement = 3.65;
	my $dx_shift = fstr( $y_enlargement * tan(rad(29.5)));
	my $dx1_adjustment = 3.9;
	
	my $spDZ	= 2;
	my $stheta	= -25.0;
	my $sphi	= 90.0;
	my $spDY1	= $mother_dy[$iregion]+$y_enlargement;
	my $spDX1	= $mother_dx1[$iregion]-$dx_shift-$dx1_adjustment;
	my $spDX2	= $mother_dx2[$iregion]+$dx_shift;
	my $spALP1	= 0.0;
	my $spDY2	= $spDY1;
	my $spDX3	= $spDX1;
	my $spDX4	= $spDX2;
	my $spALP2	= 0.0;

	my $nSectors = 6;

	for(my $s=1; $s<=$nSectors; $s++)
	{
			
		my %detector = init_det();
			
		$detector{"name"}        = "front_shielding_region$region"."_s$s";
		$detector{"mother"}      = "root";
		$detector{"description"} = "CLAS12 Drift Chamber Sheildings for DDVCS, Sector $s Region $region";
		$detector{"pos"}         = front_shield_pos($s, $iregion);
		$detector{"rotation"}    = shield_rot($s, $iregion);
		$detector{"color"}       = "555599";
		$detector{"type"}        = "G4Trap";
		$detector{"dimensions"}  = "$spDZ*mm $stheta*deg $sphi*deg $spDY1*cm $spDX1*cm $spDX2*cm $spALP1*deg $spDY2*cm $spDX3*cm $spDX4*cm $spALP2*deg";
		$detector{"material"}    = "W_alloy";
		$detector{"style"}       = 1;
			
		print_det(\%configuration, \%detector);
			
	}
	
}

sub front_shield_pos
{
	my $sector = shift;
	my $region = shift;
	my $iregion = $region-1;
	my $z_allowance = 8;
	
	my $mxplace = $mother_xcent[$region];
	my $myplace = $mother_ycent[$region];
	my $mzplace = $mother_zcent[$region]-($mother_dz[$iregion]+$z_allowance);
	
   	my $phi =  -($sector-1)*60 ;
   	my $x = fstr($mxplace*cos(rad($phi))+$myplace*sin(rad($phi)));
	my $y = fstr(-$mxplace*sin(rad($phi))+$myplace*cos(rad($phi)));
	my $z = fstr($mzplace);
	
	return "$x*cm $y*cm $z*cm";
}

sub make_region3_back_shield
{
	
	my $iregion = 2;
	my $region = $iregion+1;
		
	my $y_enlargement = 3.65;
	my $dx_shift = fstr( $y_enlargement * tan(rad(29.5)));
	
	my $spDZ	= 2;
	my $stheta	= -25.0;
	my $sphi	= 90.0;
	my $spDY1	= $mother_dy[$iregion]+$y_enlargement;
	my $spDX1	= $mother_dx1[$iregion]-$dx_shift;
	my $spDX2	= $mother_dx2[$iregion]+$dx_shift;
	my $spALP1	= 0.0;
	my $spDY2	= $spDY1;
	my $spDX3	= $spDX1;
	my $spDX4	= $spDX2;
	my $spALP2	= 0.0;

	my $nSectors = 6;

	for(my $s=1; $s<=$nSectors; $s++)
	{
			
		my %detector = init_det();
			
		$detector{"name"}        = "back_shielding_region$region"."_s$s";
		$detector{"mother"}      = "root";
		$detector{"description"} = "CLAS12 Drift Chamber Sheildings for DDVCS, Sector $s Region $region";
		$detector{"pos"}         = back_shield_pos($s, $iregion);
		$detector{"rotation"}    = shield_rot($s, $iregion);
		$detector{"color"}       = "555599";
		$detector{"type"}        = "G4Trap";
		$detector{"dimensions"}  = "$spDZ*mm $stheta*deg $sphi*deg $spDY1*cm $spDX1*cm $spDX2*cm $spALP1*deg $spDY2*cm $spDX3*cm $spDX4*cm $spALP2*deg";
		$detector{"material"}    = "W_alloy";
		$detector{"style"}       = 1;
			
		print_det(\%configuration, \%detector);
			
	}
	
}

sub back_shield_pos
{
	my $sector = shift;
	my $region = shift;
	my $iregion = $region-1;
	my $z_allowance = 8;
	
	my $mxplace = $mother_xcent[$region];
	my $myplace = $mother_ycent[$region];
	my $mzplace = $mother_zcent[$region]+($mother_dz[$iregion]+$z_allowance);
	
   	my $phi =  -($sector-1)*60 ;
   	my $x = fstr($mxplace*cos(rad($phi))+$myplace*sin(rad($phi)));
	my $y = fstr(-$mxplace*sin(rad($phi))+$myplace*cos(rad($phi)));
	my $z = fstr($mzplace);
	
	return "$x*cm $y*cm $z*cm";
}

sub shield_rot
{
	my $sector = shift;
	my $region = shift;

	my $tilt  = fstr($tilt);
	my $zrot  = -($sector-1)*60 + 90;
	
	return "ordered: zxy $zrot*deg $tilt*deg 0*deg ";
}

















