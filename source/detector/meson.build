sub_dir_name = meson.current_source_dir().split('/').get(-1)
LD += {
    'name' : sub_dir_name,
    'sources' : files(
        'detector.cc',
        'detector_factory.cc',
        'mysql_det_factory.cc',
        'sqlite_det_factory.cc',
        'gdml_det_factory.cc',
        'cad_det_factory.cc',
        'sqlite_cad_factory.cc',
        'text_det_factory.cc',
        'identifier.cc'
    ),
    'headers' : files(
        'detector.h',
        'detector_factory.h',
        'mysql_det_factory.h',
        'sqlite_det_factory.h',
        'gdml_det_factory.h',
        'cad_det_factory.h',
        'sqlite_cad_factory.h',
        'text_det_factory.h',
        'identifier.h'
    ),
    'dependencies' : [qt6_deps, clhep_deps, geant4_deps, xercesc_deps],
}
