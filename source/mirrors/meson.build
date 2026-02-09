sub_dir_name = meson.current_source_dir().split('/').get(-1)
LD += {
    'name' : sub_dir_name,
    'sources' : files(
        'mirrors_factory.cc',
        'mysql_mirrors.cc',
        'sqlite_mirrors.cc',
        'text_mirrors.cc'
    ),
    'headers' : files(
        'mirrors_factory.h',
        'mysql_mirrors.h',
        'sqlite_mirrors.h',
        'text_mirrors.h'
    ),
    'dependencies' : [qt6_deps, clhep_deps, geant4_deps],
}
