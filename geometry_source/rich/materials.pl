#!/usr/bin/perl -w

use strict;
use lib ("$ENV{GEMC}/api/perl");
use materials;

# Loading configuration file from argument
our %configuration = load_configuration($ARGV[0]);


# Table of optical photon energies:
my @penergy = ( "1.3778*eV",  "1.3933*eV",  "1.4091*eV",  "1.4253*eV",  "1.4419*eV",
		"1.4588*eV",  "1.4762*eV",  "1.4940*eV",  "1.5122*eV",  "1.5309*eV",
		"1.5500*eV",  "1.5696*eV",  "1.5897*eV",  "1.6104*eV",  "1.6316*eV",
		"1.6533*eV",  "1.6757*eV",  "1.6986*eV",  "1.7222*eV",  "1.7465*eV",
		"1.7714*eV",  "1.7971*eV",  "1.8235*eV",  "1.8507*eV",  "1.8788*eV",
		"1.9077*eV",  "1.9375*eV",  "1.9683*eV",  "2.0000*eV",  "2.0328*eV",
		"2.0667*eV",  "2.1017*eV",  "2.1379*eV",  "2.1754*eV",  "2.2143*eV",
		"2.2545*eV",  "2.2963*eV",  "2.3396*eV",  "2.3846*eV",  "2.4314*eV",
		"2.4800*eV",  "2.5306*eV",  "2.5833*eV",  "2.6383*eV",  "2.6957*eV",
		"2.7556*eV",  "2.8182*eV",  "2.8837*eV",  "2.9524*eV",	"3.0244*eV",   
		"3.1000*eV",  "3.1795*eV",  "3.2632*eV",  "3.3514*eV", 	"3.4444*eV",   
		"3.5429*eV",  "3.6471*eV",  "3.7576*eV",  "3.8750*eV", 	"4.0000*eV",   
		"4.1333*eV",  "4.2759*eV",  "4.4286*eV",  "4.5926*eV",  "4.7692*eV",   
		"4.9600*eV",  "5.1667*eV",  "5.3913*eV",  "5.6364*eV",  "5.9048*eV",   
		"6.2000*eV" );

# ------- H8500/12700 window optical properties ------

# Index of refraction of the pmt window
# for borosilicate it should be 1.473, put 1.40 to avoid internal reflections
# Mirazita
my @irefr_window_h8500 = ( 1.473,  1.473,  1.473,  1.473,  1.473,
1.473,  1.473,  1.473,  1.473,  1.473,
1.473,  1.473,  1.473,  1.473,  1.473,
1.473,  1.473,  1.473,  1.473,  1.473,
1.473,  1.473,  1.473,  1.473,  1.473,
1.473,  1.473,  1.473,  1.473,  1.473,
1.473,  1.473,  1.473,  1.473,  1.473,
1.473,  1.473,  1.473,  1.473,  1.473,
1.473,  1.473,  1.473,  1.473,  1.473,
1.473,  1.473,  1.473,  1.473,  1.473,
1.473,  1.473,  1.473,  1.473,  1.473,
1.473,  1.473,  1.473,  1.473,  1.473,
1.473,  1.473,  1.473,  1.473,  1.473,
1.473,  1.473,  1.473,  1.473,  1.473,
1.473 );


# Absorption coefficient for H8500 window glass
my @abslength_window_h8500 = ( "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",
			       "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",
			       "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",
			       "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",
			       "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",
			       "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",
			       "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",
			       "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",
			       "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",
			       "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",
			       "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",
			       "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",
			       "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",
			       "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",  "42.0000*m",
			       "42.0000*m" );
