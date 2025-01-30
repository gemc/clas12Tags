use strict;
use warnings;

our %configuration;
our %parameters;

our @colors_even = ( "ff8080", "8080ff", "80ff80", "f0f0f0" );


# Loading HTCC geometry routines specific subroutines
require "./geo/mother.pl";
require "./geo/mirrors.pl";
require "./geo/pmts.pl";


sub makeHTCC
{
	build_mother();
	build_mirrors();
	build_pmts();
}
