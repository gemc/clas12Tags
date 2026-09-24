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

# Resolve the .pc contents. Each Geant4 library (-lG4*) is turned into a real library object through
# cpp.find_library instead of a raw -l string, and a shared cache makes the full and core sets point at
# the same objects. This lets meson deduplicate the Geant4 archives across the whole link graph: raw
# declare_dependency link_args are never deduplicated, so - because every static module carries the
# Geant4 link_args - a heavy target listed the same -lG4* a dozen times, and GNU ld (Linux) reprocessed
# each large static archive on every repeat, making the link crawl (macOS ld only warns and skips them).
cpp = meson.get_compiler('cpp')
g4_pc_cflags = {}
g4_pc_libs = {}
g4_lib_dirs = []
foreach pcname : ['geant4', 'geant4_core']
    ver = run_command(pkgconf, '--modversion', pcname, env : g4_pc_env, check : true).stdout().strip()
    if not ver.version_compare('>=' + g4_min_version)
        error(pcname + ' ' + ver + ' found in ' + geant4_pc_path +
              ', but >= ' + g4_min_version + ' is required')
    endif
    pc_cflags = run_command(pkgconf, '--cflags', pcname, env : g4_pc_env, check : true).stdout().split()
    pc_libs   = run_command(pkgconf, '--libs',   pcname, env : g4_pc_env, check : true).stdout().split()
    g4_pc_cflags += { pcname : pc_cflags }
    g4_pc_libs   += { pcname : pc_libs }
    foreach l : pc_libs
        if l.startswith('-L') and not g4_lib_dirs.contains(l.substring(2))
            g4_lib_dirs += l.substring(2)
        endif
    endforeach
endforeach

# Turn each set's -lG4* into find_library objects (cached so the same archive is one shared object),
# keeping any non -l/-L tokens as plain link_args. -L dirs feed find_library's search path.
g4_lib_cache = {}
g4_set_deps = {}
g4_set_extra = {}
foreach pcname : ['geant4', 'geant4_core']
    set_deps = []
    extra_link = []
    foreach l : g4_pc_libs[pcname]
        if l.startswith('-l')
            name = l.substring(2)
            if not g4_lib_cache.has_key(name)
                g4_lib_cache += { name : cpp.find_library(name, dirs : g4_lib_dirs, required : true) }
            endif
            set_deps += g4_lib_cache[name]
        elif not l.startswith('-L')
            extra_link += l
        endif
    endforeach
    g4_set_deps  += { pcname : set_deps }
    g4_set_extra += { pcname : extra_link }
endforeach

# Full Geant4 include paths are marked system (-isystem) to silence third-party header warnings; the
# core set keeps plain -I, matching the previous include_type behaviour of the two pkg-config deps.
geant4_full_compile = []
foreach f : g4_pc_cflags['geant4']
    if f.startswith('-I')
        geant4_full_compile += ['-isystem', f.substring(2)] # -I<path> -> -isystem <path>
    else
        geant4_full_compile += f
    endif
endforeach

geant4_dep = declare_dependency(compile_args : geant4_full_compile,
                                link_args : g4_set_extra['geant4'],
                                dependencies : g4_set_deps['geant4'])
geant4_core_dep = declare_dependency(compile_args : g4_pc_cflags['geant4_core'],
                                     link_args : g4_set_extra['geant4_core'],
                                     dependencies : g4_set_deps['geant4_core'])

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
include_subproject_install = get_option('include-subproject-install')
subproject_install_option = include_subproject_install ? 'true' : 'false'
include_subproject_tests = get_option('include-subproject-tests')
subproject_tests_option = include_subproject_tests ? 'true' : 'false'
cmake_opts.set_install(include_subproject_install)
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

# Explicit installation paths bypass dependency discovery and the corresponding subprojects.
external_deps = {}
foreach name, spec : {
    'ccdb' : ['ccdb', 'CCDB/Calibration.h'],
    'hipo' : ['hipo4', 'hipo4/writer.h'],
    'clas12-cmag' : ['cMag', 'magfield.h'],
}
    location = get_option('use-' + name + '-location')
    if location == ''
        continue
    endif
    if not fs.is_absolute(location)
        error('-Duse-' + name + '-location must be an absolute installation path.')
    endif
    incdir = location / 'include'
    if name == 'clas12-cmag' and not fs.is_file(incdir / spec[1])
        incdir = location / 'includes'
    endif
    if not fs.is_file(incdir / spec[1])
        error('Missing ' + spec[1] + ' in the ' + name + ' installation at ' + location)
    endif
    # Check the requested prefix before find_library, which can also search system directories.
    libdir = ''
    static_lib = false
    suffixes = sys == 'darwin' ? ['.dylib', '.a'] : ['.so', '.a']
    if get_option('prefer_static')
        suffixes = ['.a'] + suffixes
    endif
    foreach suffix : suffixes
        foreach dirname : ['lib', 'lib64']
            if libdir == '' and fs.is_file(location / dirname / ('lib' + spec[0] + suffix))
                libdir = location / dirname
                static_lib = suffix == '.a'
            endif
        endforeach
    endforeach
    if libdir == ''
        error('Missing library lib' + spec[0] + ' in ' + location + '/lib or /lib64')
    endif
    external_deps += {name : declare_dependency(
        include_directories : include_directories(incdir, is_system : true),
        dependencies : cpp.find_library(spec[0], dirs : libdir, static : static_lib),
    )}
    message('Using installed ' + name + ' at ' + location)
