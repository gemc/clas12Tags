use strict;
use warnings;

our %configuration;

# Table of optical photon energies (wavelengths) from 190-650 nm:
my @penergy = ( "1.9074494*eV",  "1.9372533*eV",  "1.9680033*eV",  "1.9997453*eV",  "2.0325280*eV",
                "2.0664035*eV",  "2.1014273*eV",  "2.1376588*eV",  "2.1751616*eV",  "2.2140038*eV",
                "2.2542584*eV",  "2.2960039*eV",  "2.3393247*eV",  "2.3843117*eV",  "2.4310630*eV",
                "2.4796842*eV",  "2.5302900*eV",  "2.5830044*eV",  "2.6379619*eV",  "2.6953089*eV",
                "2.7552047*eV",  "2.8178230*eV",  "2.8833537*eV",  "2.9520050*eV",  "3.0240051*eV",
                "3.0996053*eV",  "3.1790823*eV",  "3.2627424*eV",  "3.3509246*eV",  "3.4440059*eV",
                "3.5424060*eV",  "3.6465944*eV",  "3.7570973*eV",  "3.8745066*eV",  "3.9994907*eV",
                "4.1328070*eV",  "4.2753176*eV",  "4.4280075*eV",  "4.5920078*eV",  "4.7686235*eV",
                "4.9593684*eV",  "5.1660088*eV",  "5.3906179*eV",  "5.6356459*eV",  "5.9040100*eV",
	             "6.1992105*eV",  "6.5254848*eV" );

# Index of refraction of CO2 gas at STP:
my @irefr = ( 1.0004473,  1.0004475,  1.0004477,  1.0004480,  1.0004483,
              1.0004486,  1.0004489,  1.0004492,  1.0004495,  1.0004498,
              1.0004502,  1.0004506,  1.0004510,  1.0004514,  1.0004518,
              1.0004523,  1.0004528,  1.0004534,  1.0004539,  1.0004545,
              1.0004552,  1.0004559,  1.0004566,  1.0004574,  1.0004583,
              1.0004592,  1.0004602,  1.0004613,  1.0004625,  1.0004638,
              1.0004652,  1.0004668,  1.0004685,  1.0004704,  1.0004724,
              1.0004748,  1.0004773,  1.0004803,  1.0004835,  1.0004873,
              1.0004915,  1.0004964,  1.0005021,  1.0005088,  1.0005167,
	           1.0005262,  1.0005378 );


# Transparency of CO2 gas at STP:
# (completely transparent except at very short wavelengths below ~200 nm)
my @abslength = ( "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m", 
                  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m", 
                  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m", 
                  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m", 
                  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m", 
                  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m", 
                  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m", 
                  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m", 
                  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",  "1000.0000000*m",    "82.8323273*m", 
						"4.6101432*m",     "0.7465970*m");

# Quantum efficiency of HTCC PMT with quartz window:
my @qeHTCCpmt = (0.0000000,     0.0014000,     0.0024000,     0.0040000,     0.0065000,
		           0.0105000,     0.0149000,     0.0216000,     0.0289000,     0.0376000,
		           0.0482000,     0.0609000,     0.0753000,     0.0916000,     0.1116000,
		           0.1265000,     0.1435000,     0.1602000,     0.1725000,     0.1892000,
		           0.2017000,     0.2122000,     0.2249000,     0.2344000,     0.2401000,
					  0.2418000,     0.2394000,     0.2372000,     0.2309000,     0.2291000,
		           0.2275000,     0.2301000,     0.2288000,     0.2236000,     0.2268000,
		           0.2240000,     0.2219000,     0.2219000,     0.2223000,     0.2189000,
		           0.2158000,     0.2093000,     0.2038000,     0.1950000,     0.1836000,
		           0.1612000,     0.1305000 );



