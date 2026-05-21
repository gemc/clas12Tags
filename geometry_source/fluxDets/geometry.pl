
use strict;
use warnings;

our %configuration;

sub sector_pos {
    my $sector = shift;

    my $r = 200;
    my $z = 500;

    my $phi = 60.0 * $sector;
    my $x = fstr($r * cos(rad($phi)));
    my $y = fstr($r * sin(rad($phi)));

    return "$x*cm $y*cm $z*cm";
}

sub makeFlux {

    if ($configuration{"variation"} eq "beamline") {
        my $nflux = 40;
        my $zstart = 100;
        my $dz = 20;

        for (my $i = 1; $i <= $nflux; $i++) {
            my $zpos = $zstart + ($i - 1) * $dz;
            my %detector = init_det();
            $detector{"name"} = "beam_flux_$i";
            $detector{"mother"} = "root";
            $detector{"description"} = "beam flux $i";
            $detector{"pos"} = "0.0*cm 0.0*cm $zpos*mm";
            $detector{"color"} = "aa0088";
            $detector{"type"} = "Tube";
            $detector{"dimensions"} = "0*mm 100*mm 0.1*mm 0.*deg 360.*deg";
            $detector{"material"} = "G4_Galactic";
            $detector{"style"} = 1;
            $detector{"sensitivity"} = "flux";
            $detector{"hit_type"} = "flux";
            $detector{"identifiers"} = "id manual $i";
            print_det(\%configuration, \%detector);
        }
    }
    elsif ($configuration{"variation"} eq "ddvcs") {

        my $pi = 3.14156;
        my $thickness = 0.1;
        my $material = "G4_Galactic";


	# polycone in the central region
        my $central_nplanes = 3;
        my @central_iradius = (250.0, 250.0, 57.6);
        my @central_zpos_root = (-400.0, 333.0, 416.0);
    
        my $dimen = "0.0*deg 360*deg $central_nplanes*counts";
        for(my $i = 0; $i <$central_nplanes; $i++) {$dimen = $dimen ." $central_iradius[$i]*mm";}
        for(my $i = 0; $i <$central_nplanes; $i++) {
		my $central_oradius = $central_iradius[$i]+$thickness;
		$dimen = $dimen ." $central_oradius*mm";
	}
        for(my $i = 0; $i <$central_nplanes; $i++) {$dimen = $dimen ." $central_zpos_root[$i]*mm";}
    
        my %detector = init_det();
    	$detector{"name"}        = "ddvcs_central_flux";
    	$detector{"mother"}      = "root";
    	$detector{"description"} = "ddvcs central flux";
    	$detector{"color"}       = "aa0088";
    	$detector{"type"}        = "Polycone";
    	$detector{"dimensions"}  = $dimen;
        $detector{"pos"}         = "0.0*cm 0.0*cm 0.0*cm";
        $detector{"material"}    = $material;
        $detector{"style"}       = 1;
        $detector{"sensitivity"} = "flux";
        $detector{"hit_type"}    = "flux";
        $detector{"identifiers"} = "id manual 1";
        print_det(\%configuration, \%detector);

    
	# trapezoid before and after the shield
        my $shield_nsectors = 6;
        my $shield_nlayers = 2;
        my @shield_distance = (580, 1400);
	my $shield_theta = 25 * $pi/180;
	my @shield_angle = (7, 37);

        for(my $il=0; $il<$shield_nlayers; $il++) {
		my $shield_r1 = $shield_distance[$il] * (sin($shield_theta) + cos($shield_theta)*tan($shield_angle[0]*$pi/180-$shield_theta)); 
        	my $shield_z1 = $shield_distance[$il] * (cos($shield_theta) - sin($shield_theta)*tan($shield_angle[0]*$pi/180-$shield_theta)); 
                my $shield_w1 = $shield_r1*tan($pi*0.999/6);
                my $shield_r2 = $shield_distance[$il] * (sin($shield_theta) + cos($shield_theta)*tan($shield_angle[1]*$pi/180-$shield_theta)); 
        	my $shield_z2 = $shield_distance[$il] * (cos($shield_theta) - sin($shield_theta)*tan($shield_angle[1]*$pi/180-$shield_theta)); 
                my $shield_w2 = $shield_r2*tan($pi*0.999/6);
                my $shield_dh = ($shield_r2-$shield_r1)/2/cos($shield_theta);
                my $shield_dz = $thickness/2;

                for(my $is=0; $is<$shield_nsectors; $is++) {
        
        		my $shield = ($is+1)*10+$il+1;
                        my $shield_ph = 90-$is*60;
                        my $shield_xc = ($shield_r2+$shield_r1)/2*cos($is*$pi/3);
                        my $shield_yc = ($shield_r2+$shield_r1)/2*sin($is*$pi/3);        
                        my $shield_zc = ($shield_z2+$shield_z1)/2;

                        %detector = init_det();
                        $detector{"name"}        = "ddvcs_shield_flux$shield";
                        $detector{"mother"}      = "root";
                        $detector{"description"} = "ddvcs shield flux $shield";
                        $detector{"color"}       = "aa0088";
                        $detector{"type"}        = "G4Trap";
                        $detector{"dimensions"}  = "$shield_dz*mm -$shield_theta*rad 90*deg $shield_dh*mm $shield_w1*mm $shield_w2*mm 0 $shield_dh*mm $shield_w1*mm $shield_w2*mm 0";
                        $detector{"pos"}         = "$shield_xc*mm $shield_yc*mm $shield_zc*mm";
                        $detector{"rotation"}    = "ordered: zyx $shield_ph*deg 0 $shield_theta*rad";
                        $detector{"material"}    = $material;
                        $detector{"style"}       = 1;
                        $detector{"sensitivity"} = "flux";
                        $detector{"hit_type"}    = "flux";
                        $detector{"identifiers"} = "id manual $shield";
                        print_det(\%configuration, \%detector);
                }
	}

	# cone before FTOF
        my $forward_nplanes = 2;
        my @forward_iradius = (4500, 300);
        my @forward_zpos_root = (4042, 6000);
    
        $dimen = "0.0*deg 360*deg $forward_nplanes*counts";
        for(my $i = 0; $i <$forward_nplanes; $i++) {$dimen = $dimen ." $forward_iradius[$i]*mm";}
        for(my $i = 0; $i <$forward_nplanes; $i++) {
		my $forward_oradius = $forward_iradius[$i]+$thickness;
		$dimen = $dimen ." $forward_oradius*mm";
	}
        for(my $i = 0; $i <$forward_nplanes; $i++) {$dimen = $dimen ." $forward_zpos_root[$i]*mm";}
    
        %detector = init_det();
    	$detector{"name"}        = "ddvcs_forward_flux";
    	$detector{"mother"}      = "root";
    	$detector{"description"} = "ddvcs forward flux";
    	$detector{"color"}       = "aa0088";
    	$detector{"type"}        = "Polycone";
    	$detector{"dimensions"}  = $dimen;
        $detector{"pos"}         = "0.0*cm 0.0*cm 0.0*cm";
        $detector{"material"}    = $material;
        $detector{"style"}       = 1;
        $detector{"sensitivity"} = "flux";
        $detector{"hit_type"}    = "flux";
        $detector{"identifiers"} = "id manual 10";
        print_det(\%configuration, \%detector);


    }

}

