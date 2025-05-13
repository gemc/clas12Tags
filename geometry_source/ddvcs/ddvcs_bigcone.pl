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


sub buildBigCone_motherVolume
{
 
    my $nplanes = 9;
    my @bcone_iradius = (302, 402, 98.8, 105.2, 105.2, 113.3, 134.8, 150, 150);
    my @bcone_oradius = (457, 614, 740, 784, 798, 798, 882.5, 627.9, 150.1 );
    my @bcone_zpos_root = (520, 696, 837, 888, 888, 951, 1132.3, 1251, 1473.8);
    
    
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

sub buildMollerCone
{
 
    my $nplanes = 5;
    my @cone_iradius = (26.1, 26.1, 33.1, 33.1, 33.1 );
    my @cone_oradius = (30.6, 149, 149, 111, 111 );
    my @cone_zpos_root = (300, 1251, 2280, 2380, 2750);
    
    
    my $dimen = "0.0*deg 360*deg $nplanes*counts";
    
    for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $cone_iradius[$i]*mm";}
    for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $cone_oradius[$i]*mm";}
    for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $cone_zpos_root[$i]*mm";}
    
    
    my %detector = init_det();
    $detector{"name"}        = "ddvcs_mollercone";
    $detector{"mother"}      = "root";
    $detector{"description"} = "Moller Cone";
    $detector{"color"}       = "222288";
    $detector{"type"}        = "Polycone";
    $detector{"dimensions"}  = $dimen;
    my $X=0.;
    my $Y=0.;
    my $Z=0.;
    $detector{"pos"}         =  "$X*mm $Y*mm $Z*mm ";
    $detector{"material"}    = "beamline_W";
    $detector{"style"}       = "1";
    print_det(\%configuration, \%detector);

}

sub makeBigCone {
    
    buildBigCone_motherVolume();
    buildMollerCone();
}






