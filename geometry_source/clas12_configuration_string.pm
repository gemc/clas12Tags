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
    else {
        return "default";
    }
}

1;