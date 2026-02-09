sub_dir_name = meson.current_source_dir().split('/').get(-1)
LD += {
    'name' : sub_dir_name,
    'sources' : files(
        'sensitiveDetector.cc',
        'backgroundHits.cc',
        'HitProcess.cc',
        'sensitiveID.cc',
        'Hit.cc'
    ),
    'headers' : files(
        'sensitiveDetector.h',
        'backgroundHits.h',
        'HitProcess.h',
        'sensitiveID.h',
        'Hit.h'
    ),
    'dependencies' : [qt6_deps, clhep_deps, geant4_deps],
}
