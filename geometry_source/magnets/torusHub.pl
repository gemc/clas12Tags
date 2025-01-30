use strict;
use warnings;

our %configuration;

# To check:
# - there is an additional plate for the warm bore shield

our $TorusLength;

my $microgap = 0.1;

# Torus Hub - it's aluminum. Measurements from https://userweb.jlab.org/~zarecky/Hub%20Assembly/B000000401-1130%20Rev%20A%20Hub%20Assembly.pdf
my $ColdHubLength = 1948.1/2.0;
my $ColdHubIR     = 175.0/2.0 ;    # taken from new drawing by D. Kashy - 87.5mm
my $ColdHubOR     = 240.0/2.0 ;    # 32 mm thicknes according to the drawing

# Warm Bore Tube: it's the innermost part of the torus. Stainless Steel. Measurements from https://userweb.jlab.org/~zarecky/Hub%20Assembly/B000000401-1132%20Rev%20A%20Warm%20Bore%20Tube%20-%20Hub.pdf
my $WarmBoreLength = 2146.38/2;
my $WarmBoreIR      = 125.35/2.0 ;
my $WarmBoreOR      = 127.0/2.0 ;

# Warm Bore Tube Shield: heat shield torus from the inner part. Copper
# Measurements taken from https://userweb.jlab.org/~zarecky/Hub%20Assembly/B00000-04-01-1133%20Center%20Tube%20-%20Shield%20-%20Hub.pdf
my $BoreShieldLength = 1988.4/2.0;
my $BoreShieldIR     = 148.9/2.0 ;  
my $BoreShieldOR     = 152.4/2.0 ;

sub torusHub()
{
	# main hub
	my %detector = init_det();
	$detector{"name"}        = "torusColdHub";
	$detector{"mother"}      = "torusVacuumFrame";
	$detector{"description"} = "Torus Cold Hub";
	$detector{"color"}       = "ee66ee";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$ColdHubIR*mm $ColdHubOR*mm $ColdHubLength*mm  0.0*deg 360.0*deg";
	$detector{"material"}    = "G4_Al";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	# warm bore
	%detector = init_det();
	$detector{"name"}        = "torusWarmBore";
	$detector{"mother"}      = "torusVacuumFrame";
	$detector{"description"} = "Torus Warm Bore";
	$detector{"color"}       = "eeee22";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$WarmBoreIR*mm $WarmBoreOR*mm $WarmBoreLength*mm  0.0*deg 360.0*deg";
	$detector{"material"}    = "G4_STAINLESS-STEEL";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
	
	# warm bore shield
	%detector = init_det();
	$detector{"name"}        = "torusWarmBoreShield";
	$detector{"mother"}      = "torusVacuumFrame";
	$detector{"description"} = "Torus Warm Bore";
	$detector{"color"}       = "ee66ee";
	$detector{"type"}        = "Tube";
	$detector{"dimensions"}  = "$BoreShieldIR*mm $BoreShieldOR*mm $BoreShieldLength*mm  0.0*deg 360.0*deg";
	$detector{"material"}    = "G4_Cu";
	$detector{"style"}       = 1;
	print_det(\%configuration, \%detector);
}


