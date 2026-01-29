#!/usr/bin/env perl
package coatjava;
use strict;
use warnings;

use geometry;          # per init_det, print_det nel main
use FindBin;
use lib $FindBin::Bin;
require 'ccdb_utils.pl';   # stesso folder

# ==============================
# Configuration
# ==============================

our $VARIATION        = $ENV{CCDB_VARIATION} // 'default';
our $PATH_URWT_MAT    = "/test/muvt/muvt_material";
our $PATH_URWT_GLOBAL = "/test/muvt/muvt_global";

# material -> color (case-insensitive: keys lowercase)
our %color_for = (
    'kapton'    => 'bf0000',
    'al'        => '2a3158',
    'gas'       => 'afb0ba',
    'cu'        => 'fd7f00',
    'dlc'       => '14b6ce',
    'cr'        => '1433ce',
    'glue'      => '14ce3d',
    'g10'       => 'aa44d8',
    'nomex'     => 'ecdb3a',
    'honeycomb' => 'ecdb3a',
);

# Filled from CCDB by init_muvt_from_ccdb()
our %layer_material;   # layer -> component -> { material, sens }
our %global;           # Nsectors, NLayers, ...
our $NREGIONS;
our $NSECTORS;

# mothers/positions/rotations/types/dimensions filled altrove
our $mothers;
our $positions;
our $rotations;
our $types;
our $dimensions;

# ==============================
# Public API
# ==============================

# Da chiamare da muvt.pl PRIMA di make_muct()
sub init_muvt_from_ccdb {

    my ($variation) = @_;                  # <-- prende la variation se passata
    $VARIATION = $variation if defined $variation && $variation ne '';
    my $CCDB_CONN = $ENV{CCDB_CONNECTION}

      or die "CCDB_CONNECTION is not defined\n";

    my $dbh = connect_ccdb($CCDB_CONN);

    my $rows_material = read_ccdb_table($dbh, $PATH_URWT_MAT,    $VARIATION);
    my $rows_global   = read_ccdb_table($dbh, $PATH_URWT_GLOBAL, $VARIATION);

    %layer_material = build_layer_material_map($rows_material);
    %global         = parse_muvt_global($rows_global);

    $NREGIONS = int($global{NLayers} / 2.0 + 0.5);
    $NSECTORS = $global{Nsectors};

    # Debug opzionale
    print "=== muvt_global (variation=$VARIATION) ===\n";
    for my $k (sort keys %global) {
        printf "%-12s = %s\n", $k, $global{$k};
    }
    print "\nNREGIONS = $NREGIONS, NSECTORS = $NSECTORS\n";

    $dbh->disconnect;
}

sub make_detector{
    ($mothers, $positions, $rotations, $types, $dimensions) = @main::volumes;
    make_muvt();
}

sub make_muvt {
    for (my $R = 1; $R <= $NREGIONS; $R++) {
        for (my $S = 1; $S <= $NSECTORS; $S++) {

            my %detector = main::init_det();
            my $vname = "region_muvt_${R}_s${S}";

            $detector{"name"}        = $vname;
            $detector{"mother"}      = $mothers->{$vname};
            $detector{"description"} = "CLAS12 muvt, Sector $S Region $R";

            $detector{"pos"}         = $positions->{$vname};
            $detector{"rotation"}    = $rotations->{$vname};
            $detector{"type"}        = $types->{$vname};
            $detector{"dimensions"}  = $dimensions->{$vname};

            $detector{"color"}       = "aa0000";
            $detector{"material"}    = "G4_Galactic";
            $detector{"style"}       = 1;
            $detector{"visible"}     = 1;

            main::print_det(\%main::configuration, \%detector);
            make_muvt_structure($R, $S);
        }
    }
}

sub make_muvt_structure {
    my ($iRegion, $iSector) = @_;

    for my $layer (sort { $a <=> $b } keys %layer_material) {
        for my $component (sort { $a <=> $b } keys %{ $layer_material{$layer} }) {

            my $material = $layer_material{$layer}{$component}{material};
            my $sens     = $layer_material{$layer}{$component}{sens};
            my $ilayer    = $layer + ($iRegion - 1) * 2;  
            my %detector = main::init_det();
            my $vname = "rg_muvt_${iRegion}_s${iSector}_l${ilayer}_matC${component}";

            $detector{"name"}        = $vname;
            $detector{"mother"}      = $mothers->{$vname};
            $detector{"description"} =
              "Region $iRegion, Sector $iSector, Layer $layer, component $component, material $material";

            $detector{"pos"}        = $positions->{$vname};
            $detector{"rotation"}   = $rotations->{$vname};
            $detector{"type"}       = $types->{$vname};
            $detector{"dimensions"} = $dimensions->{$vname};

            my $key   = lc $material;
            my $color = $color_for{$key} // '000000';

            $detector{"color"}    = $color;
            $detector{"material"} = $material;

            if ($sens eq '1') {
                $detector{"sensitivity"} = "muvt";
                $detector{"hit_type"}    = "muvt";
                $detector{"identifiers"} =
                  "region manual $iRegion sector manual $iSector layer manual $layer component manual 1";
            }

            $detector{"style"}   = 1;
            $detector{"visible"} = 1;

            main::print_det(\%main::configuration, \%detector);
        }
    }
}

# ==============================
# muvt-specific parsers
# ==============================

sub build_layer_material_map {
    my ($rows) = @_;
    my %map;

    for my $r (@$rows) {
        my ($sector, $layer, $component, $name,
            $material, $density, $Z, $A, $ZoverA, $X0, $I, $thickness,  $sens) = @$r;

        $map{$layer}{$component} = {
            material => $material,
            sens     => $sens,
        };
    }

    return %map;
}

sub parse_muvt_global {
    my ($rows) = @_;
    die "muvt_global is expected to have at least one row\n"
      unless @$rows;

    my $g = $rows->[0];

    my %params;
    @params{
        qw(
          Nsectors
          NLayers
          NComponents
          Thopen
          Thtilt
          Thmin
          Thmax
          Tgt
          Dz
          TWidth
          Width
          Pitch
          StereoAngle
        )
    } = @$g;

    return %params;
}

1;  # IMPORTANT per require
