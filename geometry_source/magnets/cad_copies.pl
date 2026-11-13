use strict;
use warnings;
use XML::LibXML;
use cad;
use geometry;

our %configuration;

sub build_magnets_copies {
    my $variation = clas12_configuration_string(\%configuration);
    my $doc = XML::LibXML->load_xml(location => "cad/cad_$variation.gxml");
    for my $volume ($doc->findnodes('//volume')) {
        my $copy = $volume->getAttribute('copyOf');
        next unless $copy;
        $configuration{'detector_name'} = 'magnets';
        my %det = init_det();
        $det{'name'} = $volume->getAttribute('name');
        $det{'mother'} = 'root';
        $det{'description'} = $volume->getAttribute('name') =~ /^coil/
            ? 'Torus coil copy' : $volume->getAttribute('name') =~ /^hubCover/
            ? 'Hub cover copy' : $volume->getAttribute('name') =~ /^hub_shield/
            ? 'Hub shield copy' : 'Vacuum jacket copy';
        $det{'type'} = "CopyOf $copy";
        $det{'pos'} = $volume->getAttribute('position');
        $det{'rotation'} = $volume->getAttribute('rotation');
        $det{'material'} = $volume->getAttribute('material');
        $det{'color'} = $volume->getAttribute('color');
        $det{'style'} = 1;
        print_det(\%configuration, \%det);
    }
}

sub build_magnets_cad {
    my %saved = %configuration;
    $configuration{'factory'} = 'SQLITE';
    $configuration{'variation'} = 'default';
    $configuration{'detector_name'} = 'magnets';
    for my $variation ('default', 'rga_spring2018', 'rga_fall2018') {
        $configuration{'run_number'} = clas12_run($variation);
        my $doc = XML::LibXML->load_xml(location => "cad/cad_$variation.gxml");
        for my $volume ($doc->findnodes('//volume')) {
            next if $volume->getAttribute('copyOf');
            my %mesh = init_cad();
            for my $attr ($volume->attributes()) {
                $mesh{$attr->nodeName} = $attr->value;
            }
            $mesh{'cad_subdir'} = 'experiments/clas12/magnets/cad';
            print_cad(\%configuration, \%mesh);
        }
    }
    %configuration = %saved;
}

1;
