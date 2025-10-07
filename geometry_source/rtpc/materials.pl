#!/usr/bin/perl -w

use strict;
use warnings;

our %configuration;

sub materials
{
	# PCB  Most likely came from detectors/clas12/bst/materials.pl
	my %mat = init_mat();
	$mat{"name"}          = "PCB";
	$mat{"description"}   = "Printed circuit board";
	$mat{"density"}       = "1.850";  # in g/cm3
	$mat{"ncomponents"}   = "3";
	$mat{"components"}    = "G4_Fe 0.3 G4_C 0.4 G4_Si 0.3";
	print_mat(\%configuration, \%mat);
    
    # Rohacell (used the rohacell31 in gemc, which is consistent with detectors/clas12/micromegas/materials.pl)
    %mat = init_mat();
    $mat{"name"}          = "Rohacell"; 
    $mat{"description"}   = "Rohacell Foam";
    $mat{"density"}       = "0.032";  # in g/cm3
    $mat{"ncomponents"}   = "4";
    $mat{"components"}    = "G4_C 0.6463 G4_H 0.0784 G4_N 0.0839 G4_O 0.1914";
    print_mat(\%configuration, \%mat);

    # Ultem  (Polyetherimide (C37H24O6N2)n )
    %mat = init_mat();
    $mat{"name"}          = "Ultem";
    $mat{"description"}   = "Ultem";
    $mat{"density"}       = "1.27";  # in g/cm3 https://dielectricmfg.com/knowledge-base/ultem/
    $mat{"ncomponents"}   = "4";
    $mat{"components"}    = "G4_C 0.75 G4_H 0.0405 G4_O 0.1622 G4_N 0.0473"; # the sum of ratio should be 1
    print_mat(\%configuration, \%mat);
    
	# Epoxy resin (C21H25ClO5)
    %mat = init_mat();
    $mat{"name"}          = "epoxy_resin";
    $mat{"description"}   = "epoxy resin";
    $mat{"density"}       = "1.10"; # in g/cm3  
    $mat{"ncomponents"}   = "4";
    $mat{"components"}    = "G4_C 0.6429 G4_H 0.0638 G4_Cl 0.0892 G4_O 0.2041";
    print_mat(\%configuration, \%mat);
    
    #G10  
    %mat = init_mat();
    $mat{"name"}          = "G10_rtpc";
    $mat{"description"}   = "G10 material";
    $mat{"density"}       = "1.80"; # g/cm3 https://www.curbellplastics.com/Research-Solutions/Materials/G10-FR-4-Glass-Epoxy
    $mat{"ncomponents"}   = "2";
    $mat{"components"}    = "G4_SILICON_DIOXIDE 0.60 epoxy_resin 0.40"; # The ratios were referred from the detectors/clas12/upstreamBeampipe/materials.pl
    print_mat(\%configuration, \%mat);
    
    # DriftbonusGas  // based on P: 1atm, T: 293.15K
    %mat = init_mat();
    my $He_prop = 0.8;
    my $CO2_prop = 0.2;
    my $He_dens = 0.0001664;
    my $CO2_dens = 0.0018233;
    my $He_fractionMass = ($He_prop*$He_dens)/($He_prop*$He_dens + $CO2_prop*$CO2_dens);
    my $CO2_fractionMass = ($CO2_prop*$CO2_dens)/($He_prop*$He_dens + $CO2_prop*$CO2_dens);
    my $bonusGas_Density = $He_prop*$He_dens+$CO2_prop*$CO2_dens;
    $mat{"name"}          = "BONuSGas";
    $mat{"description"}   = "80:20 He:CO2 Drift region BONuS12 Gas at 1atm,293.15K";
    $mat{"density"}       = $bonusGas_Density;  # in g/cm3
    $mat{"ncomponents"}   = "2";
    $mat{"components"}    = "G4_He $He_fractionMass G4_CARBON_DIOXIDE $CO2_fractionMass"; # The components should convert to the mass fraction in Geant4, not volume fraction.
    print_mat(\%configuration, \%mat);
    
    # Connector material is Vectra E130i: 30% glass filled liquid crystal polymer
	  # LCP (liquid crystal polymer): HNA(C11H8O3) + HBA(C7H6O3)
    %mat = init_mat();
    $mat{"name"}          = "LCP";
    $mat{"description"}   = "liquid crystal polymer";
    $mat{"density"}       = "1.357";  # in g/cm3, calculated from rtpc_Vectra and SiO2(density = 2.2 g/cm3)
    $mat{"ncomponents"}   = "3";
    $mat{"components"}    = "C 18 H 14 O 6";
    print_mat(\%configuration, \%mat);
	  # Vectra E130i: 30% SiO2 + 0.7 LCP
    %mat = init_mat();
    $mat{"name"}          = "rtpc_Vectra";
    $mat{"description"}   = "Vectra E130i";
    $mat{"density"}       = "1.610";  # in g/cm3
    $mat{"ncomponents"}   = "2";
    $mat{"components"}    = "G4_SILICON_DIOXIDE 0.30 LCP 0.70";
    print_mat(\%configuration, \%mat);
	  # protectionCircuit: 0.5 rtpc_Vectra + 0.5 G4_AIR
    %mat = init_mat();
    $mat{"name"}          = "protectionCircuit";
    $mat{"description"}   = "protection circuit";
    $mat{"density"}       = "0.806";  # in g/cm3 0.5*1.610 + 0.5*0.001225
    $mat{"ncomponents"}   = "2";
    $mat{"components"}    = "G4_AIR 0.5 rtpc_Vectra 0.5";
    print_mat(\%configuration, \%mat);
    
    
    # Material smearing of the electronics, ribs, and spines 
    %mat = init_mat();
    my $G10_prop = 0.098;
    my $air_prop = 0.519;
    my $vectra_prop = 0.383;
    
    my $G10_dens = 1.8;
    my $vectra_dens = 1.61;
    my $air_dens = 0.001225;
    my $ERS_density = $G10_prop * $G10_dens + $vectra_prop * $vectra_dens + $air_prop * $air_dens;
    $mat{"name"}          = "ERS";
    $mat{"description"}   = "Electronics, ribs, and spines";
    $mat{"density"}       = $ERS_density;  # in g/cm3
    $mat{"ncomponents"}   = "3";
    $mat{"components"}    = "G10_rtpc $G10_prop rtpc_Vectra $vectra_prop G4_AIR $air_prop";
    print_mat(\%configuration, \%mat);

}

