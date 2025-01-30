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
    my @ecal_iradius = (301, 77.1, 85.7, 101 );
    my @ecal_oradius = (301.1, 360.6, 401, 101.1 );
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
    $detector{"style"}       = "1";
   print_det(\%configuration, \%detector);

    
}

sub  makeEcal{
    
    buildEcal_motherVolume();
    
}






