use strict;
use warnings;

our %parameters;

# FTOF parameters
# all dimensions are in inches

our $mothergap  = 4.0/25.4;   # Gap between panels mother volumes and daughters

# panel 1a
my @panel1a_xpos  ;
my @panel1a_zpos  ;
my @panel1a_leng  ;
my $panel1a_n = $parameters{"ftof.panel1A.ncounters"};
my $panel1a_w = $parameters{"ftof.panel1A.paddle.w"};
my $panel1a_h = $parameters{"ftof.panel1A.paddle.h"};

my $tilt_p1a;   # tilt angle in degrees
my $panel1a_dz;

# panel 1b
my @panel1b_xpos  ;
my @panel1b_zpos  ;
my @panel1b_leng  ;
my $panel1b_n = $parameters{"ftof.panel1B.ncounters"};
my $panel1b_w = $parameters{"ftof.panel1B.paddle.w"};
my $panel1b_h = $parameters{"ftof.panel1B.paddle.h"};

my $tilt_p1b;   # tilt angle in degrees
my $panel1b_dz;


# panel 2
my @panel2_xpos  ;
my @panel2_zpos  ;
my @panel2_leng  ;
my $panel2_n = $parameters{"ftof.panel2.ncounters"};
my $panel2_w = $parameters{"ftof.panel2.paddle.w"};
my $panel2_h = $parameters{"ftof.panel2.paddle.h"};

my $tilt_p2;   # tilt angle in degrees
my $panel2_dz;



# calculate paddles position, dimensions, titles based on parameters
sub calculate_ftof_parameters
{
	# panel 1A
	my $p1a_x_p0 = $parameters{"ftof.panel1A.x.p0"};
	my $p1a_x_p1 = $parameters{"ftof.panel1A.x.p1"};
	my $p1a_z_p0 = $parameters{"ftof.panel1A.z.p0"};
	my $p1a_z_p1 = $parameters{"ftof.panel1A.z.p1"};
	
	for(my $p=1; $p<=$panel1a_n; $p++)
	{
		push(@panel1a_xpos, $p1a_x_p0 + $p1a_x_p1*$p);
		push(@panel1a_zpos, $p1a_z_p0 + $p1a_z_p1*$p);
		push(@panel1a_leng, $parameters{"ftof.panel1A.l.p".$p}/2.54);  # the lengths are stored in cm
		
	}
	
	$tilt_p1a = 90.0 - atan( ($panel1a_xpos[-1] - $panel1a_xpos[0])/($panel1a_zpos[0] - $panel1a_zpos[-1])  )*180.0/$pi;
	
	# this is the distance of the middle of the panel to the target
	$panel1a_dz = sqrt( sq($panel1a_zpos[0] - $panel1a_zpos[-1]) + sq($panel1a_xpos[-1] - $panel1a_xpos[0]) )/2.0  ;
	
      
	# panel 1B
	my $p1b_x_p0 = $parameters{"ftof.panel1B.x.p0"};
	my $p1b_x_p1 = $parameters{"ftof.panel1B.x.p1"};
	my $p1b_z_p0 = $parameters{"ftof.panel1B.z.p0"};
	my $p1b_z_p1 = $parameters{"ftof.panel1B.z.p1"};
	my $p1b_l_p0 = $parameters{"ftof.panel1B.l.p0"};
	my $p1b_l_p1 = $parameters{"ftof.panel1B.l.p1"};
	
	for(my $p=1; $p<=$panel1b_n; $p++)
	{
		push(@panel1b_xpos, $p1b_x_p0 + $p1b_x_p1*$p);
		push(@panel1b_zpos, $p1b_z_p0 + $p1b_z_p1*$p);
		push(@panel1b_leng, $p1b_l_p0/2.54 + $p1b_l_p1*$p/2.54);  # the lengths are stored in cm
	}
	
	$tilt_p1b = 90.0 - atan( ($panel1b_xpos[-1] - $panel1b_xpos[0])/($panel1b_zpos[0] - $panel1b_zpos[-1])  )*180.0/$pi;
	$panel1b_dz = sqrt( sq($panel1b_zpos[0] - $panel1b_zpos[-1]) + sq($panel1b_xpos[-1] - $panel1b_xpos[0]) )/2.0  ;
	
	
	# panel 2
	my $p2_x_p0 = $parameters{"ftof.panel2.x.p0"};
	my $p2_x_p1 = $parameters{"ftof.panel2.x.p1"};
	my $p2_z_p0 = $parameters{"ftof.panel2.z.p0"};
	my $p2_z_p1 = $parameters{"ftof.panel2.z.p1"};
	my $p2_l_p0 = $parameters{"ftof.panel2.l.p0"};
	my $p2_l_p1 = $parameters{"ftof.panel2.l.p1"};
	
	for(my $p=1; $p<=$panel2_n; $p++)
	{
		push(@panel2_xpos, $p2_x_p0 + $p2_x_p1*$p);
		push(@panel2_zpos, $p2_z_p0 + $p2_z_p1*$p);
		push(@panel2_leng, $p2_l_p0/2.54 + $p2_l_p1*$p/2.54);  # the lengths are stored in cm
	}
	
	$tilt_p2 = 90.0 - atan( ($panel2_xpos[-1] - $panel2_xpos[0])/($panel2_zpos[0] - $panel2_zpos[-1])  )*180.0/$pi;
	$panel2_dz = sqrt( sq($panel2_zpos[0] - $panel2_zpos[-1]) + sq($panel2_xpos[-1] - $panel2_xpos[0]) )/2.0 ;

}



