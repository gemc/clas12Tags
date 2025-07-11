#!/usr/bin/perl -w

use strict;
use lib ("$ENV{GEMC}/api/perl");
use utils;
use parameters;
use geometry;
use math;
use materials;
use bank;
use hit;

use Math::Trig;

# Help Message


# Loading configuration file from argument
our %configuration = load_configuration($ARGV[0]);



sub buildEcal_motherVolume
{
 
    my $nplanes = 4;
    my @ecal_iradius = (301, 72.8, 81.5, 98.7 );
    my @ecal_oradius = (301.1, 360.6, 401, 98.8 );
    my @ecal_zpos_root = (520, 625, 696, 836);


    my $dimen = "0.0*deg 360*deg $nplanes*counts";
    
    for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $ecal_iradius[$i]*mm";}
    for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $ecal_oradius[$i]*mm";}
    for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $ecal_zpos_root[$i]*mm";}
    
    
    my %detector = init_det();
    $detector{"name"}        = "ddvcs_ecal";
    $detector{"mother"}      = "root";
    $detector{"description"} = "volume containing PbWO4";
    $detector{"color"}       = "e30e0e";
    $detector{"type"}        = "Polycone";
    $detector{"dimensions"}  = $dimen;
    my $X=0.;
    my $Y=0.;
    my $Z=0.;
    $detector{"pos"}         = "$X*mm $Y*mm $Z*mm ";
    $detector{"material"}    = "G4_PbWO4";
    $detector{"style"}       = "0";
   print_det(\%configuration, \%detector);

    
}

# PbWO4 Crystal;
sub make_mucal_crystals
{
        my $toRad = 3.14156/180;
        my $Dat25deg = 596; # distance of the upstream face from the target at 25 deg
        my $ThetaU   = 25 * $toRad; # deg
        my $ThetaMin =  7 * $toRad; # deg
        my $ThetaMax = 30 * $toRad; # deg
        my $CwidthU = 13;
        my $CwidthD = 17;
        my $Clength = 190;
        my $CrminU = ($Dat25deg+$Clength/2) * ( tan($ThetaU) - tan($ThetaU - $ThetaMin) )*cos($ThetaU);
        my $CrmaxU = ($Dat25deg+$Clength/2) * ( tan($ThetaU) + tan($ThetaMax - $ThetaU) )*cos($ThetaU);
	my $microgap = 0.5;
        my $Cwidth = ($CwidthU+$CwidthD)/2 + $microgap;
	my $nCrystal = 2*$CrmaxU / $Cwidth;

	for(my $iX = 0; $iX < $nCrystal; $iX++)
	{
		for(my $iY = 0; $iY < $nCrystal; $iY++)
		{
			my $centerX = - $CrmaxU + $iX*$Cwidth + 0.5*$Cwidth;
			my $centerY = - $CrmaxU + $iY*$Cwidth + 0.5*$Cwidth;

			my $x12 = ($centerX - 0.5*$Cwidth)*($centerX - 0.5*$Cwidth);
			my $x22 = ($centerX + 0.5*$Cwidth)*($centerX + 0.5*$Cwidth);
			my $y12 = ($centerY - 0.5*$Cwidth)*($centerY - 0.5*$Cwidth);
			my $y22 = ($centerY + 0.5*$Cwidth)*($centerY + 0.5*$Cwidth);
			
			my $rad1 = sqrt($x12 + $y12);
			my $rad2 = sqrt($x22 + $y22);
			my $rad3 = sqrt($x12 + $y22);
			my $rad4 = sqrt($x22 + $y12);
			
			if($rad1 > $CrminU + $microgap && $rad1 < $CrmaxU - $microgap &&
				$rad2 > $CrminU + $microgap && $rad2 < $CrmaxU - $microgap &&
				$rad3 > $CrminU + $microgap && $rad3 < $CrmaxU - $microgap &&
				$rad4 > $CrminU + $microgap && $rad4 < $CrmaxU - $microgap
				)
			{
				
                                my $rxy     = sqrt($centerX*$centerX + $centerY*$centerY);
                		my $centerZ = ($Dat25deg+$Clength/2)/cos($ThetaU) - $rxy*sin($ThetaU);
            
                                my $thetaX  = -atan($centerX/$centerZ)/$toRad;
                                my $thetaY  = atan($centerY/$centerZ)/$toRad;
      
                                my $radius = sqrt($rxy*$rxy + $centerZ*$centerZ);
                                my $posX = $centerX * ($radius+$Clength*0/2)/$radius;
                                my $posY = $centerY * ($radius+$Clength*0/2)/$radius;
                                my $posZ = $centerZ * ($radius+$Clength*0/2)/$radius;

				my %detector = init_det();
				$detector{"name"}        = "ddvcs_ecal" . $iX . "_" . $iY ;
				$detector{"mother"}      = "ddvcs_ecal";
				$detector{"description"} = "ft crystal (h:" . $iX . ", v:" . $iY . ")";
            				
                                $detector{"pos"}         = "$posX*mm $posY*mm $posZ*mm";
                                $detector{"rotation"}    = "$thetaY*deg $thetaX*deg 0*deg  ";
				$detector{"color"}       = "E2A7F5";
				$detector{"type"}        = "Trd" ;
				my $dx1 = $CwidthU / 2.0;
                                my $dx2 = $CwidthD / 2.0;
                                my $dz  = $Clength / 2.0;
				$detector{"dimensions"}  = "$dx1*mm $dx2*mm $dx1*mm $dx2*mm $dz*mm";
				$detector{"material"}    = "G4_PbWO4";
			        $detector{"sensitivity"} = "ft_cal";
                                $detector{"hit_type"} = "ft_cal";
                                $detector{"identifiers"} = "ih manual $iX iv manual $iY";
                		$detector{"style"}       = 1;
				print_det(\%configuration, \%detector);
				
				
			}
		}
	}
}

sub  makeEcal{
    
    buildEcal_motherVolume();
    make_mucal_crystals();
    
}






