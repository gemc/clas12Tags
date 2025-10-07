use strict;
use warnings;



sub htccName
{
	my $element = shift;
	my $sindex = shift;
	my $rindex = shift;
	my $hindex = shift;
	
	
	
	my $ring_index = 4 - $rindex;

	
	my $sector = 0;
	
	if($hindex eq 1){ $sector = ($sindex + 2) % 6 + 1;}
	if($hindex eq 2){ $sector = ($sindex + 1) % 6 + 1;}

	
	
	return "$element"."_$ring_index"."_sector$sector"."_$hindex";
}


sub htccDesc
{
	my $element = shift;
	my $sindex = shift;
	my $rindex = shift;
	my $hindex = shift;
	
	
	
	my $ring_index = 4 - $rindex;
	
	
	my $sector = 0;
	
	if($hindex eq 1){ $sector = ($sindex + 2) % 6 + 1;}
	if($hindex eq 2){ $sector = ($sindex + 1) % 6 + 1;}
	
	my $half = "left";
	if($hindex eq 2) { $half = "right" ;}
	
	return "htcc $element"." $ring_index".", sector$sector"." $half";
}


sub htccIdentifier
{
	my $sindex = shift;
	my $rindex = shift;
	my $hindex = shift;
	
	my $ring_index = 4 - $rindex;
	
	my $sector = 0;
	
	if($hindex eq 1){ $sector = ($sindex + 2) % 6 + 1;}
	if($hindex eq 2){ $sector = ($sindex + 1) % 6 + 1;}
	
	return "sector manual $sector ring manual $ring_index half manual $hindex";
}



1;
