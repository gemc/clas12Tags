# qt: pkg-config. https://mesonbuild.com/Qt5-module.html
qt6 = import('qt6')
qt6_deps = dependency('qt6',
                      modules : [
                          'Core',
                          'Gui',
                          'Widgets',
                          'OpenGL',
                          'OpenGLWidgets',
                          'Xml',
                          'Sql'],
                      static : true,
                      include_type : 'system') # treat as system include paths - no warnings

sys = host_machine.system()

# pkg-config --cflags --libs gl
ogl_deps = dependency('opengl', required : true)

# pkg-config --cflags --libs sqlite3
if sys == 'darwin'
    sqlite_dep = dependency('sqlite3', required : true)
else
    # no static or it will link to static system
    sqlite_dep = dependency('sqlite3', static : false, required : true)
endif

# expat required as geant4 is linked statically
# Geant4’s GIDI/XML parsing in G4processes uses Expat
# pkg-config --cflags --libs zlib
expat_dep = dependency('expat', required : true)

# pkg-config --cflags --libs zlib
zlib_dep = dependency('zlib', static : false, required : true)  # Use shared libz.so instead of libz.a

# pkg-config --cflags --libs clhep
clhep_deps = dependency('clhep', version : '>=2.4.7.1', include_type : 'system') # treat as system include paths - no warnings

# pkg-config --cflags --libs xerces-c
xercesc_deps = dependency('xerces-c', version : '>=3.2.5',  static : false, include_type : 'system') # treat as system include paths - no warnings
xerces_libdir = xercesc_deps.get_variable(pkgconfig: 'libdir')
message('xerces libdir: ' + xerces_libdir)

# Geant4 ships no pkg-config file, so we generate geant4.pc / geant4_core.pc ourselves. These are a
# build-time helper for locating Geant4, so they live in a hardcoded directory inside the build tree
# (not tied to the install prefix). A fresh `rm -rf build` drops them, so they regenerate cleanly when
# the build dir is recreated - e.g. after switching Geant4 versions.
fs = import('fs')
geant4_pc_path = meson.project_build_root() / 'pkgconfig'
geant4_core_pc = geant4_pc_path / 'geant4_core.pc'
geant4_pc = geant4_pc_path / 'geant4.pc'
g4_pkgconfig_script = meson.project_source_root() / 'meson/g4_pkgconfig.py'
if not fs.exists(geant4_pc) or not fs.exists(geant4_core_pc)
    message('Generating geant4.pc / geant4_core.pc in ' + geant4_pc_path)
    run_command(g4_pkgconfig_script, geant4_pc_path, check : true)
endif
# The generated .pc files are not on the default pkg-config search path. Rather than requiring the
# caller to pass -Dpkg_config_path / export PKG_CONFIG_PATH, add that directory internally: meson.build
# cannot mutate the pkg_config_path option or its own environment for dependency(), so we resolve
# geant4 by running pkg-config ourselves with an augmented PKG_CONFIG_PATH and wrap the result in
# declare_dependency. env.append() adds to (does not replace) the inherited PKG_CONFIG_PATH, so
# module-provided paths still resolve. The generated .pc files carry flat Cflags/Libs with no Requires,
# so this is faithful to a plain pkg-config lookup.
g4_min_version = '11.3.2'
pkgconf = find_program('pkg-config', required : true)
g4_pc_env = environment()
g4_pc_env.append('PKG_CONFIG_PATH', geant4_pc_path, separator : ':')

g4_built = {}
foreach g4 : [
    { 'pc' : 'geant4',      'system' : true  }, # treat includes as system paths - no warnings
    { 'pc' : 'geant4_core', 'system' : false },
]
    pcname = g4['pc']
    ver = run_command(pkgconf, '--modversion', pcname, env : g4_pc_env, check : true).stdout().strip()
    if not ver.version_compare('>=' + g4_min_version)
        error(pcname + ' ' + ver + ' found in ' + geant4_pc_path + ', but >= ' + g4_min_version + ' is required')
    endif
    cflags = run_command(pkgconf, '--cflags', pcname, env : g4_pc_env, check : true).stdout().split()
    libs = run_command(pkgconf, '--libs', pcname, env : g4_pc_env, check : true).stdout().split()
    compile_args = []
    foreach f : cflags
        if g4['system'] and f.startswith('-I')
            compile_args += ['-isystem', f.substring(2)] # -I<path> -> -isystem <path>
        else
            compile_args += f
        endif
    endforeach
    g4_built += { pcname : declare_dependency(compile_args : compile_args, link_args : libs) }
endforeach
geant4_dep = g4_built['geant4']
geant4_core_dep = g4_built['geant4_core']

