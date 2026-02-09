sub_dir_name = meson.current_source_dir().split('/').get(-1)
LD += {
    'name' : sub_dir_name,
    'sources' : files(
        'outputFactory.cc',
        'hipo_output.cc',
        'hipoSchemas.cc',
        'txt_output.cc',
        'txt_simple_output.cc',
        'gbank.cc'
    ),
    'headers' : files(
        'outputFactory.h',
        'hipo_output.h',
        'hipoSchemas.h',
        'txt_output.h',
        'gbank.h'
    ),
    'dependencies' : [qt6_deps, clhep_deps, geant4_deps, hipo_deps, ccdb_deps],
}
