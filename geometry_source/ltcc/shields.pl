
our $startS;
our $endS;
our $startN;
our $endN;

our @rga_spring2018_sectorsPresence;
our @rga_spring2018_materials;

our @rga_fall2018_sectorsPresence;
our @rga_fall2018_materials;

our @rgb_winter2020_sectorsPresence;
our @rgb_winter2020_materials;

our @rgb_spring2019_sectorsPresence;
our @rgb_spring2019_materials;

our @rgm_winter2021_sectorsPresence;
our @rgm_winter2021_materials;

# number of mirrors
my $nmirrors = $parameters{"nmirrors"} ;

my @tilt = (); # Tilt angle of the PMT in the segment ref. system
my @shield_x0 = (); # shield dimensions
my @shield_y0 = ();
my @shield_z0 = ();
my @sub_shield_x0 = (); # dimensions of the shield which will be subtracted
my @sub_shield_y0 = ();
my @sub_shield_z0 = ();
my @shield_tilt = (); #Tilt angle of the shield
my @segphi = (); # required rotation about x axis for pmts, pmts stoppers and shields
my @shield_pos_xR = (); # positions of the shields in sectors (R=right L=left)
my @shield_pos_yR = ();
my @shield_pos_zR = ();
my @shield_pos_xL = ();
my @shield_pos_yL = ();
my @shield_pos_zL = ();

sub buildShields
{
	calculateShieldPars();
	build_shields();
}

sub calculateShieldPars
{
	for(my $n=0; $n<$nmirrors ; $n++)
	{
		my $s = $n + 1;

		$tilt[$n] = $parameters{"ltcc.wc.s$s"."_angle"};
		$shield_x0[$n] = $parameters{"ltcc.shield.s$s"."_dx"};
		$shield_y0[$n] = $parameters{"ltcc.shield.s$s"."_dy"};
		$shield_z0[$n] = $parameters{"ltcc.shield.s$s"."_dz"};
		$shield_pos_xR[$n] = $parameters{"ltcc.shield.s$s"."_xR"};
		$shield_pos_yR[$n] = $parameters{"ltcc.shield.s$s"."_yR"};
		$shield_pos_zR[$n] = $parameters{"ltcc.shield.s$s"."_zR"};
		$shield_pos_xL[$n] = $parameters{"ltcc.shield.s$s"."_xL"};
		$shield_pos_yL[$n] = $parameters{"ltcc.shield.s$s"."_yL"};
		$shield_pos_zL[$n] = $parameters{"ltcc.shield.s$s"."_zL"};
		$shield_tilt[$n] =$parameters{"ltcc.shield.s$s"."_zangle"};
		# 90 - theta of center of ltcc. segment
		$segtheta[$n] = 90 - $parameters{"ltcc.s$s"."_theta"};

		# phi rotation angle for pmts, pmt stoppers and shield in sectors ! (calculated using their phi rotation angles in segments)
		$segphi[$n] = 90 - $segtheta[$n]; #rotation of pmts in sector

		# To make shields with 5 mm thickness, the boxes with 1 mm smaller are subtracted from the original ones (G4 Box is used)
		$sub_shield_x0[$n] = $shield_x0[$n] - 0.5;
		$sub_shield_y0[$n] = $shield_y0[$n] - 0.5;
		$sub_shield_z0[$n] = $shield_z0[$n] + 0.5;

	}

}