endforeach

# Platform-specific: Add Homebrew paths on macOS for zstd and openssl
# Needed by ccdb
ccdb_platform_link_args = []
if host_machine.system() == 'darwin'

    zstd_lib = run_command('brew', '--prefix', 'zstd').stdout().strip() + '/lib'
    openssl_lib = run_command('brew', '--prefix', 'openssl').stdout().strip() + '/lib'

    cmake_opts.append_link_args('-L' + zstd_lib, '-L' + openssl_lib)
    ccdb_platform_link_args += ['-L' + zstd_lib, '-L' + openssl_lib]

    message('Using zstd lib dir: ' + zstd_lib)
    message('Using openssl lib dir: ' + openssl_lib)
endif

if external_deps.has_key('ccdb')
    ccdb_static_dep = external_deps['ccdb']
else
    # Use the same SQLite library as gemc so ccdb can be linked statically without duplicate SQLite state.
    cmake_opts.add_cmake_defines({
                                     'USE_SYSTEM_SQLITE' : true,
                                 })

    # Meson's CMake converter otherwise treats CCDB's internal object archive, tests, and benchmark as
    # installable targets when subproject installation is enabled. Only its public libraries belong in a prefix.
    foreach target : ['ccdb_objs', 'ccdb_tests', 'CCDB_bn_sqlite']
        cmake_opts.set_install(false, target : target)
    endforeach

    ccdb_proj = cmake.subproject('ccdb', options : cmake_opts)
    if ccdb_proj.target_list().contains('ccdb_sqlite_static')
        error('CCDB fell back to its bundled SQLite (ccdb_sqlite_static target present). The ' +
              'USE_SYSTEM_SQLITE CMake option did not take effect: confirm the ccdb checkout is a ' +
              'revision that defines it (v1.99.8 does, upstream) and that the option name in cmake_opts ' +
              'matches. If the checkout is stale, run `meson subprojects purge --confirm ccdb` and ' +
              'reconfigure a clean build directory.')
    endif
    ccdb_static_dep = ccdb_proj.dependency('ccdb_static', include_type : 'system')
endif

# CMake's legacy FindMySQL module supplies raw linker flags. Meson's CMake converter does not propagate
# those flags through a static library. Keep compile-only CCDB usage separate so the static archive and the
# exact platform linker flags are added only once, when linking the gemc executable.
ccdb_mysql_config = find_program('mysql_config', 'mariadb_config', required : true)
ccdb_mysql_link_args = run_command(ccdb_mysql_config, '--libs', check : true).stdout().split()
ccdb_dep = ccdb_static_dep.partial_dependency(
    compile_args : true,
    includes : true,
).as_system()
ccdb_link_dep = declare_dependency(
    dependencies : [ccdb_static_dep, sqlite_dep, dependency('threads')],
    link_args : ccdb_platform_link_args + ccdb_mysql_link_args,
)


if external_deps.has_key('hipo')
    hipo_cpp_dep = declare_dependency(
        dependencies : [
            external_deps['hipo'],
            dependency('liblz4', version : '>=1.9', allow_fallback : false),
            dependency('fmt', version : '>=10.2.1', allow_fallback : false),
        ],
    ).as_system()
else
    # passing dataframes=false, no need for ROOT support
    hipo_cpp_sp = subproject(
        'hipo-cpp',
        default_options : [
            'buildtype=release',
            'default_library=static',
            'cpp_std=c++17',
            'dataframes=false',
            'include-subproject-install=' + subproject_install_option,
            'include-subproject-tests=' + subproject_tests_option,
            'warning_level=0',
        ],
    )

    hipo_cpp_dep = hipo_cpp_sp.get_variable('hipo_dep').as_system()

endif

if external_deps.has_key('clas12-cmag')
    clas12_cmag_dep = declare_dependency(
        dependencies : [external_deps['clas12-cmag'], cpp.find_library('m', required : false)],
    )
else
    clas12_cmag_dep = dependency(
        'clas12-cmag',
        include_type : 'system',
        default_options : [
            'include-subproject-install=' + subproject_install_option,
            'warning_level=0',
        ],
    )
endif

# CLAS12 magnetic field maps.
# With -Duse-fields-location=<dir> the build uses an existing external maps directory as-is:
# nothing is fetched and FIELD_DIR points there. Otherwise the maps are taken from the magfield
# git-lfs subproject and installed under <prefix>/fields (the usual location) at `meson install`.
fields_location = get_option('use-fields-location')
if fields_location != ''
    fields_dir = fields_location
    fields_dir_literal = fields_dir.replace('\\', '\\\\').replace('"', '\\"')
    add_project_arguments('-DGEMC_DEFAULT_FIELD_DIR="' + fields_dir_literal + '"', language : 'cpp')
    message('Using external CLAS12 field maps at ' + fields_dir + ' (field-map install skipped).')
else
    fields_dir = get_option('prefix') / 'fields'
    magfield_proj = subproject('magfield')
    magfield_source_dir = magfield_proj.get_variable('magfield_source_dir')
    meson.add_install_script(
        python_exe,
        meson.current_source_dir() / 'install_fields.py',
        magfield_source_dir,
        install_tag : 'fields',
    )
endif
