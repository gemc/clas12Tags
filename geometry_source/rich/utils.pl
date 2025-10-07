use strict;
use warnings;

our %configuration;
our %parameters;


# RICH parameters
# all dimensions are in inches

my $RichBox_x     = $parameters{"par_RichBox_x"};
my $RichBox_y     = $parameters{"par_RichBox_y"};
my $RichBox_z     = $parameters{"par_RichBox_z"};
my $RichBox_the   = $parameters{"par_RichBox_the"};
my $RichBox_phi   = $parameters{"par_RichBox_phi"};
my $RichBox_psi   = $parameters{"par_RichBox_psi"};


my $RichBox_y_offset = $parameters{"par_RichBox_y_offset"};

my $RichBox_y_real = $RichBox_y + $RichBox_y_offset ;

sub rich_box_pos
{
	my $sector = shift;

	# projection into the xy plane
	my $phi = ($sector -1)*60;
	my $r = sqrt( $RichBox_x* $RichBox_x + $RichBox_y_real*$RichBox_y_real) ;
	my $x = $r*cos(rad($phi));
	my $y = $r*sin(rad($phi));
	my $z = $RichBox_z;

	print "phi, x, y, z are $phi $x $y $z \n";

	return "$x*mm $y*mm $z*mm";
}

sub rich_box_rot
{
	my $sector = shift;

	# projection into the xy plane
	my $phi = $RichBox_phi ;
	my $the = $RichBox_the*( -1 )**($sector + 1) ;
	my $psi = $RichBox_psi + ($sector -1)*60;

	my $tilt  = fstr($RichBox_the);
	my $zrot  = -($sector-1)*60 + 90;

#	print "phi, the, psi are $phi $the $psi \n";

	return "ordered: zxy $zrot*deg $tilt*deg 0*deg ";

#	return "$phi*deg $the*deg $psi*deg";
}

1;
