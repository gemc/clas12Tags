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
my %color = ('kapton' => "bf0000", "Al" => "2a3158", "gas" => " afb0ba", "Cu" => "fd7f00", "dlc" => "14b6ce", "Cr" => "1433ce", "glue" => "14ce3d", "g10" => "aa44d8", "nomex" => "ecdb3a");

my @window = ("kapton", "Al", "gas");
my @cathode = ("kapton", "Al", "gas");
my @muRwell = ("Cu", "kapton", "dlc");
my @capa_sharing_layer1 = ("glue", "Cr", "kapton");
my @capa_sharing_layer2 = ("glue", "Cr", "kapton");
my @readout1 = ("glue", "Cu", "kapton");
my @readout2 = ("glue", "Cu", "kapton");
my @readout3 = ("glue");
my @support_skin1 = ("g10");
my @support_skin2 =("g10");
my @support_honeycomb = ("nomex");



sub make_region_proto
{
    my $iregion = shift;
 
    my $region = $iregion;
    my $nSectors = 1;
    my $nChambers = 1;
    my $isProto =1;
    
    
    for(my $R=1; $R<=$region; $R++){
    for(my $s=1; $s<=$nSectors; $s++)
    {

        my $ss = 6;
        my %detector = init_det();
        my $vname = "region_uRwell_$R"."_s$ss"."_proto";
        
        $detector{"name"}        = $vname;
        $detector{"mother"}      = $mothers->{$vname};
        $detector{"description"} = "CLAS12 uRwells, Sector $ss Region $R";

        $detector{"pos"}            = $positions->{$vname};
        $detector{"rotation"}   = $rotations->{$vname};
        $detector{"type"}           = $types->{$vname};
        $detector{"dimensions"}  = $dimensions->{$vname};

        $detector{"color"}       = "aa0000";
        $detector{"material"}    = "G4_Galactic";
        $detector{"style"}       = 0;
        $detector{"visible"}     = 0;
        print_det(\%main::configuration, \%detector);
        make_chamber($R,$ss,$nChambers,$isProto);
    
    }
    }
}




sub make_region
{
	my $iregion = shift;

    #	my $region = $iregion + 1;
    my $region =$iregion;
    my $nSectors = 6;
    my $nChambers = 3;
    my $isProto =0;
    
    for(my $R=1; $R<=$region; $R++){
	for(my $s=1; $s<=$nSectors; $s++)
	{
		my %detector = init_det();
		my $vname = "region_uRwell_$R"."_s$s";
        
		$detector{"name"}        = $vname;
		$detector{"mother"}      = $mothers->{$vname};

		$detector{"description"} = "CLAS12 uRwells, Sector $s Region $R";

		$detector{"pos"}            = $positions->{$vname};
		$detector{"rotation"}   = $rotations->{$vname};
		$detector{"type"}           = $types->{$vname};
		$detector{"dimensions"}  = $dimensions->{$vname};

		$detector{"color"}       = "aa0000";
		$detector{"material"}    = "G4_Galactic";
        $detector{"style"}       = 0;
		$detector{"visible"}     = 0;
		print_det(\%main::configuration, \%detector);
        make_chamber($R,$s,$nChambers,$isProto);
    
    }
    }
}