# Index of refraction of HTCC PMT quartz window:
my @rindexHTCCpmt = ( 1.5420481,  1.5423678,  1.5427003,  1.5430465,  1.5434074,
		                1.5437840,  1.5441775,  1.5445893,  1.5450206,  1.5454731,
		                1.5459484,  1.5464485,  1.5469752,  1.5475310,  1.5481182,
		                1.5487396,  1.5493983,  1.5500977,  1.5508417,  1.5516344,
		                1.5524807,  1.5533859,  1.5543562,  1.5553983,  1.5565202,
		                1.5577308,  1.5590402,  1.5604602,  1.5620045,  1.5636888,
		                1.5655313,  1.5675538,  1.5697816,  1.5722449,  1.5749797,
							 1.5780296,  1.5814472,  1.5852971,  1.5896593,  1.5946337,
							 1.6003470,  1.6069618,  1.6146902,  1.6238138,  1.6347145,
		                1.6479224,  1.6641955 );

# Reflectivity of Al-MgF2 HTCC mirror coating:

my @reflectivityHTCCAlMgF2 =
	(  0.8860000,  0.8880000,  0.8890000,  0.8900000,  0.8930000,
		0.8960000,  0.8970000,  0.9000000,  0.9010000,  0.9020000,
		0.9030000,  0.9040000,  0.9040000,  0.9040000,  0.9040000,
		0.9040000,  0.9040000,  0.9040000,  0.9050000,  0.9050000,
		0.9050000,  0.9050000,  0.9040000,  0.9040000,  0.9040000,
		0.9040000,  0.9030000,  0.9030000,  0.9030000,  0.9020000,
		0.9020000,  0.9010000,  0.9010000,  0.9000000,  0.8970000,
		0.8930000,  0.8890000,  0.8830000,  0.8780000,  0.8660000,
		0.8520000,  0.8360000,  0.8190000,  0.7950000,  0.7660000,
		0.7370000,  0.6950000 );
#AJRP 1/29/2013:
	#Array of photon energies corresponding to wavelengths from 200-650 nm
	#This omits the point at lambda = 190 nm that is used in the other arrays above
	#Used to define mirror reflectivity based on Andrew's measurements in Fall 2012:
my @penergyHTCCmirr =
    ( "1.907449*eV",         "1.937253*eV",         "1.968003*eV",         "1.999745*eV",         "2.032528*eV",
	   "2.066404*eV",         "2.101427*eV",         "2.137659*eV",         "2.175162*eV",         "2.214004*eV",
	   "2.254258*eV",         "2.296004*eV",         "2.339325*eV",         "2.384312*eV",         "2.431063*eV",
	   "2.479684*eV",          "2.53029*eV",         "2.583004*eV",         "2.637962*eV",         "2.695309*eV",
	   "2.755205*eV",         "2.817823*eV",         "2.883354*eV",         "2.952005*eV",         "3.024005*eV",
	   "3.099605*eV",         "3.179082*eV",         "3.262742*eV",         "3.350925*eV",         "3.444006*eV",
	   "3.542406*eV",         "3.646594*eV",         "3.757097*eV",         "3.874507*eV",         "3.999491*eV",
	   "4.132807*eV",         "4.275318*eV",         "4.428008*eV",         "4.592008*eV",         "4.768623*eV",
	   "4.959368*eV",         "5.166009*eV",         "5.390618*eV",         "5.635646*eV",          "5.90401*eV",
	   "6.199211*eV");
	
	#Reflectivity of AlMgF2 coated on thermally shaped acrylic sheets, measured by AJRP, 10/01/2012:
	my @reflectivityHTCCAlMgF2Mirr =
    ( 0.8722925,        0.8725418,        0.8724854,        0.8719032,        0.8735628,
		0.8733527,        0.8728732,        0.8769834,        0.8794382,        0.8790207,
		0.8762184,        0.8800928,        0.8808256,        0.8812256,        0.8801459,
		0.876982,        0.8786141,        0.8790666,        0.8786467,        0.8802601,
		0.8824032,        0.8805016,        0.8733517,        0.8705232,        0.8753389,
		0.8739763,          0.87137,        0.8754125,        0.8802811,        0.8616457,
		0.8677598,        0.8684776,        0.8629656,         0.856517,        0.8539165,
		0.8502238,        0.8450355,        0.8342837,        0.8257114,        0.8160133,
		0.8036618,         0.783193,        0.7541341,        0.7498343,        0.6969729,
		0.6854251);
	
