#!/usr/bin/perl -w

use strict;
use lib ("$ENV{GEMC}/api/perl"); # added on 12/23/20 by KA
use utils;
use geometry;
use math;
use materials;
use bank;
use hit;

# Help Message
sub help()
{
	print "\n Usage: \n";
	print "   rtpc.pl <configuration filename>\n";
	print "   Will create the CLAS12 RTPC using the variation specified in the configuration file\n";
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


# materials
require "./materials.pl";

# sensitive geometry
require "./geometry.pl";

#bank
require "./bank.pl";
define_bank();

#bank
require "./hit.pl";

# all the scripts must be run for every configuration
my @allConfs = ("original");

foreach my $conf ( @allConfs )
{
    $configuration{"variation"} = $conf ;
    # materials
    materials();
    
    # geometry
    build_rtpc();
    
    define_hit();
    
}
