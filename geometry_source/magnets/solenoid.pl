use strict;
use warnings;

our %configuration;

my $nplanes = 14;

my $bolt_height = 18.00;
my $bolt_length = 105.7;
my $bolt_shift  = 15.7;
my $bolt_dist   = 252.82;
my $bolt_dist2  = 441.5;

# Corner:          1          2          3                     4                        5           6        7                         8                        9        10      11                         12                        13     14
my @iradius  = (536.250 ,  390.00 , 390.00                 , 390.00                 , 390.00  ,  390.00 ,  390.00                ,  390.00                ,  390.00 ,  390.00 ,  390.0                 ,  390.0                 ,  390.0  ,  784.0  );  # Inner radii of solenoid
my @oradius  = (1020.00 , 1020.00 , 1020.00 + $bolt_height , 1020.00 + $bolt_height , 1020.00 , 1020.00 , 1020.00 + $bolt_height , 1020.00 + $bolt_height , 1020.00 , 1020.00 , 1020.00 + $bolt_height , 1020.00 + $bolt_height , 1020.00 , 1020.00 );  # Outer radii of solenoid
my @zplane   = (   0.00 ,    0.00 ,    0.00                ,    0.00                ,    0.00 ,    0.00 ,    0.00                , 0.00                   ,    0.00 ,    0.00 ,    0.00                ,    0.00                ,    0.00 ,    0.00 );  # z coordinate of corners

$zplane[0]  = 0.0;
$zplane[1]  = 425.00;
$zplane[2]  = 425.00  +   $bolt_shift;
$zplane[3]  = 425.00  +   $bolt_shift +   $bolt_length;
$zplane[4]  = 425.00  + 2*$bolt_shift +   $bolt_length;
$zplane[5]  = 425.00  + 2*$bolt_shift +   $bolt_length +   $bolt_dist;
$zplane[6]  = 425.00  + 3*$bolt_shift +   $bolt_length +   $bolt_dist;
$zplane[7]  = 425.00  + 3*$bolt_shift + 2*$bolt_length +   $bolt_dist;
$zplane[8]  = 425.00  + 4*$bolt_shift + 2*$bolt_length +   $bolt_dist;
$zplane[9]  = 425.00  + 4*$bolt_shift + 2*$bolt_length + 2*$bolt_dist;
$zplane[10] = 425.00  + 5*$bolt_shift + 2*$bolt_length + 2*$bolt_dist;
$zplane[11] = 425.00  + 5*$bolt_shift + 3*$bolt_length + 2*$bolt_dist;
$zplane[12] = 425.00  + 6*$bolt_shift + 3*$bolt_length + 2*$bolt_dist;
$zplane[13] = 425.00  + 6*$bolt_shift + 3*$bolt_length + 2*$bolt_dist + $bolt_dist2;


my $zstart    = -898.093 ;             # z coordinate of border


sub makeSolenoid
{
    $configuration{"variation"} = shift;
    $configuration{"run_number"} = shift;
    $configuration{"factory"} = shift;
    $configuration{"detector_name"} = "solenoid";

	my $dimensions = "0.0*deg 360.0*deg $nplanes*counts";
	for(my $i = 0; $i <$nplanes ; $i++)
	{
		$dimensions = $dimensions ." $iradius[$i]*mm";
	}
	for(my $i = 0; $i <$nplanes ; $i++)
	{
		$dimensions = $dimensions ." $oradius[$i]*mm";
	}
	for(my $i = 0; $i <$nplanes ; $i++)
	{
		$dimensions = $dimensions ." $zplane[$i]*mm";
	}

	my %detector = init_det();
	$detector{"name"}        = "solenoid";
	$detector{"mother"}      = "root";
	$detector{"description"} = "Solenoid";
	$detector{"pos"}         = "0*cm 0.0*cm $zstart*mm";
	$detector{"rotation"}    = "0*deg 0*deg 0*deg";
	$detector{"color"}       = "0000ff";
	$detector{"type"}        = "Polycone";
	$detector{"dimensions"}	 = "$dimensions";
	$detector{"material"}    = "G4_Cu";
	$detector{"visible"}     = 1;
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
}















