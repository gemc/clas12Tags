package clas12_configuration_string;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(clas12_configuration_string clas12_runs clas12_run);

my @custom_variations = ("pbTest", "ddvcs", "rghFTOut", "rghFTOn", "TransverseUpstreamBeampipe");


# Initialize hash maps
sub clas12_configuration_string {

    my %configuration = %{+shift};

    my $varia = $configuration{"variation"};
    my $runno = $configuration{"run_number"};

    # notice for SQLITE variation is always 'default' so
    # it cannot be a case here
    if ($varia eq "rga_spring2018" || $runno eq 3029) {
        return $varia;
    }
    elsif ($varia eq "rga_fall2018" || $runno eq 4763) {
        return $varia;
    }
    elsif ($varia eq "rga_spring2019" || $runno eq 6608) {
        return $varia;
    }
    elsif ($varia eq "rgk_fall2018" || $runno eq 5674) {
        return $varia;
    }
    elsif ($varia eq "rgk_winter2018" || $runno eq 5874) {
        return $varia;
    }
    elsif ($varia eq "rgb_spring2019" || $runno eq 6150) {
        return $varia;
    }
    elsif ($varia eq "rgb_fall2019" || $runno eq 11093) {
        return $varia;
    }
    elsif ($varia eq "rgb_winter2020" || $runno eq 11323) {
        return $varia;
    }
    elsif ($varia eq "rgf_spring2020" || $runno eq 11620) {
        return $varia;
    }
    elsif ($varia eq "rgm_winter2021" || $runno eq 15016) {
        return $varia;
    }
    elsif ($varia eq "rgc_summer2022" || $runno eq 16043) {
        return $varia;
    }
    elsif ($varia eq "rgc_fall2022" || $runno eq 16843) {
        return $varia;
    }
    elsif ($varia eq "rge_spring2024" || $runno eq 20000) {
        return $varia;
    }
    # if it's in @custom_variations, it's not associated to a real run number
    elsif (grep {$_ eq $varia} @custom_variations) {
        return $varia;
    }
    # if no run is found, return the variation itself
    else {
        return $varia;
    }
}
# Return an array of runs given an array of @variations
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

# Return the corresponding run number for a given variation
sub clas12_run {
    my %variation_to_run = (
        "default"        => 11,
        "rga_spring2018" => 3029,
        "rga_fall2018"   => 4763,
        "rga_spring2019" => 6608,
        "rgk_fall2018"   => 5674,
        "rgk_winter2018" => 5874,
        "rgb_spring2019" => 6150,
        "rgb_fall2019"   => 11093,
        "rgb_winter2020" => 11323,
        "rgf_spring2020" => 11620,
        "rgm_winter2021" => 15016,
        "rgc_summer2022" => 16043,
        "rgc_fall2022"   => 16843,
        "rge_spring2024" => 20000,
        "rgl_spring2025" => 21000
    );

    return $variation_to_run{$_[0]} // 0;
}

1;