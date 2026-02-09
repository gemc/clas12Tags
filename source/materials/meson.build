sub_dir_name = meson.current_source_dir().split('/').get(-1)
LD += {
    'name' : sub_dir_name,
    'sources' : files(
        'material_factory.cc',
        'cpp_materials.cc',
        'mysql_materials.cc',
        'sqlite_materials.cc',
        'text_materials.cc'
    ),
    'headers' : files(
        'material_factory.h',
        'cpp_materials.h',
        'mysql_materials.h',
        'sqlite_materials.h',
        'text_materials.h'
    ),
    'dependencies' : [qt6_deps, clhep_deps, geant4_deps],
}
