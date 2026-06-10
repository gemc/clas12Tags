# Notice: if both static and dynamic libraries are present, the dynamic library will be used
# Forcing suffix lib instead of variants like lib64
project('clas12Tags', 'cpp',
        default_options : ['default_library=static', 'default_both_libraries=static', 'libdir=lib'],
        version : run_command('git', 'describe', '--tags', '--abbrev=0', '--always', check : true).stdout().strip(),
        meson_version : '>= 1.10.1'
)
project_description = 'GEMC (GEant Monte-Carlo) is a program based on Geant4 to simulate the passage of particles through matter. '

# additional debug options useful for profiling
if get_option('buildtype') == 'debug'
    add_project_arguments('-fno-omit-frame-pointer', language : 'cpp')
    add_project_arguments('-fno-optimize-sibling-calls', language : 'cpp')
    add_project_arguments('-O2', language : 'cpp')
endif


# init lists
############
LD = []
all_libs = []
all_includes = []
empty_dict = { 'na' : [''] }
python_exe = import('python').find_installation('python3')

subdir('meson')

# Fill dictionary
#################
subdir('options')
subdir('translationTable')
subdir('gstring')
subdir('frequencySyncSignal')
subdir('utilities')
subdir('materials')
subdir('mirrors')
subdir('parameters')
subdir('detector')
subdir('generator')
subdir('sensitivity')
subdir('physics')
subdir('fields')
subdir('hitprocess')
subdir('output')
subdir('actions')
subdir('gui')


# compilation loop
foreach L : LD

    this_lib_name = L['name'] # key name must be present
    sources = L.get('sources', [''])
    headers = L.get('headers', [''])
    this_deps = L.get('dependencies', [])
    additional_includes = L.get('additional_includes', [''])
    moc_headers = L.get('moc_headers', [''])
    moc_sources = []
    qrc_sources = L.get('qrc_sources', [''])
    qrc_examples_sources = L.get('qrc_examples_sources', [''])
    qrc_compiled_sources = []
    qrc_examples_compiled_sources = []

    if not moc_headers.contains('')
        moc_sources = qt6.compile_moc(headers : moc_headers,
                                      dependencies : this_deps)
    endif

    if not sources.contains('')
        if not qrc_sources.contains('')
            qrc_compiled_sources += qt6.compile_resources(sources : qrc_sources)
        endif
        this_library = static_library(
            this_lib_name,
            sources + moc_sources + qrc_compiled_sources,
            install : true,
            dependencies : this_deps,
            include_directories : all_includes + additional_includes
        )
        if not all_libs.contains(this_library)
            all_libs += this_library
        endif
    endif

    # header files
    if not headers.contains('')
        install_headers(headers)
    endif

    foreach include_dir : additional_includes
        if not all_includes.contains(include_dir)
            all_includes += include_dir
        endif
    endforeach
    if not all_includes.contains(this_lib_name) and not (sources.contains('') and headers.contains(''))
        all_includes += this_lib_name
    endif

endforeach

gemc = executable(
    'gemc',
    ['gemc.cc'],
    install : true,
    dependencies : [qt6_deps, clhep_deps, geant4_deps, ogl_deps, hipo_cpp_dep, ccdb_dep, clas12_cmag_dep, assimp_dep, xercesc_deps, expat_dep],
    include_directories : all_includes,
    link_with : all_libs,
    override_options : ['b_pie=true'],
    # critical:
    build_rpath  : xerces_libdir,
    install_rpath: xerces_libdir,
)

install_subdir('../api',         install_dir: get_option('prefix'))
install_subdir('../experiments', install_dir: get_option('prefix'))
#install_data(['../clas12.sqlite'],  install_dir: join_paths(get_option('prefix'), 'experiments', 'clas12'))


# ─── Gcard simulation tests ───────────────────────────────────────────────────
# Gcards are discovered from the filesystem at configure time, so any new gcard
# added under geometry_source/<det>/ is automatically included on the next
# `meson setup`.  Run a subset with: meson test --suite ec
# Run all detectors with:            meson test

gemc_run_args = [
    '-BEAM_P=e-, 4*GeV, 60*deg, 25*deg',
    '-SPREAD_P=0*GeV, 40*deg, 180*deg',
    '-USE_GUI=0',
    '-N=100',
    '-PRINT_EVENT=10',
]

gemc_test_env = environment()
gemc_test_env.set(
    'GEMC_DATA_DIR',
    run_command(
        python_exe, '-c',
        'import os, sys; print(os.path.dirname(os.path.realpath(sys.argv[1])))',
        meson.project_source_root(),
        check: true,
    ).stdout().strip(),
)

foreach det : [
    'ec', 'pcal', 'dc', 'ftof', 'ctof', 'cnd', 'bst', 'htcc',
    'micromegas', 'ltcc', 'rich', 'ft', 'beamline', 'magnets', 'targets',
]
    det_dir = join_paths(meson.project_source_root(), '..', 'geometry_source', det)
    gcard_result = run_command(
        python_exe, '-c',
        'import os, sys; d=sys.argv[1]; [print(f) for f in sorted(os.listdir(d)) if f.endswith(".gcard") and "sqlite" not in f]',
        det_dir,
        check: true,
    )
    foreach gcard : gcard_result.stdout().strip().split('\n')
        if gcard != ''
            test(
                det + '_' + gcard.replace('.gcard', ''),
                gemc,
                args    : gemc_run_args + [join_paths(det_dir, gcard)],
                workdir : det_dir,
                suite   : det,
                timeout : 600,
                env     : gemc_test_env,
            )
        endif
    endforeach
endforeach
