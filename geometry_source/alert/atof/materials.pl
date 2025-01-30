use strict;
use warnings;

our %configuration;


sub materials
{
	# uploading the mat definition
	
	# ALERT time of flight scintillator
	my %mat = init_mat();
	$mat{"name"}          = "scintillator";
	$mat{"description"}   = "scintillator material EJ-204";
	$mat{"density"}       = "1.023";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "C 9 H 10";
	print_mat(\%configuration, \%mat);
	
}
