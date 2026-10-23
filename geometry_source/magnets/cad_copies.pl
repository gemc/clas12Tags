use strict;
use warnings;
use XML::LibXML;
use cad;
use geometry;

our %configuration;

sub build_magnets_cad {
    my %saved = %configuration;
    for my $factory ('TEXT', 'SQLITE') {
        for my $variation ('default', 'rga_spring2018', 'rga_fall2018') {
            $configuration{'factory'} = $factory;
            $configuration{'variation'} = $factory eq 'TEXT' ? $variation : 'default';
            $configuration{'run_number'} = clas12_run($variation);
            my $doc = XML::LibXML->load_xml(location => "cad/cad_$variation.gxml");
            for my $volume ($doc->findnodes('//volume')) {
                my $copy = $volume->getAttribute('copyOf');
                if ($copy) {
                    $configuration{'detector_name'} = 'magnets_copies';
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
                } elsif ($factory eq 'SQLITE') {
                    $configuration{'detector_name'} = 'magnets';
                    my %mesh = init_cad();
                    for my $attr ($volume->attributes()) {
                        $mesh{$attr->nodeName} = $attr->value;
                    }
                    $mesh{'cad_subdir'} = 'experiments/clas12/magnets/cad';
                    print_cad(\%configuration, \%mesh);
                }
            }
        }
    }
    %configuration = %saved;
}

1;
