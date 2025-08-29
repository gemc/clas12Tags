use strict;
use warnings;

our %configuration;

sub define_ahdc_hit {
    # uploading the hit definition
    # keeping "ftof" to be able to run gemc simulation for a check
    my %hit = init_hit();
    $hit{"name"} = "ahdc";
    $hit{"description"} = "alert ahdc hit definitions ";
    $hit{"identifiers"} = "superlayer layer ahdccell";
    $hit{"signalThreshold"} = "0.5*MeV";
    $hit{"timeWindow"} = "400*ns";
    $hit{"prodThreshold"} = "1*mm";
    $hit{"maxStep"} = "0.5*mm";
    $hit{"delay"} = "50*ns";
    $hit{"riseTime"} = "1*ns";
    $hit{"fallTime"} = "2*ns";
    $hit{"mvToMeV"} = 100;
    $hit{"pedestal"} = -20;
    print_hit(\%configuration, \%hit);
}

sub define_atof_hit {
    # uploading the hit definition
    my %hit = init_hit();
    $hit{"name"} = "atof";
    $hit{"description"} = "atof hit definitions ";
    $hit{"identifiers"} = "sector superlayer layer paddle";
    $hit{"signalThreshold"} = "0.5*MeV";
    $hit{"timeWindow"} = "400*ns";
    $hit{"prodThreshold"} = "1*mm";
    $hit{"maxStep"} = "1*cm";
    $hit{"delay"} = "50*ns";
    $hit{"riseTime"} = "0.7*ns";
    $hit{"fallTime"} = "1.8*ns";
    $hit{"mvToMeV"} = 100;
    $hit{"pedestal"} = -20;
    print_hit(\%configuration, \%hit);
}

sub define_hit {
    define_ahdc_hit();
    define_atof_hit();
}
