sub_dir_name = meson.current_source_dir().split('/').get(-1)
LD += {
    'name' : sub_dir_name,
    'sources' : files(
        'field.cc',
        'fieldFactory.cc',
        'asciiField.cc',
        'mappedField.cc',
        'bclas12MappedField.cc',
        'clas12BinField.cc',
        'multipoleField.cc',
        'symmetries/dipole.cc',
        'symmetries/cylindrical.cc',
        'symmetries/phi-segmented.cc',
        'symmetries/cartesian_3d.cc'
    ),
    'headers' : files(
        'field.h',
        'fieldFactory.h',
        'asciiField.h',
        'mappedField.h',
        'bclas12MappedField.h',
        'clas12BinField.h',
        'multipoleField.h'
    ),
    'additional_includes' : ['fields', 'fields/symmetries'],
    'dependencies' : [qt6_deps, clhep_deps, geant4_deps, clas12_cmag_deps],
}
