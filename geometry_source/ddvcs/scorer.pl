use strict;
use warnings;

our %configuration;
our $toRad;
our $microgap;


# flux scorer at 40 cm, min theta = 4.5 cm, max theta = 100cm
sub makeScorer
{	

   my %detector = init_det();
   $detector{"name"}        = "scorer";
   $detector{"mother"}      = "root";
   $detector{"description"} = "scorer for particle fluxes";
   $detector{"color"}       = "aa0000";
	$detector{"pos"}         = "0*cm 0*cm 40*cm";
   $detector{"type"}        = "Tube";
   $detector{"dimensions"}  = "3.4*cm 35*cm 1*mm 0*deg 360*deg";
   $detector{"material"}    = "Vacuum";
   $detector{"style"}       = 1;
	$detector{"sensitivity"} = "flux";
	$detector{"hit_type"}    = "flux";
	$detector{"identifiers"} = "id manual 1";
   print_det(\%configuration, \%detector);
}


