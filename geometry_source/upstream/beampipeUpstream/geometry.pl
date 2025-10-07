use strict;
use warnings;

our %configuration;

my $shift = 126;

sub build_beampipeUpstream()
{
	build_mother();
	build_pipe();
	#build_sarclay();
}

sub build_mother()
{
	my $START = 1409; # Set to 1000 for empty Sarclay target or 1409 without Sarclay target.
	my %detector = init_det();
	$detector{"name"}        = "beampipeUpstream";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Beampipe mother volume";
	$detector{"pos"}         = "0*cm 0*cm $shift*cm";
	$detector{"rotation"}    = "180*deg 0*deg 0*deg";
	$detector{"color"}       = "eeeeee";
	$detector{"type"}        = "Polycone";
	$detector{"dimensions"}  = "0*deg 360*deg 10*counts 0*mm 0*mm 0*mm 0*mm 0*mm 0*mm 0*mm 0*mm 0*mm 0*mm 51*mm 51*mm 102*mm 102*mm 152.5*mm 152.5*mm 128*mm 128*mm 152.5*mm 152.5*mm $START*mm 2051*mm 2199*mm 2590*mm 2590*mm 2668*mm 2668*mm 4329*mm 4329*mm 4349*mm";
	# $detector{"dimensions"}  = "0*deg 360*deg 2*counts 0*mm 0*mm 150*mm 150*mm 2250*mm 2300*mm";
	$detector{"material"}    = "G4_AIR";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

}

