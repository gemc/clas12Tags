#!/usr/bin/perl -w

use strict;
use lib ("$ENV{GEMC}/api/perl");
use utils;
use parameters;
use geometry;
use hit;
use bank;
use math;
use materials;

use Math::Trig;

# Help Message
sub help()
{
	print "\n Usage: \n";
	print "    muvt.pl <configuration filename>\n";
 	print "   Will create the CLAS12 URWT geometry, materials, bank and hit definitions\n";
	exit;
}

# Make sure the argument list is correct
if( scalar @ARGV != 1)
{
	help();
	exit;
}

# Loading configuration file and parameters
our %configuration = load_configuration($ARGV[0]);

# materials
require "./materials.pl";

# banks definitions
require "./bank.pl";

# hits definitions
require "./hit.pl";

# sensitive geometry
require "./geometry_java.pl";

# bank definitions common to all variations
define_bank();

#-------------------------------
# Run GROOVY factory and parse NLAYERS from stdout
#-------------------------------
#my $variation = $configuration{"variation"};
my @allConfs = ("default");
#my @allConfs = ("urwt_proto");
for(my $ii=0; $ii<=$#allConfs; $ii++){
#	$configuration{"variation"} = $conf ;
 	my $variation = $allConfs[$ii];
    $configuration{"variation"} = $variation;

    print "$configuration{variation}\n";

	$ENV{CCDB_VARIATION} = $variation;
# run muvt factory from COATJAVA to produce volumes
	system("$ENV{COATJAVA}/bin/run-groovy factory.groovy --variation $variation --runnumber 11");


#-------------------------------
# Continue as before
#-------------------------------

# materials
	materials();

# hits
	define_hit();

# sensitive geometry
# Global pars - these should be read by the load_parameters from file or DB
	our @volumes = get_volumes(%configuration);


# Here you can use $NLAYERS if needed, e.g.:
# print "Using NLAYERS = $NLAYERS in Perl script\n";
	coatjava::init_muvt_from_ccdb($variation);
	coatjava::make_detector();
}
