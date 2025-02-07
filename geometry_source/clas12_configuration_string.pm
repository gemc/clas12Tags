package clas12_configuration_string;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(clas12_configuration_string);


# Initialize hash maps
sub clas12_configuration_string {

    my %configuration = %{+shift};

    my $varia = $configuration{"variation"};
    my $runno = $configuration{"run_number"};

    if ($varia eq "rga_spring2018" || $runno eq 3029) {
        return "rga_spring2018";
    }
    elsif ($varia eq "rga_fall2018" || $runno eq 4763) {
        return "rga_fall2018";
    }
    elsif ($varia eq "rgf_spring2020" || $runno eq 11620) {
        return "rgf_spring2020";
    }
    elsif ($varia eq "rgm_winter2021" || $runno eq 15016) {
        return "rgm_winter2021";
    }
    elsif ($varia eq "michel_9mmcopper" || $runno eq 30000) {
        return "michel_9mmcopper";
    }
    else {
        return "default";
    }
}

1;