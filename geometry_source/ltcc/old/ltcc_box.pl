use strict;
use warnings;

our %configuration;

# generate  mother volume box - it's 6m along z axis to contain all mirrors
# this volume is made so its center is clas center
# so that the mirrors that would be placed in root can be placed here instead
sub build_big_mother()
{
	my %detector = init_det();
	$detector{"name"}        = "ltcc_first_box";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Light Threshold Cerenkov Counter Box at the origin";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "2*m 5*m 6*m";
	$detector{"material"}    = "Component";
	print_det(\%configuration, \%detector);
}


# Cutting off the left/right sides that define the sector
sub cut_right_and_left()
{
	my $sector_cut_angle = 30;
	my $box_dimension    = 2000;
	my $additional_shift = 4;  # to be far from the coils
	my $xshift = $box_dimension/cos($sector_cut_angle*$pi/180.0) - $additional_shift;

	my %detector = init_det();
	$detector{"name"}        = "sector_left_cut";
	$detector{"mother"}      = "root";
	$detector{"description"} = "LTCC Left Cut";
	$detector{"pos"}         = "$xshift*cm 0*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg $sector_cut_angle*deg";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "$box_dimension*cm $box_dimension*cm $box_dimension*cm";
	$detector{"material"}    = "Component";
	print_det(\%configuration, \%detector);

	%detector = init_det();
	$detector{"name"}        = "sector_right_cut";
	$detector{"mother"}      = "root";
	$detector{"description"} = "LTCC Left Cut";
	$detector{"pos"}         = "-$xshift*cm 0*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg -$sector_cut_angle*deg";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "$box_dimension*cm $box_dimension*cm $box_dimension*cm";
	$detector{"material"}    = "Component";
	print_det(\%configuration, \%detector);

	# Subtracting left box
	%detector = init_det();
	$detector{"name"}        = "sector_box_left_cut";
	$detector{"mother"}      = "root";
	$detector{"description"} = "LTCC After Left Cut";
	$detector{"type"}        = "Operation: ltcc_first_box - sector_left_cut";
	$detector{"material"}    = "Component";
	print_det(\%configuration, \%detector);

	# Subtracting right box
	%detector = init_det();
	$detector{"name"}        = "sector_box_right_cut";
	$detector{"mother"}      = "root";
	$detector{"description"} = "LTCC After Right Cut";
	$detector{"type"}        = "Operation: sector_box_left_cut - sector_right_cut";
	$detector{"material"}    = "Component";
	print_det(\%configuration, \%detector);
}



sub cut_front_and_back()
{

	my $box_dimension = 2000;
	# Cutting off the back window
	# WARNING: For now, by EYES by looking at the mirrors and ftof
	my $zshift = 2740;
	my $cc_angle         = 25;

	my %detector = init_det();
	$detector{"name"}        = "sector_box_back_cut";
	$detector{"mother"}      = "root";
	$detector{"description"} = "LTCC Left Cut";
	$detector{"pos"}         = "0*cm 0*cm $zshift*cm";
	$detector{"rotation"}    = "$cc_angle*deg 0*deg 0*deg";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "$box_dimension*cm $box_dimension*cm $box_dimension*cm";
	$detector{"material"}    = "Component";
	print_det(\%configuration, \%detector);


	$zshift = -1830;
	%detector = init_det();
	$detector{"name"}        = "sector_box_front_cut";
	$detector{"mother"}      = "root";
	$detector{"description"} = "LTCC Left Cut";
	$detector{"pos"}         = "0*cm 0*cm $zshift*cm";
	$detector{"rotation"}    = "$cc_angle*deg 0*deg 0*deg";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "$box_dimension*cm $box_dimension*cm $box_dimension*cm";
	$detector{"material"}    = "Component";
	print_det(\%configuration, \%detector);


	# Subtracting back box
	%detector = init_det();
	$detector{"name"}        = "sector_back_cut";
	$detector{"mother"}      = "root";
	$detector{"description"} = "LTCC After Backplane Cut";
	$detector{"type"}        = "Operation: sector_box_right_cut - sector_box_back_cut";
	$detector{"material"}    = "Component";
	print_det(\%configuration, \%detector);



	# Subtracting front box
	%detector = init_det();
	$detector{"name"}        = "sector_front_cut";
	$detector{"mother"}      = "root";
	$detector{"description"} = "LTCC After Backplane Cut";
	$detector{"type"}        = "Operation: sector_back_cut - sector_box_front_cut";
	$detector{"material"}    = "Component";
	print_det(\%configuration, \%detector);
}


sub cut_top_and_bottom()
{
	my $box_dimension = 2000;
	# Top box
	my $top_angle = 20;
	my $yshift    = 2400;
	my %detector = init_det();
	my $cc_angle         = 25;
	$detector{"name"}        = "sector_box_top_cut";
	$detector{"mother"}      = "root";
	$detector{"description"} = "LTCC Top Cut";
	$detector{"pos"}         = "0*cm $yshift*cm 0*cm";
	$detector{"rotation"}    = "$cc_angle*deg 0*deg 0*deg";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "$box_dimension*cm $box_dimension*cm $box_dimension*cm";
	$detector{"material"}    = "Component";
	print_det(\%configuration, \%detector);

	# Subtracting top box
	%detector = init_det();
	$detector{"name"}        = "sector_top_cut";
	$detector{"mother"}      = "root";
	$detector{"description"} = "LTCC After Top Cut";
	$detector{"type"}        = "Operation: sector_front_cut - sector_box_top_cut";
	$detector{"material"}    = "Component";
	print_det(\%configuration, \%detector);


	# Bottom Box
	%detector = init_det();
	my $bottom_angle = 20;
	$yshift = -$box_dimension + 10;
	$detector{"name"}        = "sector_box_bottom_cut";
	$detector{"mother"}      = "root";
	$detector{"description"} = "LTCC Bottom Cut";
	$detector{"pos"}         = "0*cm $yshift*cm 0*cm";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "$box_dimension*cm $box_dimension*cm $box_dimension*cm";
	$detector{"material"}    = "Component";
	print_det(\%configuration, \%detector);

	#my $cc_zpos          = 170; # distance between the CLAS and the CLAS12 center.
	my $cc_zpos          = 0; # distance between the CLAS and the CLAS12 center.
	# Subtracting top box
	%detector = init_det();
	$detector{"name"}        = "ltcc";
	$detector{"mother"}      = "root";
	$detector{"description"} = "LTCC After Bottom Cut";
	$detector{"pos"}         = "0*cm 0*cm $cc_zpos*cm";
	$detector{"rotation"}    = "0*deg 00*deg 0*deg";
	$detector{"type"}        = "Operation: sector_top_cut - sector_box_bottom_cut";
	$detector{"material"}    = "C4F10";
	$detector{"visible"}     = 1;
	#$detector{"material"}    = "Component";
	print_det(\%configuration, \%detector);

}

sub build_ltcc_box()
{
	build_big_mother();
	cut_right_and_left();
	cut_front_and_back();
	cut_top_and_bottom();
}

return 1;

