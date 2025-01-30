use strict;
use warnings;

# Loading configuration file from argument
our %configuration = load_configuration("config_torus.dat");

# General:
our $inches      = 25.4;
our $TorusLength = 2158.4/2.0;  # 1/2 length of torus
our $TorusZpos   = 3833;        # center of the torus position (include its semilengt). Value from M. Zarecky, R. Miller PDF file on 1/13/16


# hub
require "./torusHub.pl";

# front and back plates
require "./torusPlates.pl";

# coils
require "./torusCoils.pl";

# building the torus
sub makeTorus
{
	$configuration{"variation"} = shift ;

	torusHub();
	torusPlates();
	torusCoils();
}




