# Written by Andrey Kim (kenjo@jlab.org)
package coatjava;

use strict;
use warnings;

use geometry;
use GXML;

my ($mothers, $positions, $rotations, $types, $dimensions, $ids);

my $npaddles = 48;

sub makeCTOF
{
	($mothers, $positions, $rotations, $types, $dimensions, $ids) = @main::volumes;

	my $dirName = shift;
	build_gxml($dirName);
	build_upstream_gxml("${dirName}_upstream");
}

sub build_gxml
{
	my $dirName = shift;
	my $gxmlFile = new GXML($dirName);

	build_paddles($gxmlFile);
	#build_upLightGuides($gxmlFile);
	build_downLightGuides($gxmlFile);

	$gxmlFile->print();
}

sub build_upstream_gxml
{
	my $dirName = shift;
	my $gxmlFile = new GXML($dirName);

	build_upLightGuides($gxmlFile);

	$gxmlFile->print();
}

sub build_paddles
{
	my $gxmlFile = shift;
	for(my $ipaddle=1; $ipaddle<=$npaddles; $ipaddle++){
		my %detector = init_det();

		my $vname                = sprintf("sc%02d", $ipaddle);

		$detector{"name"}        = $vname;
		$detector{"pos"}         = $positions->{$vname};
		$detector{"rotation"}    = $rotations->{$vname};

		$detector{"mother"}    = "";

		$detector{"color"}       = "444444";
		$detector{"material"}    = "scintillator";
		$detector{"sensitivity"} = "ctof";
		$detector{"hitType"}     = "ctof";

		$detector{"identifiers"}    = sprintf("paddle manual %d side manual 0", $ipaddle);


		my $paddleid = $ipaddle + 35;
		if ($ipaddle>13){
			$paddleid = $ipaddle - 13;
		}

		$gxmlFile->add(\%detector);
	}
}


sub build_upLightGuides
{
	my $gxmlFile = shift;
	for(my $ipaddle=1; $ipaddle<=$npaddles; $ipaddle++){
		my %detector = init_det();

		my $vname                = sprintf("lgu%02d", $ipaddle);
		my $vvname               = sprintf("lgd%02d", $ipaddle);


		# add 1mm gap between paddles and light guides to avoid overlaps
		my $pos = $positions->{$vvname};
		my $gap = 0.2;

		my ($x, $y, $z) = $pos =~ /([\d.]+)\*cm/g;
		$z -= $gap;
		$pos = "${x}*cm ${y}*cm ${z}*cm";

		$detector{"name"}        = $vname;
		$detector{"pos"}         = $pos;
		$detector{"rotation"}    = $rotations->{$vvname};


		$detector{"mother"}    = "";

		$detector{"color"}       = "666666";
		$detector{"material"}    = "scintillator";

		$gxmlFile->add(\%detector);
	}
}


sub build_downLightGuides
{
	my $gxmlFile = shift;
	for(my $ipaddle=1; $ipaddle<=$npaddles; $ipaddle++){
		my %detector = init_det();

		my $vname                = sprintf("lgd%02d", $ipaddle);

		# add 1mm gap between paddles and light guides to avoid overlaps
		my $pos = $positions->{$vname};
		my $gap = 0.1;

		my ($x, $y, $z) = $pos =~ /([\d.]+)\*cm/g;
		$z += $gap;
		$pos = "${x}*cm ${y}*cm ${z}*cm";


		$detector{"name"}        = $vname;
		$detector{"pos"}         = $pos;
		$detector{"rotation"}    = $rotations->{$vname};

		$detector{"mother"}    = "";

		$detector{"color"}       = "666666";
		$detector{"material"}    = "scintillator";

		$gxmlFile->add(\%detector);
	}
}



1;
