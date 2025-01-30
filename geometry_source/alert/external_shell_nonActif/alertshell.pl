#!/usr/bin/perl -w

use strict;
use lib ("$ENV{GEMC}/api/perl");
use utils;
use geometry;
use math;
use materials;
use bank;
use hit;

# Help Message
sub help()
{
	print "\n Usage: \n";
	print "   alertshell.pl <configuration filename>\n";
	print "   Will create ALERT non active external shell\n";
	exit;
}

# Make sure the argument list is correct
# If not pring the help
if( scalar @ARGV != 1)
{
	help();
	exit;
}

# Loading configuration file from argument
our %configuration = load_configuration($ARGV[0]);

#materials
require "./materials.pl";
materials();

#bank
require "./bank.pl";
define_bank();

#bank
require "./hit.pl";
define_hit();

###########################################################################################
# All dimensions in mm
# From inside to outside
# Only external structure, not used for reconstruction
# Non active geometry for material budget estimation on forward reconstruction resolution

# Defining the angle zero in the middle of Al rib 1 

#my $z_half_atof = 279.7/2.0;
#my $z_half_ribs = 330.0/2.0;

# there is a new half atof
#my $z_half_atof = 139.85;
#my $z_half_ribs = 165.0;
my $z_half_al_ribs = 318.0/2.0;
my $z_half_epoxy_ribs = 172.0/2.0;

# exemple of material array and colors array
#my @radius  = (6.0, 6.025, 30.0, 75.0,  125.0,  125.3,  155.3); # mm
#my @thickness = (0.035,  25, 30, 25); # mm
# my @layer_mater = ('G4_KAPTON', 'G4_MYLAR');
# my @layer_color = ('330099', 'aaaaff');
# my @gem_mater = ( 'G4_Cu', 'G4_KAPTON', 'G4_Cu');
# my @gem_color = ('661122',  '330099', '661122');
# my @pcb_layer_color = ('aaafff');

# mother volume
#sub make_mother
#{
#	my %detector = init_det();
#	$detector{"name"}        = "mother_shell";
#	$detector{"mother"}      = "root";
#	$detector{"description"} = "ALERT global shell";
#	$detector{"color"}       = "eeeegg";
#	$detector{"pos"}         = "0*mm 0*mm 127.7*mm";
#	$detector{"type"}        = "Tube";
#	$detector{"dimensions"}  = "27.0*mm 210.0*mm 200.0*mm 0*deg 360*deg";
#	$detector{"material"}    = "G4_He";
#	$detector{"visible"}     = 1;
#	$detector{"visible"}     = 0;
#	print_det(\%configuration, \%detector);
#}



# ATOF module fixing part
sub make_wedgePCB
{
	my $rmin = 101.5;
	my $rmax  = 103.11;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240015);
	
	$detector{"name"} = "wedgePCB";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF wedge PCB";
	$detector{"color"}       = "007645";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_NYLON-6-6";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}