sub build_shields
{

	for(my $n=$startN; $n<=$endN; $n++)
	{
		for(my $s=$startS; $s<=$endS; $s++)
		{

			# Shield dimensions were determined in a way that shields cover the outer face of the WC

			# Shield dimensions are not real dimension. Their sizes are decreased to avoid overlaps with other geometries and neighbor shields

			my $shouldPrintDetector = 0;

			if($configuration{"variation"} eq "rga_spring2018") {
				if($rga_spring2018_sectorsPresence[$s - 1] == 1) {
					$shouldPrintDetector = 1;
				}
			} elsif($configuration{"variation"} eq "rga_fall2018") {
				if($rga_fall2018_sectorsPresence[$s - 1] == 1) {
					$shouldPrintDetector = 1;
				}
			} elsif($configuration{"variation"} eq "rgb_winter2020") {
				if($rgb_winter2020_sectorsPresence[$s - 1] == 1) {
					$shouldPrintDetector = 1;

				}
			} elsif($configuration{"variation"} eq "rgb_spring2019" || $configuration{"variation"} eq "default") {
				if($rgb_spring2019_sectorsPresence[$s - 1] == 1) {
					$shouldPrintDetector = 1;
				}
			} elsif($configuration{"variation"} eq "rgm_winter2021" ) {
				if($rgm_winter2021_sectorsPresence[$s - 1] == 1) {
					$shouldPrintDetector = 1;
				}
			}

			if($shouldPrintDetector == 1) {

				if($n < $endN){

					my %detector = init_det();
					$detector{"name"}        = "shield_s$s"."right_$n";
					$detector{"mother"}      = "ltccS$s";
					$detector{"description"} = "shield right $n";
					$detector{"pos"}         = "0*cm 0*cm 0*cm";
					$detector{"rotation"}    = "0*deg 0*deg 0*deg";
					$detector{"color"}       = "000000";
					$detector{"type"}        = "Box";
					$detector{"dimensions"}  = "$shield_x0[$n-1]*cm $shield_y0[$n-1]*cm $shield_z0[$n-1]*cm";
					$detector{"material"}    = "Component";
					print_det(\%configuration, \%detector);

					%detector = init_det();
					$detector{"name"}        = "subtraction_shield_s$s"."right_$n";
					$detector{"mother"}      = "ltccS$s";
					$detector{"description"} = "Subtraction shield right $n";
					$detector{"pos"}         = "0*cm 0*cm 0*cm";
					$detector{"rotation"}    = "0*deg 0*deg 0*deg";
					$detector{"color"}       = "000000";
					$detector{"type"}        = "Box";
					$detector{"dimensions"}  = "$sub_shield_x0[$n-1]*cm $sub_shield_y0[$n-1]*cm $sub_shield_z0[$n-1]*cm";
					$detector{"material"} = "Component";
					print_det(\%configuration, \%detector);

					%detector = init_det();
					$detector{"name"}        = "final_shield_s$s"."right$n";
					$detector{"mother"}      = "ltccS$s";
					$detector{"description"} = "combined shield right $n";
					$detector{"pos"}         = "$shield_pos_xR[$n-1]*cm $shield_pos_yR[$n-1]*cm $shield_pos_zR[$n-1]*cm";
					$detector{"rotation"}    = "$segphi[$n-1]*deg -$tilt[$n-1]*deg $shield_tilt[$n-1]*deg";
					$detector{"color"}       = "202020";
					$detector{"type"}        = "Operation:  shield_s$s"."right_$n - subtraction_shield_s$s"."right_$n";
					$detector{"material"}    = "G4_Fe";
					$detector{"style"}       = 1;
					print_det(\%configuration, \%detector);


					%detector = init_det();
					$detector{"name"}        = "shield_s$s"."left_$n";
					$detector{"mother"}      = "ltccS$s";
					$detector{"description"} = "shield left $n";
					$detector{"pos"}         = "0*cm 0*cm 0*cm";
					$detector{"rotation"}    = "0*deg 0*deg 0*deg";
					$detector{"color"}       = "000000";
					$detector{"type"}        = "Box";
					$detector{"dimensions"}  = "$shield_x0[$n-1]*cm $shield_y0[$n-1]*cm $shield_z0[$n-1]*cm";
					$detector{"material"}    = "Component";
					print_det(\%configuration, \%detector);

					%detector = init_det();
					$detector{"name"}        = "subtraction_shield_s$s"."left_$n";
					$detector{"mother"}      = "ltccS$s";
					$detector{"description"} = "Subtraction shield left $n";
					$detector{"pos"}         = "0*cm 0*cm 0*cm";
					$detector{"rotation"}    = "0*deg 0*deg 0*deg";
					$detector{"color"}       = "000000";
					$detector{"type"}        = "Box";
					$detector{"dimensions"}  = "$sub_shield_x0[$n-1]*cm $sub_shield_y0[$n-1]*cm $sub_shield_z0[$n-1]*cm";
					$detector{"material"}    = "Component";
					print_det(\%configuration, \%detector);



					%detector = init_det();
					$detector{"name"}        = "final_shield_s$s"."left_$n";
					$detector{"mother"}      = "ltccS$s";
					$detector{"description"} = "combined shield left $n";
					$detector{"pos"}         = "$shield_pos_xL[$n-1]*cm $shield_pos_yL[$n-1]*cm $shield_pos_zL[$n-1]*cm";
					$detector{"rotation"}    = "$segphi[$n-1]*deg $tilt[$n-1]*deg -$shield_tilt[$n-1]*deg";
					$detector{"color"}       = "202020";
					$detector{"type"}        = "Operation:  shield_s$s"."left_$n - subtraction_shield_s$s"."left_$n";
					$detector{"material"}    = "G4_Fe";
					$detector{"style"}       = 1;
					print_det(\%configuration, \%detector);

				}
			}

		}

	}
}

1;
