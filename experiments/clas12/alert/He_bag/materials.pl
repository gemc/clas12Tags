use strict;
use warnings;

our %configuration;

sub materials
{
	
	my %mat = init_mat();
	
	# lHe gas
	%mat = init_mat();
	$mat{"name"}          = "HeBagGas";
	$mat{"description"}   = "Downstream He bag gas ";
	$mat{"density"}        = "0.000164";  # 0.164 kg/m3 <—————————————
	$mat{"ncomponents"}   = "1";
	$mat{"components"}    = "G4_He 1";
	print_mat(\%configuration, \%mat);

}
