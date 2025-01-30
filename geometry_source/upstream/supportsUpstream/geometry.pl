use strict;
use warnings;

our %configuration;

my $shift = 130;
my $STARTcart = -462.3;

sub build_supportsUpstream()
{
	build_mother();
	build_MVTpipe();
	build_SVTpipe();
}

sub build_mother()
{
	my $START = 1764;   # 1764*mm
	my $END   = 4460.9; # 4460.9*mm
	my %detector = init_det();
	$detector{"name"}        = "supportsUpstream";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Support pipes' mother volume";
	$detector{"pos"}         = "0*cm 0*cm $shift*cm";
	$detector{"rotation"}    = "0*deg 180*deg 0*deg";
	$detector{"color"}       = "eeeeee";
	$detector{"type"}        = "Polycone";
	# $detector{"dimensions"}  = "0*deg 360*deg 12*counts 103*mm 103*mm 152.6*mm 152.6*mm 152.6*mm 152.6*mm 152.6*mm 152.6*mm 152.6*mm 152.6*mm 152.6*mm 152.6*mm 248.4*mm 248.4*mm 248.4*mm 248.4*mm 500*mm 500*mm 800*mm 800*mm 1800*mm 1800*mm 800*mm 800*mm $START*mm 2589*mm 2589*mm 2816*mm 2816*mm 3170*mm 3170*mm 3540*mm 3540*mm 3693*mm 3693*mm $END*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 6*counts 103*mm 103*mm 152.6*mm 152.6*mm 152.6*mm 152.6*mm 248.4*mm 248.4*mm 248.4*mm 248.4*mm 500*mm 500*mm $START*mm 2589*mm 2589*mm 2816*mm 2816*mm 3146.41*mm";
	$detector{"material"}    = "G4_AIR";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

}

sub build_MVTpipe()
{
	my %detector = init_det();
	$detector{"name"}        = "JL0046104";
	$detector{"mother"}      = "supportsUpstream";
	$detector{"description"} = "MVT support pipe";
	$detector{"color"}       = "777777";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 20*counts 237*mm 236*mm 236*mm 238*mm 238*mm 238*mm 238*mm 238*mm 238*mm 238*mm 238*mm 238*mm 238*mm 244.77*mm 254*mm 254*mm 257*mm 257*mm 257*mm 257*mm 244*mm 244*mm 244*mm 244*mm 244*mm 241*mm 241*mm 245.5*mm 245.5*mm 245.78*mm 247.5*mm 250.627*mm 253.124*mm 260*mm 260*mm 260*mm 260*mm 260*mm 314*mm 314*mm 1979.76*mm 1980.76*mm 1991.76*mm 1991.76*mm 2001.76*mm 2001.76*mm 2836.76*mm 2836.76*mm 2840.76*mm 2841.76*mm 2842.76*mm 2842.76*mm 2846.76*mm 2857.76*mm 2872.76*mm 2878.76*mm 2878.76*mm 2949.76*mm 2949.76*mm 2979.76*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "JL0045868";
	$detector{"mother"}      = "supportsUpstream";
	$detector{"description"} = "MVT support pipe";
	$detector{"color"}       = "777777"; #cccccc
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 13*counts 205*mm 204*mm 204*mm 204*mm 204*mm 204*mm 204*mm 209.501*mm 209.501*mm 209.501*mm 209.501*mm 209.501*mm 209.501*mm 208*mm 208*mm 208*mm 208.279*mm 210*mm 212.5*mm 212.5*mm 212.5*mm 212.5*mm 244*mm 244*mm 235.999*mm 235.999*mm 1764.76*mm 1765.76*mm 1800.76*mm 1801.76*mm 1802.76*mm 1802.76*mm 1815.76*mm 1815.76*mm 1967.76*mm 1967.76*mm 1979.76*mm 1979.76*mm 1985.76*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

}

sub build_SVTpipe()
{
	my %detector = init_det();

	$detector{"name"}        = "14_Inch_Tube";
	$detector{"mother"}      = "supportsUpstream";
	$detector{"description"} = "14 Inch Tube, flange cart side and forward mounting flange";
	$detector{"color"}       = "ff7f00";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 8*counts 171.45*mm 171.45*mm 136.525*mm 136.525*mm 171.45*mm 171.45*mm 171.45*mm 171.45*mm 177.8*mm 177.8*mm 177.8*mm 177.8*mm 177.8*mm 177.8*mm 228.6*mm 228.6*mm 2397.11*mm 2409.81*mm 2409.81*mm 2422.51*mm 2422.51*mm 3127.36*mm 3127.36*mm 3146.41*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "MVTflangeI";
	$detector{"mother"}      = "supportsUpstream";
	$detector{"description"} = "Reg 4 and MVT Mounting Flange (Inner Ring)";
	$detector{"color"}       = "771111";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 196.85*mm 196.85*mm 228.6*mm 228.6*mm 2979.76*mm 3005.16*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "MVTflangeO";
	$detector{"mother"}      = "supportsUpstream";
	$detector{"description"} = "Reg 4 and MVT Mounting Flange (Outer Ring)";
	$detector{"color"}       = "771111";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 260.35*mm 260.35*mm 304.8*mm 304.8*mm 2979.76*mm 3005.16*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

	$detector{"name"}        = "10.75_Inch_Tube";
	$detector{"mother"}      = "supportsUpstream";
	$detector{"description"} = "SVT 10.75 Inch Tube, center step flange, and SVT interface flange";
	$detector{"color"}       = "ff7f00"; #444444
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 10*counts 132.334*mm 132.334*mm 107.95*mm 107.95*mm 132.334*mm 132.334*mm 132.334*mm 132.334*mm 136.525*mm 136.525*mm 136.525*mm 136.525*mm 136.525*mm 136.525*mm 136.525*mm 136.525*mm 165.735*mm 165.735*mm 165.735*mm 165.735*mm 2039.96*mm 2053.34*mm 2053.34*mm 2066.04*mm 2066.04*mm 2397.11*mm 2397.11*mm 2409.53*mm 2409.53*mm 2409.81*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

}


