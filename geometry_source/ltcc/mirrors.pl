use strict;
use warnings;

use lib ("../");
use clas12_configuration_string;

our %configuration;

# Table of optical photon energies (wavelengths) from 170-650 nm:
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
"  6.1992105*eV  6.5254848*eV  6.8880107*eV  7.2931878*eV  ";

# Reflectivity of AlMgF2 coated on thermally shaped acrylic sheets, measured by AJRP, 10/01/2012:
my $reflectivity =
"  0.8331038     0.8309071     0.8279127     0.8280742     0.8322623 " .
"  0.837572      0.8396875     0.8481834     0.8660284     0.8611336 " .
"  0.8566167     0.8667431     0.86955       0.8722481     0.8728122 " .
"  0.8771635     0.879907      0.879761      0.8831943     0.8894673 " .
"  0.8984234     0.9009531     0.8910166     0.8887382     0.8869093 " .
"  0.8941976     0.8948479     0.8877356     0.9026919     0.8999685 " .
"  0.9101617     0.8983005     0.8991694     0.8990987     0.9000493 " .
"  0.9065833     0.9028855     0.8985184     0.9009736     0.9086968 " .
"  0.9015145     0.8914838     0.8816829     0.8666895     0.8452400" .
"  0.8293650     0.8095238     0.7857142     0.7579365 ";


sub buildMirrorsSurfaces
{
	# htcc gas is 100% CO2 with optical properties
	my %mat = init_mir();
	$mat{"name"}         = "ltcc_AlMgF2";
	$mat{"description"}  = "ltcc mirror reflectivity";
	$mat{"type"}         = "dielectric_metal";
	$mat{"finish"}       = "polished";
	$mat{"model"}        = "unified";
	$mat{"border"}       = "SkinSurface";
	$mat{"photonEnergy"} = $penergy ;
	$mat{"reflectivity"} = $reflectivity ;
	print_mir(\%configuration, \%mat);
}


