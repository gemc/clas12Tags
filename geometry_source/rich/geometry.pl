# Written by Giovanni Angelini (gangel@gwu.edu), Andrey Kim (kenjo@jlab.org) and Connor Pecar (cmp115@duke.edu)
#package coatjava;

use strict;
use warnings;

use geometry;
use GXML;

my ($mothers, $positions, $rotations, $types, $dimensions, $ids);


#sub makeRICHtext
#{

#    ($mothers, $positions, $rotations, $types, $dimensions, $ids) = @main::volumes;
#    my $module = shift;
#    my $sector = shift;
#    build_text($module,$sector);
#}

sub makeRICHcad {

    my $variation = shift;
    my ($sectors_ref) = shift;
    my @sectors = @{$sectors_ref};

    ($mothers, $positions, $rotations, $types, $dimensions, $ids) = @main::volumes;

    # print("sectors (in build_gxml): @sectors \n");
    my $dirName = "cad_" . $variation;
    my $gxmlFile = new GXML($dirName);

    #remove the Spherical Mirror STL
    for (my $i = 0; $i < @sectors; $i++) {
        my $sector = $sectors[$i];
        my $module = $i + 1;
        #print("module (in build_gxml): ");
        #print($module);
        print("\n");
        build_MESH($gxmlFile, $sector, $module, $variation);
        build_Elements($gxmlFile, $module, $variation);
        my $modulesuffix = "_m" . $module;
        my @files = ($dirName . '/Layer_302_component_1' . $modulesuffix . '.stl', $dirName . '/Layer_302_component_2' . $modulesuffix . '.stl', $dirName . '/Layer_302_component_3' . $modulesuffix . '.stl', $dirName . '/Layer_302_component_4' . $modulesuffix . '.stl', $dirName . '/Layer_302_component_5' . $modulesuffix . '.stl', $dirName . '/Layer_302_component_6' . $modulesuffix . '.stl', $dirName . '/Layer_302_component_7' . $modulesuffix . '.stl', $dirName . '/Layer_302_component_8' . $modulesuffix . '.stl', $dirName . '/Layer_302_component_9' . $modulesuffix . '.stl', $dirName . '/Layer_302_component_10' . $modulesuffix . '.stl');
        my $removed = unlink(@files);
        # print "Removed  $removed files from $dirName. (Spherical Mirrors STLs)\n";
    }
    if (scalar @sectors > 0) {
        $gxmlFile->print();
    }
}
sub makeRICHtext {
    ($mothers, $positions, $rotations, $types, $dimensions, $ids) = @main::volumes;
    my $module = shift;
    my $sector = shift;
    build_SphericalMirrors($module);
    build_PMTs($module, $sector);
}

