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

#my $z_half_atof = 279.7/2.0;
#my $z_half_ribs = 330.0/2.0;

my $z_half_atof = 139.85;
my $z_half_ribs = 165.0;

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
	#$detector{"visible"}     = 1;
#	$detector{"visible"}     = 0;
#	print_det(\%configuration, \%detector);
#}

# ATOF module fixing part
sub make_ATOFfixAl
{
        my $rmin = 120.0;
	my $rmax  = 124.692;
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
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_atof*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);

}

sub make_ATOFfixPCB
{
        my $rmin = 124.692;
	my $rmax  = 127.027;
        my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',24002);

	$detector{"name"} = "ATOFfixPCB";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF PCB fixing";
	$detector{"color"}       = "ff0000";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_atof*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_NYLON-6-6";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);

}

sub make_ATOFfixSSteel
{
        my $rmin = 127.027;
	my $rmax  = 127.476;
        my $phistart = 0;
	my $pspan = 360;
	#my $mate  = "stainless_steel";
	my %detector = init_det();
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',24003);

	$detector{"name"} = "ATOFfixSSteel";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF SSteel fixing";
	#$detector{"color"}       = "ff0a7f";
	$detector{"color"}       = "080808";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_atof*mm $phistart*deg $pspan*deg";
	#$detector{"material"}    = $mate;
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);

}

sub make_ATOFfixCarbon
{
        my $rmin = 127.476;
	my $rmax  = 133.990;
        my $phistart = 0;
	my $pspan = 360;
	#my $mate  = "He4_gas_3atm";
	my %detector = init_det();
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',24004);

	$detector{"name"} = "ATOFfixCarbon";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF C fixing";
	$detector{"color"}       = "9b7bc8";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_atof*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_C";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);

}

sub make_ATOFfixASteel
{
        my $rmin = 133.990;
	my $rmax  = 134.211;
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
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_atof*mm $phistart*deg $pspan*deg";
	#$detector{"material"}    = $mate;
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);

}

sub make_ATOFfixBrass
{
        my $rmin = 134.211;
	my $rmax  = 134.225;
        my $phistart = 0;
	my $pspan = 360;
	#my $mate  = "alloy_steel";
	my %detector = init_det();
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',240051);

	$detector{"name"} = "ATOFfixBrass";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF BRASS fixing";
	$detector{"color"}       = "ffff00";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_atof*mm $phistart*deg $pspan*deg";
	#$detector{"material"}    = $mate;
	$detector{"material"}    = "G4_Cu";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	print_det(\%configuration, \%detector);

}

# AL ribs for ATOF sustain
sub make_ribs
{
        my $rmin = 147.078;
	my $rmax  = 150.000;
        my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $id_string = join('','sector manual ',0, ' superlayer manual ',0,' layer manual ',0,' component manual ',24006);

	$detector{"name"} = "ribs";
	#$detector{"mother"}      = "mother_shell";
	$detector{"mother"}      = "ahdc_mother";
	$detector{"description"} = "ATOF AL ribs";
	$detector{"color"}       = "0055ff";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$rmin*mm $rmax*mm $z_half_ribs*mm $phistart*deg $pspan*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	$detector{"identifiers"} = $id_string;
	#$detector{"sensitivity"}  = "alertshell"; # name of the hit
	#$detector{"hit_type"}     = "alertshell"; # name of the hit
	print_det(\%configuration, \%detector);

}

# Front plates, downstream
sub make_frontcarbon_1
{
        my $rmin = 74.000;
	my $rmax  = 150.000;
	my $half_thickness  = 9.384/2.0; 
        my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $position = $z_half_ribs+$half_thickness;
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
	my $rmax  = 86.916;
	my $half_thickness  = 5.000/2.0;
        my $phistart = 0;
	my $pspan = 360;
	#my $mate  = "MACOR";
	my %detector = init_det();
	my $position = $z_half_ribs+9.384+$half_thickness;
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
        my $rmin = 86.916;
	my $rmax  = 150.000;
	my $half_thickness  = 5.000/2.0;
        my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $position = $z_half_ribs+9.384+$half_thickness;
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
	my $half_thickness  = 0.637/2.0;
        my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $position = $z_half_ribs+9.384+5.000+$half_thickness;
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

# Back AL plate, upstream
sub make_backAl
{
	
	my $rmin  = 75.000;
	my $rmax  = 205.000;
	my $half_thickness  = 10.364/2.0;
        my $phistart = 0;
	my $pspan = 360;
	my %detector = init_det();
	my $position = -1*($half_thickness+$z_half_ribs);
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

make_ATOFfixAl();
make_ATOFfixPCB();
make_ATOFfixSSteel();
make_ATOFfixCarbon();
make_ATOFfixASteel();
make_ATOFfixBrass();

make_ribs();

make_frontmacor();
make_frontAlPins();
make_frontcarbon_1();
make_frontcarbon_2();

make_backAl();