sub build_pipe()
{
	my %detector = init_det();
# centeringring
	$detector{"name"}        = "centeringring";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "centeringring";
	$detector{"color"}       = "eecc55";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 13*mm 13*mm 30*mm 30*mm 1547.88*mm 1559.88*mm";
	$detector{"material"}    = "G10";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# condenser
	$detector{"name"}        = "condenser";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Condenser";
	$detector{"color"}       = "cc5500";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 4*counts 34.8806*mm 34.8806*mm 34.8806*mm 35.8771*mm 67.9999*mm 69.8815*mm 69.8815*mm 68.9999*mm 2259.19*mm 2261.19*mm 2340.19*mm 2341.19*mm";
	$detector{"material"}    = "G4_Cu";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# build_condenserpipe_001
	$detector{"name"}        = "condenserpipe001";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Condenser piping attached to cell adapter 001";
	$detector{"color"}       = "777777";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "23*mm -40*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 6*counts 8.524*mm 8.524*mm 3.9687*mm 3.9687*mm 3.9687*mm 3.9687*mm 10.9855*mm 10.9855*mm 10.9855*mm 10.9855*mm 5*mm 5*mm 2239.69*mm 2243.78*mm 2243.78*mm 2250.74*mm 2250.74*mm 2259.19*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_condenserpipe_002
	$detector{"name"}        = "condenserpipe002";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Condenser piping attached to cell adapter 002";
	$detector{"color"}       = "777777";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "-46*mm 0*mm 0*mm";  # (55.0958-37.4042)/2 = 8.8458   (54.4522-38.0478)/2 = 8.2022
	$detector{"rotation"}    = "0*deg 0*deg 0*deg"; # (8.8458+8.2022)/2 = 8.524
	$detector{"dimensions"}  = "0*deg 360*deg 6*counts 8.524*mm 8.524*mm 3.9687*mm 3.9687*mm 3.9687*mm 3.9687*mm 10.9855*mm 10.9855*mm 10.9855*mm 10.9855*mm 5*mm 5*mm 2239.69*mm 2243.78*mm 2243.78*mm 2250.74*mm 2250.74*mm 2259.19*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_condenserpipe_003
	$detector{"name"}        = "condenserpipe003";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Condenser piping attached to cell adapter 003";
	$detector{"color"}       = "777777";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "23*mm 40*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 6*counts 8.524*mm 8.524*mm 3.9687*mm 3.9687*mm 3.9687*mm 3.9687*mm 10.9855*mm 10.9855*mm 10.9855*mm 10.9855*mm 5*mm 5*mm 2239.69*mm 2243.78*mm 2243.78*mm 2250.74*mm 2250.74*mm 2259.19*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# cryotube
	$detector{"name"}        = "cryotube";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Cryotube";
	$detector{"color"}       = "aaaaaa";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 6*counts 123.825*mm 123.825*mm 123.825*mm 123.825*mm 123.825*mm 123.825*mm 152.4*mm 152.4*mm 127*mm 127*mm 152.4*mm 152.4*mm 2648.71*mm 2667.76*mm 2667.76*mm 4329.69*mm 4329.69*mm 4348.74*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_distributiontube001_1
	$detector{"name"}        = "distributiontube001_1";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Distribution tube 001";
	$detector{"color"}       = "aaaaaa";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"rotation"}    = "-0.62*deg -0.36*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 4.049*mm 4.049*mm 4.762*mm 4.762*mm 1560.5*mm 2115.9*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_distributiontube001_2
	$detector{"name"}        = "distributiontube001_2";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Distribution tube 001";
	$detector{"color"}       = "aaaaaa";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "-355*mm 588*mm 129*mm";
	$detector{"rotation"}    = "-17*deg -10*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 4.049*mm 4.049*mm 4.762*mm 4.762*mm 2123.81*mm 2169.74*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_distributiontube001_3
	$detector{"name"}        = "distributiontube001_3";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Distribution Tube 001";
	$detector{"color"}       = "aaaaaa";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "23*mm -40*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 4.049*mm 4.049*mm 4.762*mm 4.762*mm 2177.95*mm 2214.32*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_celladapter001_1
	$detector{"name"}        = "celladapter001_1";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Cell adapter 001";
	$detector{"color"}       = "777777";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "23*mm -40*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 4.8625*mm 4.8625*mm 5.7785*mm 5.7785*mm 2190.76*mm 2214.32*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_celladapter001_2
	$detector{"name"}        = "celladapter001_2";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Cell adapter 001";
	$detector{"color"}       = "999999";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "23*mm -40*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 6*counts 4.8625*mm 4.8625*mm 4.1275*mm 4.1257*mm 4.1275*mm 4.1275*mm 5.7785*mm 5.7785*mm 5.7785*mm 5.7785*mm 7.0445*mm 7.0445*mm 2217.32*mm 2235.7*mm 2235.7*mm 2241.56*mm 2241.56*mm 2243.7*mm";
	$detector{"material"}    = "G4_Al"; #                                                                                                                                                                                           2244.1
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_celladapter001_nut
	$detector{"name"}        = "celladapter001_nut";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Cell adapter 001 nut";
	$detector{"color"}       = "777777";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "23*mm -40*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 7*counts 6.408*mm 6.408*mm 6.408*mm 6.408*mm 6.408*mm 7.4779*mm 7.4779*mm 8.249*mm 8.249*mm 8.1727*mm 8.1727*mm 8.2022*mm 8.2022*mm 8.2022*mm 2232.29*mm 2238.64*mm 2238.64*mm 2239.64*mm 2241.56*mm 2241.56*mm 2243.47*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);
##############################################################################---END_OF_001---

# build_distributiontube002_1
	$detector{"name"}        = "distributiontube002_1";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Distribution tube 002";
	$detector{"color"}       = "aaaaaa";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0.72*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 4.049*mm 4.049*mm 4.762*mm 4.762*mm 1560.5*mm 2115.9*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_distributiontube002_2
	$detector{"name"}        = "distributiontube002_2";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Distribution tube 002";
	$detector{"color"}       = "aaaaaa";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "698*mm 0*mm 130*mm";
	$detector{"rotation"}    = "0*deg 20.0*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 4.049*mm 4.049*mm 4.762*mm 4.762*mm 2123.81*mm 2169.74*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_distributiontube002_3
	$detector{"name"}        = "distributiontube002_3";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Distribution tube 002";
	$detector{"color"}       = "aaaaaa";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "-46*mm 0*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 4.049*mm 4.049*mm 4.762*mm 4.762*mm 2177.95*mm 2214.32*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_celladapter002_1
	$detector{"name"}        = "celladapter002_1";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Cell adapter 002";
	$detector{"color"}       = "999999";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "-46*mm 0*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 4.8625*mm 4.8625*mm 5.7785*mm 5.7785*mm 2190.76*mm 2214.32*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_celladapter002_2
	$detector{"name"}        = "celladapter002_2";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Cell adapter 002";
	$detector{"color"}       = "999999";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "-46*mm 0*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 6*counts 4.8625*mm 4.8625*mm 4.1275*mm 4.1257*mm 4.1275*mm 4.1275*mm 5.7785*mm 5.7785*mm 5.7785*mm 5.7785*mm 7.0445*mm 7.0445*mm 2217.32*mm 2235.7*mm 2235.7*mm 2241.56*mm 2241.56*mm 2243.7*mm";
	$detector{"material"}    = "G4_Al"; #                                                                                                                                                                                           2244.1
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_celladapter002_nut
	$detector{"name"}        = "celladapter002_nut";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Cell adapter 002 nut";
	$detector{"color"}       = "777777";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "-46*mm 0*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 7*counts 6.408*mm 6.408*mm 6.408*mm 6.408*mm 6.408*mm 7.4779*mm 7.4779*mm 8.249*mm 8.249*mm 8.1727*mm 8.1727*mm 8.2022*mm 8.2022*mm 8.2022*mm 2232.29*mm 2238.64*mm 2238.64*mm 2239.64*mm 2241.56*mm 2241.56*mm 2243.47*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);
