use strict;
use warnings;

our %configuration;

# Table of optical photon energies (wavelengths) from 190-650 nm:
my $penergy =
"  1.9074494*eV  1.9372533*eV  1.9680033*eV  1.9997453*eV  2.0325280*eV " .
"  2.0664035*eV  2.1014273*eV  2.1376588*eV  2.1751616*eV  2.2140038*eV " .
"  2.2542584*eV  2.2960039*eV  2.3393247*eV  2.3843117*eV  2.4310630*eV " .
"  2.4796842*eV  2.5302900*eV  2.5830044*eV  2.6379619*eV  2.6953089*eV " .
"  2.7552047*eV  2.8178230*eV  2.8833537*eV  2.9520050*eV  3.0240051*eV " .
"  3.0996053*eV  3.1790823*eV  3.2627424*eV  3.3509246*eV  3.4440059*eV " .
"  3.5424060*eV  3.6465944*eV  3.7570973*eV  3.8745066*eV  3.9994907*eV " .
"  4.1328070*eV  4.2753176*eV  4.4280075*eV  4.5920078*eV  4.7686235*eV " .
"  4.9593684*eV  5.1660088*eV  5.3906179*eV  5.6356459*eV  5.9040100*eV " .
"  6.1992105*eV  ";

# Reflectivity of AlMgF2 coated on thermally shaped acrylic sheets, measured by AJRP, 10/01/2012:
my $reflectivity =
" 0.857039 0.857293 0.856738 0.856274 0.856759 0.857221 " .
" 0.857728 0.859595 0.862254 0.860438 0.85846  0.860516 " .
" 0.859955 0.85901  0.858631 0.858253 0.858375 0.857274 " .
" 0.855112 0.856456 0.857805 0.857126 0.855172 0.852165 " .
" 0.849445 0.84416  0.842736 0.839978 0.846421 0.84075  " .
" 0.838185 0.836668 0.835591 0.828604 0.826597 0.82482  " .
" 0.823019 0.81091  0.805545 0.801419 0.791633 0.787155 " .
" 0.754003 0.735616 0.705016 0.722675 ";


sub buildMirrorsSurfaces
{
    # htcc gas is 100% CO2 with optical properties
	my %mat = init_mir();
	$mat{"name"}         = "htcc_AlMgF2";
	$mat{"description"}  = "htcc mirror AlMgF2";
	$mat{"type"}         = "dielectric_metal";
	$mat{"finish"}       = "polished";
	$mat{"model"}        = "unified";
	$mat{"border"}       = "SkinSurface";
	$mat{"photonEnergy"} = $penergy ;
	$mat{"reflectivity"} = $reflectivity ;	
	print_mir(\%configuration, \%mat);
}