sub make_ATOFfixAl
{
	my $rmin = 111;
	my $rmax  = 114.805;
	my $half_thickness = 250.0/2.0;
	my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',24001);
	
	$detector{"name"} = "ATOFfixAl";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF AL fixing";
	$detector{"color"}       = "00ff00";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

# not segmented --> is a tube outside of Al
sub make_ATOFfixASteel
{
	my $rmin = 114.805;
	my $rmax  = 114.997;
	my $half_thickness = 250.0/2.0;
	my $phistart = 0;
	my $pspan = 360;
	#my $mate  = "alloy_steel";
	my %detector = init_det();
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',24005);
	
	$detector{"name"} = "ATOFfixASteel";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF Alloy Steel fixing";
	$detector{"color"}       = "080808";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	#$detector{"material"}    = $mate;
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

#not segmented --> a tube on top of alloy steel
sub make_ATOFfixBrass
{
	my $rmin = 114.997;
	my $rmax  = 115.015;
	my $half_thickness = 250.0/2.0;
	my $phistart = 0;
	my $pspan = 360;
	#my $mate  = "alloy_steel";
	my %detector = init_det();
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240051);
	
	$detector{"name"} = "ATOFfixBrass";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF BRASS fixing";
	$detector{"color"}       = "53f6d6";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	#$detector{"material"}    = $mate;
	$detector{"material"}    = "G4_Cu";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

sub make_CarbonMountingBar1
{
	my $rmin = 124.5;
	my $rmax  = 128.471;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 6;
	my $pspan = 12;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240016);
	
	$detector{"name"} = "CarbonMountingBar1";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Carbon Mounting Bar 1";
	$detector{"color"}       = "ffff00";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

sub make_CarbonMountingBar2
{
	my $rmin = 124.5;
	my $rmax  = 128.471;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 30;
	my $pspan = 12;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240029);
	
	$detector{"name"} = "CarbonMountingBar2";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Carbon Mounting Bar 2";
	$detector{"color"}       = "ffff00";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

sub make_CarbonMountingBar3
{
	my $rmin = 124.5;
	my $rmax  = 128.471;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 54;
	my $pspan = 12;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240030);
	
	$detector{"name"} = "CarbonMountingBar3";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Carbon Mounting Bar 3";
	$detector{"color"}       = "ffff00";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

sub make_CarbonMountingBar4
{
	my $rmin = 124.5;
	my $rmax  = 128.471;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 78;
	my $pspan = 12;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240031);
	
	$detector{"name"} = "CarbonMountingBar4";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Carbon Mounting Bar 4";
	$detector{"color"}       = "ffff00";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

sub make_CarbonMountingBar5
{
	my $rmin = 124.5;
	my $rmax  = 128.471;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 102;
	my $pspan = 12;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240032);
	
	$detector{"name"} = "CarbonMountingBar5";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Carbon Mounting Bar 5";
	$detector{"color"}       = "ffff00";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

sub make_CarbonMountingBar6
{
	my $rmin = 124.5;
	my $rmax  = 128.471;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 126;
	my $pspan = 12;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240033);
	
	$detector{"name"} = "CarbonMountingBar6";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Carbon Mounting Bar 6";
	$detector{"color"}       = "ffff00";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

sub make_CarbonMountingBar7
{
	my $rmin = 124.5;
	my $rmax  = 128.471;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 150;
	my $pspan = 12;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240034);
	
	$detector{"name"} = "CarbonMountingBar7";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Carbon Mounting Bar 7";
	$detector{"color"}       = "ffff00";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

sub make_CarbonMountingBar8
{
	my $rmin = 124.5;
	my $rmax  = 128.471;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 174;
	my $pspan = 12;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240035);
	
	$detector{"name"} = "CarbonMountingBar8";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Carbon Mounting Bar 8";
	$detector{"color"}       = "ffff00";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

sub make_CarbonMountingBar9
{
	my $rmin = 124.5;
	my $rmax  = 128.471;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 198;
	my $pspan = 12;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240036);
	
	$detector{"name"} = "CarbonMountingBar9";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Carbon Mounting Bar 9";
	$detector{"color"}       = "ffff00";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

sub make_CarbonMountingBar10
{
	my $rmin = 124.5;
	my $rmax  = 128.471;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 222;
	my $pspan = 12;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240037);
	
	$detector{"name"} = "CarbonMountingBar10";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Carbon Mounting Bar 10";
	$detector{"color"}       = "ffff00";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

sub make_CarbonMountingBar11
{
	my $rmin = 124.5;
	my $rmax  = 128.471;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 246;
	my $pspan = 12;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240038);
	
	$detector{"name"} = "CarbonMountingBar11";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Carbon Mounting Bar 11";
	$detector{"color"}       = "ffff00";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

sub make_CarbonMountingBar12
{
	my $rmin = 124.5;
	my $rmax  = 128.471;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 270;
	my $pspan = 12;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240039);
	
	$detector{"name"} = "CarbonMountingBar12";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Carbon Mounting Bar 12";
	$detector{"color"}       = "ffff00";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

sub make_CarbonMountingBar13
{
	my $rmin = 124.5;
	my $rmax  = 128.471;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 294;
	my $pspan = 12;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240040);
	
	$detector{"name"} = "CarbonMountingBar13";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Carbon Mounting Bar 13";
	$detector{"color"}       = "ffff00";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

sub make_CarbonMountingBar14
{
	my $rmin = 124.5;
	my $rmax  = 128.471;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 318;
	my $pspan = 12;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240041);
	
	$detector{"name"} = "CarbonMountingBar14";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Carbon Mounting Bar 14";
	$detector{"color"}       = "ffff00";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

sub make_CarbonMountingBar15
{
	my $rmin = 124.5;
	my $rmax  = 128.471;
	my $half_thickness  = 282.4/2.0; 
	my $phistart = 342;
	my $pspan = 12;
	my %detector = init_det();
#	my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240042);
	
	$detector{"name"} = "CarbonMountingBar15";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Carbon Mounting Bar 15";
	$detector{"color"}       = "ffff00";
#	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}


sub make_ATOFpatchPCB
{
	my $rmin = 172.8;
	my $rmax  = 173.866;
	my $half_thickness = 101.6/2.0;
	my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $position = -1*($half_thickness);
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',24002);
	
	$detector{"name"} = "ATOFpatchPCB";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF Patch PCB";
	$detector{"color"}       = "00760e";
	$detector{"pos"}	 = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_NYLON-6-6";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}


sub make_ATOFCarbonPlate
{
	my $rmin = 147.4;
	my $rmax  = 152.57;
	my $half_thickness = 153.0/2.0;
	my $phistart = 0;
	my $pspan = 360;
	#my $mate  = "He4_gas_3atm"; --> take out?
	my %detector = init_det();
	my $position = -1*($half_thickness)+13;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',24004);
	
	$detector{"name"} = "ATOFCarbonPlate";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF Carbon Mounting Plate and Spacer";
	$detector{"color"}       = "ff0000";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}

# AL ribs for ATOF sustain
sub make_AlRib1
{
	my $rmin = 133.4;
	my $rmax  = 147.4;
	my $phistart = 357.09;
	my $pspan = 5.82;
	my %detector = init_det();
	# my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',24006);
	
	$detector{"name"} = "AlRib1";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF AL rib 1";
	$detector{"color"}       = "0055ff";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_al_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}


sub make_AlRib2
{
	my $rmin = 133.4;
	my $rmax  = 147.4;
	my $phistart = 69.09;
	my $pspan = 5.82;
	my %detector = init_det();
	# my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240062);
	
	$detector{"name"} = "AlRib2";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF AL rib 2";
	$detector{"color"}       = "0055ff";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_al_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}


sub make_AlRib3
{
	my $rmin = 133.4;
	my $rmax  = 147.4;
	my $phistart = 141.09;
	my $pspan = 5.82;
	my %detector = init_det();
	# my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240063);
	
	$detector{"name"} = "AlRib3";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF AL rib 3";
	$detector{"color"}       = "0055ff";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_al_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}


sub make_AlRib4
{
	my $rmin = 133.4;
	my $rmax  = 147.4;
	my $phistart = 213.09;
	my $pspan = 5.82;
	my %detector = init_det();
	# my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240064);
	
	$detector{"name"} = "AlRib4";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF AL rib 4";
	$detector{"color"}       = "0055ff";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_al_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}

sub make_AlRib5
{
	my $rmin = 133.4;
	my $rmax  = 147.4;
	my $phistart = 285.09;
	my $pspan = 5.82;
	my %detector = init_det();
	# my $position = ;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240065);
	
	$detector{"name"} = "AlRib5";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF AL rib 5";
	$detector{"color"}       = "0055ff";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_al_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}


# Epoxy ribs for ATOF
sub make_EpoxyRib1
{
	my $rmin = 133.4;
	my $rmax  = 147.4;
	my $phistart = 21.09;
	my $pspan = 5.82;
	my %detector = init_det();
	my $position = -1*($z_half_epoxy_ribs)+13.0;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240017);
	
	$detector{"name"} = "EpoxyRib1";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF Epoxy rib 1";
	$detector{"color"}       = "ff8600";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_epoxy_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "EpoxyFiberGlass";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}


sub make_EpoxyRib2
{
	my $rmin = 133.4;
	my $rmax  = 147.4;
	my $phistart = 45.09;
	my $pspan = 5.82;
	my %detector = init_det();
	my $position = -1*($z_half_epoxy_ribs)+13.0;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240018);
	
	$detector{"name"} = "EpoxyRib2";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF Epoxy rib 2";
	$detector{"color"}       = "ff8600";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_epoxy_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "EpoxyFiberGlass";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}


sub make_EpoxyRib3
{
	my $rmin = 133.4;
	my $rmax  = 147.4;
	my $phistart = 93.09;
	my $pspan = 5.82;
	my %detector = init_det();
	my $position = -1*($z_half_epoxy_ribs)+13.0;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240019);
	
	$detector{"name"} = "EpoxyRib3";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF Epoxy rib 3";
	$detector{"color"}       = "ff8600";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_epoxy_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "EpoxyFiberGlass";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}


sub make_EpoxyRib4
{
	my $rmin = 133.4;
	my $rmax  = 147.4;
	my $phistart = 117.09;
	my $pspan = 5.82;
	my %detector = init_det();
	my $position = -1*($z_half_epoxy_ribs)+13.0;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240020);
	
	$detector{"name"} = "EpoxyRib4";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF Epoxy rib 4";
	$detector{"color"}       = "ff8600";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_epoxy_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "EpoxyFiberGlass";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}

