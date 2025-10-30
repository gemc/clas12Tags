use strict;
use warnings;
use XML::LibXML;
use lib ("$ENV{GEMC}/api/perl");
use cad;

our %configuration;

# Function to process the GXML file and print CAD information
sub process_gxml {
    my ($gxml_file, $cad_dir) = @_;

    if (not defined $gxml_file) {
        die "process_gxml requires a GXML file \n";
    }

    # Parse the GXML file
    my $parser = XML::LibXML->new();
    my $doc = $parser->parse_file($gxml_file);

    # Loop through each <volume> element
    foreach my $volume ($doc->findnodes('//volume')) {
        my %cad = init_cad();

        # Extract attributes from the <volume> element
        foreach my $attr ($volume->attributes()) {
            $cad{$attr->nodeName} = $attr->value;
            if ($attr->nodeName eq "hitType") {
                $cad{"hit_type"} = $attr->value;
            }
        }
        $cad{"cad_subdir"} = $cad_dir;

        # Print the CAD information
       # print_cad(\%cad);
        print_cad(\%configuration, \%cad);

    }
}

1;
