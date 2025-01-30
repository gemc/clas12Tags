use strict;
use warnings;

our %configuration;

our $TorusZpos;
our $SteelFrameLength;
our $tungstenColor;

my $torusZstart = $TorusZpos - $SteelFrameLength;

sub torusBeamShield()
{
	# original physicists design of the a beamline shielding
	# that starts inside the torus
	# common to all configurations
	
	
	my $microgap = 0.2;
	my $totalLength  = $SteelFrameLength;   # total beamline semi-length
	my $bpipeTorusZ  = $torusZstart + $totalLength ;  # z position - to place the pipe inside torus
	my $pipeIR       = 40 + $microgap;
	my $pipeOR       = 60 - $microgap;
	if ( $configuration{"variation"} eq "FTOff_mount_is_W" || $configuration{"variation"} eq "FTOn_mount_is_W")
	{
		$pipeIR       = 37.55;
		$pipeOR       = 57.15;
	}
	my $SSout_pipeIR       = 57.15;
	my $SSout_pipeOR       = 60.325;
	my $SSin_pipeIR       = 34.55;
	my $SSin_pipeOR       = 37.55;
	
	
	
	# Tungsten Cone
	my %detector = init_det();
	$detector{"name"}        = "tungstenTorusBeamShield";
	$detector{"mother"}      = "root";
	$detector{"description"} = "tungsten beampipe shield inside torus";
	$detector{"color"}       = $tungstenColor;
	$detector{"pos"}         = "0*mm 0.0*mm $bpipeTorusZ*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$pipeIR*mm $pipeOR*mm $totalLength*mm 0.0*deg 360*deg";
	$detector{"material"}    = "beamline_W";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	if ($configuration{"variation"} eq "FTOff_mount_is_W" || $configuration{"variation"} eq "FTOn_mount_is_W")
	{
		# Stainless-steel Cones
		%detector = init_det();
		$detector{"name"}        = "SSlayer_out_tungstenTorusBeamShield";
		$detector{"mother"}      = "root";
		$detector{"description"} = "tungsten beampipe shield inside torus";
		$detector{"color"}       = "3333ff";
		$detector{"pos"}         = "0*mm 0.0*mm $bpipeTorusZ*mm";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$SSout_pipeIR*mm $SSout_pipeOR*mm $totalLength*mm 0.0*deg 360*deg";
		$detector{"material"}    = "G4_STAINLESS-STEEL";
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);

		%detector = init_det();
		$detector{"name"}        = "SSlayer_in_tungstenTorusBeamShield";
		$detector{"mother"}      = "root";
		$detector{"description"} = "tungsten beampipe shield inside torus";
		$detector{"color"}       = "3333ff";
		$detector{"pos"}         = "0*mm 0.0*mm $bpipeTorusZ*mm";
		$detector{"type"}        = "Tube";
		$detector{"dimensions"}  = "$SSin_pipeIR*mm $SSin_pipeOR*mm $totalLength*mm 0.0*deg 360*deg";
		$detector{"material"}    = "G4_STAINLESS-STEEL";
		$detector{"style"}       = 1;
		print_det(\%configuration, \%detector);
	}


	
}
	return 1;