sub make_EpoxyRib5
{
	my $rmin = 133.4;
	my $rmax  = 147.4;
	my $phistart = 165.09;
	my $pspan = 5.82;
	my %detector = init_det();
	my $position = -1*($z_half_epoxy_ribs)+13.0;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240021);
	
	$detector{"name"} = "EpoxyRib5";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF Epoxy rib 5";
	$detector{"color"}       = "ff8600";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_epoxy_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "EpoxyFiberGlass";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}

sub make_EpoxyRib6
{
	my $rmin = 133.4;
	my $rmax  = 147.4;
	my $phistart = 189.09;
	my $pspan = 5.82;
	my %detector = init_det();
	my $position = -1*($z_half_epoxy_ribs)+13.0;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240022);
	
	$detector{"name"} = "EpoxyRib6";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF Epoxy rib 6";
	$detector{"color"}       = "ff8600";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_epoxy_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "EpoxyFiberGlass";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}

sub make_EpoxyRib7
{
	my $rmin = 133.4;
	my $rmax  = 147.4;
	my $phistart = 237.09;
	my $pspan = 5.82;
	my %detector = init_det();
	my $position = -1*($z_half_epoxy_ribs)+13.0;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240023);
	
	$detector{"name"} = "EpoxyRib7";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF Epoxy rib 7";
	$detector{"color"}       = "ff8600";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_epoxy_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "EpoxyFiberGlass";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}

