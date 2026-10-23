use strict;
use warnings;
use XML::LibXML;
use cad;
use geometry;

our %configuration;

sub build_dc_cad {
    my $doc = XML::LibXML->load_xml(location => 'cad/cad_default.gxml');
    my %saved = %configuration;
    for my $factory ('TEXT', 'SQLITE') {
        my @runs = $factory eq 'TEXT' ? (11) : clas12_runs('default', 'rga_spring2018', 'rga_fall2018');
        for my $run (@runs) {
            $configuration{'factory'} = $factory;
            $configuration{'variation'} = 'default';
            $configuration{'run_number'} = $run;
            for my $volume ($doc->findnodes('//volume')) {
                my $copy = $volume->getAttribute('copyOf');
                if ($copy) {
                    $configuration{'detector_name'} = 'dc_copies';
                    my %det = init_det();
                    $det{'name'} = $volume->getAttribute('name');
                    $det{'mother'} = 'root';
                    $det{'description'} = $det{'name'} =~ /back$/
                        ? 'DC region-1 back membrane copy' : 'DC region-1 support copy';
                    $det{'type'} = "CopyOf $copy";
                    $det{'pos'} = $volume->getAttribute('position');
                    $det{'rotation'} = $volume->getAttribute('rotation');
                    $det{'material'} = $volume->getAttribute('material');
                    $det{'color'} = $volume->getAttribute('color');
                    $det{'style'} = 1;
                    print_det(\%configuration, \%det);
                } elsif ($factory eq 'SQLITE') {
                    $configuration{'detector_name'} = 'dc';
                    my %mesh = init_cad();
                    for my $attr ($volume->attributes()) {
                        $mesh{$attr->nodeName} = $attr->value;
                    }
                    $mesh{'cad_subdir'} = 'experiments/clas12/dc/cad';
                    print_cad(\%configuration, \%mesh);
                }
            }
        }
    }
    %configuration = %saved;
}

1;