sub make_chamber
{
    my $iRegion = $_[0];
    my $isector = $_[1];
    my $nChambers =$_[2];
    my $isProto = $_[3];

    
    for(my $c=1; $c<=$nChambers; $c++){
        my %detector = init_det();
        my $vname = "rg$iRegion"."_s$isector"."_c$c";
        if($isProto == 1){
            $vname = "rg$iRegion"."_s$isector"."_c$c"."_proto";
        }
        $detector{"name"}        = $vname;
        $detector{"mother"}      = $mothers->{$vname};
        $detector{"description"} = "Region $iRegion,Sector $isector, Chamber $c";

        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"type"} = $types->{$vname};
        $detector{"dimensions"}  = $dimensions->{$vname};
        if($c ==1){
        $detector{"color"}       = "4f84f7";
        }
        if($c ==2){
        $detector{"color"}       = "ff73f3";
        }
        if($c ==3){
        $detector{"color"}       = "f76b4f";
        }
        $detector{"material"}    = "G4_Galactic";
        $detector{"style"}       = 0;
        $detector{"visible"}     = 0;
        print_det(\%main::configuration, \%detector);
        
        # Window
        for(my $ii=0; $ii<=$#window; $ii++) {
        make_layers($iRegion, $isector, $c, "window",$window[$ii], $isProto);
        }
        
        # Cathode
        for(my $ii=0; $ii<=$#cathode; $ii++) {
        make_layers($iRegion, $isector, $c, "cathode",$cathode[$ii], $isProto);
        }
        
        #muRwell
        for(my $ii=0; $ii<=$#muRwell; $ii++) {
        make_layers($iRegion, $isector, $c, "muRwell",$muRwell[$ii], $isProto);
        }
        
        #@capa_sharing_layer1
        for(my $ii=0; $ii<=$#capa_sharing_layer1; $ii++) {
        make_layers($iRegion, $isector, $c, "capa_sharing_layer1",$capa_sharing_layer1[$ii], $isProto);
        }
        
        #@capa_sharing_layer2
        for(my $ii=0; $ii<=$#capa_sharing_layer2; $ii++) {
        make_layers($iRegion, $isector, $c, "capa_sharing_layer2",$capa_sharing_layer2[$ii], $isProto);
        }
        
        #@readout1
        for(my $ii=0; $ii<=$#readout1; $ii++) {
        make_layers($iRegion, $isector, $c, "readout1",$readout1[$ii], $isProto);
        }

        #@readout2
        for(my $ii=0; $ii<=$#readout2; $ii++) {
        make_layers($iRegion, $isector, $c, "readout2",$readout2[$ii], $isProto);
        }

        #@readout3
        for(my $ii=0; $ii<=$#readout3; $ii++) {
        make_layers($iRegion, $isector, $c, "readout3",$readout3[$ii], $isProto);
        }
        
        #@support_skin1
        for(my $ii=0; $ii<=$#support_skin1; $ii++) {
        make_layers($iRegion, $isector, $c, "support_skin1",$support_skin1[$ii], $isProto);
        }

        #@support_skin2
        for(my $ii=0; $ii<=$#support_skin2; $ii++) {
        make_layers($iRegion, $isector, $c, "support_skin2",$support_skin2[$ii], $isProto);
        }
        
        #@support_honeycomb
        for(my $ii=0; $ii<=$#support_honeycomb; $ii++) {
        make_layers($iRegion, $isector, $c, "support_honeycomb",$support_honeycomb[$ii], $isProto);
        }
        
    }
    
}

# Layers

sub make_layers{
    my $iRegion = $_[0];
    my $isector = $_[1];
    my $nChamber = $_[2];
    my $layer = $_[3];
    my $material = $_[4];
    my $isProto = $_[5];
    my %detector = init_det();
    

    my $vname = "rg$iRegion"."_s$isector"."_c$nChamber"."_$layer"."_$material";
    if($isProto ==1){
        $vname = "rg$iRegion"."_s$isector"."_c$nChamber"."_$layer"."_$material"."_proto";
    }

    $detector{"name"}        = $vname;
    $detector{"mother"}      = $mothers->{$vname};
    $detector{"description"} = "Region $iRegion,Sector $isector, Chamber $nChamber, $layer $material";
    $detector{"pos"} = $positions->{$vname};
    $detector{"rotation"} = $rotations->{$vname};
    $detector{"type"} = $types->{$vname};
    $detector{"dimensions"}  = $dimensions->{$vname};
    $detector{"color"}       = $color{$material};
    $detector{"material"}    = $material;
    
    if($layer eq "cathode" && $material eq "gas" ){
        $detector{"sensitivity"} = "urwell";
        $detector{"hit_type"} = "urwell";
        $detector{"identifiers"} ="region manual $iRegion sector manual $isector chamber manual $nChamber layer manual 1 component manual 1";
    }
    $detector{"style"}       = 1;
    $detector{"visible"}     = 1;
    print_det(\%main::configuration, \%detector);

}





sub makeURWELL
{

	($mothers, $positions, $rotations, $types, $dimensions, $ids) = @main::volumes;
   
    my $NRegion = shift;
 
    make_region($NRegion);


}

sub makeURWELL_PROTO
{
    ($mothers, $positions, $rotations, $types, $dimensions, $ids) = @main::volumes;

    my $NRegion = shift;
    make_region_proto($NRegion);


}



1;
