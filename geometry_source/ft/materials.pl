use strict;
use warnings;

our %configuration;

sub materials
{
	# uploading the mat definition
	
	
	# peek
	my %mat = init_mat();
	$mat{"name"}          = "ft_peek";
	$mat{"description"}   = "ft peek plastic 1.31 g/cm3";
	$mat{"density"}       = "1.31";
	$mat{"ncomponents"}   = "3";
	$mat{"components"}    = "G4_C 0.76 G4_H 0.08 G4_O 0.16";
	print_mat(\%configuration, \%mat);

	
    # ft_Tungsten
    %mat = init_mat();
    $mat{"name"}          = "ft_W";
    $mat{"description"}   = "ft tungsten alloy 17.6 g/cm3";
    $mat{"density"}       = "17.6";
    $mat{"ncomponents"}   = "2";
    $mat{"components"}    = "G4_Fe 0.08 G4_W 0.92";
    print_mat(\%configuration, \%mat);

    
    # epoxy
	%mat = init_mat();
	$mat{"name"}          = "epoxy";
	$mat{"description"}   = "epoxy glue 1.16 g/cm3";
	$mat{"density"}       = "1.16";
	$mat{"ncomponents"}   = "4";
	$mat{"components"}    = "H 32 N 2 O 4 C 15";
	print_mat(\%configuration, \%mat);
	
	
	# carbon fiber
	%mat = init_mat();
	$mat{"name"}          = "carbonFiber";
	$mat{"description"}   = "ft carbon fiber material is epoxy and carbon - 1.75g/cm3";
	$mat{"density"}       = "1.75";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_C 0.745 epoxy 0.255";
	print_mat(\%configuration, \%mat);

	
	# pcboard
	%mat = init_mat();
	$mat{"name"}          = "pcboard";
	$mat{"description"}   = "ft pcb 1.86 g/cm3";
	$mat{"density"}       = "1.86";
	$mat{"ncomponents"}   = "3";
	$mat{"components"}    = "G4_Fe 0.3 G4_C 0.4 G4_Si 0.3";
	print_mat(\%configuration, \%mat);
	

	# ftinsfoam
	%mat = init_mat();
	$mat{"name"}          = "insfoam";
	$mat{"description"}   = "ft insulation foam 34 kg/m3";
	$mat{"density"}       = "0.034";
	$mat{"ncomponents"}   = "4";
	$mat{"components"}    = "G4_C 0.6 G4_H 0.1 G4_N 0.1 G4_O 0.2";
	print_mat(\%configuration, \%mat);
	

	# scintillator
	%mat = init_mat();
	$mat{"name"}          = "scintillator";
	$mat{"description"}   = "ft scintillator material C9H10 1.032 g/cm3";
	$mat{"density"}       = "1.032";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "C 9 H 10";
	print_mat(\%configuration, \%mat);

    
    # pcb-FR4
    %mat = init_mat();
    $mat{"name"}          = "myFR4";
    # found in geant4 materials database here : http://www.phenix.bnl.gov/~suhanov/ncc/geant/rad-source/src/ExN03DetectorConstruction.cc
    $mat{"description"}   = "pcb FR4";
    $mat{"density"}       = "1.86";
    $mat{"ncomponents"}   = "4";
    $mat{"components"}    = "G4_C 0.4355 G4_H 0.0365 G4_Si 0.2468 G4_O 0.2812";
    print_mat(\%configuration, \%mat);
    
    # micromegas strips
    my $mmstriptransparency = 459./559.; #strips filling fraction
    my $mmstripdensity      = 8.96*$mmstriptransparency*(15./12.); #3 extra microns for connecting strips underneath
    %mat = init_mat();
    $mat{"name"}          = "mmstrips";
    $mat{"description"}   = "ft micromegas strips";
    $mat{"density"}       = $mmstripdensity;
    $mat{"ncomponents"}   = "1";
    $mat{"components"}    = "G4_Cu 1";
    print_mat(\%configuration, \%mat);
    
#    %mat = init_mat();
#    $mat{"name"}          = "myKapton"; # found in gemc materials database.
#    $mat{"description"}   = "Kapton";
#    $mat{"density"}       = "1.42";
#    $mat{"ncomponents"}   = "4";
#    $mat{"components"}    = "G4_H 0.026362 G4_C 0.691133 G4_N 0.073270 G4_O 0.209235";
#    print_mat(\%configuration, \%mat);
    
    # resistive strips
    %mat = init_mat();
    my $ResistPasteTransparency_Density = 0.81*1.33;
    # for fmt: 81% filling fraction, 1.33 density from excel file;
    # from Cern mail 12/06/16, suppose 50% C / 50% epoxy;
    # adopt C at above density.
    # thickness almost negligible, so not crucial to be exact.
    $mat{"name"}          = "ResistPaste";
    $mat{"description"}   = "micromegas fmt resistiv strips";
    $mat{"density"}       = "$ResistPasteTransparency_Density";
    $mat{"ncomponents"}   = "1";
    $mat{"components"}    = "G4_C 1";
    print_mat(\%configuration, \%mat);
    
    # micromegas mesh
    my $mmmeshtransparency = 0.55;
    my $mmmeshdensity = 7.93*$mmmeshtransparency;
    %mat = init_mat();
    $mat{"name"}          = "mmmesh";
    $mat{"description"}   = "ft micromegas mesh";
    $mat{"density"}       = $mmmeshdensity;
    $mat{"ncomponents"}   = "5";
    $mat{"components"}    = "G4_Mn 0.02 G4_Si 0.01 G4_Cr 0.19 G4_Ni 0.10 G4_Fe 0.68";
    print_mat(\%configuration, \%mat);
    
    
    # micromegas gas: Ar/Isobutane for now, but not sure what will be used
    my $mmgasdensity = (1.662*0.95+2.489*0.05)*0.001;
    %mat = init_mat();
    $mat{"name"}          = "mmgas";
    $mat{"description"}   = "ft micromegas gas";
    $mat{"density"}       = $mmgasdensity;
    $mat{"ncomponents"}   = "3";
    $mat{"components"}    = "G4_Ar 0.95 G4_H 0.0086707 G4_C 0.0413293";
    print_mat(\%configuration, \%mat);
    
    # photoresist (pillars and inner/outer remaining rings)
    %mat = init_mat();
    my $PhotoResist_Density = 1.42;
    # 1.42 density from excel file;
    # from Cern mail 12/06/16, suppose 50% acrylique / 50% epoxy;
    # adopt C at above density.
    # thickness negligible compared to Al rings at similar radii, but extends 1.5 mm into the active area.
    $mat{"name"}          = "myPhRes";
    $mat{"description"}   = "PhotoResist";
    $mat{"density"}       = "$PhotoResist_Density";
    $mat{"ncomponents"}   = "1";
    $mat{"components"}    = "G4_C 1";
    print_mat(\%configuration, \%mat);
    
    # micromegas mylar
    %mat = init_mat();
    $mat{"name"}          = "mmmylar";
    $mat{"description"}   = "ft micromegas mylar 1.40g/cm3";
    $mat{"density"}       = "1.4";
    $mat{"ncomponents"}   = "3";
    $mat{"components"}    = "G4_H 0.041958 G4_C 0.625017 G4_O 0.333025";
    print_mat(\%configuration, \%mat);
    

}