# Absorption coefficient for H8500 photocathode
my @abslength_cathode_h8500 = ( "1*mm",  "1*mm",  "1*mm",  "1*mm",  "1*mm",
			       "1*mm",  "1*mm",  "1*mm",  "1*mm",  "1*mm",
			       "1*mm",  "1*mm",  "1*mm",  "1*mm",  "1*mm",
			       "1*mm",  "1*mm",  "1*mm",  "1*mm",  "1*mm",
			       "1*mm",  "1*mm",  "1*mm",  "1*mm",  "1*mm",
			       "1*mm",  "1*mm",  "1*mm",  "1*mm",  "1*mm",
			       "1*mm",  "1*mm",  "1*mm",  "1*mm",  "1*mm",
			       "1*mm",  "1*mm",  "1*mm",  "1*mm",  "1*mm",
			       "1*mm",  "1*mm",  "1*mm",  "1*mm",  "1*mm",
			       "1*mm",  "1*mm",  "1*mm",  "1*mm",  "1*mm",
			       "1*mm",  "1*mm",  "1*mm",  "1*mm",  "1*mm",
			       "1*mm",  "1*mm",  "1*mm",  "1*mm",  "1*mm",
			       "1*mm",  "1*mm",  "1*mm",  "1*mm",  "1*mm",
			       "1*mm",  "1*mm",  "1*mm",  "1*mm",  "1*mm",
			       "1*mm" );
my @efficiency_cathode_h8500 = ( 1.,  1.,  1.,  1.,  1.,
                               1.,  1.,  1.,  1.,  1.,
                               1.,  1.,  1.,  1.,  1.,
                               1.,  1.,  1.,  1.,  1.,
                               1.,  1.,  1.,  1.,  1.,
                               1.,  1.,  1.,  1.,  1.,
                               1.,  1.,  1.,  1.,  1.,
                               1.,  1.,  1.,  1.,  1.,
                               1.,  1.,  1.,  1.,  1.,
                               1.,  1.,  1.,  1.,  1.,
                               1.,  1.,  1.,  1.,  1.,
                               1.,  1.,  1.,  1.,  1.,
                               1.,  1.,  1.,  1.,  1.,
                               1.,  1.,  1.,  1.,  1.,
				1. );


# -------- aerogel properties ----------
my @mielength_aerogel = ("15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm",
			 "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm",
			 "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm",
			 "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm",
			 "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm",
			 "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm",
			 "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm",
			 "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm", "15.12*cm"
    );
#Mie scattering parameters
my $mieforward_aerogel = 0.999; # \sigma ~ 1mrad
my $miebackward_aerogel = 1.0;
my $mieratio_aerogel = 1; #100% forward scattering

#Roughness
my $aerogelSigmaAlpha = 0.006;