sub make_EpoxyRib8
{
	my $rmin = 133.4;
	my $rmax  = 147.4;
	my $phistart = 261.09;
	my $pspan = 5.82;
	my %detector = init_det();
	my $position = -1*($z_half_epoxy_ribs)+13.0;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240024);
	
	$detector{"name"} = "EpoxyRib8";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF Epoxy rib 8";
	$detector{"color"}       = "ff8600";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_epoxy_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "EpoxyFiberGlass";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}

sub make_EpoxyRib9
{
	my $rmin = 133.4;
	my $rmax  = 147.4;
	my $phistart = 309.09;
	my $pspan = 5.82;
	my %detector = init_det();
	my $position = -1*($z_half_epoxy_ribs)+13.0;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240025);
	
	$detector{"name"} = "EpoxyRib9";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF Epoxy rib 9";
	$detector{"color"}       = "ff8600";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_epoxy_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "EpoxyFiberGlass";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}

sub make_EpoxyRib10
{
	my $rmin = 133.4;
	my $rmax  = 147.4;
	my $phistart = 333.09;
	my $pspan = 5.82;
	my %detector = init_det();
	my $position = -1*($z_half_epoxy_ribs)+13.0;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240026);
	
	$detector{"name"} = "EpoxyRib10";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF Epoxy rib 10";
	$detector{"color"}       = "ff8600";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_epoxy_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "EpoxyFiberGlass";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}

