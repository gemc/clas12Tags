package coatjava;

use strict;
use warnings;

use geometry;

my $mothers;
my $positions;
my $rotations;
my $types;
my $dimensions;
my $ids;

sub make_region
{
	my $iregion = shift;
	my $region = $iregion + 1;
	my $nSectors = 6;

	for(my $s=1; $s<=$nSectors; $s++)
	{
		my %detector = init_det();
		my $vname = "region$region"."_s$s";

		$detector{"name"}        = $vname;
		$detector{"mother"}      = $mothers->{$vname};
		$detector{"description"} = "CLAS12 Drift Chambers, Sector $s Region $region";

		$detector{"pos"}            = $positions->{$vname};
		$detector{"rotation"}   = $rotations->{$vname};
		$detector{"type"}           = $types->{$vname};
		$detector{"dimensions"}  = $dimensions->{$vname};

		$detector{"color"}       = "aa0000";
		$detector{"material"}    = "dcgas";
		$detector{"visible"}     = 0;
		print_det(\%main::configuration, \%detector);
	}

}

# Layers
sub make_superlayers
{
	my $iregion = shift;
	my $region = $iregion + 1;
	
	my $superlayer_min = $region*2 - 1;
	my $superlayer_max = $region*2;
	
	for (my $isup = $superlayer_min; $isup < $superlayer_max+1 ; $isup++)
	{
                my $nSectors = 6;

                for(my $s=1; $s<=$nSectors; $s++)
                {
                        # names
                        my %detector = init_det();
                        my $vname = "sl$isup"."_s$s";

                        $detector{"name"}        = $vname;
                        $detector{"mother"}      = $mothers->{$vname};
                        $detector{"description"} = "Region $region, Super Layer $isup, Sector $s";

                        $detector{"pos"} = $positions->{$vname};
                        $detector{"rotation"} = $rotations->{$vname};
                        $detector{"type"} = $types->{$vname};
                        $detector{"dimensions"}  = $dimensions->{$vname};

                        $detector{"color"}       = "99aaff2";
                        $detector{"material"}    = "dcgas";
                        $detector{"style"}       = 1;
                        $detector{"sensitivity"} = "dc";
                        $detector{"hit_type"}    = "dc";
                        $detector{"identifiers"} = "sector manual $s superlayer manual $isup layer manual 1 wire manual 1";

                        print_det(\%main::configuration, \%detector);
                }
	}
}


sub makeDC
{
	($mothers, $positions, $rotations, $types, $dimensions, $ids) = @main::volumes;

	make_region(0);
	make_region(1);
	make_region(2);
		
	make_superlayers(0);
	make_superlayers(1);
	make_superlayers(2);
}

1;
