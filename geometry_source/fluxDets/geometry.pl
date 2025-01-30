use strict;
use warnings;

our %configuration;


sub makeFlux
{

	if($configuration{"variation"} eq "beamline")
	{
		my $nflux  = 40;
		my $zstart = 100;
		my $dz     = 20;

		for ( my $i = 1; $i <= $nflux; $i++ )
		{
			my $zpos = $zstart + ($i-1)*$dz;
			my %detector = init_det();
			$detector{"name"}        = "beam_flux_$i";
			$detector{"mother"}      = "root";
			$detector{"description"} = "beam flux $i";
			$detector{"pos"}         = "0.0*cm 0.0*cm $zpos*mm";
			$detector{"color"}       = "aa0088";
			$detector{"type"}        = "Tube";
			$detector{"dimensions"}  = "0*mm 100*mm 0.1*mm 0.*deg 360.*deg";
			$detector{"material"}    = "G4_Galactic";
			$detector{"style"}       =  1;
			$detector{"sensitivity"} = "flux";
			$detector{"hit_type"}    = "flux";
			$detector{"identifiers"} = "id manual $i";
			print_det(\%configuration, \%detector);
		}

	}

}