# z is in the direction of paddle number
#
#  z ^ 
#    | /y
#    |/
#    ----> x
#
#
#
# -----------------------
#  \                   /
#   \                 /
#    \               /  dz
#     \             /
#      \-----------/
#           dx




sub panel_1a_pos
{
	my $sector = shift;
	
	# projection into the xy plane
	my $panel1a_pos_xy = fstr($panel1a_xpos[0] + $panel1a_dz*cos(rad($tilt_p1a)));
	my $phi = ($sector - 1)*60;
	my $x = fstr($panel1a_pos_xy*cos(rad($phi)));
	my $y = fstr($panel1a_pos_xy*sin(rad($phi)));
	
	my $panel1a_pos_z = fstr($panel1a_zpos[0] - $panel1a_dz*sin(rad($tilt_p1a)));
	
	return "$x*inches $y*inches $panel1a_pos_z*inches";
}

sub panel_1a_rot
{
	my $sector = shift;
	
	my $tilt  = fstr(-90 - $tilt_p1a);
	my $zrot  = -($sector-1)*60 - 90;
	
	return "ordered: zxy $zrot*deg $tilt*deg 0*deg ";
}

sub panel_1a_dims
{
	my $panel1a_mother_dx1 = fstr($panel1a_leng[1]/2.0  + $mothergap);
	my $panel1a_mother_dx2 = $panel1a_leng[-1]/2.0 + ($panel1a_leng[-1] - $panel1a_leng[-2])/2.0 + $mothergap;
	my $panel1a_mother_dy  = fstr($panel1a_w/2.0 + $mothergap);
	my $panel1a_mother_dz  = fstr($panel1a_dz + $panel1a_h/2.0 + $mothergap) ;
	
	return "$panel1a_mother_dx1*inches $panel1a_mother_dx2*inches $panel1a_mother_dy*inches $panel1a_mother_dy*inches $panel1a_mother_dz*inches";
}

sub panel_1a_counter_pos
{
	my $n    = shift;
	my $zpos = fstr(sqrt( sq($panel1a_xpos[$n-1] - $panel1a_xpos[0]) + sq($panel1a_zpos[0] - $panel1a_zpos[$n-1]) ) - $panel1a_dz) ;
	return "0*cm 0*mm $zpos*inches";
}

sub panel_1a_counter_dims
{
	my $n    = shift;
	
	my $length = $panel1a_leng[$n-1]/2.0;
	my $height = $panel1a_h/2.0;
	my $width  = $panel1a_w/2.0;
	
	return "$length*inches $width*inches $height*inches";
}

sub panel_1b_counter_pos
{
	my $n    = shift;
	my $zpos = fstr(sqrt( sq($panel1b_xpos[$n-1] - $panel1b_xpos[0]) + sq($panel1b_zpos[0] - $panel1b_zpos[$n-1]) ) - $panel1b_dz) ;
	return "0*cm 0*mm $zpos*inches";
}

sub panel_1b_counter_dims
{
	my $n    = shift;
	
	my $length = $panel1b_leng[$n-1]/2.0;
	my $height = $panel1b_h/2.0;
	my $width  = $panel1b_w/2.0;
	
	return "$length*inches $width*inches $height*inches";
}


