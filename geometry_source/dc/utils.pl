use strict;
use warnings;

our %configuration;
our %parameters;


our @mother_dx1;
our @mother_dx2;
our @mother_dy;
our @mother_dz;
our @mother_xcent;
our @mother_ycent;
our @mother_zcent;

our @daughter_dx1;
our @daughter_dx2;
our @daughter_dy;
our @daughter_dz;
our @daughter_palp;
our @daughter_xcent;
our @daughter_ycent;
our @daughter_zcent;
our @daughter_tilt;


sub calculate_dc_parameters
{
	# read parameters of the mother volume for 3 regions
	my $ifile = "mother-geom-ccdb.dat";
	#	my $ifile = "mother-geom-$configuration{\"variation\"}.dat";
	print "Open file ".$ifile."\n";
	
	
	open(FILE, $ifile);
	my @lines = <FILE>;
	close(FILE);
	foreach my $line (@lines)
	{
		if ($line !~ /#/)
		{
			chomp($line);
			my @numbers = split(/[ \t]+/,$line);
			(my $ireg, my $dx1, my $dx2, my $dy, my $dz, my $xcent, my $ycent, my $zcent) = @numbers;
			$ireg-- ;  # index is c++ convention
			$mother_dx1[$ireg]     = $dx1 + 1.0;   # Custom enlarging mother volume to contain daugthers
			$mother_dx2[$ireg]     = $dx2 + 1.0;
			$mother_dy[$ireg]      = $dy  + 1.0;
			$mother_dz[$ireg]      = $dz;
			$mother_xcent[$ireg]   = $xcent;
			$mother_ycent[$ireg]   = $ycent;
			$mother_zcent[$ireg]   = $zcent;
		}
	}
	
	
	
	# read parameters of the daughter volumes for 3 regions, 6 superlayers
	$ifile = "layers-geom-ccdb.dat";
	#	$ifile = "layers-geom-$configuration{\"variation\"}.dat";
	open(FILE, $ifile);
	@lines = <FILE>;
	close(FILE);
	foreach my $line (@lines)
	{
		if ($line !~ /#/)
		{
			chomp($line);
			my @numbers = split(/[ \t]+/,$line);
			(my $isup, my $ilayer, my $xcent, my $ycent, my $zcent, my $dx1, my $dx2, my $dy, my $palp, my $dz, my $tilt) = @numbers;
			# print $isup."\t".$ilayer."\t".$xcent."\t".$ycent."\t".$zcent."\t".$dx1."\t".$dx2."\t".$dy."\t".$palp."\t".$dz."\n";
			# index is c++ convention
			$ilayer-- ;
			$daughter_dx1[$isup][$ilayer]   = $dx1;
			$daughter_dx2[$isup][$ilayer]   = $dx2;
			$daughter_dy[$isup][$ilayer]    = $dy;
			$daughter_dz[$isup][$ilayer]    = $dz;
			$daughter_palp[$isup][$ilayer]  = $palp;
			$daughter_xcent[$isup][$ilayer] = $xcent;
			$daughter_ycent[$isup][$ilayer] = $ycent;
			$daughter_zcent[$isup][$ilayer] = $zcent;
			$daughter_tilt[$isup][$ilayer]  = $tilt;
		}
	}

}

my $tilt = 25;   # tilt angle in degrees

sub region_pos
{
	my $sector = shift;
	my $region = shift;
	
	my $mxplace = $mother_xcent[$region];
	my $myplace = $mother_ycent[$region];
	my $mzplace = $mother_zcent[$region];
	
    my $phi =  -($sector-1)*60 + 90;
    my $x = fstr( $mxplace*cos(rad($phi))+$myplace*sin(rad($phi)));
    my $y = fstr(-$mxplace*sin(rad($phi))+$myplace*cos(rad($phi)));
    my $z = fstr($mzplace);
	
	return "$x*cm $y*cm $z*cm";
}

sub region_rot
{

	my $sector = shift;
	my $region = shift;

	my $tilt  = fstr($tilt);
	my $zrot  = -($sector-1)*60 + 90;
	
	return "ordered: zxy $zrot*deg $tilt*deg 0*deg ";
}



1;
