##############################################################################---END_OF_002---

##############################################################################---START_OF_003---

# build_distributiontube003_1
	$detector{"name"}        = "distributiontube003_1";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Distribution tube 003";
	$detector{"color"}       = "aaaaaa";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"rotation"}    = "0.62*deg -0.36*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 4.049*mm 4.049*mm 4.762*mm 4.762*mm 1560.5*mm 2115.9*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_distributiontube003_2
	$detector{"name"}        = "distributiontube003_2";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Distribution tube 003";
	$detector{"color"}       = "aaaaaa";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "-355*mm -588*mm 129*mm";
	$detector{"rotation"}    = "17*deg -10*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 4.049*mm 4.049*mm 4.762*mm 4.762*mm 2123.81*mm 2169.74*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_distributiontube003_3
	$detector{"name"}        = "distributiontube003_3";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Distribution Tube 003";
	$detector{"color"}       = "aaaaaa";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "23*mm 40*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 4.049*mm 4.049*mm 4.762*mm 4.762*mm 2177.95*mm 2214.32*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_celladapter003_1
	$detector{"name"}        = "celladapter003_1";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Cell adapter 003";
	$detector{"color"}       = "777777";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "23*mm 40*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 4.8625*mm 4.8625*mm 5.7785*mm 5.7785*mm 2190.76*mm 2214.32*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_celladapter003_2
	$detector{"name"}        = "celladapter003_2";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Cell adapter 003";
	$detector{"color"}       = "999999";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "23*mm 40*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 6*counts 4.8625*mm 4.8625*mm 4.1275*mm 4.1257*mm 4.1275*mm 4.1275*mm 5.7785*mm 5.7785*mm 5.7785*mm 5.7785*mm 7.0445*mm 7.0445*mm 2217.32*mm 2235.7*mm 2235.7*mm 2241.56*mm 2241.56*mm 2243.7*mm";
	$detector{"material"}    = "G4_Al"; #                                                                                                                                                                                           2244.1
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_celladapter003_nut
	$detector{"name"}        = "celladapter003_nut";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Cell adapter 003 nut";
	$detector{"color"}       = "777777";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "23*mm 40*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 7*counts 6.408*mm 6.408*mm 6.408*mm 6.408*mm 6.408*mm 7.4779*mm 7.4779*mm 8.249*mm 8.249*mm 8.1727*mm 8.1727*mm 8.2022*mm 8.2022*mm 8.2022*mm 2232.29*mm 2238.64*mm 2238.64*mm 2239.64*mm 2241.56*mm 2241.56*mm 2243.47*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);
##############################################################################---END_OF_003---

