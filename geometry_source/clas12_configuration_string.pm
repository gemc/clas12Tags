package clas12_configuration_string;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(clas12_configuration_string clas12_runs clas12_run clas12_runs_for_variations clas12_variation);

my %custom_variations = map {$_ => 1} (
    "pbtest", "ND3", "hdice", "longitudinal", "transverse", "ddvcs",
    "rghFTOut", "rghFTOn", "TransverseUpstreamBeampipe",
    "michel_9mmcopper"
);


# New mapping: variation => arrayref of runs
my %variation_to_runs = (
    "default"                    => [ 11 ],
    "rga_spring2018"             => [ 3029 ],
    "rga_fall2018"               => [ 4763 ],
    "rga_spring2019"             => [ 6608, 15016, 15534, 15628 ],
    "rgb_spring2019"             => [ 6150 ],
    "rgb_fall2019"               => [ 11093, 15043, 15434, 15566 ],
    "rgb_spring2020"             => [ 11323 ],
    "rgc_fall2022"               => [ 16843 ],
    "rgc_spring2023"             => [ 18305 ],
    "rge_spring2024_Empty_Al"    => [ 20506 ],
    "rge_spring2024_Empty_C"     => [ 20014, 20070 ],
    "rge_spring2024_Empty_Empty" => [ 20035, 20507 ],
    "rge_spring2024_Empty_Pb"    => [ 20269 ],
    "rge_spring2024_LD2_Al"      => [ 20435 ],
    "rge_spring2024_LD2_C"       => [ 20021, 20131, 20508 ],
    "rge_spring2024_LD2_Cu"      => [ 20177 ],
    "rge_spring2024_LD2_Pb"      => [ 20041, 20074, 20232, 20282, 20494, 20520 ],
    "rge_spring2024_LD2_Sn"      => [ 20331 ],
    "rgk_fall2018"               => [ 5674 ],
    "rgk_winter2018"             => [ 5874 ],
    "rgk_fall2023"             => [ 19200 ],
    "rgk_spring2024"             => [ 19300 ],
    "rgf_spring2020"             => [ 11620 ],
    "rgf_summer2020"             => [ 12389 ],
    "rgm_fall2021_He"            => [ 15108, 15458 ],
    "rgm_fall2021_C"             => [ 15643, 15733, 15766, 15778 ],
    "rgm_fall2021_C_v2_S"        => [ 15643 ],
    "rgm_fall2021_C_v2_L"        => [ 15733, 15766, 15778 ],
    "rgm_fall2021_Ar"            => [ 15671, 15734, 15789 ],
    "rgm_fall2021_Cx4"           => [ 15178 ],
    "rgm_fall2021_Ca"            => [ 15356, 15829 ],
    "rgm_fall2021_Sn"            => [ 15804 ],
    "rgm_fall2021_Snx4"          => [ 15318 ],
    "rgc_summer2022"             => [ 16043 ],
    "rgd_fall2023_CuSn"          => [ 18347, 18372, 18560, 18660, 18874, 19061 ],
    "rgd_fall2023_CxC"           => [ 18339, 18369, 18400, 18440, 18756, 18796 ],
    "rgd_fall2023_empty"         => [ 18399, 19060, 18316 ],
    "rgd_fall2023_lD2"           => [ 18305, 18318, 18419, 18528, 18644, 18764, 18851, 19021 ],
    "rgl_spring2025"             => [ 21000 ],
    "rgl_spring2025_H2"          => [ 21001 ],
    "rgl_spring2025_D2"          => [ 21002 ],
    "rgl_spring2025_He"          => [ 21003 ]
);

# Build reverse mapping: run => array of variations
my %run_to_variations;
while (my ($variation, $runs) = each %variation_to_runs) {
    foreach my $run (@$runs) {
        push @{$run_to_variations{$run}}, $variation;
    }
}

sub clas12_configuration_string {
    my %configuration = %{+shift};
    my $varia = $configuration{"variation"};
    my $runno = $configuration{"run_number"};

    if (exists $custom_variations{$varia}) {
        return $varia;
    }

    if (defined $runno && exists $run_to_variations{$runno}) {
        if ($varia eq "default" && $runno != 11) {
            return $run_to_variations{$runno}[0]; # Just return the first match
        }
    }

    if (exists $variation_to_runs{$varia}) {
        return $varia;
    }

    return $varia;
}

sub clas12_runs {
    my @variations = @_;
    my @all_runs;

    print " > Running variations and runs:\n";
    foreach my $var (@variations) {
        my $runs_ref = $variation_to_runs{$var} || [];
        push @all_runs, @$runs_ref;
        print "   - $var -> @{$runs_ref}\n";
    }
    print "\n";

    return @all_runs;
}

sub clas12_runs_for_variations {
    my $variation = shift;
    my $runs_ref = $variation_to_runs{$variation};
    return $runs_ref ? @$runs_ref : ();
}

# when we know there's one to one correspondence
sub clas12_run {
    my $variation = shift;
    my $runs_ref = $variation_to_runs{$variation};
    return $runs_ref ? $runs_ref->[0] : 0;
}

sub clas12_variation {
    my $run_number = shift;
    my $vars_ref = $run_to_variations{$run_number};

    return $vars_ref ? $vars_ref->[0] : "default";
}

1;
