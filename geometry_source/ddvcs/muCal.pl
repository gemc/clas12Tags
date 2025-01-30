use strict;
use warnings;

our %configuration;
our $toRad;
our $microgap;


our $CwidthU;    # Upstream   crystal width in mm (side of the squared front face)
our $CwidthD;    # Downstream crystal width in mm (side of the squared front face)
our $Clength;    # Crystal length in mm

our $CZpos;    # Position of the front face of the crystals

our $CrminU;
our $CrmaxU;

our $CrminD;
our $CrmaxD;


sub make_mucal_mvolume
{	
	my @mucal_zpos    = ( $CZpos - $microgap, $CZpos + $Clength + $microgap );
	# my @mucal_iradius = ( $CrminU - $microgap, $CrminD - $microgap );

	# keeping radius flat as crystals are not tilted yet
	my @mucal_iradius = ( $CrminU - 40*$microgap, $CrminU - 40*$microgap );

	my @mucal_oradius = ( $CrmaxU + 40*$microgap, $CrmaxD + 40*$microgap );

	my $nplanes = 2;
	
	my $dimen = "0.0*deg 360*deg $nplanes*counts";
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $mucal_iradius[$i]*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $mucal_oradius[$i]*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $mucal_zpos[$i]*mm";}

	
   my %detector = init_det();
   $detector{"name"}        = "mucal";
   $detector{"mother"}      = "root";
   $detector{"description"} = "muon calorimeter mother volume";
   $detector{"color"}       = "a50021";
   $detector{"type"}        = "Polycone";
   $detector{"dimensions"}  = $dimen;
   $detector{"material"}    = "G4_PbWO4";
	if($configuration{"variation"} eq "mucalActive")
	{
		$detector{"material"}    = "Vacuum";
		$detector{"visible"}     = 0;
	}

   $detector{"style"}       = 1;
   print_det(\%configuration, \%detector);
}




# PbWO4 Crystal;
#sub make_mucal_crystals
#{
#	my $nCrystal = 2*$CrmaxU / $CwidthU;
#	
#	for(my $iX = 0; $iX < $nCrystal; $iX++)
#	{
#		for(my $iY = 0; $iY < $nCrystal; $iY++)
#		{
#			my $centerX = - $CrmaxU + $iX*$CwidthU + 0.5*$CwidthU;
#			my $centerY = - $CrmaxU + $iY*$CwidthU + 0.5*$CwidthU;
#			
#			my $x12 = ($centerX - 0.5*$CwidthU)*($centerX - 0.5*$CwidthU);
#			my $x22 = ($centerX + 0.5*$CwidthU)*($centerX + 0.5*$CwidthU);
#			my $y12 = ($centerY - 0.5*$CwidthU)*($centerY - 0.5*$CwidthU);
#			my $y22 = ($centerY + 0.5*$CwidthU)*($centerY + 0.5*$CwidthU);
#			
#			my $rad1 = sqrt($x12 + $y12);
#			my $rad2 = sqrt($x22 + $y22);
#			my $rad3 = sqrt($x12 + $y22);
#			my $rad4 = sqrt($x22 + $y12);
#			
#			if($rad1 > $CrminU + $microgap && $rad1 < $CrmaxU - $microgap &&
#				$rad2 > $CrminU + $microgap && $rad2 < $CrmaxU - $microgap &&
#				$rad3 > $CrminU + $microgap && $rad3 < $CrmaxU - $microgap &&
#				$rad4 > $CrminU + $microgap && $rad4 < $CrmaxU - $microgap
#				)
#			{
#				
#            #my $radius = sqrt($centerX*$centerX + $centerY*$centerY);
#            
#            my $thetaX  = -atan($centerX/$CZpos)/$toRad;
#            my $thetaY  = atan($centerY/$CZpos)/$toRad;
#      
#            
#				my %detector = init_det();
#				$detector{"name"}        = "mucal_cr_" . $iX . "_" . $iY ;
#				$detector{"mother"}      = "mucal";
#				$detector{"description"} = "ft crystal (h:" . $iX . ", v:" . $iY . ")";
#            
#            #my $xpos = $centerX + $Clength*tan($theta * $toRad);
#            #my $ypos = $centerY + $Clength*tan($phi * $toRad);
#            my $zPos = $CZpos + $Clength / 2.0;
#				$detector{"pos"}         = "$centerX*mm $centerY*mm $zPos*mm";
#            $detector{"rotation"}    = "$thetaY*deg $thetaX*deg 0*deg  ";
#				$detector{"color"}       = "a50021";
#				$detector{"type"}        = "Trd" ;
#				my $dx1 = $CwidthU / 2.0;
#            my $dx2 = $CwidthD / 2.0;
#            my $dz  = $Clength / 2.0;
#				$detector{"dimensions"}  = "$dx2*mm $dx1*mm $dx2*mm $dx1*mm $dz*mm";
#				$detector{"material"}    = "G4_PbWO4";
#				$detector{"style"}       = 0;
#				print_det(\%configuration, \%detector);
#				
#				
#			}
#		}
#	}
#}



# Loop over all crystals and define their positions
sub make_mucal_crystals
{
	my $nCrystal = 2*$CrmaxU / $CwidthU;

	my $centX = ( int $nCrystal/2 )+0.5;
	my $centY = ( int $nCrystal/2 )+0.5;

	my $zPos  = $CZpos + $Clength/2.0 + $microgap;


	for ( my $iX = 1; $iX < $nCrystal; $iX++ )
	{
		for ( my $iY = 1; $iY < $nCrystal; $iY++ )
		{
			my $locX = ($iX-$centX)*$CwidthU;
			my $locY = ($iY-$centY)*$CwidthU;
			my $locR = sqrt($locX*$locX+$locY*$locY);

			if($locR>$CrminU + 1 && $locR < $CrmaxU-$CwidthU/2 - 0.8)
			{
				# crystal mother volume
				my %detector = init_det();
				$detector{"name"}        = "crystal_" . $iX . "_" . $iY ;
				$detector{"mother"}      = "mucal";
				$detector{"description"} = "crystal volume (h:" . $iX . ", v:" . $iY . ")";
				$detector{"pos"}         = "$locX*mm $locY*mm $zPos*mm";
				$detector{"color"}       = "838EDE";
				$detector{"type"}        = "Box" ;
				my $dX = $CwidthU/2.0;
				my $dY = $CwidthU/2.0;
				my $dZ = $Clength/2.0;
				$detector{"dimensions"}  = "$dX*mm $dY*mm $dZ*mm";
				$detector{"material"}    = "G4_PbWO4";
#				$detector{"sensitivity"} = "flux";
#				$detector{"hit_type"}    = "flux";
#				my $fluxID = 1000*$iX + $iY;
#				$detector{"identifiers"} = "id manual $fluxID";
				$detector{"sensitivity"} = "ft_cal";
				$detector{"hit_type"}    = "ft_cal";
				$detector{"identifiers"} = "ih manual $iX iv manual $iY";
				print_det(\%configuration, \%detector);

			}
		}
	}
}


sub make_mu_cal
{
   make_mucal_mvolume();
	if($configuration{"variation"} eq "mucalActive")
	{
		make_mucal_crystals();
	}
}











