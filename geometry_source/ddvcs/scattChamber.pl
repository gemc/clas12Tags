use strict;
use warnings;

our %configuration;
our $toRad;
our $microgap;




sub make_scatt_chambers
{
	my $nplanes = 4;

	my @zpos       = ( -115.0,  260.0, 290.0, 390.0 );
	my @oradius    = (   50.0,   50.0,  26.0,  26.0 );
	my @iradius    = (   44.0,   44.0,  22.0,  22.0 );
	my @t_oradius  =  (  56.0,   56.0,  26.0,  26.0 );
	
	my @z_plane    =  ( $zpos[0] - 1, $zpos[1], $zpos[2], $zpos[3] + 1 );
	
	
	# vacuum target container
	my %detector = init_det();
	$detector{"name"}        = "target";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Target Container";
	$detector{"color"}       = "22ff22";
	$detector{"type"}        = "Polycone";
	my $dimen = "0.0*deg 360*deg $nplanes*counts";
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." 0.0*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $t_oradius[$i]*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $z_plane[$i]*mm";}
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "G4_Galactic";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	
	$dimen = "0.0*deg 360*deg $nplanes*counts";
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $iradius[$i]*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $oradius[$i]*mm";}
	for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $zpos[$i]*mm";}	
        %detector = init_det();
        $detector{"name"}        = "scattChamber";
        $detector{"mother"}      = "target";
        $detector{"description"} = "ddvcs scatt chambers";
        $detector{"color"}       = "aaaaaa";
        $detector{"type"}        = "Polycone";
        $detector{"dimensions"}  = $dimen;
        $detector{"material"}    = "rohacell";
        print_det(\%configuration, \%detector);
	
	$dimen = "0.0*deg 360*deg 2*counts";
        my $s_iradius = $oradius[0] + 0.1;
        my $s_oradius = $oradius[0] + 0.2;
	for(my $i = 0; $i <2; $i++) {$dimen = $dimen ." $s_iradius*mm";}
	for(my $i = 0; $i <2; $i++) {$dimen = $dimen ." $s_oradius*mm";}
	for(my $i = 0; $i <2; $i++) {$dimen = $dimen ." $zpos[$i]*mm";}
        %detector = init_det();
        $detector{"name"}        = "scattChamberShield";
        $detector{"mother"}      = "target";
        $detector{"description"} = "ddvcs scatt chambers W shield";
        $detector{"color"}       = "aaaaaa";
        $detector{"type"}        = "Polycone";
        $detector{"dimensions"}  = $dimen;
        $detector{"material"}    = "G4_W";
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
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	# 50 microns exit / entry windows
	
	my $wzpos = $zpos[3] + 0.1;
	my $worad = $oradius[3] - 2;
	
	%detector = init_det();
	$detector{"name"}        = "scattChamberExitWindow";
	$detector{"mother"}      = "target";
	$detector{"description"} = "Vacuum exit window";
	$detector{"color"}       = "aaaaff";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "0*mm $worad*mm 0.05*mm 0*deg 360*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"pos"}         = "0 0 $wzpos*mm";
	print_det(\%configuration, \%detector);

}


