package clas12_configuration_string;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(clas12_configuration_string clas12_runs clas12_run clas12_variation);

my %custom_variations = map {$_ => 1} (
    "pbtest", "ND3", "hdice", "longitudinal", "transverse", "ddvcs",
    "rghFTOut", "rghFTOn", "TransverseUpstreamBeampipe",
    "michel_9mmcopper"
);

# Centralized mapping
my %variation_to_run = (
    "default"        => 11,
    "rga_spring2018" => 3029,
    "rga_fall2018"   => 4763,
    "rga_spring2019" => 6608,
    "rgk_fall2018"   => 5674,
    "rgk_winter2018" => 5874,
    "rgk_winter2023" => 19200,
    "rgk_spring2024" => 19300,
    "rgb_spring2019" => 6150,
    "rgb_fall2019"   => 11093,
    "rgb_winter2020" => 11323,
    "rgf_spring2020" => 11620,
    "rgf_summer2020" => 12389,
    "rgm_winter2021" => 15016,
    "rgc_summer2022" => 16043,
    "rgc_fall2022"   => 16843,
    "rgc_winter2023" => 17471,
    "rge_spring2024" => 20000,
    "rgl_spring2025" => 21000
);

# Reverse mapping for run -> variation
my %run_to_variation = reverse %variation_to_run;

sub clas12_configuration_string {

    my %configuration = %{+shift};
    my $varia = $configuration{"variation"};
    my $runno = $configuration{"run_number"};


    # Check if the input variation is a known custom variation
    if (exists $custom_variations{$varia}) {
        return $varia;
    }

    # Check if the run number maps to a known variation
    if (defined $runno && exists $run_to_variation{$runno}) {
        # if variation is default but run number is not 11, return the map value
        if ($varia eq "default" && $runno != 11) {
            return $run_to_variation{$runno};
        }
    }

    # Check if variation exists in the map
    if (exists $variation_to_run{$varia}) {
        return $varia;
    }

    # Default fallback
    return $varia;
}

sub clas12_runs {
    my @variations = @_;
    my @runs = map {clas12_run($_)} @variations;

    print " > Running variations and runs:\n";
    for (my $i = 0; $i < @variations; $i++) {
        print "   - $variations[$i] -> $runs[$i]\n";
    }
    print "\n";

    return @runs;
}

sub clas12_run {
    return $variation_to_run{$_[0]} // 0;
}

sub clas12_variation {
    my $run_number = shift;
    return $run_to_variation{$run_number} // "default";
}

1;
