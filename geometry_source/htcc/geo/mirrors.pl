use strict;
use warnings;
use math;
use Math::Trig;

our %configuration;
our %parameters;
our @colors_even;


my $nZplanes = 21;

my @zplanes_mirrorback = (360.01139,  423.09863,  486.18587,  549.27312,  612.36036,  675.4476,  738.53484,
                          801.62208,  864.70932,  927.79656,  990.8838 , 1053.971  , 1117.0583, 1180.1455,
                         1243.2328 , 1306.32   , 1369.4073 , 1432.4945 , 1495.5817 , 1558.669 , 1621.7562);
my @Router_mirrorback = (1435.3392 , 1461.162  , 1483.4626 , 1502.4172 , 1518.1665 , 1530.8215, 1540.4676,
                         1547.168  , 1550.9654 , 1551.8836 , 1549.9283 , 1545.0874,  1537.3303, 1526.6071,
                         1512.8469 , 1495.9556 , 1475.8119 , 1452.2631 , 1425.1181 , 1394.1386, 1359.0258);

my $Rinner_mirrorback = 0;




# Ellipse semimajor and semiminor axes:
my @a = ( $parameters{"M1a"}, $parameters{"M2a"}, $parameters{"M3a"}, $parameters{"M4a"} );
my @b = ( $parameters{"M1b"}, $parameters{"M2b"}, $parameters{"M3b"}, $parameters{"M4b"} );




# Ellipse focal point coordinates

my $xfp = 0;
my @yfp = ( $parameters{"yfp1"}, $parameters{"yfp2"}, $parameters{"yfp3"}, $parameters{"yfp4"} );
my @zfp = ( $parameters{"zfp1"}, $parameters{"zfp2"}, $parameters{"zfp3"}, $parameters{"zfp4"} );


# Points defining dividing planes:
my @dividing_plane_points_left12 = ( [ $parameters{"M12Lx1"}, $parameters{"M12Ly1"}, $parameters{"M12Lz1"} ],
									 [ $parameters{"M12Lx2"}, $parameters{"M12Ly2"}, $parameters{"M12Lz2"} ],
				                     [ $parameters{"M12Lx3"}, $parameters{"M12Ly3"}, $parameters{"M12Lz3"} ]);
my @dividing_plane_points_left23 = ( [ $parameters{"M23Lx1"}, $parameters{"M23Ly1"}, $parameters{"M23Lz1"} ],
									 [ $parameters{"M23Lx2"}, $parameters{"M23Ly2"}, $parameters{"M23Lz2"} ],
				                     [ $parameters{"M23Lx3"}, $parameters{"M23Ly3"}, $parameters{"M23Lz3"} ] );
my @dividing_plane_points_left34 = ( [ $parameters{"M34Lx1"}, $parameters{"M34Ly1"}, $parameters{"M34Lz1"} ],
				                     [ $parameters{"M34Lx2"}, $parameters{"M34Ly2"}, $parameters{"M34Lz2"} ],
				                     [ $parameters{"M34Lx3"}, $parameters{"M34Ly3"}, $parameters{"M34Lz3"} ] );


my @dividing_plane_points_right12 = ( [ $parameters{"M12Rx1"}, $parameters{"M12Ry1"}, $parameters{"M12Rz1"} ],
				                      [ $parameters{"M12Rx2"}, $parameters{"M12Ry2"}, $parameters{"M12Rz2"} ],
				                      [ $parameters{"M12Rx3"}, $parameters{"M12Ry3"}, $parameters{"M12Rz3"} ] );
my @dividing_plane_points_right23 = ( [ $parameters{"M23Rx1"}, $parameters{"M23Ry1"}, $parameters{"M23Rz1"} ],
				                      [ $parameters{"M23Rx2"}, $parameters{"M23Ry2"}, $parameters{"M23Rz2"} ],
				                      [ $parameters{"M23Rx3"}, $parameters{"M23Ry3"}, $parameters{"M23Rz3"} ] );
my @dividing_plane_points_right34 = ( [ $parameters{"M34Rx1"}, $parameters{"M34Ry1"}, $parameters{"M34Rz1"} ],
				                      [ $parameters{"M34Rx2"}, $parameters{"M34Ry2"}, $parameters{"M34Rz2"} ],
				                      [ $parameters{"M34Rx3"}, $parameters{"M34Ry3"}, $parameters{"M34Rz3"} ] );


my $Routercylinder = $parameters{"Routercut"};
my $Rback = $parameters{"Rback"};
my $x0 = $parameters{"xbarrelcenter"};
my $z0 = $parameters{"zbarrelcenter"};
my $theta_axis = $parameters{"thetabarrelaxis"} * $pi/180.0;

my $phi0 = 15.0 * $pi/180.0;
my $phistep = 60.0 * $pi/180.0;


# mirrors will be complicated solids composed of Boolean operations:
# Mirror 4:
# a) cut at the bottom by a cone subtending 5 deg. starting from origin
# b) cut at the top by the 3/4 dividing plane
# c) cut at the outside by barrel
# d) cut at the inside by ellipsoid:


