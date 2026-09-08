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

my $toRad = 3.14156/180;
my $Dat25deg = 596; # distance of the upstream face from the target at 25 deg
my $ThetaU   = 25 * $toRad; # deg
my $ThetaMin =  7 * $toRad; # deg
my $ThetaMax = 30 * $toRad; # deg
my $ThetaCut = 30 * $toRad; # deg
my $CwidthU = 13;
my $CwidthD = 17;
my $Clength = 190;


sub buildEcal_motherVolume
{
    my $otheta = $ThetaCut + 0.0*$toRad;;
    my $itheta = $ThetaMin - 0.3*$toRad;;

    my $rminU = ($Dat25deg         +1 ) * ( tan($ThetaU) - tan($ThetaU - $itheta) )*cos($ThetaU);
    my $rmaxU = ($Dat25deg         +1 ) * ( tan($ThetaU) + tan($otheta - $ThetaU) )*cos($ThetaU);
    my $rminD = ($Dat25deg+$Clength+14) * ( tan($ThetaU) - tan($ThetaU - $itheta) )*cos($ThetaU);
    my $rmaxD = ($Dat25deg+$Clength+14) * ( tan($ThetaU) + tan($otheta - $ThetaU) )*cos($ThetaU);
    my @zs = ($rmaxU/tan($otheta), $rminU/tan($itheta), $rmaxD/tan($otheta), $rminD/tan($itheta));
    my @ir = ($rmaxU, $rminU, $zs[2]*tan($itheta), $rminD);	
    my @or = ($rmaxU, $zs[1]*tan($otheta), $rmaxD, $rminD);	

    my $nplanes = 4;
    my $dimen = "0.0*deg 360*deg $nplanes*counts";
    for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $ir[$i]*mm";}
    for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $or[$i]*mm";}
    for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $zs[$i]*mm";}
    
    
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
    $detector{"material"}    = "G4_AIR";
    $detector{"style"}       = "0";
   print_det(\%configuration, \%detector);

    
}

# PbWO4 Crystal;
sub make_mucal_crystals
{
        my $Crmin = ($Dat25deg+$Clength/2) * ( tan($ThetaU) - tan($ThetaU - $ThetaMin) )*cos($ThetaU);
        my $Crmax = ($Dat25deg+$Clength/2) * ( tan($ThetaU) + tan($ThetaMax - $ThetaU) )*cos($ThetaU);
        my $Crcut = ($Dat25deg+$Clength/2) * ( tan($ThetaU) + tan($ThetaCut - $ThetaU) )*cos($ThetaU);
	my $microgap = 0.5;
        my $Cwidth = ($CwidthU+$CwidthD)/2 + $microgap;
	my $nCrystal = 2*(int($Crmax / $Cwidth)+0);

	for(my $iX = 0; $iX < $nCrystal; $iX++)
	{
		for(my $iY = 0; $iY < $nCrystal; $iY++)
		{
			my $centerX = - $nCrystal/2*$Cwidth + $iX*$Cwidth + 0.5*$Cwidth;
			my $centerY = - $nCrystal/2*$Cwidth + $iY*$Cwidth + 0.5*$Cwidth;

			my $x12 = ($centerX - 0.5*$Cwidth)*($centerX - 0.5*$Cwidth);
			my $x22 = ($centerX + 0.5*$Cwidth)*($centerX + 0.5*$Cwidth);
			my $y12 = ($centerY - 0.5*$Cwidth)*($centerY - 0.5*$Cwidth);
			my $y22 = ($centerY + 0.5*$Cwidth)*($centerY + 0.5*$Cwidth);
			
			my $rad1 = sqrt($x12 + $y12);
			my $rad2 = sqrt($x22 + $y22);
			my $rad3 = sqrt($x12 + $y22);
			my $rad4 = sqrt($x22 + $y12);
			
			if($rad1 > $Crmin + $microgap && $rad1 < $Crcut - $microgap &&
				$rad2 > $Crmin + $microgap && $rad2 < $Crcut - $microgap &&
				$rad3 > $Crmin + $microgap && $rad3 < $Crcut - $microgap &&
				$rad4 > $Crmin + $microgap && $rad4 < $Crcut - $microgap
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
                                my $idX = $iX+1;
                                my $idY = $iY+1;
				$detector{"name"}        = "ddvcs_ecal" . $idX . "_" . $idY ;
				$detector{"mother"}      = "ddvcs_ecal";
				$detector{"description"} = "ft crystal (h:" . $idX . ", v:" . $idY . ")";
            				
                                $detector{"pos"}         = "$posX*mm $posY*mm $posZ*mm";
                                $detector{"rotation"}    = "$thetaY*deg $thetaX*deg 0*deg  ";
				$detector{"color"}       = "E2A7F5";
				$detector{"type"}        = "Trd" ;
				my $dx1 = $CwidthU / 2.0;
                                my $dx2 = $CwidthD / 2.0;
                                my $dz  = $Clength / 2.0;
				$detector{"dimensions"}  = "$dx1*mm $dx2*mm $dx1*mm $dx2*mm $dz*mm";
				$detector{"material"}    = "G4_PbWO4";
			        $detector{"sensitivity"} = "mucal";
                                $detector{"hit_type"} = "mucal";
                                $detector{"identifiers"} = "ih manual $idX iv manual $idY";
                		$detector{"style"}       = 1;
				print_det(\%configuration, \%detector);
				
				
			}
		}
	}
}

sub  makeEcal{
    
    $ThetaCut = shift;
    $ThetaCut *= $toRad;

    buildEcal_motherVolume();
    make_mucal_crystals();
    
}






