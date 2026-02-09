sub_dir_name = meson.current_source_dir().split('/').get(-1)
LD += {
    'name' : sub_dir_name,
    'sources' : files(
        'gstring.cc'
    ),
    'headers' : files(
        'gstring.h'
    ),
    'dependencies' : [qt6_deps, clhep_deps, geant4_deps],
}
