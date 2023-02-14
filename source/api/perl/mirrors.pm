package mirrors;
require Exporter;

use lib ("$ENV{GEMC}/io");
use utils;
use 5.010;

@ISA = qw(Exporter);
@EXPORT = qw(init_mir print_mir);


# Available finish in materials/include/G4OpticalSurface.hh:
#
# polished,                    // smooth perfectly polished surface
# polishedfrontpainted,        // smooth top-layer (front) paint
# polishedbackpainted,         // same is 'polished' but with a back-paint
#
# ground,                      // rough surface
# groundfrontpainted,          // rough top-layer (front) paint
# groundbackpainted,           // same as 'ground' but with a back-paint
#
# polishedlumirrorair,         // mechanically polished surface, with lumirror
# polishedlumirrorglue,        // mechanically polished surface, with lumirror & meltmount
# polishedair,                 // mechanically polished surface
# polishedteflonair,           // mechanically polished surface, with teflon
# polishedtioair,              // mechanically polished surface, with tio paint
# polishedtyvekair,            // mechanically polished surface, with tyvek
# polishedvm2000air,           // mechanically polished surface, with esr film
# polishedvm2000glue,          // mechanically polished surface, with esr film & meltmount
#
# etchedlumirrorair,           // chemically etched surface, with lumirror
# etchedlumirrorglue,          // chemically etched surface, with lumirror & meltmount
# etchedair,                   // chemically etched surface
# etchedteflonair,             // chemically etched surface, with teflon
# etchedtioair,                // chemically etched surface, with tio paint
# etchedtyvekair,              // chemically etched surface, with tyvek
# etchedvm2000air,             // chemically etched surface, with esr film
# etchedvm2000glue,            // chemically etched surface, with esr film & meltmount
#
# groundlumirrorair,           // rough-cut surface, with lumirror
# groundlumirrorglue,          // rough-cut surface, with lumirror & meltmount
# groundair,                   // rough-cut surface
# groundteflonair,             // rough-cut surface, with teflon
# groundtioair,                // rough-cut surface, with tio paint
# groundtyvekair,              // rough-cut surface, with tyvek
# groundvm2000air,             // rough-cut surface, with esr film
# groundvm2000glue             // rough-cut surface, with esr film & meltmount


# Available models in materials/include/G4OpticalSurface.hh:
#
# glisur,                      // original GEANT3 model
# unified,                     // UNIFIED model
# LUT                          // Look-Up-Table model



# Available surface types in materials/include/G4SurfaceProperty.hh
#
# dielectric_metal,            // dielectric-metal interface
# dielectric_dielectric,       // dielectric-dielectric interface
# dielectric_LUT,              // dielectric-Look-Up-Table interface
# firsov,                      // for Firsov Process
# x_ray                        // for x-ray mirror process


# Border Volume Types:
#
# SkinSurface: surface of a volume
# Border Surface: surface between two volumes (second volume must exist)


# Initialize hash maps
sub init_mir
{
	my %mir = ();
	
	# The default value for identifier is "id"
	$mir{"description"} = "id";
	
	# The optical properties are defaulted to none
	# User can define a optical property with arrays of:
	#
	# These properties are mandatory
	$mir{"type"}         = "mustBeDefined";
	$mir{"finish"}       = "mustBeDefined";
	$mir{"model"}        = "mustBeDefined";
	$mir{"border"}       = "mustBeDefined";
	
	# If materialOptProperties is defined, use the material
	# optical properties instead of defining new ones
	$mir{"maptOptProps"} = "notDefined";
	
	# - At least one of the following quantities arrays
	$mir{"photonEnergy"}       = "none";
	$mir{"indexOfRefraction"}  = "none";
	$mir{"reflectivity"}       = "none";
	$mir{"efficiency"}         = "none";
	$mir{"specularlobe"}       = "none";
	$mir{"specularspike"}      = "none";
	$mir{"backscatter"}        = "none";
	$mir{"sigmaAlhpa"}         = "-1";


	return %mir;
}


