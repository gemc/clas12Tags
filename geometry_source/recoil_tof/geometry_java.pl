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
 
sub make_sector
{
    my $nSectors = 2;
    my $nRows = 5;
    my $nCols = 63;

    
    for(my $s=1; $s<=$nSectors; $s++)
    {
	my %detector = init_det();
	my $vname = "recoil_tof_sector$s";
        
	$detector{"name"}        = $vname;
	$detector{"mother"}      = $mothers->{$vname};
	$detector{"description"} = "CLAS12 recoil TOF, Sector $s";
	$detector{"pos"}         = $positions->{$vname};
	$detector{"rotation"}    = $rotations->{$vname};
	$detector{"type"}        = $types->{$vname};
	$detector{"dimensions"}  = $dimensions->{$vname};
	$detector{"color"}       = "aa0000";
	$detector{"material"}    = "G4_Galactic";
	$detector{"style"}       = 0;
	$detector{"visible"}     = 0;
	print_det(\%main::configuration, \%detector);

	for(my $row=1; $row<=$nRows; $row++) {
	    for(my $col=1; $col<=$nCols; $col++) {
		make_bar($s, $row, $col);
    	    }
	}
    }	
    
}

sub make_bar
{
    my $iSector = $_[0];
    my $iRow = $_[1];
    my $iCol =$_[2];
    
    my %detector = init_det();

    my $vname = "bar_sector${iSector}_row${iRow}_column${iCol}";

    $detector{"name"}        = $vname;
    $detector{"mother"}      = $mothers->{$vname};
    $detector{"description"} = "Sector $iSector, Bar, row $iRow, column $iCol";
    $detector{"pos"}         = $positions->{$vname};
    $detector{"rotation"}    = $rotations->{$vname};
    $detector{"type"}        = $types->{$vname};
    $detector{"dimensions"}  = $dimensions->{$vname};
    $detector{"color"}    = "aa0000";
    $detector{"material"} = "scintillator";
    $detector{"style"}    = 0;
    $detector{"visible"}  = 1;
    $detector{"sensitivity"} = "recoil_tof";
    $detector{"hit_type"} = "recoil_tof";
    # set the identifiers
    $detector{"identifiers"}  = "sector manual $iSector row manual $iRow column manual $iCol order manual 0";
    print_det(\%main::configuration, \%detector);
        
}


sub makeRECOILTOF
{

    ($mothers, $positions, $rotations, $types, $dimensions, $ids) = @main::volumes;
   
    make_sector();


}

1;
