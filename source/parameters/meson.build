sub_dir_name = meson.current_source_dir().split('/').get(-1)
LD += {
    'name' : sub_dir_name,
    'sources' : files(
        'parameter_factory.cc',
        'mysql_parameters.cc',
        'text_parameters.cc'
    ),
    'headers' : files(
        'parameter_factory.h',
        'mysql_parameters.h',
        'text_parameters.h'
    ),
    'dependencies' : [qt6_deps, clhep_deps, geant4_deps],
}