# extensiontube
	$detector{"name"}        = "extensiontube";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Extension Tube";
	$detector{"color"}       = "aaaaaa"; #00aaaa
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 49.2*mm 49.2*mm 50.8*mm 50.8*mm 1409.33*mm 2058.92*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# flange
	$detector{"name"}        = "flange";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Flange";
	$detector{"color"}       = "aaaaaa"; #aa00aa
	$detector{"type"}        = "Tube";
	$detector{"pos"}         = "0*mm 0*mm 2250.11*mm";
	$detector{"dimensions"}  = "85.03*mm 87.37*mm 26*mm 0*deg 360*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# flangespacer
	$detector{"name"}        = "flangespacer";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Flange Spacer";
	$detector{"color"}       = "aaaaaa"; #aaaa00
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 6*counts 118.5*mm 118.5*mm 118.5*mm 118.5*mm 123.5*mm 123.5*mm 123.5*mm 123.5*mm 152.5*mm 152.5*mm 152.5*mm 152.5*mm 2609.08*mm 2609.08*mm 2609.08*mm 2644.61*mm 2644.61*mm 2648.71*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# flangetube
	$detector{"name"}        = "flangetube";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Flangetube";
	$detector{"color"}       = "aaaaaa"; #0000aa
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 9*counts 98.4*mm 98.4*mm 98.4*mm 98.4*mm 98.4*mm 123.2*mm 124*mm 124*mm 124*mm 101.6*mm 101.6*mm 151.499*mm 152.4*mm 152.4*mm 152.4*mm 152.4*mm 152.4*mm 151.499*mm 2206.53*mm 2591.03*mm 2591.03*mm 2591.93*mm 2604.93*mm 2604.93*mm 2607.93*mm 2608.13*mm 2609.03*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# manifoldsupportring
	$detector{"name"}        = "manifoldsupportring";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Manifold Support Ring";
	$detector{"color"}       = "aaaaaa"; #00aa00
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 36.9336*mm 36.9336*mm 52.9276*mm 52.9276*mm 2214.32*mm 2217.32*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# solid024
	$detector{"name"}        = "solid024";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Solid 024";
	$detector{"color"}       = "aaaaaa"; #aa0000
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 8*counts 72*mm 72*mm 80.8926*mm 80.8926*mm 80.8926*mm 80.8926*mm 80.8926*mm 80.8926*mm 85*mm 85*mm 85*mm 85*mm 107.5*mm 107.5*mm 103.5*mm 103.5*mm 2238.61*mm 2248.61*mm 2248.61*mm 2638.61*mm 2638.61*mm 2644.61*mm 2644.61*mm 2648.61*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# reducer
	$detector{"name"}        = "reducer";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Reducer";
	$detector{"color"}       = "777777"; #770000
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 50.8*mm 98.4*mm 50.85*mm 101.6*mm 2051.28*mm 2199.89*mm";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# reduceradapter
	$detector{"name"}        = "reduceradapter";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "reducer adaptor";
	$detector{"color"}       = "aaaaaa"; #007700aaaaaa
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 3*counts 71*mm 75*mm 75*mm 71.4*mm 76*mm 76*mm 2180.11*mm 2184.88*mm 2236.11*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# reduceradapter001
# build_reduceradapter001_1
	$detector{"name"}        = "reduceradapter001_1";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "reducer adaptor001_1";
	$detector{"color"}       = "aaaaaa"; #000077aaaaaa
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 4*counts 100.437*mm 100.437*mm 98.2356*mm 98.2356*mm 101.6*mm 101.6*mm 101.6*mm 101.6*mm 2199.89*mm 2203.53*mm 2203.53*mm 2206.53*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# build_reduceradapter001_2
	$detector{"name"}        = "reduceradapter001_2";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "reducer adaptor001_2";
	$detector{"color"}       = "aaaaaa"; #777700aaaaaa
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 4*counts 95.375*mm 95.375*mm 95.375*mm 95.375*mm 95.375*mm 98.1951*mm 98.2356*mm 98.2356*mm 2194.65*mm 2203.53*mm 2203.53*mm 2218.65*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# solid019
	$detector{"name"}        = "solid019";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Solid019";
	$detector{"color"}       = "aaaaaa"; #770077
	$detector{"type"}        = "Tube";
	$detector{"pos"}         = "0*mm 0*mm 1760.09*mm";
	$detector{"dimensions"}  = "43*mm 44.5*mm 334*mm 0*deg 360*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

