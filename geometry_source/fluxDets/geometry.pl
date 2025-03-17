use strict;
use warnings;

our %configuration;

sub sector_pos {
    my $sector = shift;

    my $r = 200;
    my $z = 500;

    my $phi = 60.0 * $sector;
    my $x = fstr($r * cos(rad($phi)));
    my $y = fstr($r * sin(rad($phi)));
    my $z = fstr($z);

    return "$x*cm $y*cm $z*cm";
}

sub makeFlux {

    if ($configuration{"variation"} eq "beamline") {
        my $nflux = 40;
        my $zstart = 100;
        my $dz = 20;

        for (my $i = 1; $i <= $nflux; $i++) {
            my $zpos = $zstart + ($i - 1) * $dz;
            my %detector = init_det();
            $detector{"name"} = "beam_flux_$i";
            $detector{"mother"} = "root";
            $detector{"description"} = "beam flux $i";
            $detector{"pos"} = "0.0*cm 0.0*cm $zpos*mm";
            $detector{"color"} = "aa0088";
            $detector{"type"} = "Tube";
            $detector{"dimensions"} = "0*mm 100*mm 0.1*mm 0.*deg 360.*deg";
            $detector{"material"} = "G4_Galactic";
            $detector{"style"} = 1;
            $detector{"sensitivity"} = "flux";
            $detector{"hit_type"} = "flux";
            $detector{"identifiers"} = "id manual $i";
            print_det(\%configuration, \%detector);
        }
    }
    elsif ($configuration{"variation"} eq "ddvcs") {

        # tube that contains the scattering chamber
        my $thickness = 1;
        my $inner_radius = 100;
        my $length = 650;
        my $zpos = 175;
        my $material = "G4_Galactic";

        my %detector = init_det();
        $detector{"name"} = "ddvcs_central_tube_flux";
        $detector{"mother"} = "root";
        $detector{"description"} = "ddvcs central tube flux";
        $detector{"pos"} = "0.0*cm 0.0*cm $zpos*mm";
        $detector{"color"} = "aa0088";
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "$inner_radius*mm " . ($inner_radius + $thickness) . "*mm " . ($length / 2) . "*mm 0.*deg 360.*deg";
        $detector{"material"} = $material;
        $detector{"style"} = 1;
        $detector{"sensitivity"} = "flux";
        $detector{"hit_type"} = "flux";
        $detector{"identifiers"} = "id manual 1";
        print_det(\%configuration, \%detector);


        # disk at the end of scattering chamber
        my $outer_radius = 100;
        $length = 1;
        $zpos = 500;

        %detector = init_det();
        $detector{"name"} = "ddvcs_central_disk_flux";
        $detector{"mother"} = "root";
        $detector{"description"} = "ddvcs central disk flux";
        $detector{"pos"} = "0.0*cm 0.0*cm $zpos*mm";
        $detector{"color"} = "aa0088";
        $detector{"type"} = "Tube";
        $detector{"dimensions"} = "0*mm $outer_radius*mm " . ($length / 2) . "*mm 0.*deg 360.*deg";
        $detector{"material"} = $material;
        $detector{"style"} = 1;
        $detector{"sensitivity"} = "flux";
        $detector{"hit_type"} = "flux";
        $detector{"identifiers"} = "id manual 2";
        print_det(\%configuration, \%detector);

        # six sectors of fluxes just before FTOF

        my $panel1b_mother_dx1 = 8.635;
        my $panel1b_mother_dx2 = 200;
        my $panel1b_mother_dz = 180;
        my $panel1b_mother_dy = 0.01; # 0.1 mm

        # loop over sectors
        for (my $isect = 0; $isect < 6; $isect++) {

            my $sector = $isect + 1;
            my $identifier = 10 + $sector;

            my $zrot = 90 - 60.0 * $isect;
            my $xrot = 90.0 + 25;

            my $position = sector_pos($isect);
            my $rotation = "ordered: zxy $zrot*deg $xrot*deg 0*deg";

            %detector = init_det();

            $detector{"name"} = "ddvcs_forward_trap_sector$sector";
            $detector{"mother"} = "root";
            $detector{"description"} = "ddvcs forward trap flux sector $sector";
            $detector{"pos"} = $position;
            $detector{"rotation"} = $rotation;
            $detector{"color"} = "222299";
            $detector{"type"} = "Trd";
            $detector{"dimensions"} = "$panel1b_mother_dx1*cm $panel1b_mother_dx2*cm $panel1b_mother_dy*cm $panel1b_mother_dy*cm $panel1b_mother_dz*cm";
            $detector{"material"} = $material;
            $detector{"visible"} = 1;
            $detector{"style"} = 1;
            $detector{"sensitivity"} = "flux";
            $detector{"hit_type"} = "flux";
            $detector{"identifiers"} = "id manual $identifier";
            print_det(\%configuration, \%detector);
        }

    }

}

