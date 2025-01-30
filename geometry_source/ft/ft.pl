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
	print "   ft.pl <configuration filename>\n";
 	print "   Will create the CLAS12 Forward Tagger (ft) using the variation specified in the configuration file\n";
 	print "   Note: The passport and .visa files must be present to connect to MYSQL. \n\n";
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

# One can change the "variation" here if one is desired different from the config.dat
# $configuration{"variation"} = "myvar";

# To get the parameters proper authentication is needed.
# our %parameters    = get_parameters(%configuration);

# Loading FT specific subroutines
require "./hit.pl";
require "./bank.pl";
require "./geometry.pl";
require "./materials.pl";


# bank definitions commong to all variations
define_banks();

# all the scripts must be run for every configuration
#my @allConfs = ("FTOn", "FTOff", "WithInnerSST", "WithInnerShield", "NotUsedWithInnerSST", "NotUsedWithInnerShield");
my @allConfs = ("FTOn", "FTOff", "KPP");

foreach my $conf ( @allConfs )
{
    $configuration{"variation"} = $conf ;

    # materials
    materials();
    
    define_ft_hits();
    
    #  make_ft_shield();
    if($configuration{"variation"} eq "KPP") {
        make_ft_pipe();
    }
    else {
        make_ft_cal();
        make_ft_hodo();
        if($configuration{"variation"} eq "FTOn" ) {
            make_ft_trk();
        }
    }
}
