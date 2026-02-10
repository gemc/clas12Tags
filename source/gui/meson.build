sub_dir_name = meson.current_source_dir().split('/').get(-1)
LD += {
    'name' : sub_dir_name,
    'sources' : files(
        'gemc_MainGui.cc',
        'detector_editor.cc',
        'runControl/run_control.cc',
        'runControl/primaryTab.cc',
        'runControl/momControls.cc',
        'runControl/vtxControls.cc',
        'camera_control.cc',
        'detector_tree.cc',
        'infos.cc',
        'g4dialog.cc',
        'gsignal.cc',
        'physicsListGui.cc',
        'gtrigger.cc',
        'graph.cc'
    ),

    'moc_headers' :  files(
    'gemc_MainGui.h',
    'detector_editor.h',
    'runControl/run_control.h',
    'runControl/primaryTab.h',
    'runControl/momControls.h',
    'runControl/vtxControls.h',
    'camera_control.h',
    'detector_tree.h',
    'infos.h',
    'g4dialog.h',
    'gsignal.h',
    'physicsListGui.h',
    'gtrigger.h',
    'graph.h'
    ),

    'dependencies' : [qt6_deps, clhep_deps, geant4_deps, xercesc_deps, hipo_cpp_dep, ccdb_dep, clas12_cmag_dep, assimp_dep],
}