sub define_aerogels
{
    my $module = shift;
    my $modulesuffix = "_m" . $module;
    my %mat = init_mat();
    my $n400Fit = 1.0494;
    
    # Computing the wavelength in microns from the energy
    my @wavelength;
    my $arrSize = @penergy;
    my $conversion = 1.2398;
    for(my $i=0; $i < $arrSize; $i++){
	my @array = split(/\*/, $penergy[$i]);
	my $lambda = $conversion / $array[0];
	$wavelength[$i] = $lambda;
	#printf(" E=%s   lambda=%f\n", $penergy[$i], $lambda);
    }
    
    # read in aerogel tile passports
    my $AerogelTable = "Aerogel_module".$module.".txt";
    open (INFILE, "<$AerogelTable");
    
    my $j = 1;
    while (<INFILE>) {

        chomp;
	my @array = split(/ /);

	my $sector = $array[0];
	my $layer = $array[1];
	my $component = $array[2];

	my $n400 = $array[4];
	# density / n relationship from DOI 10.1140/epja/i2016-16023-4
	my $density = ($n400 * $n400  - 1) / 0.438;

	# refractive index calculation
	# p1, p2: from fit for n(\lambda)
	my $p1 = $array[5];
	my $p2 = $array[6];

	# calculate refractive index as a function of wavelength based on fit to beam test measurements
	my @irefr_aerogel;
	for(my $i=0; $i < $arrSize; $i++){
	    my $lambda = $wavelength[$i] * 1000;
	    $irefr_aerogel[$i] = $n400/$n400Fit * sqrt (1. + ($p1*$lambda*$lambda) / ($lambda*$lambda-$p2*$p2));
	}

	# transparency calculation
	my $thickness = $array[3]; #mm
	my $A0 = $array[7]; # absoprtion coeff.
	my $L400 = $array[8]; #mm
	my $Clarity = $array[9]; # um^4 / cm

	# calculate absorption length from clarity
	# scale scattering length by wavelength
	my @abslength_aerogel; 
	my @scattlength_aerogel;
	for(my $i=0; $i < $arrSize; $i++){
	    if ($thickness != 0 && $A0 != 0 && $Clarity != 0) {
		my $lambda = $wavelength[$i];
		
		# L_A = t / -ln(A_0)
		my $L = $thickness / (-log($A0));
		$abslength_aerogel[$i] = $L . "*mm";
		$scattlength_aerogel[$i] = ( (($lambda)**4) / $Clarity  ) . "*cm";
		#printf(" lambda=%f   Lscatt=%s cm\n", $lambda,$scattlength_aerogel[$i]);		
	    }
	    else {
		$scattlength_aerogel[$i] = "10000*mm";
		$abslength_aerogel[$i] = "10000*mm";
	    }
	}
	$mat{"name"}          = "aerogel_module" . $module . "_layer" . $layer . "_component" . $component;
	$mat{"description"}   = "Aerogel tile " . $j;
	$mat{"density"}       = $density;
	$mat{"ncomponents"}   = "1";
	$mat{"components"}    = "G4_SILICON_DIOXIDE 1.0";
	$mat{"photonEnergy"}      = arrayToString(@penergy);
	$mat{"indexOfRefraction"} = arrayToString(@irefr_aerogel);
	$mat{"absorptionLength"}  = arrayToString(@abslength_aerogel);	
	$mat{"rayleigh"} = arrayToString(@scattlength_aerogel);
	$mat{"mie"} = arrayToString(@mielength_aerogel);
	$mat{"mieforward"} = $mieforward_aerogel;
	$mat{"miebackward"} = $miebackward_aerogel;
	$mat{"mieratio"} = $mieratio_aerogel;
	print_mat(\%configuration, \%mat);

	$j = $j + 1;
    }

    my %mir = init_mir();
    $mir{"name"} = "aerogel_surface_roughness";
    $mir{"description"} = "rough surface";
    $mir{"type"} = "dielectric_dielectric";
    $mir{"finish"} = "ground";
    $mir{"model"} = "unified";
    $mir{"border"} = "SkinSurface";
    $mir{"photonEnergy"} = arrayToString(@penergy);
    $mir{"sigmaAlhpa"} = $aerogelSigmaAlpha;
    print_mir(\%configuration, \%mir);

    close(INFILE);


}