# Print mirror to TEXT file or upload it onto the DB
sub print_mir
{
	my %configuration = %{+shift};
	my %mirs          = %{+shift};
	
	my $table   = $configuration{"detector_name"}."__mirrors";
	my $varia   = $configuration{"variation"};
	
	# converting the hash maps in local variables
	# (this is necessary to parse the MYSQL command)
	my $lname              = trim($mirs{"name"});
	my $ldesc              = trim($mirs{"description"});
	
	# Mirror mandatory properties
	my $ltype              = trim($mirs{"type"});         # see above surface types
	my $lfinish            = trim($mirs{"finish"});       # see above finishes
	my $lmodel             = trim($mirs{"model"});        # see above model types
	my $lborder            = trim($mirs{"border"});       # see above border types

	# If materialOptProperties is defined, use the material
	# optical properties instead of defining new ones
	my $lmatOptProps       = trim($mirs{"maptOptProps"});
	
	my $lphotonEnergy      = trim($mirs{"photonEnergy"});
	my $lindexOfRefraction = trim($mirs{"indexOfRefraction"});
	my $lreflectivity      = trim($mirs{"reflectivity"});
	my $lefficiency        = trim($mirs{"efficiency"});
	my $lspecularlobe      = trim($mirs{"specularlobe"});
	my $lspecularspike     = trim($mirs{"specularspike"});
	my $lbackscatter       = trim($mirs{"backscatter"});
	my $lsigmaAlhpa        = trim($mirs{"sigmaAlhpa"});

	if($lmatOptProps eq "notDefined")
	{
		if($lphotonEnergy eq "none")
		{
			print " !! Error: there is no material with optical properties associated with this mirror.\n";
			print " !! Optical properties must be defined.\n";
		}
	}
	
	# after 5.10 once can use "state" to use a static variable`
	state $counter = 0;
	state $this_variation = "";
	
	# TEXT Factory
	if($configuration{"factory"} eq "TEXT")
	{
		my $file = $configuration{"detector_name"}."__mirrors_".$varia.".txt";
		
		if($counter == 0 || $this_variation ne  $varia)
		{
			`rm -f $file`;
			print "Overwriting if existing: ",  $file, "\n";
			$counter = 1;
			$this_variation = $varia;
		}
		
		open(INFO, ">>$file");
		printf INFO ("%20s  |",  $lname);
		printf INFO ("%30s  |",  $ldesc);
		
		if($ltype    eq "mustBeDefined") { print "Error: type undefined.\n"; }
		if($lfinish  eq "mustBeDefined") { print "Error: finish undefined.\n"; }
		if($lmodel   eq "mustBeDefined") { print "Error: model undefined.\n"; }
		if($lborder  eq "mustBeDefined") { print "Error: border undefined.\n"; }

		
		printf INFO ("%24s  |", $ltype);
		printf INFO ("%20s  |", $lfinish);
		printf INFO ("%10s  |", $lmodel);
		printf INFO ("%25s  |", $lborder);
		printf INFO ("%25s  |", $lmatOptProps);
				
			
		# photon energy
		if($lphotonEnergy eq "none")     {printf INFO ("%5s |", $lphotonEnergy);}
		else                             {printf INFO ("%s  |", $lphotonEnergy);}
		# index of refraction
		if($lindexOfRefraction eq "none"){printf INFO ("%5s |", $lindexOfRefraction);}
		else                             {printf INFO ("%s  |", $lindexOfRefraction);}
		# reflectivity
		if($lreflectivity eq "none")     {printf INFO ("%5s |", $lreflectivity);}
		else                             {printf INFO ("%s  |", $lreflectivity);}
		# efficiency
		if($lefficiency eq "none")       {printf INFO ("%5s |", $lefficiency);}
		else                             {printf INFO ("%s  |", $lefficiency);}
		# specularlobe
		if($lspecularlobe eq "none")     {printf INFO ("%5s |", $lspecularlobe);}
		else                             {printf INFO ("%s  |", $lspecularlobe);}
		# specularspike
		if($lspecularspike eq "none")    {printf INFO ("%5s |", $lspecularspike);}
		else                             {printf INFO ("%s  |", $lspecularspike);}
		# backscatter
		if($lbackscatter eq "none")      {printf INFO ("%5s |", $lbackscatter);}
		else                             {printf INFO ("%s  |", $lbackscatter);}
		# sigmaAlhpa
		if($lsigmaAlhpa eq "-1")         {printf INFO ("%5s\n", $lsigmaAlhpa);}
		else                             {printf INFO ("%s \n", $lsigmaAlhpa);}

		
		close(INFO);
	}
	
	# MYSQL Factory
#	my $err;
#	if($configuration{"factory"} eq "MYSQL")
#	{
#		my $dbh = open_db(%configuration);
#		
#		$dbh->do("insert into $table( \
#			          name,     description,     density,    ncomponents,    components,    photonEnergy,    indexOfRefraction,    absorptionLength,    reflectivity,   efficiency,   variation) \
#			values(      ?,               ?,           ?,              ?,             ?,               ?,                    ?,                   ?,               ?,            ?,           ?) ON DUPLICATE KEY UPDATE \
#			        name=?,   description=?,   density=?,  ncomponents=?,  components=?,  photonEnergy=?,  indexOfRefraction=?,  absorptionLength=?,  reflectivity=?, efficiency=?, variation=?, \
#			        time=CURRENT_TIMESTAMP",  undef,
#			        $lname,          $ldesc,   $ldensity,  $lncomponents,  $lcomponents,  $lphotonEnergy,  $lindexOfRefraction,  $labsorptionLength,  $lreflectivity, $lefficiency,      $varia,
#			        $lname,          $ldesc,   $ldensity,  $lncomponents,  $lcomponents,  $lphotonEnergy,  $lindexOfRefraction,  $labsorptionLength,  $lreflectivity, $lefficiency,      $varia)
#			
#			or die "SQL Error: $DBI::errstr\n";
#		
#		$dbh->disconnect();
#	}
	
	if($configuration{"verbosity"} > 0)
	{
		print "  + Mirror $lname uploaded successfully for variation \"$varia\" \n";
	}
}


1;





