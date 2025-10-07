use strict;
use warnings;

our %configuration;

our $TorusZpos;
our $SteelFrameLength;
our $mountTotalLength;            # total length of the torus Mount
our $tungstenColor;


sub tungstenCone()
{
    my $microgap = 0.1;
    
    # original physicists design of the moeller shield:
    # tapered tungsten with tapered aluminum vacuum pipe inside
    # corrected physicists design of the moeller shield:
    # tapered tungsten with straight aluminum beam inside
    
    if($configuration{"variation"} eq "physicistsCorrectedBaselineNoFT")
    {
        my $nplanes_tcone = 3;
        
        # shield is a tapered pipe (G4 polycone)
        my @iradius_tcone  = ( 29.8, 29.8,  29.8 );
        my @oradius_tcone  = ( 33.0, 90.0,  90.0 );
        
        my $pipeZstart    = 420.0;    # start of cone
        my $taperedLength = 1390.0;   # length of tapered part
        my $totalLength   = $TorusZpos - $SteelFrameLength - $mountTotalLength - $microgap;   # total cone length
        
        my @z_plane_tcone  = ( $pipeZstart, $taperedLength, $totalLength );
        
        # Tungsten Cone
        my %detector = init_det();
        $detector{"name"}        = "tungstenConeNoFT";
        $detector{"mother"}      = "root";
        $detector{"description"} = "tungsten moller shield - no FT configuration";
        $detector{"color"}       = $tungstenColor;
        $detector{"type"}        = "Polycone";
        my $dimen = "0.0*deg 360*deg $nplanes_tcone*counts";
        for(my $i = 0; $i <$nplanes_tcone; $i++) {$dimen = $dimen ." $iradius_tcone[$i]*mm";}
        for(my $i = 0; $i <$nplanes_tcone; $i++) {$dimen = $dimen ." $oradius_tcone[$i]*mm";}
        for(my $i = 0; $i <$nplanes_tcone; $i++) {$dimen = $dimen ." $z_plane_tcone[$i]*mm";}
        $detector{"dimensions"}  = $dimen;
        $detector{"material"}    = "beamline_W";
        $detector{"style"}       = 1;
        print_det(\%configuration, \%detector);
    }
    
    else
    {
        # Tungsten Cone
        my $totalShieldLength    = 1010.;
        my $partialShieldLength  = 115.4;
        my $partialShieldLengthI = $totalShieldLength - $partialShieldLength;
        my $shieldIR1            = 60.0/2.0;
        my $shieldIR2            = 80.2/2.0;
        my $shieldOR1            = 64.0/2.0;
        my $shieldOR3            = 152.1/2.0;
        my $tgTheta              = ($shieldOR3 - $shieldOR1) / $totalShieldLength;
        my $shieldOR2            = $shieldOR3 - $partialShieldLength*$tgTheta;
        
        my $zConeStart           = 433.9;  # htcc starts at 384 with ID 60.96
        
        my $tantheta25 = 0.0435;
        if($configuration{"variation"} eq "realityWithFT" ||
        $configuration{"variation"} eq "realityWithFTWithInnerShield" ||
        $configuration{"variation"} eq "realityWithFTWithHeliumBag")
        {
            $zConeStart          = 750.0;
        }
        elsif($configuration{"variation"} eq "FTOnINFN" ||
        $configuration{"variation"} eq "FTOn_mount_is_W" ||
        $configuration{"variation"} eq "finalNoFT"   ||
        $configuration{"variation"} eq "FTOffINFN" ||
        $configuration{"variation"} eq "FTOff_mount_is_W") {
            $zConeStart           = 850.0;
            $totalShieldLength    = 1010. - 100.;
            $partialShieldLengthI = $totalShieldLength - $partialShieldLength;
            $shieldOR1            = $zConeStart*$tantheta25;
            $shieldIR1            = $shieldOR1-2;
            $shieldOR2            = $shieldOR3 - $partialShieldLength*$tantheta25;
            if($configuration{"variation"} eq "finalNoFT" || $configuration{"variation"} eq "FTOffINFN" || $configuration{"variation"} eq "FTOff_mount_is_W") {
                $zConeStart           = 433.9+100.;
            }
        }
        elsif($configuration{"variation"} eq "FTOn" ||
        $configuration{"variation"} eq "FTOff" ||
        $configuration{"variation"} eq "KPP") {
            $totalShieldLength    = 882.6;
            $zConeStart           = 1760 - $totalShieldLength;
            $partialShieldLengthI = $totalShieldLength - $partialShieldLength;
            $shieldOR1            = 3.004*25.4/2.;
            $shieldIR1            = $shieldOR1-0.12*25.4;
            $shieldOR3            = 5.988*25.4/2.;
            $tgTheta              = ($shieldOR3 - $shieldOR1) / $totalShieldLength;
            $shieldOR2            = $shieldOR3 - $partialShieldLength*$tgTheta;
            if($configuration{"variation"} eq "FTOff") {
                $zConeStart           = 458.2+103;
            }
        }
        
        my $nplanes_tcone = 4;
        my @iradius_tcone  = ( $shieldIR1,            $shieldIR1,            $shieldIR2,         $shieldIR2 );
        my @oradius_tcone  = ( $shieldOR1,            $shieldOR2,            $shieldOR2,         $shieldOR3 );
        my @z_plane_tcone  = (          0, $partialShieldLengthI, $partialShieldLengthI, $totalShieldLength );
        
        my %detector = init_det();
        $detector{"name"}        = "tungstenConeFT";
        $detector{"mother"}      = "root";
        $detector{"description"} = "FT tungsten moller shield";
        $detector{"color"}       = $tungstenColor;
        $detector{"pos"}         = "0*mm 0.0*mm $zConeStart*mm";
        $detector{"type"}        = "Polycone";
        my $dimen = "0.0*deg 360*deg $nplanes_tcone*counts";
        for(my $i = 0; $i <$nplanes_tcone; $i++) {$dimen = $dimen ." $iradius_tcone[$i]*mm";}
        for(my $i = 0; $i <$nplanes_tcone; $i++) {$dimen = $dimen ." $oradius_tcone[$i]*mm";}
        for(my $i = 0; $i <$nplanes_tcone; $i++) {$dimen = $dimen ." $z_plane_tcone[$i]*mm";}
        $detector{"dimensions"}  = $dimen;
        $detector{"material"}    = "beamline_W";
        $detector{"style"}       = 1;
        print_det(\%configuration, \%detector);
        
        
        
        # Shield after cone - LEAD
        if( $configuration{"variation"} eq "realityWithFT"    ||
        $configuration{"variation"} eq "FTOnINFN" ||
        $configuration{"variation"} eq "FTOn" ||
        $configuration{"variation"} eq "KPP" ||
        $configuration{"variation"} eq "FTOn_mount_is_W" ||
        $configuration{"variation"} eq "realityWithFTWithHeliumBag" ||
        $configuration{"variation"} eq "realityWithFTWithInnerShield") {
            ;
        }
        else {
            my $coneTubeShieldLength = (2269.6 - $zConeStart - $totalShieldLength -20.)/2.;
            my $coneTubeIR           = 88.4/2;
            my $coneTubeOR           = 241.1/2;
            
            # Stainless steel pipe supporting the cone
            my $nplanes_ssts = 6;
            my $sstsIR1      = $shieldIR1;
            my $sstsOR1      = $shieldIR2  - $microgap ;
            my $sstsIR2      = $sstsIR1;
            my $sstsOR2      = $sstsOR1;
            my $sstsIR3      = $sstsIR1;
            my $sstsOR3      = $coneTubeIR - $microgap;
            my $sstsIR4      = $sstsIR1;
            my $sstsOR4      = $sstsOR3;
            my $sstsIR5      = $sstsIR1;
            my $sstsOR5      = 100.0;
            my $sstsIR6      = $sstsIR1;
            my $sstsOR6      = $sstsOR5;
            my $sstsz2       = $partialShieldLength - $microgap;
            my $sstsz3       = $sstsz2;
            my $sstsz4       = $sstsz3 + $coneTubeShieldLength*2;
            my $sstsz5       = $sstsz4;
            my $sstsz6       = $sstsz5 + 20;
            
            if($configuration{"variation"} eq "realityWithFTNotUsed" ||
            $configuration{"variation"} eq "FTOffINFN"   ||
            $configuration{"variation"} eq "FTOff"   ||
            $configuration{"variation"} eq "FTOff_mount_is_W"   ||
            $configuration{"variation"} eq "realityWithFTNotUsedWithInnerShield" ||
            $configuration{"variation"} eq "realityWithFTNotUsedHeliumBag")
            {
                $coneTubeShieldLength = (316.1 + 49.61) / 2.0;
                $nplanes_ssts = 6;
                $sstsIR4      = $sstsIR3;
                $sstsOR4      = $sstsOR3;
                $sstsIR5      = 40.0;
                $sstsOR5      = $coneTubeIR - $microgap;
                $sstsIR6      = $sstsIR5;
                $sstsOR6      = $sstsOR5;
                $sstsz4       = $sstsz3 + $coneTubeShieldLength*2 -49.61 - $partialShieldLength ;
                $sstsz5       = $sstsz4;
                $sstsz6       = $sstsz3 + $coneTubeShieldLength*2;
                
            }
            
            my $coneTubeZpos         = $zConeStart + $totalShieldLength + $coneTubeShieldLength;
            
            if($configuration{"variation"} eq "FTOff" || $configuration{"variation"} eq "FTOffNoField" ) {
                my $nplanes_lead = 3;
                my $coneTubeOR1 = 8.553*25.4/2;
                $coneTubeZpos   = $zConeStart + $totalShieldLength;
                my @iradius_lead  = ( $coneTubeIR,  $coneTubeIR, $coneTubeIR);
                my @oradius_lead  = ( $coneTubeOR1, $coneTubeOR, $coneTubeOR);
                my @z_plane_lead  = (            0,      151.52,       355.7);
                %detector = init_det();
                $detector{"name"}        = "leadShieldAfterCone";
                $detector{"mother"}      = "root";
                $detector{"description"} = "lead Tube after shield";
                $detector{"color"}       = "999999";
                $detector{"pos"}         = "0*mm 0.0*mm $coneTubeZpos*mm";
                $detector{"type"}        = "Polycone";
                $dimen = "0.0*deg 360*deg $nplanes_lead*counts";
                for(my $i = 0; $i <$nplanes_lead; $i++) {$dimen = $dimen ." $iradius_lead[$i]*mm";}
                for(my $i = 0; $i <$nplanes_lead; $i++) {$dimen = $dimen ." $oradius_lead[$i]*mm";}
                for(my $i = 0; $i <$nplanes_lead; $i++) {$dimen = $dimen ." $z_plane_lead[$i]*mm";}
                $detector{"dimensions"}  = $dimen;
                $detector{"material"}    = "G4_Pb";
                $detector{"style"}       = 1;
                print_det(\%configuration, \%detector);
                
            }
            else {
                %detector = init_det();
                $detector{"name"}        = "leadShieldAfterCone";
                $detector{"mother"}      = "root";
                $detector{"description"} = "lead Tube after shield";
                $detector{"color"}       = "999999";
                $detector{"pos"}         = "0*mm 0.0*mm $coneTubeZpos*mm";
                $detector{"type"}        = "Tube";
                $detector{"dimensions"}  = "$coneTubeIR*mm $coneTubeOR*mm $coneTubeShieldLength*mm 0.0*deg 360*deg";
                $detector{"material"}    = "G4_Pb";
                $detector{"style"}       = 1;
                print_det(\%configuration, \%detector);
            }
            
            
            # Stainless steel support of the FT cone (if FT is not used0
            my $sstsPos         = $zConeStart + $totalShieldLength - $sstsz2;
            
            my @iradius_ssts  = ( $sstsIR1, $sstsIR2, $sstsIR3, $sstsIR4, $sstsIR5, $sstsIR6 );
            my @oradius_ssts  = ( $sstsOR1, $sstsOR2, $sstsOR3, $sstsOR4, $sstsOR5, $sstsOR6 );
            my @z_plane_ssts  = (        0,  $sstsz2,  $sstsz3,  $sstsz4,  $sstsz5,  $sstsz6 );
            
            %detector = init_det();
            $detector{"name"}        = "sstShieldSupport";
            $detector{"mother"}      = "root";
            $detector{"description"} = "Stainless Steel support for tungsten cone and shield";
            $detector{"pos"}         = "0*mm 0.0*mm $sstsPos*mm";
            $detector{"color"}       = "bbbbbb";
            $detector{"type"}        = "Polycone";
            $dimen = "0.0*deg 360*deg $nplanes_ssts*counts";
            for(my $i = 0; $i <$nplanes_ssts; $i++) {$dimen = $dimen ." $iradius_ssts[$i]*mm";}
            for(my $i = 0; $i <$nplanes_ssts; $i++) {$dimen = $dimen ." $oradius_ssts[$i]*mm";}
            for(my $i = 0; $i <$nplanes_ssts; $i++) {$dimen = $dimen ." $z_plane_ssts[$i]*mm";}
            $detector{"dimensions"}  = $dimen;
            $detector{"color"}       = "3333ff";
            $detector{"material"}    = "G4_STAINLESS-STEEL";
            $detector{"style"}       = 1;
            print_det(\%configuration, \%detector);
            
            
            # Additional Cone on top of the FT cone
            my $addLength = 300;
            my $addY      = $shieldOR3*tan(2.5/180*3.141592);
            my $addThickStart = 2;
            
            my $nplanes_addCone = 2;
            
            my @iradius_addCone  = ( $shieldOR3 - $addY + $microgap     ,  $shieldOR3 + $microgap, 0. );
            my @oradius_addCone  = ( $shieldOR3 - $addY + $addThickStart,  $coneTubeOR ,0.);
            my @z_plane_addCone  = (          0,  $addLength ,0.);
            
            my $zAddConeStart  = $coneTubeZpos - $addLength - $microgap - $coneTubeShieldLength;
            
            if($configuration{"variation"} eq "FTOff") {
                $nplanes_addCone = 3;
                $addLength      = 284.3 ;
                my $addLength1   = $addLength - 4.299*25.4/2.;
                $zAddConeStart  = $coneTubeZpos - $addLength;
                my $addIR1 = 5.035*25.4/2.;
                my $addIR3 = 5.988*25.4/2.;
                my $addIR2 = $addIR1 + ($addIR3-$addIR1)*$addLength1/$addLength;
                my $addOR1 = 5.285*25.4/2.;
                my $addOR3 = 8.553*25.4/2;
                my $addOR2 = $addOR3 - ($addLength - $addLength1)*0.0787;
                @iradius_addCone  = ( $addIR1,     $addIR2,     $addIR3);
                @oradius_addCone  = ( $addOR1,     $addOR2,     $addOR3);
                @z_plane_addCone  = (       0, $addLength1,  $addLength);
            }
            
            %detector = init_det();
            $detector{"name"}        = "additionalCone";
            $detector{"mother"}      = "root";
            $detector{"description"} = "Tungsten additional cone";
            $detector{"pos"}         = "0*mm 0.0*mm $zAddConeStart*mm";
            $detector{"color"}       = $tungstenColor;
            $detector{"type"}        = "Polycone";
            $dimen = "0.0*deg 360*deg $nplanes_addCone*counts";
            for(my $i = 0; $i <$nplanes_addCone; $i++) {$dimen = $dimen ." $iradius_addCone[$i]*mm";}
            for(my $i = 0; $i <$nplanes_addCone; $i++) {$dimen = $dimen ." $oradius_addCone[$i]*mm";}
            for(my $i = 0; $i <$nplanes_addCone; $i++) {$dimen = $dimen ." $z_plane_addCone[$i]*mm";}
            $detector{"dimensions"}  = $dimen;
            $detector{"material"}    = "beamline_W";
            $detector{"style"}       = 1;
            print_det(\%configuration, \%detector);
            
            
            if($configuration{"variation"} eq "finalNoFT" ||
            $configuration{"variation"} eq "FTOffINFN" ||
            $configuration{"variation"} eq "FTOff_mount_is_W")
            {
                my $nplanes_ConeTip = 4;
                
                my $length_ConeTip  = 100;
                my $zConeTipStart   = $zConeStart - $length_ConeTip;
                my $zConeTipEnd     = $zConeStart + $length_ConeTip;
                my $TipIR1          = 60.0/2.0;
                my $TipOR1          = 64.0/2.0;
                
                my @iradius_ConeTip  = ( $TipIR1,    $TipIR1,    $TipIR1,    $TipIR1 );
                my @oradius_ConeTip  = ( $TipOR1, $shieldOR1, $shieldIR1, $shieldIR1 );
                my @z_plane_ConeTip  = (       0, $zConeStart - $zConeTipStart, $zConeStart - $zConeTipStart, $zConeTipEnd - $zConeTipStart );
                
                %detector = init_det();
                $detector{"name"}        = "ConeTip";
                $detector{"mother"}      = "root";
                $detector{"description"} = "Tungsten cone tip";
                $detector{"pos"}         = "0*mm 0.0*mm $zConeTipStart*mm";
                $detector{"color"}       = $tungstenColor;
                $detector{"type"}        = "Polycone";
                $dimen = "0.0*deg 360*deg $nplanes_ConeTip*counts";
                for(my $i = 0; $i <$nplanes_ConeTip; $i++) {$dimen = $dimen ." $iradius_ConeTip[$i]*mm";}
                for(my $i = 0; $i <$nplanes_ConeTip; $i++) {$dimen = $dimen ." $oradius_ConeTip[$i]*mm";}
                for(my $i = 0; $i <$nplanes_ConeTip; $i++) {$dimen = $dimen ." $z_plane_ConeTip[$i]*mm";}
                $detector{"dimensions"}  = $dimen;
                $detector{"material"}    = "beamline_W";
                $detector{"style"}       = 1;
                print_det(\%configuration, \%detector);
                
                
            }
            
            if($configuration{"variation"} eq "FTOff")
            {
                my $nplanes_ConeTip = 4;
                
                my $length_ConeTip  = 103;
                my $zConeTipStart   = $zConeStart - $length_ConeTip;
                my $zConeTipEnd     = $zConeStart + 2.856*25.4;
                my $TipOR1          = 2.615*25.4/2.0;
                my $TipIR1          = $TipOR1 - 0.13*25.4;
                
                my @iradius_ConeTip  = ( $TipIR1,    $TipIR1,    $TipIR1,    $TipIR1 );
                my @oradius_ConeTip  = ( $TipOR1, $shieldOR1, $shieldIR1, $shieldIR1 );
                my @z_plane_ConeTip  = (       0, $zConeStart - $zConeTipStart, $zConeStart - $zConeTipStart, $zConeTipEnd - $zConeTipStart );
                
                %detector = init_det();
                $detector{"name"}        = "ConeTip";
                $detector{"mother"}      = "root";
                $detector{"description"} = "Tungsten cone tip";
                $detector{"pos"}         = "0*mm 0.0*mm $zConeTipStart*mm";
                $detector{"color"}       = $tungstenColor;
                $detector{"type"}        = "Polycone";
                $dimen = "0.0*deg 360*deg $nplanes_ConeTip*counts";
                for(my $i = 0; $i <$nplanes_ConeTip; $i++) {$dimen = $dimen ." $iradius_ConeTip[$i]*mm";}
                for(my $i = 0; $i <$nplanes_ConeTip; $i++) {$dimen = $dimen ." $oradius_ConeTip[$i]*mm";}
                for(my $i = 0; $i <$nplanes_ConeTip; $i++) {$dimen = $dimen ." $z_plane_ConeTip[$i]*mm";}
                $detector{"dimensions"}  = $dimen;
                $detector{"material"}    = "beamline_W";
                $detector{"style"}       = 1;
                print_det(\%configuration, \%detector);
                
                
            }
        }
        
    }
    
    
}
