#Gas enclosure rings
sub make_frontGasRing
{
	my $rmin = 219.075;
	my $rmax = 250.851;
	my $half_thickness = 16.0/2.0;
	my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $position = -1*(10.364+$z_half_al_ribs)+257.5+$half_thickness+6.275;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual',240012);

	$detector{"name"} = "frontGasRing";
	#$detector{"mother"} 	= "mother_shell";
	$detector{"mother"}	 = "ahdc_mother";
	$detector{"description"} = "Front Gas Ring";
	$detector{"color"}       = "fffb00";
	$detector{"pos"}         = "0*mm 0*mm $position*mm ";
	$detector{"type"}        = "Tube";       
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
        $detector{"material"}    = "EpoxyFiberGlass";
        $detector{"style"}       = 1;		
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);


}



sub make_backGasRing
{
        my $rmin = 219.075;
        my $rmax = 234.95;
        my $half_thickness = 12.55/2.0;
        my $phistart = 0;
        my $pspan = 360;
        my %detector = init_det();
	my $position = -1*(10.364+$z_half_al_ribs);
        my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual',240014);

        $detector{"name"} = "backGasRing";
	#$detector{"mother"}    = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
        $detector{"description"} = "Back Gas Ring";
        $detector{"color"}       = "fffb00";
        $detector{"pos"}         = "0*mm 0*mm $position*mm ";
        $detector{"type"}        = "Tube";
        $detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
        $detector{"material"}    = "EpoxyFiberGlass";
        $detector{"style"}       = 1;
        $detector{"identifiers"} = $id_string;
        print_det(\%configuration, \%detector);

}

# epoxy ring, part of gas enclosure, downstream
sub make_epoxyring
{
	my $rmin = 15.82;
	my $rmax  = 23.985;
	my $half_thickness  = 18.0/2.0; 
	my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $position = 304.27+$half_thickness;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240043);

        $detector{"name"} = "epoxyring";
	#$detector{"mother"}    = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
        $detector{"description"} = "Back Gas Ring";
        $detector{"color"}       = "c82566";
        $detector{"pos"}         = "0*mm 0*mm $position*mm ";
        $detector{"type"}        = "Tube";
        $detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
        $detector{"material"}    = "EpoxyFiberGlass";
        $detector{"style"}       = 1;
        $detector{"identifiers"} = $id_string;
        print_det(\%configuration, \%detector);

}


# Front plates, downstream
sub make_frontcarbon_1
{
	my $rmin = 74.000;
	my $rmax  = 151.000;
	my $half_thickness  = 8.823/2.0; 
	my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $position = $z_half_al_ribs+$half_thickness;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',24007);
	
	$detector{"name"} = "frontcarbon1";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Front CARBON AHDC plate 1";
	$detector{"color"}       = "c8b525";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}

