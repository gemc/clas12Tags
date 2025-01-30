use strict;
use warnings;
use Getopt::Long;
use Math::Trig;

our %configuration;
our $microgap = 0.1;
our $CZpos;    # Position of the front face of the crystals
our $Clength;    # Crystal length in mm

our $supportLength;
our $pipeIR ;
our $pipeOR ;
our $pipeL;


our $CrminD;
our $CrmaxD;

our $Smax ;

our $CrminU;

our $CexitAngle;

our $Addoradius;
our $AddsupportLength;


sub buildBeamPipe
{
	my %detector = init_det();
	$detector{"name"}        = "vaccumPipe";
	$detector{"mother"}      = "root";
	$detector{"description"} = "volume containing cherenkov gas";
	$detector{"color"}       = "aabbbb";
   my $pipeZPos = $pipeL + 400;
   $detector{"pos"}         = "0*cm 0*cm $pipeZPos*mm";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$pipeIR*mm $pipeOR*mm $pipeL*mm 0*deg 360*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = "1";
   print_det(\%configuration, \%detector);
	
	my $pipeORS = $pipeOR + $microgap;
	
   my @mucal_zpos    = ( $CZpos              , $CZpos +  $Clength + 2*$microgap, $CZpos +  $Clength + 2*$microgap, $CZpos +  $Clength + $supportLength + $AddsupportLength   );
   my @mucal_iradius = ( $pipeORS            , $pipeORS                        , $pipeORS                        ,  $pipeORS                                                 );
   my @mucal_oradius = ( $CrminU - 50*$microgap , $CrminU - 50*$microgap             , $CrmaxD + $Addoradius           ,  $Smax + $Addoradius + $AddsupportLength*tan($CexitAngle) );
	#	my @mucal_oradius = ( $CrminU - $microgap , $CrminD - $microgap             , $CrmaxD + $Addoradius           ,  $Smax + $Addoradius + $AddsupportLength*tan($CexitAngle) );


   my $nplanes = 4;
   
   my $dimen = "0.0*deg 360*deg $nplanes*counts";
   for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $mucal_iradius[$i]*mm";}
   for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $mucal_oradius[$i]*mm";}
   for(my $i = 0; $i <$nplanes; $i++) {$dimen = $dimen ." $mucal_zpos[$i]*mm";}

   
	%detector = init_det();
	$detector{"name"}        = "supportCone";
	$detector{"mother"}      = "root";
	$detector{"description"} = "volume containing cherenkov gas";
	$detector{"color"}       = "55ff55";
	$detector{"type"}        = "Polycone";
	$detector{"dimensions"}  = $dimen;
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = "1";
   print_det(\%configuration, \%detector);

}
