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



our $pi    = 3.141592653589793238;
our $toRad = $pi/180.0;


# Loading configuration file from argument
our %configuration = load_configuration($ARGV[0]);


sub buildBigCone
{
    my $thetaCut = shift;
 
    my $nplanes = 9;
    my @bcone_iradius = (302, 402, 98.8, 105.2, 105.2, 113.3, 134.8, 150, 150);
    my @bcone_oradius = (457, 614, 740, 784, 798, 798, 882.5, 627.9, 150.1 );
    my @bcone_zpos_root = (520, 696, 837, 888, 888, 951, 1132.3, 1251, 1473.8);
    
    if($thetaCut==15) {
       $nplanes = 5;
       @bcone_zpos_root = (785, 837, 1251, 1370, 1473.8);
       @bcone_iradius = (210, 98.8, 150, 150, 150);
       @bcone_oradius = (210, 224, 335, 368, 150.1 );
    }

    my $dimen = "0.0*deg 360*deg $nplanes*counts";
    
    for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $bcone_iradius[$i]*mm";}
    for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $bcone_oradius[$i]*mm";}
    for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $bcone_zpos_root[$i]*mm";}
    
    
    my %detector = init_det();
    $detector{"name"}        = "ddvcs_bigcone";
    $detector{"mother"}      = "root";
    $detector{"description"} = "volume containing W";
    $detector{"color"}       = "555599";
    $detector{"type"}        = "Polycone";
    $detector{"dimensions"}  = $dimen;
    my $X=0.;
    my $Y=0.;
    my $Z=0.;
    $detector{"pos"}         =  "$X*mm $Y*mm $Z*mm ";
    $detector{"material"}    = "ddvcs_shield_mat";
    $detector{"style"}       = "1";
    print_det(\%configuration, \%detector);

}