sub build_mirrors
{
	my $x0 = 0.0;
	my $y0 = 0.0;
	my $z0 = 0.0;

	
	# This defines the outer edge of the largest-angle mirrors:
	my %detector = init_det();
    $detector{"name"}        = "HTCC_OuterCutCylinder";
    $detector{"mother"}      = "htcc";
    $detector{"description"} = "Outer cut cylinder";
    $detector{"pos"}         = "$x0*mm $y0*mm ".(1500+$z0)."*mm";
    $detector{"type"}        = "Tube";
    $detector{"dimensions"}  = "$Routercylinder"."*mm 1500.0*mm 500*mm 0*deg 360*deg";
    $detector{"material"}    = "Component";
	print_det(\%configuration, \%detector);
	
    # This defines the inner edge of the smallest-angle mirrors (cone subtending 5 deg. in theta):
	%detector = init_det();
    $detector{"name"}        = "HTCC_InnerCutCone";
    $detector{"mother"}      = "htcc";
    $detector{"description"} = "Inner cut cone";
    $detector{"pos"}         = "$x0*mm $y0*mm ".(1000+$z0)."*mm";
    $detector{"type"}        = "Cons";
    $detector{"dimensions"}  = "0.0*mm 0.0*mm 0.0*mm 174.97733*mm 1000.0*mm 0*deg 360*deg";
    $detector{"material"}    = "Component";
	print_det(\%configuration, \%detector);


	 # six sectors
	for( my $i = 0; $i < 6; $i++ )
	{
		# two half-sectors (left and right)
		for( my $k = 0; $k < 2; $k++ )
		{
			# phi rotation relative to vertical up (universal per half-sector):
			
			# The parameters of the "left" and "right" mirrors for the "first" sector are
			# shifted by - and + 15 deg. relative to vertical (phi = 90 deg.)
			# gemc considers the rotation angles we give to be clockwise about the axis specified,
			# so a positive clockwise rotation corresponds to a rotation in the direction of decreasing phi
			# a counter-clockwise rotation about the z axis (rotation in the direction of increasing phi),
			# is accomplished via a negative clockwise rotation;
			# therefore, we rotate each half-sector by -/+15 deg. - 60 deg. * sector number:
			my $phirot = -$phi0 * (2.0*$k-1.0) - $phistep * $i;
			
			if( $phirot < -$pi ){ $phirot += 2.0*$pi; }
			
			my $sphirot     = sprintf("%14.10g",$phirot);
			my $stheta_axis = sprintf("%14.10g",$theta_axis);
			
			
			# the barrel defining the common back surface for all four mirrors in a half-sector
			# can be defined by a polycone shape
            # (for now, GEANT4 does not have an easy way to define a solid whose surface is the surface of
			#  revolution of a circle about a chord that is not a diameter).
			# The easiest way to define it is a polycone with outer radius defined at a "large" number
			# of planes along the z axis, and then rotate it into place.
			# The polycone solid defining the barrel is then always positioned at the origin with
			# rotation depending on which half-sector we are in.
			# The axis of the barrel always makes a polar angle of 79.76 deg. relative to the beamline:
			
			# There is only one barrel shape defining the mirror back per half-sector:
			# define polycone dimensions:
			my $dimensions = "0.0*deg 360.0*deg $nZplanes*counts";
			for(my $i=0; $i<$nZplanes; $i++){ $dimensions = $dimensions ." $Rinner_mirrorback*mm";  }
			for(my $i=0; $i<$nZplanes; $i++){ $dimensions = $dimensions ." $Router_mirrorback[$i]*mm";  }
			for(my $i=0; $i<$nZplanes; $i++){ $dimensions = $dimensions ." $zplanes_mirrorback[$i]*mm"; }

			%detector = init_det();
			$detector{"name"}        = "Barrel_sect".$i."half".$k;
			$detector{"mother"}      = "htcc";
			$detector{"description"} = "Barrel defining mirror back surface";
			$detector{"rotation"}    = "ordered: yzx 0*rad "."$sphirot"."*rad "."$stheta_axis"."*rad ";
			$detector{"type"}        = "Polycone";
			$detector{"dimensions"}  = $dimensions;
			$detector{"material"}    = "Component";
			print_det(\%configuration, \%detector);

			
			
			# Define a slice in phi for each half-sector used to cut the mirror:
			# the starting phi angle of the slice is 60 deg. * sector number + 30 deg. for the "right" half of each sector
			my $phistart_cut = $pi/2.0 + $phi0 * (2.0*$k - 2.0) + $phistep * $i;
			if( $phistart_cut > 2.0*$pi )
			{
				$phistart_cut = $phistart_cut - 2.0*$pi;
			}
			
			# the slice subtends 30 degrees in phi:
			# Adding a microgap between mirrors for overlaps
			my $dphi_microgap = 0.001;
			my $dphi_cut = 0.5*$phistep - $dphi_microgap;
			
			my $sphistart_cut = sprintf( "%14.10g", $phistart_cut );
			my $sdphi_cut = sprintf("%14.10g", $dphi_cut );
			
			# This is the cylindrical wedge that cuts all the mirrors to their half-sector size along phi:
			%detector = init_det();
			$detector{"name"}           = "phicut_sect$i"."half$k";
			$detector{"mother"}         = "htcc";
			$detector{"description"}    = "Half-sector phi cut";
			$detector{"pos"}            = "$x0*mm $y0*mm ".(1500+$z0)."*mm";
			$detector{"type"}           = "Tube";
			$detector{"dimensions"}     = "0.0*mm 1500.0*mm 500.0*mm $sphistart_cut"."*rad $sdphi_cut"."*rad";
			$detector{"material"}       = "Component";
			print_det(\%configuration, \%detector);

			
			
			
			
			# in each half sector there are four mirrors:
			for( my $j = 0; $j < 4; $j++ )
			{
				# choose either "UVa" or "MIT" colors depending on half-sector:
				my $color_index = 2*($k%2) + $j%2;
				
				# make the inner ellipsoid:
				
				# the major axis of the ellipsoid is oriented along the ray from the origin to the second focal point of the ellipsoid, which is then revolved around its axis:
				
				my @axis     = ( 0., 0., 0. );
				my @unitaxis = ( 0., 0., 1.);
				my @center   = ( 0., 0., 0. );
				
				$axis[0] =     $xfp * cos( $phirot ) + $yfp[$j] * sin( $phirot );
				$axis[1] = $yfp[$j] * cos( $phirot ) -     $xfp * sin( $phirot );
				$axis[2] = $zfp[$j];
				
				# the vector "axis" is the ray from the origin to the second focal point
				
				my $mag = sqrt( $axis[0]**2 + $axis[1]**2 + $axis[2]**2 );
				
				# the vector "unitaxis" is the unit vector in the direction of "axis":
				# the "center" of the ellipse is located halfway between the two foci along the axis, this is where it will be positioned:
				
				for( my $m=0; $m<3; $m++ )
				{
					$unitaxis[$m] = $axis[$m]/ $mag;
					$center[$m] = 0.5*$axis[$m];
				}
				
				my @scenter = ( sprintf("%14.10g", $center[0]), sprintf("%14.10g", $center[1]), sprintf("%14.10g", $center[2]) );
				
				# the axis of the ellipse makes a polar angle of $angle wrt the beamline:
				my $sangle = sprintf( "%14.10g", acos( $unitaxis[2] ));
				
				# The azimuthal angle of the ellipse with respect to the vertical is atan2(x,y):
				my $sphiellipse = sprintf( "%14.10g", atan2( $unitaxis[0], $unitaxis[1] ));
				
								
				
				# These are the ellipsoids defining the mirror front surfaces:
				%detector = init_det();
				$detector{"name"}        = "Mirror_sect".$i."mirr".$j."half".$k;
				$detector{"mother"}      = "htcc";
				$detector{"description"} = "Ellipsoid defining mirror surface";
				$detector{"pos"}         = ($scenter[0]+$x0)."*mm ".($scenter[1]+$y0)."*mm ".($scenter[2]+$z0)."*mm";
				$detector{"rotation"}    = "ordered: yzx 0*rad "."$sphiellipse"."*rad "."$sangle"."*rad ";
				$detector{"dimensions"}  = "$b[$j]*mm $b[$j]*mm $a[$j]*mm 0*mm 0*mm";
				$detector{"type"}        = "Ellipsoid";
				$detector{"material"}    = "Component";
				print_det(\%configuration, \%detector);
				
				
				# Make the subtraction of the inner ellipsoid from the outer barrel:
				# the "Operation:@" indicates that gemc should assume the coordinates
				# and rotations of the mirror ellipsoid are given in its mother coordinate system,
				# not relative to the outer barrel coordinate system:
				%detector = init_det();
				$detector{"name"}           = "BarrelEllipseCut_sect$i"."mirr$j"."half$k";
				$detector{"mother"}         = "htcc";
				$detector{"description"}    = "subtraction of barrel and ellipse";
				$detector{"pos"}            = "$x0"."*mm $y0"."*mm $z0"."*mm";
				$detector{"rotation"}       = "ordered: yzx 0*rad "."$sphirot"."*rad "."$stheta_axis"."*rad ";
				$detector{"type"}           = "Operation:@ Barrel_sect$i"."half$k"." - Mirror_sect$i"."mirr$j"."half$k";
				$detector{"dimensions"}     = "0";
				$detector{"material"}       = "Component";
				print_det(\%configuration, \%detector);
				
				
				# Now, we need to make cut solids: This depends on which mirror we are addressing:
				
				# mirror 1: need cylindrical cut (outer edge) and lower dividing plane:
				if( $j == 0 )
				{
					
					
					# need to calculate position of box:
					# calculate normal axis to plane by calculating the cross product of the three points:
					#my @boxaxis = ( 0., 0., 1. );
					
					my @point1  = ( 0., 0., 0. );
					my @point2  = ( 0., 0., 0. );
					my @point3  = ( 0., 0., 0. );
					
					# because the coordinates of the dividing plane points already include the +/- 15 deg. rotation relative to the vertical for the "left" and "right" mirrors,
					# the only rotation needed is by 60 deg. * sector number about z:
					
					if( $k == 0 )
					{ # left
						@point1 = ( $dividing_plane_points_left12[0][0] * cos($i * $phistep) - $dividing_plane_points_left12[0][1] * sin($i * $phistep),
						$dividing_plane_points_left12[0][1] * cos($i * $phistep) + $dividing_plane_points_left12[0][0] * sin($i * $phistep),
						$dividing_plane_points_left12[0][2] );
						@point2 = ( $dividing_plane_points_left12[1][0] * cos($i * $phistep) - $dividing_plane_points_left12[1][1] * sin($i * $phistep),
						$dividing_plane_points_left12[1][1] * cos($i * $phistep) + $dividing_plane_points_left12[1][0] * sin($i * $phistep),
						$dividing_plane_points_left12[1][2] );
						@point3 = ( $dividing_plane_points_left12[2][0] * cos($i * $phistep) - $dividing_plane_points_left12[2][1] * sin($i * $phistep),
						$dividing_plane_points_left12[2][1] * cos($i * $phistep) + $dividing_plane_points_left12[2][0] * sin($i * $phistep),
						$dividing_plane_points_left12[2][2] );
					}
					else
					{
						@point1 = ( $dividing_plane_points_right12[0][0] * cos($i * $phistep) - $dividing_plane_points_right12[0][1] * sin($i * $phistep),
						$dividing_plane_points_right12[0][1] * cos($i * $phistep) + $dividing_plane_points_right12[0][0] * sin($i * $phistep),
						$dividing_plane_points_right12[0][2] );
						@point2 = ( $dividing_plane_points_right12[1][0] * cos($i * $phistep) - $dividing_plane_points_right12[1][1] * sin($i * $phistep),
						$dividing_plane_points_right12[1][1] * cos($i * $phistep) + $dividing_plane_points_right12[1][0] * sin($i * $phistep),
						$dividing_plane_points_right12[1][2] );
						@point3 = ( $dividing_plane_points_right12[2][0] * cos($i * $phistep) - $dividing_plane_points_right12[2][1] * sin($i * $phistep),
						$dividing_plane_points_right12[2][1] * cos($i * $phistep) + $dividing_plane_points_right12[2][0] * sin($i * $phistep),
						$dividing_plane_points_right12[2][2] );
						
					}
					# the ray from point 2 to point 1:
					my @vec21 = ( $point1[0] - $point2[0],
					$point1[1] - $point2[1],
					$point1[2] - $point2[2] );
					
					# the ray from point 2 to point 3:
					my @vec23 = ( $point3[0] - $point2[0],
					$point3[1] - $point2[1],
					$point3[2] - $point2[2] );
					
					# the cross product of the two rays, defining the normal vector to the plane:
					my @crossproduct = ( $vec21[1]*$vec23[2] - $vec21[2]*$vec23[1],
					$vec21[2]*$vec23[0] - $vec21[0]*$vec23[2],
					$vec21[0]*$vec23[1] - $vec21[1]*$vec23[0] );
					
					# the magnitude of the cross product, which allows us to define the unit normal vector:
					$mag = sqrt( $crossproduct[0]**2 + $crossproduct[1]**2 + $crossproduct[2]**2 );
					
					
					my @plane_unitnormal = ( $crossproduct[0]/$mag,
					$crossproduct[1]/$mag,
					$crossproduct[2]/$mag );
					
					
					# we always want to choose the direction of the normal vector that points along the +z axis!!!
					if( $plane_unitnormal[2] < 0.0 )
					{
						for( my $m=0; $m<3; $m++ )
						{
							$plane_unitnormal[$m] *= -1.0;
						}
					}
					
					
					my $boxwidth = 1000.0; #mm
					
					# position the box at one of the points in the dividing plane, and then translate along the axis of the plane by the box half width
					# in this case we subtract the box half-width, since we want to cut out everything BELOW the dividing plane:
					
					# Subtracting microgap here so that there's no overlaps between mirrors
					my $vertical_microgap1 = 0.1;
					my @boxpos = ( $point2[0] - $boxwidth*$plane_unitnormal[0] ,
					               $point2[1] - $boxwidth*$plane_unitnormal[1],
					               $point2[2] - $boxwidth*$plane_unitnormal[2] + $vertical_microgap1 );
					
					my @sboxpos = ( sprintf("%14.10g", $boxpos[0] ), sprintf("%14.10g", $boxpos[1] ), sprintf("%14.10g", $boxpos[2] ) );
					
					
					# next step: figure out the proper rotation angles: the z axis of the box should be along the unit normal to the dividing plane
					# figure out the polar theta and azimuthal phi angles:
					
					# angle is the polar angle relative to the beamline:
					$sangle = sprintf( "%14.10g", acos( $plane_unitnormal[2] ) );
					# phibox is the azimuthal angle relative to the vertical, with phi increasing from the y axis toward the x axis: this coincides with the
					# clockwise rotation that gemc wants:
					
					my $sphibox = sprintf( "%14.10g", atan2( $plane_unitnormal[0], $plane_unitnormal[1] ) );
					
					
					
					%detector = init_det();
					$detector{"name"}          = "Boxcut12_sect".$i."mirr".$j."half".$k;
					$detector{"mother"}        = "htcc";
					$detector{"description"}   = "Box defining dividing plane 1/2";
					$detector{"dimensions"}    = "$boxwidth*mm $boxwidth*mm $boxwidth*mm";
					$detector{"pos"}           = ($x0+$sboxpos[0])."*mm ".($sboxpos[1]+$y0)."*mm ".($sboxpos[2]+$z0)."*mm";
					$detector{"rotation"}      = "ordered: yzx 0*rad "."$sphibox"."*rad "."$sangle"."*rad";
					$detector{"type"}          = "Box";
					$detector{"material"}      = "Component";
					print_det(\%configuration, \%detector);
					
					# To make the cut, the positioning and rotation of the resulting object
					# is the same as that of "Barrel"
					# again we use Operation:@ to specify to gemc that both solids
					# are positioned with absolute coordinates in their common mother volume:
					%detector = init_det();
					$detector{"name"}           = "MirrorBoxCut_sect$i"."mirr$j"."half$k";
					$detector{"mother"}         = "htcc";
					$detector{"description"}    = "subtraction of box and (barrel - ellipse)";
					$detector{"pos"}            = "$x0"."*mm $y0"."*mm $z0"."*mm";
					$detector{"rotation"}       = "ordered: yzx 0*rad "."$sphirot"."*rad "."$stheta_axis"."*rad ";
					$detector{"type"}           = "Operation:@ BarrelEllipseCut_sect$i"."mirr$j"."half$k - Boxcut12_sect".$i."mirr".$j."half".$k;
					$detector{"dimensions"}     = "0";
					$detector{"material"}       = "Component";
					print_det(\%configuration, \%detector);
					
					# Next, we subtract the outer cylinder from the "MirrorBoxCut" to define the outer boundary of the largest-angle mirror:
					%detector = init_det();
					$detector{"name"}           = "MirrorCylinderCut_sect$i"."mirr$j"."half$k";
					$detector{"mother"}         = "htcc";
					$detector{"description"}    = "subtraction of cylinder and (box - (barrel - ellipse))";
					$detector{"pos"}            = "$x0"."*mm $y0"."*mm $z0"."*mm";
					$detector{"rotation"}       = "ordered: yzx 0*rad "."$sphirot"."*rad "."$stheta_axis"."*rad ";
					$detector{"type"}           = "Operation:@ MirrorBoxCut_sect$i"."mirr$j"."half$k - HTCC_OuterCutCylinder";
					$detector{"dimensions"}     = "0";
					$detector{"material"}       = "Component";
					print_det(\%configuration, \%detector);
					
					# The first "final" mirror: it is the intersection of the "mirror cylinder cut" with the cylindrical phi slice:
					
					%detector = init_det();
				    $detector{"name"}           = htccName("mirror", $i, $j, ($k+1)%2+1);
					$detector{"mother"}         = "htcc";
				    $detector{"description"}    = htccDesc("mirror", $i, $j, ($k+1)%2+1);
					$detector{"pos"}            = "$x0"."*mm $y0"."*mm $z0"."*mm";
					$detector{"rotation"}       = "ordered: yzx 0*rad "."$sphirot"."*rad "."$stheta_axis"."*rad ";
					$detector{"color"}          = $colors_even[$color_index];
					$detector{"type"}           = "Operation:@ MirrorCylinderCut_sect$i"."mirr$j"."half$k * phicut_sect$i"."half$k";
					$detector{"dimensions"}     = "0";
					$detector{"style"}          = "1";
					$detector{"material"}       = "rohacell31";
					
					# The "mirror" sensitivity allow gemc to access the mirror to define the optical properties
					# The identfier is sector*1000 + 1/2*10 + mirror
					my $MirId = $i*1000 + $k*10 + $j;
					$detector{"sensitivity"}    = "mirror: htcc_AlMgF2";
					$detector{"hit_type"}       = "mirror";
					$detector{"identifiers"}    = "id manual $MirId";
					print_det(\%configuration, \%detector);
					
				}
				# middle two mirrors: we need two dividing planes
				elsif ( $j == 1 || $j == 2 )
				{
					my @box1point1  = ( 0., 0., 0. );
					my @box1point2  = ( 0., 0., 0. );
					my @box1point3  = ( 0., 0., 0. );
										
					my @box2point1  = ( 0., 0., 0. );
					my @box2point2  = ( 0., 0., 0. );
					my @box2point3  = ( 0., 0., 0. );
					
					# since we have two dividing planes, we want to define a shorthand for the three points defining
					# the upper plane and the three points defining the lower plane:
					
					my @upperpointstemp;
					my @lowerpointstemp;
					
					 # left mirrors
					if( $k == 0 )
					{
						# for Mirror #2, the "upper" plane is 1/2 and the "lower" plane is 2/3
						if( $j == 1 )
						{
							@upperpointstemp = @dividing_plane_points_left12;
							@lowerpointstemp = @dividing_plane_points_left23;
						}
						# for Mirror #3, the "upper" plane is 2/3 and the "lower" plane is 3/4
						else
						{
							@upperpointstemp = @dividing_plane_points_left23;
							@lowerpointstemp = @dividing_plane_points_left34;
						}
						# first (upper) box:
						@box1point1 = ( $upperpointstemp[0][0] * cos($i * $phistep) - $upperpointstemp[0][1] * sin($i * $phistep),
						$upperpointstemp[0][1] * cos($i * $phistep) + $upperpointstemp[0][0] * sin($i * $phistep),
						$upperpointstemp[0][2] );
						@box1point2 = ( $upperpointstemp[1][0] * cos($i * $phistep) - $upperpointstemp[1][1] * sin($i * $phistep),
						$upperpointstemp[1][1] * cos($i * $phistep) + $upperpointstemp[1][0] * sin($i * $phistep),
						$upperpointstemp[1][2] );
						@box1point3 = ( $upperpointstemp[2][0] * cos($i * $phistep) - $upperpointstemp[2][1] * sin($i * $phistep),
						$upperpointstemp[2][1] * cos($i * $phistep) + $upperpointstemp[2][0] * sin($i * $phistep),
						$upperpointstemp[2][2] );
                        # second (lower) box:
						@box2point1 = ( $lowerpointstemp[0][0] * cos($i * $phistep) - $lowerpointstemp[0][1] * sin($i * $phistep),
						$lowerpointstemp[0][1] * cos($i * $phistep) + $lowerpointstemp[0][0] * sin($i * $phistep),
						$lowerpointstemp[0][2] );
						@box2point2 = ( $lowerpointstemp[1][0] * cos($i * $phistep) - $lowerpointstemp[1][1] * sin($i * $phistep),
						$lowerpointstemp[1][1] * cos($i * $phistep) + $lowerpointstemp[1][0] * sin($i * $phistep),
						$lowerpointstemp[1][2] );
						@box2point3 = ( $lowerpointstemp[2][0] * cos($i * $phistep) - $lowerpointstemp[2][1] * sin($i * $phistep),
						$lowerpointstemp[2][1] * cos($i * $phistep) + $lowerpointstemp[2][0] * sin($i * $phistep),
						$lowerpointstemp[2][2] );
						
						
					}
					# right mirrors
					else
					{
						#upper = 1/2, lower = 2/3
						if( $j == 1 )
						{
							@upperpointstemp = @dividing_plane_points_right12;
							@lowerpointstemp = @dividing_plane_points_right23;
						}
						#upper = 2/3, lower = 3/4
						else
						{
							@upperpointstemp = @dividing_plane_points_right23;
							@lowerpointstemp = @dividing_plane_points_right34;
						}
						
						# first (upper) box:
						@box1point1 = ( $upperpointstemp[0][0] * cos($i * $phistep) - $upperpointstemp[0][1] * sin($i * $phistep),
						$upperpointstemp[0][1] * cos($i * $phistep) + $upperpointstemp[0][0] * sin($i * $phistep),
						$upperpointstemp[0][2] );
						@box1point2 = ( $upperpointstemp[1][0] * cos($i * $phistep) - $upperpointstemp[1][1] * sin($i * $phistep),
						$upperpointstemp[1][1] * cos($i * $phistep) + $upperpointstemp[1][0] * sin($i * $phistep),
						$upperpointstemp[1][2] );
						@box1point3 = ( $upperpointstemp[2][0] * cos($i * $phistep) - $upperpointstemp[2][1] * sin($i * $phistep),
						$upperpointstemp[2][1] * cos($i * $phistep) + $upperpointstemp[2][0] * sin($i * $phistep),
						$upperpointstemp[2][2] );
						
						# second (lower) box:
						@box2point1 = ( $lowerpointstemp[0][0] * cos($i * $phistep) - $lowerpointstemp[0][1] * sin($i * $phistep),
						$lowerpointstemp[0][1] * cos($i * $phistep) + $lowerpointstemp[0][0] * sin($i * $phistep),
						$lowerpointstemp[0][2] );
						@box2point2 = ( $lowerpointstemp[1][0] * cos($i * $phistep) - $lowerpointstemp[1][1] * sin($i * $phistep),
						$lowerpointstemp[1][1] * cos($i * $phistep) + $lowerpointstemp[1][0] * sin($i * $phistep),
						$lowerpointstemp[1][2] );
						@box2point3 = ( $lowerpointstemp[2][0] * cos($i * $phistep) - $lowerpointstemp[2][1] * sin($i * $phistep),
						$lowerpointstemp[2][1] * cos($i * $phistep) + $lowerpointstemp[2][0] * sin($i * $phistep),
						$lowerpointstemp[2][2] );
					}
					
					# ray from point 2 to point 1, upper plane:
					my @box1_vec21 = ( $box1point1[0] - $box1point2[0],
					$box1point1[1] - $box1point2[1],
					$box1point1[2] - $box1point2[2] );
					
					# ray from point 2 to point 3, upper plane:
					my @box1_vec23 = ( $box1point3[0] - $box1point2[0],
					$box1point3[1] - $box1point2[1],
					$box1point3[2] - $box1point2[2] );
					
					# ray from point 2 to point 1, lower plane:
					my @box2_vec21 = ( $box2point1[0] - $box2point2[0],
					$box2point1[1] - $box2point2[1],
					$box2point1[2] - $box2point2[2] );
					
					# ray from point 2 to point 3, lower plane:
					my @box2_vec23 = ( $box2point3[0] - $box2point2[0],
					$box2point3[1] - $box2point2[1],
					$box2point3[2] - $box2point2[2] );
					
					# normal vector, upper plane:
					my @box1crossproduct = ( $box1_vec21[1]*$box1_vec23[2] - $box1_vec21[2]*$box1_vec23[1],
					$box1_vec21[2]*$box1_vec23[0] - $box1_vec21[0]*$box1_vec23[2],
					$box1_vec21[0]*$box1_vec23[1] - $box1_vec21[1]*$box1_vec23[0] );
					
					# normal vector, lower plane:
					my @box2crossproduct = ( $box2_vec21[1]*$box2_vec23[2] - $box2_vec21[2]*$box2_vec23[1],
					$box2_vec21[2]*$box2_vec23[0] - $box2_vec21[0]*$box2_vec23[2],
					$box2_vec21[0]*$box2_vec23[1] - $box2_vec21[1]*$box2_vec23[0] );
					
					# magnitudes of normal vectors, upper and lower planes:
					
					my $mag1 = sqrt( $box1crossproduct[0]**2 + $box1crossproduct[1]**2 + $box1crossproduct[2]**2 );
					my $mag2 = sqrt( $box2crossproduct[0]**2 + $box2crossproduct[1]**2 + $box2crossproduct[2]**2 );
					
					# unit normal vectors, upper and lower planes:
					my @plane1_unitnormal = ( $box1crossproduct[0]/$mag1,
					$box1crossproduct[1]/$mag1,
					$box1crossproduct[2]/$mag1 );
					
					my @plane2_unitnormal = ( $box2crossproduct[0]/$mag2,
					$box2crossproduct[1]/$mag2,
					$box2crossproduct[2]/$mag2 );
					
					# check that we are using the unit normal vectors that point along the +z axis, change sign if not:
					if( $plane1_unitnormal[2] < 0.0 )
					{
						for( my $m=0; $m<3; $m++ )
						{
							$plane1_unitnormal[$m] *= -1.;
						}
					}
					
					if( $plane2_unitnormal[2] < 0.0 )
					{
						for( my $m=0; $m<3; $m++ )
						{
							$plane2_unitnormal[$m] *= -1.;
						}
					}
					
					my $box1width = 1000.0; #mm
					my $box2width = 1000.0; #mm
					
					# because box 1 defines the "upper" dividing plane, we shift it along its axis by + its half width
					# so that the subtraction cuts everything above it


					my @box1pos = ( $box1point2[0] + $box1width*$plane1_unitnormal[0],
									$box1point2[1] + $box1width*$plane1_unitnormal[1],
									$box1point2[2] + $box1width*$plane1_unitnormal[2] );
					
					my @sbox1pos = ( sprintf("%14.10g", $box1pos[0] ),
					                 sprintf("%14.10g", $box1pos[1] ),
					                 sprintf("%14.10g", $box1pos[2] ) );
					
					# polar and azimuthal angles, defined in the proper sense, upper plane:
					my $box1angle = acos( $plane1_unitnormal[2] );
					my $box1phi   = atan2( $plane1_unitnormal[0], $plane1_unitnormal[1] );
					
					my $sangle1 = sprintf( "%14.10g", $box1angle );
					my $sphi1   = sprintf( "%14.10g", $box1phi );
					
					# because box 2 defines the "lower" dividing plane, we shift it along its axis by - its half width
					# so that the subtraction cuts everything below it:

					# Subtracting microgap here so that there's no overlaps between mirrors
					my $vertical_microgap2 = 0.1;

					my @box2pos = ( $box2point2[0] - $box2width*$plane2_unitnormal[0],
									$box2point2[1] - $box2width*$plane2_unitnormal[1],
									$box2point2[2] - $box2width*$plane2_unitnormal[2] + $vertical_microgap2);
					
					my @sbox2pos = ( sprintf("%14.10g", $box2pos[0] ),
					sprintf("%14.10g", $box2pos[1] ),
					sprintf("%14.10g", $box2pos[2] ) );
					# polar and azimuthal orientation angles, lower plane:
					my $box2angle = acos( $plane2_unitnormal[2] );
					my $box2phi   = atan2( $plane2_unitnormal[0], $plane2_unitnormal[1] );
					
					my $sangle2 = sprintf( "%14.10g", $box2angle );
					my $sphi2   = sprintf( "%14.10g", $box2phi );
					
					# define the box volumes to be subtracted which define the dividing planes:
					
					# upper plane:
					%detector = init_det();
					$detector{"name"}             = "Boxcut_up_sect$i"."mirr$j"."half$k";
					$detector{"mother"}           = "htcc";
					$detector{"description"}      = "upper plane cut";
					$detector{"dimensions"}       = "$box1width*mm $box1width*mm $box1width*mm";
					$detector{"pos"}              = ($sbox1pos[0]+$x0)."*mm ".($sbox1pos[1]+$y0)."*mm ".($sbox1pos[2]+$z0)."*mm";
					$detector{"rotation"}         = "ordered: yzx 0*rad "."$sphi1"."*rad "."$sangle1"."*rad";
					$detector{"type"}             = "Box";
					$detector{"material"}         = "Component";
					print_det(\%configuration, \%detector);
					
					# lower plane:
					%detector = init_det();
					$detector{"name"}             = "Boxcut_down_sect$i"."mirr$j"."half$k";
					$detector{"mother"}           = "htcc";
					$detector{"description"}      = "lower plane cut";
					$detector{"dimensions"}       = "$box2width*mm $box2width*mm $box2width*mm";
					$detector{"pos"}              = ($sbox2pos[0]+$x0)."*mm ".($sbox2pos[1]+$y0)."*mm ".($sbox2pos[2]+$z0)."*mm";
					$detector{"rotation"}         = "ordered: yzx 0*rad "."$sphi2"."*rad "."$sangle2"."*rad";
					$detector{"type"}             = "Box";
					$detector{"material"}         = "Component";
					print_det(\%configuration, \%detector);
					
					# Now we need to make the "upper" and "lower" box cuts:
					%detector = init_det();
					$detector{"name"}             = "MirrorBoxCut_up_sect$i"."mirr$j"."half$k";
					$detector{"mother"}           = "htcc";
					$detector{"description"}      = "subtraction of upper box from (barrel - ellipse)";
					$detector{"pos"}              = "$x0"."*mm $y0"."*mm $z0"."*mm";
					$detector{"rotation"}         = "ordered: yzx 0*rad "."$sphirot"."*rad "."$stheta_axis"."*rad ";
					$detector{"type"}             = "Operation:@ BarrelEllipseCut_sect$i"."mirr$j"."half$k - Boxcut_up_sect$i"."mirr$j"."half$k";
					$detector{"dimensions"}       = "0";
					$detector{"material"}         = "Component";
					print_det(\%configuration, \%detector);
					
					%detector = init_det();
					$detector{"name"}             = "MirrorBoxCut_down_sect$i"."mirr$j"."half$k";
					$detector{"mother"}           = "htcc";
					$detector{"description"}      = "subtraction of lower box from (barrel - ellipse - upper box)";
					$detector{"pos"}              = "$x0"."*mm $y0"."*mm $z0"."*mm";
					$detector{"rotation"}         = "ordered: yzx 0*rad "."$sphirot"."*rad "."$stheta_axis"."*rad ";
					$detector{"type"}             = "Operation:@ MirrorBoxCut_up_sect$i"."mirr$j"."half$k - Boxcut_down_sect$i"."mirr$j"."half$k";
					$detector{"dimensions"}       = "0";
					$detector{"material"}         = "Component";
					print_det(\%configuration, \%detector);
					
					# The final mirrors: barrel - ellipse - upper box - lower box, intersection with phi slice:
					%detector = init_det();
				    $detector{"name"}           = htccName("mirror", $i, $j, ($k+1)%2+1);
					$detector{"mother"}         = "htcc";
				    $detector{"description"}    = htccDesc("mirror", $i, $j, ($k+1)%2+1);
					$detector{"pos"}            = "$x0"."*mm $y0"."*mm $z0"."*mm";
					$detector{"rotation"}       = "ordered: yzx 0*rad "."$sphirot"."*rad "."$stheta_axis"."*rad ";
					$detector{"color"}          = $colors_even[$color_index];
					$detector{"type"}           = "Operation:@ MirrorBoxCut_down_sect$i"."mirr$j"."half$k * phicut_sect$i"."half$k";
					$detector{"dimensions"}     = "0";
					$detector{"style"}          = "1";
					$detector{"material"}       = "rohacell31";
					# The "mirror" sensitivity allow gemc to access the mirror to define the optical properties
					# The identfier is sector*1000 + 1/2*10 + mirror
					my $MirId = $i*1000 + $k*10 + $j;
					$detector{"sensitivity"}    = "mirror: htcc_AlMgF2";
					$detector{"hit_type"}       = "mirror";
					$detector{"identifiers"}    = "id manual $MirId";
					print_det(\%configuration, \%detector);
					

				} else { # j == 3: need upper plane cut and lower conical cut:
					my @point1 = ( 0., 0., 0. );
					my @point2 = ( 0., 0., 0. );
					my @point3 = ( 0., 0., 0. );
					
					if( $k == 0 ){ # left:
						@point1 = ( $dividing_plane_points_left34[0][0] * cos( $i * $phistep ) - $dividing_plane_points_left34[0][1] * sin( $i * $phistep ),
						$dividing_plane_points_left34[0][1] * cos( $i * $phistep ) + $dividing_plane_points_left34[0][0] * sin( $i * $phistep ),
						$dividing_plane_points_left34[0][2] );
						
						@point2 = ( $dividing_plane_points_left34[1][0] * cos( $i * $phistep ) - $dividing_plane_points_left34[1][1] * sin( $i * $phistep ),
						$dividing_plane_points_left34[1][1] * cos( $i * $phistep ) + $dividing_plane_points_left34[1][0] * sin( $i * $phistep ),
						$dividing_plane_points_left34[1][2] );
						
						@point3 = ( $dividing_plane_points_left34[2][0] * cos( $i * $phistep ) - $dividing_plane_points_left34[2][1] * sin( $i * $phistep ),
						$dividing_plane_points_left34[2][1] * cos( $i * $phistep ) + $dividing_plane_points_left34[2][0] * sin( $i * $phistep ),
						$dividing_plane_points_left34[2][2] );
						
					} else { # right:
						@point1 = ( $dividing_plane_points_right34[0][0] * cos( $i * $phistep ) - $dividing_plane_points_right34[0][1] * sin( $i * $phistep ),
						$dividing_plane_points_right34[0][1] * cos( $i * $phistep ) + $dividing_plane_points_right34[0][0] * sin( $i * $phistep ),
						$dividing_plane_points_right34[0][2] );
						
						@point2 = ( $dividing_plane_points_right34[1][0] * cos( $i * $phistep ) - $dividing_plane_points_right34[1][1] * sin( $i * $phistep ),
						$dividing_plane_points_right34[1][1] * cos( $i * $phistep ) + $dividing_plane_points_right34[1][0] * sin( $i * $phistep ),
						$dividing_plane_points_right34[1][2] );
						
						@point3 = ( $dividing_plane_points_right34[2][0] * cos( $i * $phistep ) - $dividing_plane_points_right34[2][1] * sin( $i * $phistep ),
						$dividing_plane_points_right34[2][1] * cos( $i * $phistep ) + $dividing_plane_points_right34[2][0] * sin( $i * $phistep ),
						$dividing_plane_points_right34[2][2] );
					}
					
					my @vec21 = ( $point1[0] - $point2[0],
					$point1[1] - $point2[1],
					$point1[2] - $point2[2] );
					
					my @vec23 = ( $point3[0] - $point2[0],
					$point3[1] - $point2[1],
					$point3[2] - $point2[2] );
					
					my @crossproduct = ( $vec21[1]*$vec23[2] - $vec21[2]*$vec23[1],
					$vec21[2]*$vec23[0] - $vec21[0]*$vec23[2],
					$vec21[0]*$vec23[1] - $vec21[1]*$vec23[0] );
					my $mag = sqrt( $crossproduct[0]**2 + $crossproduct[1]**2 + $crossproduct[2]**2 );
					
					my @unitnormal = ( $crossproduct[0]/$mag,
					$crossproduct[1]/$mag,
					$crossproduct[2]/$mag );
					
					if( $unitnormal[2] < 0.0 )
					{
						for( my $m=0; $m<3; $m++ )
						{
							$unitnormal[$m] *= -1.;
						}
					}
					
					my $boxwidth = 1000.0;
					# for mirror #4, we shift the box by + its half-width, because we want to cut out everything ABOVE the dividing plane:
					my @boxpos = ( $point2[0] + $boxwidth*$unitnormal[0],
					$point2[1] + $boxwidth*$unitnormal[1],
					$point2[2] + $boxwidth*$unitnormal[2] );
					
					my @sboxpos = ( sprintf("%14.10g", $boxpos[0]),
				    sprintf("%14.10g", $boxpos[1]),
				    sprintf("%14.10g", $boxpos[2]) );
					
					my $boxangle = acos( $unitnormal[2] );
					my $boxphi   = atan2( $unitnormal[0], $unitnormal[1] );
					
					my $sboxangle = sprintf( "%14.10g", $boxangle );
					my $sboxphi   = sprintf( "%14.10g", $boxphi );
					
					# define the "box" volume to be subtracted
					
					%detector = init_det();
					$detector{"name"}                = "Boxcut_up_sect$i"."mirr$j"."half$k";
					$detector{"mother"}              = "htcc";
					$detector{"description"}         = "upper plane cut";
					$detector{"dimensions"}          = "$boxwidth*mm $boxwidth*mm $boxwidth*mm";
					$detector{"pos"}                 = ($sboxpos[0]+$x0)."*mm ".($sboxpos[1]+$y0)."*mm ".($sboxpos[2]+$z0)."*mm";
					$detector{"rotation"}            = "ordered: yzx 0*rad $sboxphi"."*rad $sboxangle"."*rad";
					$detector{"color"}               = "ff0000";
					$detector{"type"}                = "Box";
					$detector{"material"}            = "Component";
					print_det(\%configuration, \%detector);
					
					# define the operation subtracting the "barrel - ellipse - upper dividing plane":
					%detector = init_det();
					$detector{"name"}                = "MirrorBoxCut_up_sect$i"."mirr$j"."half$k";
					$detector{"mother"}              = "htcc";
					$detector{"description"}         = "subtraction of upper box from (barrel - ellipse)";
					$detector{"pos"}                 = "$x0"."*mm $y0"."*mm $z0"."*mm";
					$detector{"rotation"}            = "ordered: yzx 0*rad $sphirot"."*rad $stheta_axis"."*rad ";
					$detector{"color"}               = "ffffff";
					$detector{"type"}                = "Operation:@ BarrelEllipseCut_sect$i"."mirr$j"."half$k - Boxcut_up_sect$i"."mirr$j"."half$k";
					$detector{"dimensions"}          = "0";
					$detector{"material"}            = "Component";
					print_det(\%configuration, \%detector);
					
					# define the operation that removes everything below the inner cone:
					%detector = init_det();
					$detector{"name"}                = "MirrorConeCut_sect$i"."mirr$j"."half$k";
					$detector{"mother"}              = "htcc";
					$detector{"description"}         = "subtraction of lower cone from (barrel - ellipse - box)";
					$detector{"pos"}                 = "$x0"."*mm $y0"."*mm $z0"."*mm";
					$detector{"rotation"}            = "ordered: yzx 0*rad $sphirot"."*rad $stheta_axis"."*rad";
					$detector{"color"}               = "ffffff";
					$detector{"type"}                = "Operation:@ MirrorBoxCut_up_sect$i"."mirr$j"."half$k - HTCC_InnerCutCone";
					$detector{"dimensions"}          = "0";
					$detector{"material"}            = "Component";
					print_det(\%configuration, \%detector);
					
					# final mirror: intersection of (barrel - ellipsoid - upper plane box - inner theta cone ) * phi slice:
					
					%detector = init_det();
				    $detector{"name"}           = htccName("mirror", $i, $j, ($k+1)%2+1);
					$detector{"mother"}         = "htcc";
				    $detector{"description"}    = htccDesc("mirror", $i, $j, ($k+1)%2+1);
					$detector{"pos"}            = "$x0"."*mm $y0"."*mm $z0"."*mm";
					$detector{"rotation"}       = "ordered: yzx 0*rad $sphirot"."*rad $stheta_axis"."*rad";
					$detector{"color"}          = $colors_even[$color_index];
					$detector{"type"}           = "Operation:@ MirrorConeCut_sect$i"."mirr$j"."half$k * phicut_sect$i"."half$k";
					$detector{"dimensions"}     = "0";
					$detector{"style"}          = "1";
					$detector{"material"}       = "rohacell31";
					# The "mirror" sensitivity allow gemc to access the mirror to define the optical properties
					# The identfier is sector*1000 + 1/2*10 + mirror
					my $MirId = $i*1000 + $k*10 + $j;
					$detector{"sensitivity"}    = "mirror: htcc_AlMgF2";
					$detector{"hit_type"}       = "mirror";
					$detector{"identifiers"}    = "id manual $MirId";
					print_det(\%configuration, \%detector);
										
				}
			}
		}
	}
}




