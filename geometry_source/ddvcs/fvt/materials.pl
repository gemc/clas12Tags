use strict;
use warnings;

our %configuration;


sub materials
{
	# uploading the mat definition

	my %mat = init_mat();

    $mat{"name"}          = "kapton";
    $mat{"description"}   = "uRwell kapton";
    $mat{"density"}       = "1.42";
    $mat{"ncomponents"}   = "4";
    $mat{"components"}    = "G4_H 0.026362 G4_C 0.691133 G4_N 0.073270 G4_O 0.209235";
    print_mat(\%configuration, \%mat);

    $mat{"name"}          = "Al";
    $mat{"description"}   = "uRwell Al";
    $mat{"density"}       = "2.699";
    $mat{"ncomponents"}   = "1";
    $mat{"components"}    = "G4_Al 1 ";
    print_mat(\%configuration, \%mat);
    
	$mat{"name"}          = "gas";
	$mat{"description"}   = "clas12 uRwell gas";
	$mat{"density"}       = "0.00184";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_Ar 0.7 G4_CARBON_DIOXIDE 0.3";
	print_mat(\%configuration, \%mat);
    
    $mat{"name"}          = "dlc";
    $mat{"description"}   = "clas12 uRwell dlc";
    $mat{"density"}       = "1.8";
    $mat{"ncomponents"}   = "1";
    $mat{"components"}    = "G4_C 1";
    print_mat(\%configuration, \%mat);

    $mat{"name"}          = "Cr";
    $mat{"description"}   = "clas12 uRwell Cr";
    $mat{"density"}       = "7.8";
    $mat{"ncomponents"}   = "1";
    $mat{"components"}    = "G4_Cr 1";
    print_mat(\%configuration, \%mat);
    
    $mat{"name"}          = "Cu";
    $mat{"description"}   = "clas12 uRwell Cu";
    $mat{"density"}       = "8.96";
    $mat{"ncomponents"}   = "1";
    $mat{"components"}    = "G4_Cu 1";
    print_mat(\%configuration, \%mat);
    
    $mat{"name"}          = "glue";
    $mat{"description"}   = "glue epoxy";
    $mat{"density"}       = "1.16";
    $mat{"ncomponents"}   = "4";
    $mat{"components"}    = "C 15 H 32 N 2 O 4";
    print_mat(\%configuration, \%mat);

    $mat{"name"}          = "nomex_pure";
    $mat{"description"}   = "nomex pure";
    $mat{"density"}       = "1.38";
    $mat{"ncomponents"}   = "4";
    $mat{"components"}    = "C 14 H 10 N 2 O 2";
    print_mat(\%configuration, \%mat);
    
    $mat{"name"}          = "nomex";
    $mat{"description"}   = "nomex honeycomb";
    $mat{"density"}       = "0.04";
    $mat{"ncomponents"}   = "2";
    $mat{"components"}    = "nomex_pure 0.5 G4_AIR 0.5";
    print_mat(\%configuration, \%mat);
    
    $mat{"name"}          = "g10";
    $mat{"description"}   = "g10 material";
    $mat{"density"}       = "1.700";
    $mat{"ncomponents"}   = "4";
    $mat{"components"}    = "G4_Si 0.1 G4_O 0.2 G4_C 0.35 G4_H 0.35";
    print_mat(\%configuration, \%mat);
    


}


