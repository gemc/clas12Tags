use strict;
use utils;

our %configuration;

our @mother_dx1;
our @mother_dx2;
our @mother_dy;
our @mother_dz;
our @mother_xcent;
our @mother_ycent;
our @mother_zcent;

# base plate thickness 1.50"

our $pl_thick  = 1.5*$inches/2;
our $tilt      = 25;

my @plateMat  = ("G4_Al", "G4_STAINLESS-STEEL", "G4_Al");

sub make_plates
{
	
	# plate parameters by region DISCLAIMER: R1 and R2 are not set from drawings (yet)
	my @pl_bottom = (1.4*$inches/2    , 1.9*$inches/2    , 4.774*$inches/2);
	my @pl_top    = (2.8*$inches/2    , 3.4*$inches/2    , 8.168*$inches/2);
	
	my $nRegions = 3;
	if( $configuration{"variation"} eq "cosmicR1") {$nRegions = 1;}

	
	for(my $iregion=0; $iregion<$nRegions; $iregion++)
	{
		
		my $region = $iregion+1;
		
		my $nSectors = 6;
		if( $configuration{"variation"} eq "cosmicR1") {$nSectors = 1;}

		for(my $s=1; $s<=$nSectors; $s++)
		{
			
			my %detector = init_det();
			
			$detector{"name"}        = "plates_region$region"."_s$s";
			$detector{"mother"}      = "region$region"."_s$s";
			$detector{"description"} = "CLAS12 Drift Chamber Baseplates, Sector $s Region $region";
			$detector{"pos"}         = plate_pos($s, $iregion);
			$detector{"rotation"}    = plate_rot($s, $iregion);
			$detector{"color"}       = "GCE937";
			$detector{"type"}        = "G4Trap";
			$detector{"dimensions"}  = "$mother_dy[$iregion]*mm 0*deg 0*deg $pl_thick*cm $pl_bottom[$iregion]*cm $pl_top[$iregion]*cm 0*deg $pl_thick*cm $pl_bottom[$iregion]*cm $pl_top[$iregion]*cm 0*deg";
			$detector{"material"}    = $plateMat[$iregion];
			$detector{"style"}       = 1;
			
			print_det(\%configuration, \%detector);
			
		}
	}
}

sub plate_pos
{
	my $sector = shift;
	my $region = shift;
	
	my $y   = -0.5*$pl_thick - $mother_dy[$region] - 0.01;
	my $x   = 0;
	my $z   = 0;
	
	return "$x*cm $y*cm $z*cm";
}

sub plate_rot
{
	
	my $sector = shift;
	my $region = shift;
	
	# undo the tilt of the mother volume
	my $ptilt  = -$tilt;
	
	return "ordered: zxy 0*deg $ptilt*deg 0*deg ";
}


