# Ship the generated .pc into <prefix>/lib/pkgconfig. Downstream GEMC projects (e.g. clas12-systems)
# resolve geant4_core straight from the installed GEMC's lib/pkgconfig, and ci/env.sh /
# ci/package_install.sh export $GEMC/lib/pkgconfig, so the installed tree must carry these files.
# An install script (rather than install_data) is used because the .pc are generated build-tree files,
# which install_data deprecates. $MESON_INSTALL_DESTDIR_PREFIX is set by meson at install time.
meson.add_install_script(
    'sh', '-c',
    'set -e; d="$MESON_INSTALL_DESTDIR_PREFIX/$1"; mkdir -p "$d"; shift; cp "$@" "$d"',
    'install_geant4_pc', get_option('libdir') / 'pkgconfig', geant4_pc, geant4_core_pc,
)

geant4_deps = [geant4_dep]
geant4_core_deps = [geant4_core_dep]
if sys == 'linux'
    # Only on Linux: pull in GLX/X11 stack for G4OpenGL(.a)
    geant4_deps += [
        dependency('x11', required : true),
        dependency('xmu', required : true),
        dependency('gl', required : true),
    ]
endif

cmake = import('cmake')
cmake_opts = cmake.subproject_options()
cmake_opts.add_cmake_defines({
                                 'BUILD_STATIC_LIBS' : true,
                                 'ZLIB_USE_STATIC_LIBS' : false, # prefer shared zlib
                                 'CMAKE_POSITION_INDEPENDENT_CODE' : true,
                                 'CMAKE_C_STANDARD' : 17, # avoid C23 warnings in bundled zlib if you ever enable it
                                 'CMAKE_POLICY_VERSION_MINIMUM' : '4.0',
                             })


use_sharedl = false
cmake_opts.add_cmake_defines({
                                 'BUILD_SHARED_LIBS' : use_sharedl,
                                 # Avoid pulling GUI/sample/tooling deps like X11
                                 'ASSIMP_BUILD_ASSIMP_TOOLS' : false,
                                 'ASSIMP_BUILD_SAMPLES' : false,
                                 'ASSIMP_BUILD_TESTS' : false,
                             })


if host_machine.system() == 'darwin'
    # there's a macro collision in Assimp’s bundled zlib on macOS.
    # Using system zlib is fine on macos
    cmake_opts.add_cmake_defines({
                                     'ASSIMP_BUILD_ZLIB' : false,
                                 })
else
    # Ubuntu: zlib is not compiled with fPic on the system. Let Assimp compile it.
    cmake_opts.add_cmake_defines({
                                     'ASSIMP_BUILD_ZLIB' : true,
                                 })
endif


# -w suppresses all warnings from cmake subprojects (ccdb, assimp)
cmake_opts.append_compile_args('c',   '-fPIC', '-w')
# TODO: remove temp workaround for _LIBCPP_ENABLE_ASSERTIONS deprecation
cmake_opts.append_compile_args('cpp',
                               '-fPIC',
                               '-w',
                               '-Wno-shadow',
                               '-U_LIBCPP_ENABLE_ASSERTIONS',
                               '-D_LIBCPP_HARDENING_MODE_DEBUG=true',
)

assimp_proj = cmake.subproject('assimp', options : cmake_opts)
assimp_dep = assimp_proj.dependency('assimp')

# Platform-specific: Add Homebrew paths on macOS for zstd and openssl
# Needed by ccdb
if host_machine.system() == 'darwin'

    zstd_lib = run_command('brew', '--prefix', 'zstd').stdout().strip() + '/lib'
    openssl_lib = run_command('brew', '--prefix', 'openssl').stdout().strip() + '/lib'

    cmake_opts.append_link_args('-L' + zstd_lib, '-L' + openssl_lib)

    message('Using zstd lib dir: ' + zstd_lib)
    message('Using openssl lib dir: ' + openssl_lib)
endif

ccdb_proj = cmake.subproject('ccdb', options : cmake_opts)
# NOTE: ccdb exposes a static target (ccdb_static), but it bundles its own vendored
# sqlite3 (ccdb_sqlite). gemc already links the system sqlite3 (see sqlite_dep above), so
# linking ccdb statically pulls a SECOND sqlite3 into the gemc binary and crashes at
# startup (duplicate global state). Keep the shared `ccdb` target, which hides ccdb's
# sqlite3 inside libccdb.so; ensure libccdb.so is on the runtime path instead.
ccdb_dep = ccdb_proj.dependency('ccdb', include_type : 'system')


# passing dataframes=false, no need for ROOT support
hipo_cpp_sp = subproject(
    'hipo-cpp',
    default_options : [
        'buildtype=release',
        'default_library=static',
        'cpp_std=c++17',
        'dataframes=false',
        'warning_level=0',
    ],
)

hipo_cpp_dep = hipo_cpp_sp.get_variable('hipo_dep').as_system()

clas12_cmag_dep = dependency('clas12-cmag', include_type : 'system', default_options : ['warning_level=0'])

# Download field maps to prefix/fields during `meson install` (skips existing files).
fields_dir = get_option('prefix') / 'fields'
meson.add_install_script(
    python_exe,
    meson.current_source_dir() / 'install_fields.py',
    install_tag : 'fields',
)