# solid020
	$detector{"name"}        = "solid020";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Solid020";
	$detector{"color"}       = "aaaaaa"; #007777
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 9*counts 44.5001*mm 44.5001*mm 44.5001*mm 43.001*mm 60.3552*mm 61.2885*mm 62.867*mm 64.097*mm 64.097*mm 45.4971*mm 47.5761*mm 48.8206*mm 48.8206*mm 67.2017*mm 68.0602*mm 69.7701*mm 69.7701*mm 69.7701*mm 2094.41*mm 2102.6*mm 2106.42*mm 2106.42*mm 2162.82*mm 2165.85*mm 2173.46*mm 2184.53*mm 2192.84*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 0;
	print_det(\%configuration, \%detector);

}

sub build_sarclay()
{
# 50micron [target]
	my %detector = init_det();
	$detector{"name"}        = "50micron";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "50 micron Al foil on Solid022";
	$detector{"color"}       = "aaaaaa";
	$detector{"type"}        = "Tube";
	$detector{"pos"}         = "0*mm 0*mm 1017.245*mm";
	$detector{"dimensions"}  = "0*mm 19.5*mm 25*um 0*deg 360*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# basecone [target]
	$detector{"name"}        = "basecone";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Base cone";
	$detector{"color"}       = "eecc55";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 9*counts 11.822*mm 11.822*mm 11.6603*mm 11.6603*mm 22.6297*mm 22.6297*mm 22.6297*mm 25.25*mm 25.25*mm 11.822*mm 13.272*mm 13.272*mm 14.098*mm 25.070*mm 26.75*mm 26.75*mm 26.75*mm 26.75*mm 1340.84*mm 1342.91*mm 1342.91*mm 1344.09*mm 1359.76*mm 1362.16*mm 1366.11*mm 1366.11*mm 1372.11*mm";
	$detector{"material"}    = "G10";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# build_cellwall [target]
	$detector{"name"}        = "cellwall";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Cell wall";
	$detector{"color"}       = "aa4400";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 7.49154*mm 11.7216*mm 7.54193*mm 11.7718*mm 1280.68*mm 1342.91*mm";
	$detector{"material"}    = "G4_KAPTON";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# cellendcap [target]
	$detector{"name"}        = "cellendcap";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Cell end cap";
	$detector{"color"}       = "aa4400";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 5*counts 5*mm 5*mm 7.4942*mm 7.59083*mm 7.86904*mm 5*mm 5.29445*mm 7.71148*mm 7.71575*mm 7.99374*mm 1279.1*mm 1279.24*mm 1280.62*mm 1280.68*mm 1284.68*mm";
	$detector{"material"}    = "G4_KAPTON";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# basering [target]
	$detector{"name"}        = "basering";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Base Ring";
	$detector{"color"}       = "eecc55";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 11*counts 22.6297*mm 22.6297*mm 22.6297*mm 22.6297*mm 22.6297*mm 22.6297*mm 7.75*mm 7.75*mm 8.8*mm 8.8*mm 8.8*mm 25.25*mm 25.25*mm 25.15*mm 25.15*mm 25.25*mm 25.25*mm 29.25*mm 29.25*mm 29.25*mm 29.25*mm 10.3049*mm 1366.11*mm 1367.11*mm 1367.11*mm 1371.11*mm 1371.11*mm 1376.98*mm 1376.98*mm 1388.51*mm 1388.51*mm 1389.26*mm 1389.51*mm";
	$detector{"material"}    = "G10";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# build_basering2 [target]
	$detector{"name"}        = "basering2";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Base Ring inner tube";
	$detector{"color"}       = "eecc55";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 7.75*mm 7.75*mm 8.70966*mm 8.70966*mm 1366.11*mm 1376.98*mm";
	$detector{"material"}    = "G10";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# basetube [target]
	$detector{"name"}        = "basetube";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Basetube";
	$detector{"color"}       = "ee3344";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 11*counts 7.6152*mm 5*mm 5*mm 6.025*mm 6.025*mm 6.025*mm 6.025*mm 6.025*mm 6.025*mm 6.025*mm 6.025*mm 7.75*mm 7.75*mm 7.75*mm 7.75*mm 7.75*mm 7.65*mm 7.65*mm 7.75*mm 7.75*mm 8.75*mm 8.75*mm 1325.85*mm 1327.32*mm 1327.91*mm 1327.91*mm 1368.11*mm 1368.11*mm 1387.51*mm 1387.51*mm 1388.51*mm 1388.51*mm 1389.51*mm";
	$detector{"material"}    = "G4_KAPTON";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# build_quartzglasstube [target]
	$detector{"name"}        = "quartzglasstube";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Quartz Glass Tube";
	$detector{"color"}       = "eeeeee";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 6*counts 5*mm 5*mm 5.0116*mm 5.0711*mm 5.21108*mm 6.8482*mm 6*mm 6*mm 6*mm 6.09046*mm 6.27450*mm 7.91237*mm 1349.75*mm 1390.03*mm 1390.21*mm 1390.72*mm 1391.23*mm 1395.73*mm";
	$detector{"material"}    = "G4_SILICON_DIOXIDE";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# forwardretainingring [target]
	$detector{"name"}        = "forwardretainingring";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "forwardretainingring";
	$detector{"color"}       = "eecc55";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 6.27451*mm 7.91238*mm 12*mm 12*mm 1391.23*mm 1395.73*mm";
	$detector{"material"}    = "G10";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# build_fibercollar [target]
	$detector{"name"}        = "fibercollar";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "fibercollar";
	$detector{"color"}       = "eecc55";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 6.00001*mm 6.00001*mm 12*mm 12*mm 1395.73*mm 1400.73*mm";
	$detector{"material"}    = "G10";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# solid022 [target]
	$detector{"name"}        = "solid022";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Solid022 minus face 2";
	$detector{"color"}       = "eecccc";
	$detector{"type"}        = "Sphere";
	$detector{"pos"}         = "0*mm 0*mm 1067.21*mm";
	$detector{"dimensions"}  = "39.6*mm 50*mm 0*deg 360*deg 90*deg 70*deg";
	$detector{"material"}    = "rohacell";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# build_solid022_1 [target]
	$detector{"name"}        = "solid022_1";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Solid022 face 7";
	$detector{"color"}       = "eecccc";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 4*counts 12.85*mm 12.85*mm 17.10*mm 26.31*mm 20.181*mm 21.7109*mm 21.7109*mm 26.31*mm 1017.27*mm 1020*mm 1020*mm 1024*mm";
	$detector{"material"}    = "rohacell";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# build_solid022_2 [target]
	$detector{"name"}        = "solid022_2";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Solid022 face 7 inside";
	$detector{"color"}       = "eecccc";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 12.85*mm 12.85*mm 17.0*mm 13.54*mm 1020.23*mm 1029.75*mm";
	$detector{"material"}    = "rohacell";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# solid023 [target]
	$detector{"name"}        = "solid023";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Solid023, Solid021, Solid022 face 2";
	$detector{"color"}       = "eecccc";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"dimensions"}  = "0*deg 360*deg 5*counts 39.6*mm 39.6*mm 39.6*mm 39.6*mm 43.1932*mm 50*mm 50*mm 49.11*mm 49.11*mm 49.11*mm 1067.21*mm 1409.31*mm 1409.31*mm 1413.67*mm 1419.71*mm";
	$detector{"material"}    = "rohacell";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# distributiontube001_0 [target]------------------------------------------FROM PIPE----------------------------------------------------------
	$detector{"name"}        = "distributiontube001_0";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Distribution tube 001";
	$detector{"color"}       = "aaaaaa";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"rotation"}    = "-0.62*deg -0.36*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 4.049*mm 4.049*mm 4.762*mm 4.762*mm 1390*mm 1547*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# distributiontube002_0 [target]
	$detector{"name"}        = "distributiontube002_0";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Distribution tube 002";
	$detector{"color"}       = "aaaaaa";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"rotation"}    = "0*deg 0.72*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 4.049*mm 4.049*mm 4.762*mm 4.762*mm 1390*mm 1547*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

# distributiontube003_0 [target]
	$detector{"name"}        = "distributiontube003_0";
	$detector{"mother"}      = "beampipeUpstream";
	$detector{"description"} = "Distribution tube 003";
	$detector{"color"}       = "aaaaaa";
	$detector{"type"}        = "Polycone";
	$detector{"pos"}         = "0*mm 0*mm 0*mm";
	$detector{"rotation"}    = "0.62*deg -0.36*deg 0*deg";
	$detector{"dimensions"}  = "0*deg 360*deg 2*counts 4.049*mm 4.049*mm 4.762*mm 4.762*mm 1390*mm 1547*mm";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);

}
