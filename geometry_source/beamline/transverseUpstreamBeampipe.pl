use strict;
use warnings;

our %configuration;

sub transverseUpstreamBeampipe()
{
	my $pipeLength = 500;
	my $zpos = -858;
	my $firstVacuumOR = 35;

	my %detector = init_det();
	$detector{"name"}        = "upstreamTransverseMagnetVacuumPipe1";
	$detector{"mother"}      = "root";
	$detector{"description"} = "upstreamTransverseMagnetVacuumPipe1";
	$detector{"color"}       = "334488";
	$detector{"type"}        = "Tube";
	$detector{"pos"}         = "0*mm 0*mm $zpos*mm";
	$detector{"dimensions"}  = "0*mm $firstVacuumOR*mm $pipeLength*mm 0*deg 360*deg";
	$detector{"material"}    = "G4_Galactic";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);


	$pipeLength = 148;
	$zpos = -204;
	$firstVacuumOR = 35;

	%detector = init_det();
	$detector{"name"}        = "upstreamTransverseMagnetVacuumPipe2";
	$detector{"mother"}      = "root";
	$detector{"description"} = "upstreamTransverseMagnetVacuumPipe2";
	$detector{"color"}       = "334488";
	$detector{"type"}        = "Tube";
	$detector{"pos"}         = "0*mm 0*mm $zpos*mm";
	$detector{"dimensions"}  = "0*mm $firstVacuumOR*mm $pipeLength*mm 0*deg 360*deg";
	$detector{"material"}    = "G4_Galactic";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	print "for transverseUpstreamBeampipe, remember to rename the geometry to beamline2, this steps will be eliminated once we have the real geo\n"
}