#Reflectivity of AlMgF2 coated on Winston Cones, measured by AJRP on 10/04/2012:
	my @reflectivityHTCCAlMgF2WC =
    ( 0.8331038,        0.8309071,        0.8279127,        0.8280742,        0.8322623,
		0.837572,        0.8396875,        0.8481834,        0.8660284,        0.8611336,
		0.8566167,        0.8667431,          0.86955,        0.8722481,        0.8728122,
		0.8771635,         0.879907,         0.879761,        0.8831943,        0.8894673,
		0.8984234,        0.9009531,        0.8910166,        0.8887382,        0.8869093,
		0.8941976,        0.8948479,        0.8877356,        0.9026919,        0.8999685,
		0.9101617,        0.8983005,        0.8991694,        0.8990987,        0.9000493,
		0.9065833,        0.9028855,        0.8985184,        0.9009736,        0.9086968,
		0.9015145,        0.8914838,        0.8816829,        0.8666895,        0.8496298,
		0.9042583 );
		
		
sub materials
{
    # htcc gas is 100% CO2 with optical properties
	my %mat = init_mat();
	$mat{"name"}          = "HTCCgas";
	$mat{"description"}   = "htcc gas is 100% CO2 with optical properties";
	$mat{"density"}       = "0.00184";
	$mat{"ncomponents"}   = "1";
	$mat{"components"}    = "G4_CARBON_DIOXIDE 1.0";
	$mat{"photonEnergy"}      = arrayToString(@penergy);
	$mat{"indexOfRefraction"} = arrayToString(@irefr);
	$mat{"absorptionLength"}  = arrayToString(@abslength);
	print_mat(\%configuration, \%mat);
	
	# rohacell
	%mat = init_mat();
	$mat{"name"}          = "rohacell31";
	$mat{"description"}   = "rohacell composite material";
	$mat{"density"}       = "0.032";
#	$mat{"density"}       = "0.131";  # mirror width is 0.6 rohacell 100 micron acrylic sheet
	$mat{"ncomponents"}   = "4";
	$mat{"components"}    = "G4_C 0.6463 G4_H 0.0784 G4_N 0.0839 G4_O 0.1914";
	print_mat(\%configuration, \%mat);

	# tedlar
	%mat = init_mat();
	$mat{"name"}         = "HTCCTedlar";
	$mat{"description"}  = "tedlar material used in the composite window";
	$mat{"density"}      = "1.43";
	$mat{"ncomponents"}  = "3";
	$mat{"components"}   = "G4_C 0.33 G4_F 0.33 G4_H 0.34";
	print_mat(\%configuration, \%mat);


	# composite window
	# Mylar density is 1.4 tedlar is 1.43. Using 1.415 as the average
	%mat = init_mat();
	$mat{"name"}         = "HTCCCompositeWindow";
	$mat{"description"}  = "composite window material";
	$mat{"density"}      = "1.415";
	$mat{"ncomponents"}  = "2";
	$mat{"components"}   = "HTCCTedlar 0.5 G4_MYLAR 0.5";
	print_mat(\%configuration, \%mat);


	# Quartz window of HTCC PMT:
	# - refractive index (required for tracking of optical photons)
	# - efficiency (for quantum efficiency of photocathode)
	# NOTE: in principle the quantum efficiency data of the photocathode
	# already includes the effects of reflection and transmission
	# at the interface between the window and the surrounding environment.
	# Therefore, it is possible that we are "double-counting" such effects
	# on the photo-electron yield by including the refractive index here.
	# However, only a small fraction of the light will be reflected by the
	# window in any case so we don't need to worry too much.
	%mat = init_mat();
	$mat{"name"}         = "HTCCPMTQuartz";
	$mat{"description"}  = "refractive index and efficency of HTCC PMT Quartz window";
	$mat{"density"}      = "2.32";
	$mat{"ncomponents"}  = "1";
	$mat{"components"}   = "G4_SILICON_DIOXIDE 1.0";
	$mat{"photonEnergy"} = arrayToString(@penergy);
	$mat{"efficiency"}   = arrayToString(@qeHTCCpmt);
	$mat{"indexOfRefraction"} = arrayToString(@rindexHTCCpmt);
	print_mat(\%configuration, \%mat);

	# AlMgF2 mirror reflective coating for HTCC.
	# Mass fractions and density are calculated assuming 27.5 nm thickness
	# of Al and 50 nm thickness of MgF2.
	# However, this information is largely irrelevant, because:
	# For optics purposes, we put in the reflectivity by hand,
	# while the material thickness is negligible for Eloss/multiple
	# scattering purposes.
	# Furthermore, the only place this material will be used
	# (in principle) is as the "Mirror skin" surface for the HTCC mirrors
	# and Winston Cones (as a G4LogicalSkinSurface)	
	%mat = init_mat();
	$mat{"name"}        = "HTCCECIAlMgF2";
	$mat{"description"} = "Measured reflectivity for Al+MgF2";
	$mat{"density"}     = "2.9007";
	$mat{"ncomponents"} = "3";
	$mat{"components"}  = "G4_Al 0.331 G4_Mg 0.261 G4_F 0.408";
	$mat{"photonEnergy"} = arrayToString(@penergy);
	$mat{"reflectivity"} = arrayToString(@reflectivityHTCCAlMgF2);
	print_mat(\%configuration, \%mat);


	#Below we add new material definitions which include the actual measured reflectivity of thermally shaped sheets of acryl
	#coated with Aluminum and "MgF2" by ECI (Actually, "MgF2" is ECI's proprietary protective overcoat material, we do not know its composition.
	# We only measured its reflectivity.).
	# ECI = Evaporated Coatings, Inc.
	# New material definition with actual reflectivity measured for Al+MgF2 coated on acryl sheets, AJRP 10/08/2012:
	%mat = init_mat();
	$mat{"name"}         = "HTCCECIMirr";
	$mat{"description"}  = "Measured reflectivity for Al+MgF2 coated on acryl sheets";
	$mat{"density"}      = "2.9007";
	$mat{"ncomponents"}  = "3";
	$mat{"components"}   = "G4_Al 0.331 G4_Mg 0.261 G4_F 0.408";
	$mat{"photonEnergy"} = arrayToString(@penergyHTCCmirr);
	$mat{"reflectivity"} = arrayToString(@reflectivityHTCCAlMgF2Mirr);
	print_mat(\%configuration, \%mat);

	
	#Below is a new material definition which is the same as above, except this time we use the measured reflectivity of
	#the same coating applied to a Winston cone and measured with the test beam incident parallel to the axis of the cone at a "grazing"
	# angle-of-incidence:
	# New material definition with actual reflectivity measured for Al+MgF2 coated on Winston cone, AJRP 10/08/2012:
	%mat = init_mat();
	$mat{"name"}         = "HTCCECIWC";
	$mat{"description"}  = "Measured reflectivity for Al+MgF2 coated on acryl sheets";
	$mat{"density"}      = "2.9007";
	$mat{"ncomponents"}  = "3";
	$mat{"components"}   = "G4_Al 0.331 G4_Mg 0.261 G4_F 0.408";
	$mat{"photonEnergy"} = arrayToString(@penergyHTCCmirr);
	$mat{"reflectivity"} = arrayToString(@reflectivityHTCCAlMgF2WC);
	print_mat(\%configuration, \%mat);
}