sub build_MESH {
    my $gxmlFile = shift;
    my $sector = shift;
    my $module = shift;
    my $variation = shift;
    my $modulesuffix = "_m" . $module;

    my $sector_val = $sector + 0;
    my %rotation_angles = (
        1 => 180,
        2 => 240,
        3 => 300,
        4 => 0,
        5 => 60,
        6 => 120,
    );
    my $sectorRotation = $rotation_angles{$sector_val};
    my @allMeshes = ("RICH_s4", "TedlarWrapping", "Aluminum", "CFRP", "MirrorSupport");
    foreach my $mesh (@allMeshes) {
        my %detector = init_det();
        my $vname = $mesh;

        $detector{"name"} = $vname . $modulesuffix;
        if ($mesh eq "RICH_s4") {
            $detector{"name"} = "AaRICH" . $modulesuffix;
        }
        $detector{"pos"} = $positions->{$vname};
        if ($mesh eq "RICH_s4" and ($variation eq "rga_fall2018" or $variation eq "rgc_summer2022")) {
            $detector{"pos"} = "0*cm 0*cm 5*cm";
        }
        #rotate mesh for sector 1 180 deg. around z
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"mother"} = $mothers->{$vname};
        if ($mesh eq "RICH_s4") {
            $detector{"rotation"} = "0 0 " . $sectorRotation . "*deg";
            # temporary: ensure that mother of RICH volume is 'root'
            # (in case using coatajva < 11.0.2)
            $detector{"mother"} = "root";
        }

        if ($mesh eq "RICH_s4") {
            $detector{"color"} = "444444";
            $detector{"style"} = "wireframe";
            $detector{"material"} = "Air_Opt";
        }
        elsif ($mesh eq "Aluminum") {
            $detector{"color"} = "4444ff";
            $detector{"material"} = "G4_Al";
            $detector{"identifiers"} = "aluminum";
            $detector{"mother"} = "AaRICH" . $modulesuffix;
        }
        elsif ($mesh eq "CFRP") {
            $detector{"color"} = "44ff44";
            $detector{"material"} = "CarbonFiber";
            $detector{"identifiers"} = "CarbonFiber";
            $detector{"mother"} = "AaRICH" . $modulesuffix;
        }
        elsif ($mesh eq "TedlarWrapping") {
            $detector{"color"} = "444444";
            $detector{"material"} = "G4_AIR";
            $detector{"identifiers"} = "CarbonFiber";
            $detector{"mother"} = "AaRICH" . $modulesuffix;
        }
        elsif ($mesh eq "MirrorSupport") {
            $detector{"color"} = "E9C45D";
            $detector{"material"} = "CarbonFiber";
            $detector{"identifiers"} = "CarbonFiber";
            $detector{"mother"} = "AaRICH" . $modulesuffix;
        }

        $gxmlFile->add(\%detector);
    }
}

sub build_Elements {
    my $gxmlFile = shift;
    my $module = shift;
    my $variation = shift;
    my $modulesuffix = "_m" . $module;
    my $Max_Layer201 = 16;
    my $Max_Layer202 = 22;
    my $Max_Layer203 = 32;
    my $Max_Layer204 = 32;
    my $Max_Layer301 = 7;
    my $Max_Layer302 = 10;

    my $Layer = 201;
    for (my $Component = 1; $Component <= $Max_Layer201; $Component++) {
        my $MaterialName = 'aerogel_module' . $module . '_layer' . $Layer . '_component' . $Component;
        my $Sensitivity = 'mirror: aerogel_surface_roughness';
        my $mesh = 'Layer_' . $Layer . '_component_' . $Component;
        my %detector = init_det();
        my $vname = $mesh;
        $detector{"name"} = $vname . $modulesuffix;
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"mother"} = $mothers->{$vname};
        $detector{"color"} = "4444ff";
        $detector{"material"} = $MaterialName;
        $detector{"sensitivity"} = $Sensitivity;
        $detector{"hitType"} = "mirror";
        $detector{"identifiers"} = "aerogel";
        $detector{"mother"} = "AaRICH" . $modulesuffix;
        $gxmlFile->add(\%detector);
    }

    $Layer = 202;
    for (my $Component = 1; $Component <= $Max_Layer202; $Component++) {
        my $MaterialName = 'aerogel_module' . $module . '_layer' . $Layer . '_component' . $Component;
        my $Sensitivity = 'mirror: aerogel_surface_roughness';
        my $mesh = 'Layer_' . $Layer . '_component_' . $Component;
        my %detector = init_det();
        my $vname = $mesh;
        $detector{"name"} = $vname . $modulesuffix;
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"mother"} = $mothers->{$vname};
        $detector{"color"} = "4444ff";
        $detector{"material"} = $MaterialName;
        $detector{"sensitivity"} = $Sensitivity;
        $detector{"hitType"} = "mirror";
        $detector{"identifiers"} = "aerogel";
        $detector{"mother"} = "AaRICH" . $modulesuffix;
        $gxmlFile->add(\%detector);
    }

    $Layer = 203;
    for (my $Component = 1; $Component <= $Max_Layer203; $Component++) {
        my $MaterialName = 'aerogel_module' . $module . '_layer' . $Layer . '_component' . $Component;
        my $Sensitivity = 'mirror: aerogel_surface_roughness';
        my $mesh = 'Layer_' . $Layer . '_component_' . $Component;
        my %detector = init_det();
        my $vname = $mesh;
        $detector{"name"} = $vname . $modulesuffix;
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"mother"} = $mothers->{$vname};
        $detector{"color"} = "4444ff";
        $detector{"material"} = $MaterialName;
        $detector{"sensitivity"} = $Sensitivity;
        $detector{"hitType"} = "mirror";
        $detector{"identifiers"} = "aerogel";
        $detector{"mother"} = "AaRICH" . $modulesuffix;
        $gxmlFile->add(\%detector);
    }

    $Layer = 204;
    for (my $Component = 1; $Component <= $Max_Layer204; $Component++) {
        my $MaterialName = 'aerogel_module' . $module . '_layer' . $Layer . '_component' . $Component;
        my $Sensitivity = 'mirror: aerogel_surface_roughness';
        my $mesh = 'Layer_' . $Layer . '_component_' . $Component;
        my %detector = init_det();
        my $vname = $mesh;
        $detector{"name"} = $vname . $modulesuffix;
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"mother"} = "AaRICH" . $modulesuffix;
        $detector{"color"} = "4444ff";
        $detector{"material"} = $MaterialName;
        $detector{"sensitivity"} = $Sensitivity;
        $detector{"hitType"} = "mirror";
        $detector{"identifiers"} = "aluminum";
        $gxmlFile->add(\%detector);
    }

    $Layer = 301;
    for (my $Component = 1; $Component <= $Max_Layer301; $Component++) {
        my $MaterialName = 'mirror_module' . $module . '_layer' . $Layer . '_component' . $Component;
        my $mesh = 'Layer_' . $Layer . '_component_' . $Component;
        my %detector = init_det();
        my $vname = $mesh;
        $detector{"name"} = $vname . $modulesuffix;
        $detector{"pos"} = $positions->{$vname};
        $detector{"rotation"} = $rotations->{$vname};
        $detector{"mother"} = "AaRICH" . $modulesuffix;
        $detector{"color"} = "cc99ff";
        $detector{"material"} = "G4_Pyrex_Glass";
        $detector{"hitType"} = 'mirror';
        $detector{"sensitivity"} = "mirror: rich_m" . $module . "_mirror_planar_comp_" . $Component;
        $detector{"identifiers"} = 'module manual ' . $Component;
        $gxmlFile->add(\%detector);
    }
}