sub panel_1b_pos
{
	my $sector = shift;

	# projection into the xy plane
	my $panel1b_pos_xy = $panel1b_xpos[0] + $panel1b_dz*cos(rad($tilt_p1b));
	my $phi = ($sector - 1)*60;
	my $x = fstr($panel1b_pos_xy*cos(rad($phi)));
	my $y = fstr($panel1b_pos_xy*sin(rad($phi)));
	
	my $panel1b_pos_z = fstr($panel1b_zpos[0] - $panel1b_dz*sin(rad($tilt_p1b)));
	
	return "$x*inches $y*inches $panel1b_pos_z*inches";

}

sub panel_1b_rot
{
	my $sector = shift;
	
	my $tilt  = fstr(-90 - $tilt_p1b);
	my $zrot  = -($sector-1)*60 - 90;
	
	return "ordered: zxy $zrot*deg $tilt*deg 0*deg ";
}

sub panel_1b_dims
{
	my $panel1b_mother_dx1 = fstr($panel1b_leng[1]/2.0  + $mothergap);
	my $panel1b_mother_dx2 = $panel1b_leng[-1]/2.0 + ($panel1b_leng[-1] - $panel1b_leng[-2])/2.0 + $mothergap;
	my $panel1b_mother_dy  = fstr($panel1b_w/2.0 + $mothergap) + 1.026;
	my $panel1b_mother_dz  = fstr($panel1b_dz + $panel1b_h/2.0 + $mothergap) ;
	
	return "$panel1b_mother_dx1*inches $panel1b_mother_dx2*inches $panel1b_mother_dy*inches $panel1b_mother_dy*inches $panel1b_mother_dz*inches";
}


sub panel_2_pos
{
	my $sector = shift;
	
	# projection into the xy plane
	my $panel2_pos_xy = $panel2_xpos[0] + $panel2_dz*cos(rad($tilt_p2));
	my $phi = ($sector - 1)*60;
	my $x = fstr($panel2_pos_xy*cos(rad($phi)));
	my $y = fstr($panel2_pos_xy*sin(rad($phi)));
	
	my $panel2_pos_z = fstr($panel2_zpos[0] - $panel2_dz*sin(rad($tilt_p2)));
	
	return "$x*inches $y*inches $panel2_pos_z*inches";
	
}

sub panel_2_rot
{
	my $sector = shift;
	
	my $tilt  = fstr(-90 - $tilt_p2);
	my $zrot  = -($sector-1)*60 - 90;
	
	return "ordered: zxy $zrot*deg $tilt*deg 0*deg ";
}

sub panel_2_dims
{
	my $panel2_mother_dx1 = fstr($panel2_leng[1]/2.0  + $mothergap);
	my $panel2_mother_dx2 = $panel2_leng[-1]/2.0 + ($panel2_leng[-1] - $panel2_leng[-2])/2.0 + $mothergap;
	my $panel2_mother_dy  = fstr($panel2_w/2.0 + $mothergap);
	my $panel2_mother_dz  = fstr($panel2_dz + $panel2_h/2.0 + $mothergap) ;
	
	return "$panel2_mother_dx1*inches $panel2_mother_dx2*inches $panel2_mother_dy*inches $panel2_mother_dy*inches $panel2_mother_dz*inches";
}

sub panel_2_counter_pos
{
	my $n    = shift;
	my $zpos = fstr(sqrt( sq($panel2_xpos[$n-1] - $panel2_xpos[0]) + sq($panel2_zpos[0] - $panel2_zpos[$n-1]) ) - $panel2_dz) ;
	return "0*cm 0*mm $zpos*inches";
}

sub panel_2_counter_dims
{
	my $n    = shift;
	
	my $length = $panel2_leng[$n-1]/2.0;
	my $height = $panel2_h/2.0;
	my $width  = $panel2_w/2.0;
	
	return "$length*inches $width*inches $height*inches";
}

sub pb_dims
{
	my $panel1b_mother_dx1 = fstr($panel1b_leng[1]/2.0  + $mothergap);
	my $panel1b_mother_dx2 = $panel1b_leng[-1]/2.0 + ($panel1b_leng[-1] - $panel1b_leng[-2])/2.0 + $mothergap;
	my $panel1b_mother_dy  = 1/25.4; # 1mm
	my $panel1b_mother_dz  = fstr($panel1b_dz + $panel1b_h/2.0 + $mothergap);
	
	return "$panel1b_mother_dx1*inches $panel1b_mother_dx2*inches $panel1b_mother_dy*inches $panel1b_mother_dy*inches $panel1b_mother_dz*inches";
}

sub pb_pos 
{
    # shift the lead forward wrt mother center
    # by a distance half the thickness of the counters
    my $ypos = (0.001 + fstr($panel1b_w/2.0 + $mothergap));
    return "0*inches $ypos*inches 0*inches";
}



1;