sub define_MAPMT
{

	my %mat = init_mat();
	# materials for the H8500 window - BoromTriOxide
	$mat{"name"}          = "BoromTriOxide";
	$mat{"description"}   = "MAPMT window component";
	$mat{"density"}       = "2.55";  # in g/cm3
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "B 2 O 3";
	print_mat(\%configuration, \%mat);

	# materials for the H8500 window - MagnesiumOxide
	%mat = init_mat();
	$mat{"name"}          = "MagnesiumOxide";
	$mat{"description"}   = "MAPMT window component";
	$mat{"density"}       = "3.58";  # in g/cm3
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "Mg 1 O 1";
	print_mat(\%configuration, \%mat);

	# materials for the H8500 window - IronTriOxide
	%mat = init_mat();
	$mat{"name"}          = "IronTriOxide";
	$mat{"description"}   = "MAPMT window component";
	$mat{"density"}       = "5.242";  # in g/cm3
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "Fe 1 O 3";
	print_mat(\%configuration, \%mat);

	# materials for the H8500 window - SilicOxide
	%mat = init_mat();
	$mat{"name"}          = "SilicOxide";
	$mat{"description"}   = "MAPMT window component";
	$mat{"density"}       = "2.00";  # in g/cm3 --> CHECK THE DENSITY: questa me la sono inventata io!
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "Si 1 O 1";
	print_mat(\%configuration, \%mat);


	# materials for the H8500 window - SodMonOxide
	%mat = init_mat();
	$mat{"name"}          = "SodMonOxide";
	$mat{"description"}   = "MAPMT window component";
	$mat{"density"}       = "2.00";  # in g/cm3 --> CHECK THE DENSITY: questa me la sono inventata io!
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "N 1 O 1";
	print_mat(\%configuration, \%mat);

	# materials for the H8500 window - CalciumOxide
	%mat = init_mat();
	$mat{"name"}          = "CalciumOxide";
	$mat{"description"}   = "MAPMT window component";
	$mat{"density"}       = "3.3";  # in g/cm3 
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "Ca 1 O 1";
	print_mat(\%configuration, \%mat);

	# materials for the H8500 window - AluminiumOxide
	%mat = init_mat();
	$mat{"name"}          = "AluminiumOxide";
	$mat{"description"}   = "MAPMT window component";
	$mat{"density"}       = "3.97";  # in g/cm3
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "Al 2 O 3";
	print_mat(\%configuration, \%mat);


	# h8500 windows
	%mat = init_mat();
	$mat{"name"}          = "Glass_H8500";
	$mat{"description"}   = "MAPMT window";
	$mat{"density"}       = "2.76";  # in g/cm3
	$mat{"ncomponents"}   = "8";
	$mat{"components"}    = "G4_SILICON_DIOXIDE 0.8071 G4_BORON_OXIDE 0.126 G4_SODIUM_MONOXIDE 0.042 G4_ALUMINUM_OXIDE 0.022 G4_CALCIUM_OXIDE 0.001 G4_Cl 0.001 G4_MAGNESIUM_OXIDE 0.0005 G4_FERRIC_OXIDE 0.0004";
	$mat{"photonEnergy"}      = arrayToString(@penergy);
        $mat{"indexOfRefraction"} = arrayToString(@irefr_window_h8500);
        $mat{"absorptionLength"}  = arrayToString(@abslength_window_h8500);
 	print_mat(\%configuration, \%mat);

	print("making photocathode material \n");
	# h8500 photocathode
	%mat = init_mat();
	$mat{"name"}          = "Photocathode_H8500";
	$mat{"description"}   = "MAPMT photocathode";
	$mat{"density"}       = "2.";  # in g/cm3
	$mat{"ncomponents"}   = "3";
	$mat{"components"}    = "K 1 Cs 1 Sb 1";
	#$mat{"photonEnergy"}      = arrayToString(@penergy);
        #$mat{"absorptionLength"}  = arrayToString(@abslength_cathode_h8500);
        #$mat{"indexOfRefraction"} = arrayToString(@efficiency_cathode_h8500);
	#$mat{"efficiency"} = arrayToString(@efficiency_cathode_h8500);
 	print_mat(\%configuration, \%mat);

}


# To define an EFFECTIVE CFRP for Spherical Mirrors


sub define_CFRP
{
  #To verify

        my %mat = init_mat();

        # epoxy
	$mat{"name"}          = "epoxy";
	$mat{"description"}   = "epoxy glue 1.16 g/cm3";
	$mat{"density"}       = "1.16";
	$mat{"ncomponents"}   = "4";
	$mat{"components"}    = "H 32 N 2 O 4 C 15";
	print_mat(\%configuration, \%mat);
	
	
	# carbon fiber
  
  #to check with Sandro and Dario about the material (comment done on June 2017
	%mat = init_mat();
	$mat{"name"}          = "CarbonFiber";
	$mat{"description"}   = "ft carbon fiber material is epoxy and carbon - 1.75g/cm3";
	$mat{"density"}       = "1.75";
	$mat{"ncomponents"}   = "2";
	$mat{"components"}    = "G4_C 0.745 epoxy 0.255";
	print_mat(\%configuration, \%mat);

}

1;
