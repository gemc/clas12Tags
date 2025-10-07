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
our $tilt;



# to scale the plates in the radial direction
my $yscale = 0.9;

# regions 1, and 3 taken from Cyril Wiggins drawings (Endplate LEFT)
# region 2 averaged from 1, 3.  RIGHT assumed identical to LEFT
my @ep_dz = (  0.375*$inches/2  ,   0.375*$inches/2,   0.375*$inches/2);
my @ep_dy = ( 77.161*$inches/2 , 101.059*$inches/2, 178.220*$inches/2);
my @ep_dx = ( 11.010*$inches/2  ,  16.395*$inches/2,  21.780*$inches/2);

foreach my $dy (@ep_dy) { $dy = $dy * $yscale; }

my $ep_alpha = -25.00;
my $ep_theta = 0.00;
my $ep_phi   = 0.01;

my @endPlateMat = ("G4_Al", "G4_STAINLESS-STEEL", "G4_Al");

sub make_endplates
{
		
	for(my $iregion=0; $iregion<3; $iregion++)
	{
	    my $region = $iregion+1;
		
		for(my $s=1; $s<=6; $s++)
		{
		    for (my $iside=1; $iside<3; $iside++)
		    {
			my %detector = init_det();
			
			$detector{"name"}        = "endplates_region$region"."_s$s"."_side$iside";
			$detector{"mother"}      = "region$region"."_s$s";
			$detector{"description"} = "CLAS12 Drift Chamber End plates, Sector $s Region $region";
			$detector{"pos"}         = endplate_pos($iside, $s, $iregion);
			$detector{"rotation"}    = endplate_rot($iside, $s, $iregion);
			$detector{"color"}       = "GCE937";
			$detector{"type"}        = "Parallelepiped";
			$detector{"dimensions"}  = "$ep_dx[$iregion]*cm $ep_dy[$iregion]*cm $ep_dz[$iregion]*cm $ep_alpha*deg $ep_theta*deg $ep_phi*deg";
			$detector{"material"}    = $endPlateMat[$iregion];
			$detector{"style"}       = 1;
			
			print_det(\%configuration, \%detector);
		    }	
		}
	} 
}

sub endplate_pos
{
    my $side   = shift;
    my $sector = shift;
    my $region = shift;
    
    my @sign = (-1.000, 1.000);

    my $y   = 0.00;
    my $x   = $sign[$side-1]*($mother_dx1[$region]+$mother_dx2[$region])/2;
    my $z   = 0.00;
    
    return "$x*cm $y*cm $z*cm";
}

sub endplate_rot
{
    my $side   = shift;
    my $sector = shift;
    my $region = shift;

    my @ztilt = (-32.5, 32.5);
    my @ytilt = (12.0 + 90.0, -12.0 + 90.0); # the plates are contructed 90 degrees out of place and rotated in


    return "ordered: zxy $ztilt[$side-1]*deg -25.0*deg $ytilt[$side-1]*deg ";
}


