sub build_PMTs {

    my $module = shift;
    my $sector = shift;

    my $nPMTS = 0;
    my $modulesuffix = "_m" . $module;

    my $PMT_rows = 23;
    for (my $irow = 0; $irow < $PMT_rows; $irow++) {
        my $nPMTInARow = 6 + $irow;

        for (my $ipmt = $nPMTInARow - 1; $ipmt >= 0; $ipmt--) {
            my $vname = sprintf("MAPMT_${irow}_${ipmt}");
            my %detector = init_det();

            $nPMTS++;

            %detector = init_det();
            $detector{"name"} = "$vname" . $modulesuffix;
            $detector{"mother"} = "AaRICH" . $modulesuffix;
            $detector{"description"} = "PMT mother volume";
            $detector{"pos"} = $positions->{$vname};
            $detector{"rotation"} = $rotations->{$vname};
            $detector{"color"} = "444444";
            $detector{"type"} = $types->{$vname};
            $detector{"dimensions"} = $dimensions->{$vname};
            $detector{"material"} = "Air_Opt";

            print_det(\%main::configuration, \%detector);

            my @Case = ("Top", "Bottom", "Left", "Right");
            foreach my $section (@Case) {
                my $AlCase = sprintf("Al${section}_${vname}");
                my %detector = init_det();

                $detector{"name"} = "$AlCase" . $modulesuffix;
                $detector{"mother"} = $mothers->{$AlCase} . $modulesuffix;
                $detector{"description"} = "PMT mother volume";
                $detector{"pos"} = $positions->{$AlCase};
                $detector{"rotation"} = $rotations->{$AlCase};
                $detector{"type"} = $types->{$AlCase};
                $detector{"dimensions"} = $dimensions->{$AlCase};
                $detector{"material"} = "G4_Al";
                $detector{"style"} = "0";
                print_det(\%main::configuration, \%detector);
            }

            my $Socket = sprintf("Socket_${vname}");

            %detector = init_det();
            $detector{"name"} = "$Socket" . $modulesuffix;
            $detector{"mother"} = $mothers->{$Socket} . $modulesuffix;
            $detector{"description"} = "PMT mother volume";
            $detector{"pos"} = $positions->{$Socket};
            $detector{"rotation"} = $rotations->{$Socket};
            $detector{"color"} = "ff9900";
            $detector{"type"} = $types->{$Socket};
            $detector{"dimensions"} = $dimensions->{$Socket};
            $detector{"material"} = "G4_Cu";

            print_det(\%main::configuration, \%detector);

            my $Window = sprintf("Window_${vname}");

            %detector = init_det();
            $detector{"name"} = "$Window" . $modulesuffix;
            $detector{"mother"} = $mothers->{$Window} . $modulesuffix;
            $detector{"description"} = "PMT mother volume";
            $detector{"pos"} = $positions->{$Window};
            $detector{"rotation"} = $rotations->{$Window};
            $detector{"color"} = "99bbff";
            $detector{"type"} = $types->{$Window};
            $detector{"dimensions"} = $dimensions->{$Window};
            $detector{"material"} = "Glass_H8500";
            print_det(\%main::configuration, \%detector);

            my $Photocathode = sprintf("Photocathode_${vname}");

            %detector = init_det();
            $detector{"name"} = "$Photocathode" . $modulesuffix;
            $detector{"mother"} = $mothers->{$Photocathode} . $modulesuffix;
            $detector{"description"} = "PMT mother volume";
            $detector{"pos"} = $positions->{$Photocathode};
            $detector{"rotation"} = $rotations->{$Photocathode};
            $detector{"color"} = "999966";
            $detector{"type"} = $types->{$Photocathode};
            $detector{"dimensions"} = $dimensions->{$Photocathode};
            $detector{"material"} = "Air_Opt"; #"Photocathode_H8500";
            $detector{"sensitivity"} = "rich";
            $detector{"hit_type"} = "rich";
            $detector{"identifiers"} = "module sector $sector pad manual $nPMTS pixel manual 1";
            print_det(\%main::configuration, \%detector);

        }
    }
    #print "Produced $nPMTS pmt  ";
}

