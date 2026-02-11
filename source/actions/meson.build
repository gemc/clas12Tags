sub_dir_name = meson.current_source_dir().split('/').get(-1)
LD += {
    'name' : sub_dir_name,
    'sources' : files(
        'dmesg_init.cc',
        'gemc_options.cc',
        'MDetectorConstruction.cc',
        'MEventAction.cc',
        'ActionInitialization.cc',
        'MSteppingAction.cc'
    ),
    'headers' : files(
        'dmesg_init.h',
        'MDetectorConstruction.h',
        'MEventAction.h',
        'ActionInitialization.h',
        'MSteppingAction.h'
    ),
    'dependencies' : [qt6_deps, clhep_deps, geant4_deps, xercesc_deps, hipo_cpp_dep, ccdb_dep, clas12_cmag_dep, assimp_dep],
}
