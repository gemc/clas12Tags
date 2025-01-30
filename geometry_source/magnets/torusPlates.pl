use strict;
use warnings;

our %configuration;

our $TorusLength;
our $TorusZpos;
our $inches;

my $microgap = 0.1;

my $plates_IR = 127./2. + $microgap;         # chosen to match Torus Inner Pipe defined above
my $plates_OR = 7.64*$inches - $microgap;
my $plate_LE  = 1.0*$inches/2.0;             # based on information from D. Kashy (April 2010)



sub torusPlates()
{
	# Upstream plate
	my $up_zpos   = - $TorusLength + $plate_LE + $microgap;

	my %detector = init_det();
	$detector{"name"}        = "torusUpstreamPlate";
	$detector{"mother"}      = "torusVacuumFrame";
	$detector{"description"} = "Torus Upstream Plate";
	$detector{"pos"}         = "0.0*cm 0.0*cm $up_zpos*mm";
	$detector{"color"}       = "99ccff";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$plates_IR*mm $plates_OR*mm $plate_LE*mm  0.0*deg 360.0*deg";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	# Downstream plate
	my $dp_zpos   = $TorusLength - $plate_LE - $microgap;

	%detector = init_det();
	$detector{"name"}        = "torusDownstreamPlate";
	$detector{"mother"}      = "torusVacuumFrame";
	$detector{"description"} = "Torus Downstream Plate";
	$detector{"pos"}         = "0.0*cm 0.0*cm $dp_zpos*mm";
	$detector{"color"}       = "99ccff";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$plates_IR*mm $plates_OR*mm $plate_LE*mm  0.0*deg 360.0*deg";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	
}


