use strict;
use warnings;

our %configuration;

sub materials
{
	# uploading the mat definition
	
	# Scintillator
	my %mat = init_mat();
	$mat{"name"}          = "scintillator";
	$mat{"description"}   = "pcal scintillator material";
	$mat{"density"}       = "1.032";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "C 9 H 10";
	print_mat(\%configuration, \%mat);

	# From $CLAS_PACK/gsim/init_ec.F
	# See also http://galileo.phys.Virginia.EDU/~lcs1h/gsim/archive/ecsim.html
	# note 240 mg/cm3 is 15 lb/ft3, which is the recommended density for bulkheads
	# See: http://www.generalplastics.com/products/rigid-foams/fr-7100
	
	%mat = init_mat();
	$mat{"name"}          = "LastaFoam";
	$mat{"description"}   = "ec foam material";
	$mat{"density"}       = "0.24";
	$mat{"ncomponents"}   = "4";
	$mat{"components"}    = "G4_C 0.4045 G4_H 0.0786 G4_N 0.1573 G4_O 0.3596";
	print_mat(\%configuration, \%mat);
	
	
}


