use strict;
use warnings;

our %configuration;


sub make_tagger
{
	my %detector = init_det();
	$detector{"name"}        = "tag_mag_tube_iron1";
	$detector{"mother"}      = "root";
	$detector{"description"} = "tag_mag_tube_iron1";
	$detector{"color"}       = "993333";
	$detector{"type"}        = "Tube";
	$detector{"pos"}         = "0*mm 0.0*mm 0.0*mm";
	$detector{"dimensions"}  = "600.*cm 730.*cm 45.*cm 50.*deg 37.*deg";
	$detector{"material"}    = "G4_Fe";
	$detector{"material"}    = "Component";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	
	%detector = init_det();
	$detector{"name"}        = "tag_mag_box1";
	$detector{"mother"}      = "root";
	$detector{"description"} = "tag_mag_box1";
	$detector{"color"}       = "993333";
	$detector{"type"}        = "Box";
	$detector{"pos"}         = "220*cm  560.*cm  0.*cm";
	$detector{"rotation"}    = "0*deg 0*deg 21*deg";
	$detector{"dimensions"}  = "222.*cm 47.*cm 50.*cm";
	$detector{"material"}    = "G4_Fe";
	$detector{"material"}    = "Component";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	
	%detector = init_det();
	$detector{"name"}        = "tag_mag_iron1";
	$detector{"mother"}      = "root";
	$detector{"description"} = "tag_mag_iron1";
	$detector{"color"}       = "aaff22";
	$detector{"type"}        = "Operation: tag_mag_tube_iron1 - tag_mag_box1";
	$detector{"material"}    = "G4_Fe";
	$detector{"material"}    = "Component";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	
	%detector = init_det();
	$detector{"name"}        = "tag_mag_vac_tube";
	$detector{"mother"}      = "root";
	$detector{"description"} = "tag_mag_vac_tube";
	$detector{"color"}       = "993333";
	$detector{"type"}        = "Tube";
	$detector{"pos"}         = "0*cm -30.*cm 0.*cm";
	$detector{"dimensions"}  = " 600.*cm 735.*cm 1.2*2.54*cm 45.*deg 50.*degm";
	$detector{"material"}    = "G4_Fe";
	$detector{"material"}    = "Component";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	
	%detector = init_det();
	$detector{"name"}        = "tag_mag_iron2";
	$detector{"mother"}      = "root";
	$detector{"description"} = "tag_mag_iron2";
	$detector{"color"}       = "00ff22";
	$detector{"type"}        = "Operation: tag_mag_iron1 - tag_mag_vac_tube";
	$detector{"material"}    = "G4_Fe";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
}



