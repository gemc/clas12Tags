use strict;
use warnings;

our %configuration;
our %parameters;
our @nsegments;
our $nregions;

our $silicon_width;
our $epoxy_width;
our $bus_cable_width;
our $carbon_fiber_width;
our $microgap_width;
our $rohacell_width;
our $module_height;
our $pad_displacement;
our $pad_radius;
our $chip_displacement;

my @radius   = ( $parameters{"radius_r1"},
                 $parameters{"radius_r2"},
                 $parameters{"radius_r3"},
                 $parameters{"radius_r4"} );

my @starting_theta     = (180        , 180         , 180         , 180      );   # Starting angle of the first segment
my @dtheta             = (0        , 0         , 0         , 0      );   # Delta theta


# Starting theta 
for(my $i = 0; $i < $nregions; $i++)
{
	$dtheta[$i] = 360/$nsegments[$i];
}

# Sensitive Sandwich:
# Starts from the bottom silicon up to the top silicon
my @module_composition = ($silicon_width,
					      $epoxy_width,
					      $bus_cable_width,
					      $carbon_fiber_width,
					      $rohacell_width,
					      $carbon_fiber_width,
					      $bus_cable_width,
					      $epoxy_width,
					      $silicon_width);

# Return total number of layers
sub tot_nlayers
{
	return $#module_composition + 1;
}


# This routine will use place a volume
# in a layer specified by the first argument
# and at the position index specified by the second argument
# For example the silicon has the first position index
# see (@module_composition )
sub r_placement
{
	my $l  = shift;
	my $ml = shift;
	
	my $r = $radius[$l];
	
	for(my $z = 0; $z < $ml-1; $z++)
	{
		$r = $r + $module_composition[$z];
		if($ml>1)
		{
			$r = $r + $microgap_width;
		}
	}
	$r = $r + $module_composition[$ml-1]/2.0;

	return $r;
}



# placement of layers in the active zone
sub pos_t
{
	my $R = shift;
	my $l = shift;
	my $s = shift;
	
	my $theta     = 90 + $starting_theta[$l] + $s*$dtheta[$l] ;
	my $x         = sprintf("%.3f",$R*cos(rad($theta)));
	my $y         = sprintf("%.3f",$R*sin(rad($theta)));
	return "$x*mm $y*mm";
}


sub rot
{
	my $R = shift;
	my $l = shift;
	my $s = shift;
	
	my $theta_rot = $starting_theta[$l] - $s*$dtheta[$l];
	
	if($s == 199) {$theta_rot -= 7.5;}
	
	return "0*deg 0*deg $theta_rot*deg";
}


sub pos_t_epoxy
{
	my $R      = shift;
	my $l      = shift;
	my $s      = shift;
	my $updown = shift;  # 1 = bottom, 2 = top
	my $type   = shift;
	
	my $displacement = 0;
	if($type == 1)
	{
		if($updown == 1)
		{
			$displacement = ($module_height / 2 + $pad_displacement + $pad_radius)/2;
		}
		if($updown == 2)
		{
			$displacement = -($module_height / 2 - $pad_displacement + $pad_radius)/2;
		}
	}
	if($type == 2)
	{
		if($updown == 1)
		{
			$displacement = -($module_height / 2 - $pad_displacement + $pad_radius)/2;
		}
		if($updown == 2)
		{
			$displacement = ($module_height / 2 + $pad_displacement + $pad_radius)/2;
		}
	}
	
	
	my $dth = asind($displacement / $R);
	
	my $theta = 0;
	
	if($type == 1){ $theta     = 90 - $dth + $starting_theta[$l] + $s*$dtheta[$l] ; }
	if($type == 2){ $theta     = 90 + $dth + $starting_theta[$l] + $s*$dtheta[$l] ; }
	
	my $x         = sprintf("%.3f",$R*cos(rad($theta)));
	my $y         = sprintf("%.3f",$R*sin(rad($theta)));
	
	return "$x*mm $y*mm";
}



sub pos_t_pad
{
	my $R = shift;  # radius
	my $l = shift;  # layer
	my $t = shift;  # left / right
	my $s = shift;  # module number
	
	my $dth = asind($pad_displacement / $R);
	
	my $theta = 0;
	
	if($t == 1){ $theta     = 90 - $dth + $starting_theta[$l] + $s*$dtheta[$l] ; }
	if($t == 2){ $theta     = 90 + $dth + $starting_theta[$l] + $s*$dtheta[$l] ; }
	
	my $x         = sprintf("%.3f",$R*cos(rad($theta)));
	my $y         = sprintf("%.3f",$R*sin(rad($theta)));
	return "$x*mm $y*mm";
}



sub rot_pad
{
	my $R = shift;
	my $l = shift;
	my $s = shift;
	
	my $theta_rot = $starting_theta[$l] - $s*$dtheta[$l];
	#if($l == 2)  {$theta_rot -= 20;}
	if($s == 199) {$theta_rot -= 7.5;}
	
	$theta_rot = -$theta_rot;
	
	return "90*deg $theta_rot*deg 0*deg";
}



sub pos_t_chip
{
	my $R = shift;
	my $l = shift;
	my $t = shift;
	my $s = shift;
	
	my $dth = asind($chip_displacement / $R);
	
	my $theta = 0;
	
	if($t == 1){ $theta     = 90 - $dth + $starting_theta[$l] + $s*$dtheta[$l] ; }
	if($t == 2){ $theta     = 90 + $dth + $starting_theta[$l] + $s*$dtheta[$l] ; }
	
	my $x         = sprintf("%.3f",$R*cos(rad($theta)));
	my $y         = sprintf("%.3f",$R*sin(rad($theta)));
	return "$x*mm $y*mm";
}