sub build_SphericalMirrors {
    my $module = shift;
    my $modulesuffix = "_m" . $module;

    my $RadiusSphere = 2700.00;
    my $RadiusSphereFinal = 2701.00;

    my %detector = init_det();
    # Spherical Mirror 1 Component
    %detector = init_det();
    $detector{"name"} = "SphericalMirror3PreShift" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"description"} = "Spherical Mirror 1 component";
    $detector{"type"} = "Sphere";
    $detector{"dimensions"} = "$RadiusSphere*mm $RadiusSphereFinal*mm 122*deg 12.25*deg 60.0*deg 15.0*deg";
    $detector{"material"} = "Component";
    print_det(\%main::configuration, \%detector);

    # Spherical Mirror 6
    %detector = init_det();
    $detector{"name"} = "SphericalMirror6" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "-458.68*mm 0*mm  3919.77*mm ";
    $detector{"rotation"} = "90*deg 0*deg -90*deg";
    $detector{"description"} = "SphericalMirror6 ";
    $detector{"color"} = "696277";
    $detector{"type"} = "Sphere";
    $detector{"dimensions"} = "$RadiusSphere*mm $RadiusSphereFinal*mm 122*deg 12.25*deg 75.0*deg 15.0*deg";
    $detector{"material"} = "CarbonFiber";
    $detector{"style"} = "1";
    $detector{"sensitivity"} = "mirror: rich_m" . $module . "_mirror_spherical_6";
    $detector{"hit_type"} = "mirror";
    $detector{"identifiers"} = "id manual 10";
    print_det(\%main::configuration, \%detector);

    # Spherical Mirror 7
    %detector = init_det();
    $detector{"name"} = "SphericalMirror7" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "-458.68*mm 0*mm  3919.77*mm ";
    $detector{"rotation"} = "90*deg 0*deg -90*deg";
    $detector{"description"} = "SphericalMirror7 ";
    $detector{"color"} = "696277";
    $detector{"type"} = "Sphere";
    $detector{"dimensions"} = "$RadiusSphere*mm $RadiusSphereFinal*mm 122*deg 12.25*deg 90.0*deg 15.0*deg";
    $detector{"material"} = "CarbonFiber";
    $detector{"style"} = "1";
    $detector{"sensitivity"} = "mirror: rich_m" . $module . "_mirror_spherical_7";
    $detector{"hit_type"} = "mirror";
    $detector{"identifiers"} = "id manual 11";
    print_det(\%main::configuration, \%detector);

    # Spherical Mirror 4 pre shift
    %detector = init_det();
    $detector{"name"} = "SphericalMirror4PreShift" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "0*mm 0*mm  0*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"description"} = "SphericalMirror4PreShift";
    $detector{"color"} = "696277";
    $detector{"type"} = "Sphere";
    $detector{"dimensions"} = "$RadiusSphere*mm $RadiusSphereFinal*mm 122*deg 12.25*deg 105.0*deg 15.0*deg";
    $detector{"material"} = "Component";
    print_det(\%main::configuration, \%detector);

    # Spherical Mirror 8 pre shift
    %detector = init_det();
    $detector{"name"} = "SphericalMirror8PreShift" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "0*mm 0*mm  0*mm ";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"description"} = "SphericalMirror8PreShift";
    $detector{"color"} = "696277";
    $detector{"type"} = "Sphere";
    $detector{"dimensions"} = "$RadiusSphere*mm $RadiusSphereFinal*mm 134.25*deg 11.5*deg 60.0*deg 21.0*deg";
    $detector{"material"} = "Component";
    print_det(\%main::configuration, \%detector);

    # Spherical Mirror 9
    %detector = init_det();
    $detector{"name"} = "SphericalMirror9" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "-458.68*mm 0*mm  3919.77*mm";
    $detector{"rotation"} = "90*deg 0*deg -90*deg";
    $detector{"description"} = "SphericalMirror9";
    $detector{"color"} = "696277";
    $detector{"type"} = "Sphere";
    $detector{"dimensions"} = "$RadiusSphere*mm $RadiusSphereFinal*mm 134.25*deg 11.5*deg 81.0*deg 18.0*deg";
    $detector{"material"} = "CarbonFiber";
    $detector{"style"} = "1";
    $detector{"sensitivity"} = "mirror: rich_m" . $module . "_mirror_spherical_9";
    $detector{"hit_type"} = "mirror";
    $detector{"identifiers"} = "id manual 12";
    print_det(\%main::configuration, \%detector);

    # Spherical Mirror 10 (3C) pre shift
    %detector = init_det();
    $detector{"name"} = "SphericalMirror10PreShift" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "0*mm 0*mm  0*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"description"} = "SphericalMirror10PreShift";
    $detector{"color"} = "696277";
    $detector{"type"} = "Sphere";
    $detector{"dimensions"} = "$RadiusSphere*mm $RadiusSphereFinal*mm 134.25*deg 11.5*deg 99.0*deg 21.0*deg";
    $detector{"material"} = "Component";
    print_det(\%main::configuration, \%detector);

    # Spherical Mirror 1 before shift
    %detector = init_det();
    $detector{"name"} = "SphericalMirror1PreShift" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "0*mm 0*mm  0*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"description"} = "SphericalMirror1PreShift";
    $detector{"color"} = "696277";
    $detector{"type"} = "Sphere";
    $detector{"dimensions"} = "$RadiusSphere*mm $RadiusSphereFinal*mm 145.75*deg 11.25*deg 60.0*deg 21.0*deg";
    $detector{"material"} = "Component";
    print_det(\%main::configuration, \%detector);

    # Spherical Mirror 5
    %detector = init_det();
    $detector{"name"} = "SphericalMirror5" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "-458.68*mm 0*mm  3919.77*mm";
    $detector{"rotation"} = "90*deg 0*deg -90*deg";
    $detector{"description"} = "SphericalMirror5";
    $detector{"color"} = "696277";
    $detector{"type"} = "Sphere";
    $detector{"dimensions"} = "$RadiusSphere*mm $RadiusSphereFinal*mm 145.75*deg 11.25*deg 81.0*deg 18.0*deg";
    $detector{"material"} = "CarbonFiber";
    $detector{"style"} = "1";
    $detector{"sensitivity"} = "mirror: rich_m" . $module . "_mirror_spherical_5";
    $detector{"hit_type"} = "mirror";
    $detector{"identifiers"} = "id manual 13";
    print_det(\%main::configuration, \%detector);

    # Spherical Mirror 2 pre shift
    %detector = init_det();
    $detector{"name"} = "SphericalMirror2PreShift" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "0*mm 0*mm  0*mm";
    $detector{"rotation"} = "0*deg 0*deg 0*deg";
    $detector{"description"} = "SphericalMirror2PreShift";
    $detector{"color"} = "696277";
    $detector{"type"} = "Sphere";
    $detector{"dimensions"} = "$RadiusSphere*mm $RadiusSphereFinal*mm 145.75*deg 11.25*deg 99.0*deg 21.0*deg";
    $detector{"material"} = "Component";
    print_det(\%main::configuration, \%detector);

    # Tilted Plane1
    %detector = init_det();
    $detector{"name"} = "TiltedPlane1" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "0*mm 0*mm -525.0*mm";
    $detector{"rotation"} = "30*deg 0*deg 40*deg";
    $detector{"description"} = "TiltedPlane1";
    $detector{"color"} = "696277";
    $detector{"type"} = "Box";
    $detector{"dimensions"} = "3000.0*mm 3000.0*mm 280*mm";
    $detector{"material"} = "Component";
    print_det(\%main::configuration, \%detector);

    # Tilted Plane2
    %detector = init_det();
    $detector{"name"} = "TiltedPlane2" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "0*mm 0*mm 525.0*mm";
    $detector{"rotation"} = "-30*deg 0*deg 40*deg";
    $detector{"description"} = "TiltedPlane2";
    $detector{"color"} = "696277";
    $detector{"type"} = "Box";
    $detector{"dimensions"} = "3000.0*mm 3000.0*mm 280*mm";
    $detector{"material"} = "Component";
    print_det(\%main::configuration, \%detector);

    # Spherical Mirror 4
    %detector = init_det();
    $detector{"name"} = "SphericalMirror4" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "-458.68*mm 0*mm  3919.77*mm";
    $detector{"rotation"} = "90*deg 0*deg -90*deg";
    $detector{"description"} = "subtraction mirror4-plane";
    $detector{"color"} = "696277";
    $detector{"type"} = "Operation:@ SphericalMirror4PreShift" . $modulesuffix . " - TiltedPlane1" . $modulesuffix;
    $detector{"dimensions"} = "0";
    $detector{"material"} = "CarbonFiber";
    $detector{"style"} = "1";
    $detector{"sensitivity"} = "mirror: rich_m" . $module . "_mirror_spherical_4";
    $detector{"hit_type"} = "mirror";
    $detector{"identifiers"} = "id manual 15";
    print_det(\%main::configuration, \%detector);

    # SphericalMirror 10
    %detector = init_det();
    $detector{"name"} = "SphericalMirror10" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "-458.68*mm 0*mm  3919.77*mm ";
    $detector{"rotation"} = "90*deg 0*deg -90*deg";
    $detector{"description"} = "subtraction mirror4-plane";
    $detector{"color"} = "696277";
    $detector{"type"} = "Operation:@ SphericalMirror10PreShift" . $modulesuffix . " - TiltedPlane1" . $modulesuffix;
    $detector{"dimensions"} = "0";
    $detector{"material"} = "CarbonFiber";
    $detector{"style"} = "1";
    $detector{"sensitivity"} = "mirror: rich_m" . $module . "_mirror_spherical_10";
    $detector{"hit_type"} = "mirror";
    $detector{"identifiers"} = "id manual 16";
    print_det(\%main::configuration, \%detector);

    # Spherical mirror 2
    %detector = init_det();
    $detector{"name"} = "SphericalMirror2" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "-458.68*mm 0*mm  3919.77*mm ";
    $detector{"rotation"} = "90*deg 0*deg -90*deg";
    $detector{"description"} = "subtraction mirror";
    $detector{"color"} = "696277";
    $detector{"type"} = "Operation:@ SphericalMirror2PreShift" . $modulesuffix . " - TiltedPlane1" . $modulesuffix;
    $detector{"dimensions"} = "0";
    $detector{"material"} = "CarbonFiber";
    $detector{"style"} = "1";
    $detector{"sensitivity"} = "mirror: rich_m" . $module . "_mirror_spherical_2";
    $detector{"hit_type"} = "mirror";
    $detector{"identifiers"} = "id manual 17";
    print_det(\%main::configuration, \%detector);

    # Spherical Mirror 3
    %detector = init_det();
    $detector{"name"} = "SphericalMirror3" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "-458.68*mm 0*mm  3919.77*mm ";
    $detector{"rotation"} = "90*deg 0*deg -90*deg";
    $detector{"description"} = "subtraction mirror 3";
    $detector{"color"} = "696277";
    $detector{"type"} = "Operation:@ SphericalMirror3PreShift" . $modulesuffix . " - TiltedPlane2" . $modulesuffix;
    $detector{"dimensions"} = "0";
    $detector{"material"} = "CarbonFiber";
    $detector{"style"} = "1";
    $detector{"sensitivity"} = "mirror: rich_m" . $module . "_mirror_spherical_3";
    $detector{"hit_type"} = "mirror";
    $detector{"identifiers"} = "id manual 18";
    print_det(\%main::configuration, \%detector);

    # Spherical Mirror 8
    %detector = init_det();
    $detector{"name"} = "SphericalMirror8" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "-458.68*mm 0*mm  3919.77*mm";
    $detector{"rotation"} = "90*deg 0*deg -90*deg";
    $detector{"description"} = "subtraction mirror 5";
    $detector{"color"} = "696277";
    $detector{"type"} = "Operation:@ SphericalMirror8PreShift" . $modulesuffix . " - TiltedPlane2" . $modulesuffix;
    $detector{"dimensions"} = "0";
    $detector{"material"} = "CarbonFiber";
    $detector{"style"} = "1";
    $detector{"sensitivity"} = "mirror: rich_m" . $module . "_mirror_spherical_8";
    $detector{"hit_type"} = "mirror";
    $detector{"identifiers"} = "id manual 19";
    print_det(\%main::configuration, \%detector);

    # SphericalMirror1
    %detector = init_det();
    $detector{"name"} = "SphericalMirror1" . $modulesuffix;
    $detector{"mother"} = "AaRICH" . $modulesuffix;
    $detector{"pos"} = "-458.68*mm 0*mm  3919.77*mm";
    $detector{"rotation"} = "90*deg 0*deg -90*deg";
    $detector{"description"} = "subtraction mirror 1";
    $detector{"color"} = "696277";
    $detector{"type"} = "Operation:@ SphericalMirror1PreShift" . $modulesuffix . " - TiltedPlane2" . $modulesuffix;
    $detector{"dimensions"} = "0";
    $detector{"material"} = "CarbonFiber";
    $detector{"style"} = "1";
    $detector{"sensitivity"} = "mirror: rich_m" . $module . "_mirror_spherical_1";
    $detector{"hit_type"} = "mirror";
    $detector{"identifiers"} = "id manual 20";
    print_det(\%main::configuration, \%detector);

}

1;
