use strict;
use warnings;

our %configuration;

sub spot_finder_mother()
{
	my %detector = init_det();
	$detector{"name"}        = "spot_finder_mom";
	$detector{"mother"}      = "root";
	$detector{"description"} = "mother for spot finder";
	$detector{"pos"}         = "170*cm 340*cm 0*cm";
	$detector{"rotation"}    = "0*deg 0*deg -25*deg";
	$detector{"type"}        = "Box";
	$detector{"dimensions"}  = "52*cm 31.5*cm 52*cm";
	$detector{"material"}    = "Air_Opt";
	print_det(\%configuration, \%detector);
}

sub spot_finder_layers()
{
	for(my $n=0; $n<30; $n++)
	{
		my $ypos = -30.45 + 2.1*$n;
		my %detector = init_det();
		$detector{"name"}        = "spot_finder_layer$n";
		$detector{"mother"}      = "spot_finder_mom";
		$detector{"description"} = "spot finder layers";
		$detector{"pos"}         = "0*cm $ypos*cm 0*cm";
		$detector{"rotation"}    = "0*deg 0*deg 0*deg";
		$detector{"type"}        = "Box";
		$detector{"dimensions"}  = "50*cm 0.1*cm 50*cm";
		$detector{"material"}    = "C4F10";
		$detector{"sensitivity"} = "flux";
		$detector{"hit_type"}    = "flux";
		$detector{"identifiers"} = "id manual $n";
		print_det(\%configuration, \%detector);
	}
}

sub build_spot_finder()
{
	spot_finder_mother();
	spot_finder_layers();
}

return 1;

