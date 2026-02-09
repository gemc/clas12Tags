sub_dir_name = meson.current_source_dir().split('/').get(-1)
LD += {
    'name' : sub_dir_name,
    'sources' : files(
        'string_utilities.cc',
        'gemcOptions.cc',
        'lStdHep.cc',
        'lXDR.cc',
        'run_conditions.cc',
        'gemcUtils.cc'
    ),
    'headers' : files(
        'string_utilities.h',
        'gemcOptions.h',
        'lStdHep.cc',
        'lXDR.cc',
        'json.hpp',
        'run_conditions.cc',
        'gemcUtils.h'
    ),
    'dependencies' : [qt6_deps, clhep_deps, geant4_deps],
}
