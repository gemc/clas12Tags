package clas12_configuration_string;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(clas12_configuration_string clas12_runs);


# Initialize hash maps
sub clas12_configuration_string {

    my %configuration = %{+shift};

    my $varia = $configuration{"variation"};
    my $runno = $configuration{"run_number"};

    # notice for SQLITE variation is always 'default' so
    # it cannot be a case here
    if ($varia eq "rga_spring2018" || $runno eq 3029) {
        return "rga_spring2018";
    }
    elsif ($varia eq "rga_fall2018" || $runno eq 4763) {
        return "rga_fall2018";
    }
    elsif ($varia eq "rga_spring2019" || $runno eq 6608) {
        return "rga_spring2019";
    }
    elsif ($varia eq "rgk_fall2018" || $runno eq 5674) {
        return "rgk_fall2018";
    }
    elsif ($varia eq "rgk_winter2018" || $runno eq 5874) {
        return "rgk_winter2018";
    }
    elsif ($varia eq "rgb_spring2019" || $runno eq 6150) {
        return "rgb_spring2019";
    }
    elsif ($varia eq "rgb_fall2019" || $runno eq 11093) {
        return "rgb_fall2019";
    }
    elsif ($varia eq "rgb_winter2020" || $runno eq 11323) {
        return "rgb_winter2020";
    }
    elsif ($varia eq "rgf_spring2020" || $runno eq 11620) {
        return "rgf_spring2020";
    }
    elsif ($varia eq "rgm_winter2021" || $runno eq 15016) {
        return "rgm_winter2021";
    }
    elsif ($varia eq "rgc_summer2022" || $runno eq 16043) {
        return "rgc_summer2022";
    }
    elsif ($varia eq "rge_spring2024" || $runno eq 20000) {
        return "rge_spring2024";
    }
    elsif ($varia eq "michel_9mmcopper" || $runno eq 30000) {
        return "michel_9mmcopper";
    }
    else {
        return "default";
    }
}

# return an array of runs given as input an array of @variations
sub clas12_runs {
    my @variations = @_;
    my @runs = ();
    foreach my $var (@variations) {
        if ($var eq "default") {
            push(@runs, 11);
        }
        elsif ($var eq "rga_spring2018") {
            push(@runs, 3029);
        }
        elsif ($var eq "rga_fall2018") {
            push(@runs, 4763);
        }
        elsif ($var eq "rga_spring2019") {
            push(@runs, 6608);
        }
        elsif ($var eq "rgk_fall2018") {
            push(@runs, 5674);
        }
        elsif ($var eq "rgk_winter2018") {
            push(@runs, 5874);
        }
        elsif ($var eq "rgb_spring2019") {
            push(@runs, 6150);
        }
        elsif ($var eq "rgb_fall2019") {
            push(@runs, 11093);
        }
        elsif ($var eq "rgb_winter2020") {
            push(@runs, 11323);
        }
        elsif ($var eq "rgf_spring2020") {
            push(@runs, 11620);
        }
        elsif ($var eq "rgm_winter2021") {
            push(@runs, 15016);
        }
        elsif ($var eq "rgc_summer2022") {
            push(@runs, 16043);
        }
        elsif ($var eq "rge_spring2024") {
            push(@runs, 20000);
        }
        elsif ($var eq "michel_9mmcopper") {
            push(@runs, 100000);
        }
        elsif ($var eq "ddvcs") {
            push(@runs, 200000);
        }
    }

    print " > Running variations and runs:\n";
    for (my $i = 0; $i < @variations; $i++) {
        print "   - $variations[$i] -> $runs[$i]\n";
    }
    print("\n");
    return @runs;
}

1;