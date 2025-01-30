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
 
    my $nplanes = 6;
    my @bcone_iradius = (489, 380, 402, 104, 120, 153 );
    my @bcone_oradius = (490, 544, 584, 704, 798, 153.1 );
    my @bcone_zpos_root = (584, 649, 696, 840, 951, 1251);
    
    
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
    $detector{"material"}    = "beamline_W";
    $detector{"style"}       = "1";
    print_det(\%configuration, \%detector);

}

sub buildMollerCone
{
 
    my $nplanes = 5;
    my @cone_iradius = (38.1, 38.1, 38.1, 38.1, 38.1 );
    my @cone_oradius = (42.8, 153, 153, 111, 111 );
    my @cone_zpos_root = (381, 1280, 1310, 1380, 2750);
    
    
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