sub make_frontmacor
{
	my $rmin = 28.000;
	my $rmax  = 90.000;
	my $half_thickness  = 4.65/2.0;
	my $phistart = 0;
	my $pspan = 360;
	#my $mate  = "MACOR";
	my %detector = init_det();
	my $position = $z_half_al_ribs+8.823+$half_thickness;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',24008);
	
	$detector{"name"} = "frontmacor";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Front MACOR AHDC plate";
	$detector{"color"}       = "ffff00";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	#$detector{"material"}    = $mate;
	$detector{"material"}    = "G4_SILICON_DIOXIDE";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	##$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}

# this part of front C plate is with MACOR plate inside
sub make_frontcarbon_2
{
	my $rmin = 90.000;
	my $rmax  = 151.000;
	my $half_thickness  = 4.65/2.0;
	my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $position = $z_half_al_ribs+8.823+$half_thickness;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',24009);
	
	$detector{"name"} = "frontcarbon2";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Front CARBON AHDC plate 2";
	$detector{"color"}       = "550000";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}

sub make_frontAlPins
{
	my $rmin = 32.000;
	my $rmax  = 68.000;
	my $half_thickness  = 0.542/2.0;
	my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $position = $z_half_al_ribs+8.823+4.65+$half_thickness;
	#my $position = 180.384+2.0;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240010);
	
	$detector{"name"} = "frontAlPins";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Front AL pins on plate";
	$detector{"color"}       = "c82566";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
	
}

sub make_frontEpoxySupport
{
	my $rmin = 28.0;
	my $rmax = 111.0;
	my $half_thickness = 1.987;
	my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $position = $z_half_al_ribs+8.823+4.65+0.54+$half_thickness;
	my $id_string = join('','sector manual ',0, ' suparlayer manual ',0,' layer manual ',0,' component manual ',240028);

	$detector{"name"} = "frontEpoxySupport";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Front Epoxy Support";
	$detector{"color"}       = "c82566";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "EpoxyFiberGlass";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);
	
}


#Front PCB plate
sub make_frontPCB
{
	my $rmin  = 77.0;
	my $rmax  = 133.7;
	my $half_thickness  = 1.413/2.0;
	my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $position = (101.6/2.0)+$half_thickness;
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240027);

	$detector{"name"} = "frontPCB";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Front PCB AHDC plate";
	$detector{"color"}       = "aaaa00";
	#$detector{"pos"}         = "0*mm 0*mm -($thickness/2+$z_half_ribs)*mm";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_NYLON-6-6";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
}


# Back AL plate, upstream
sub make_backAl
{
	
	my $rmin  = 75.000;
	my $rmax  = 205.000;
	my $half_thickness  = 10.364/2.0;
	my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $position = -1*($half_thickness+$z_half_al_ribs);
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240011);
	
	$detector{"name"} = "backAl";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "Back AL AHDC plate";
	$detector{"color"}       = "aaaa00";
	#$detector{"pos"}         = "0*mm 0*mm -($thickness/2+$z_half_ribs)*mm";
	$detector{"pos"}         = "0*mm 0*mm $position*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $half_thickness*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);
}

#make_mother();

make_wedgePCB();
make_ATOFfixAl();
make_ATOFfixASteel();
make_ATOFfixBrass();

make_CarbonMountingBar1();
make_CarbonMountingBar2();
make_CarbonMountingBar3();
make_CarbonMountingBar4();
make_CarbonMountingBar5();
make_CarbonMountingBar6();
make_CarbonMountingBar7();
make_CarbonMountingBar8();
make_CarbonMountingBar9();
make_CarbonMountingBar10();
make_CarbonMountingBar11();
make_CarbonMountingBar12();
make_CarbonMountingBar13();
make_CarbonMountingBar14();
make_CarbonMountingBar15();

make_ATOFpatchPCB();
make_ATOFCarbonPlate();

make_AlRib1();
make_AlRib2();
make_AlRib3();
make_AlRib4();
make_AlRib5();

make_EpoxyRib1();
make_EpoxyRib2();
make_EpoxyRib3();
make_EpoxyRib4();
make_EpoxyRib5();
make_EpoxyRib6();
make_EpoxyRib7();
make_EpoxyRib8();
make_EpoxyRib9();
make_EpoxyRib10();

make_frontGasRing();
make_backGasRing();
make_epoxyring();

make_frontmacor();
make_frontAlPins();
make_frontcarbon_1();
make_frontcarbon_2();
make_frontEpoxySupport();

make_backAl();






