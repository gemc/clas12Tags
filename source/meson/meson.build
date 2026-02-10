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
xercesc_deps = dependency('xerces-c', version : '>=3.2.5', include_type : 'system') # treat as system include paths - no warnings

# geant4.pc if not found
fs = import('fs')
gemc_prefix = get_option('prefix')
geant4_pc_path = gemc_prefix / 'lib/pkgconfig'
geant4_core_pc = geant4_pc_path / 'geant4_core.pc'
geant4_pc = geant4_pc_path / 'geant4.pc'
g4_pkgconfig_script = meson.project_source_root() / 'meson/g4_pkgconfig.py'
if not fs.exists(geant4_pc) or not fs.exists(geant4_core_pc)
    message('geant4.pc or geant4_core.pc  not found in ' + geant4_pc_path + ', running install script to install it in ' + gemc_prefix)
    run_command(g4_pkgconfig_script, gemc_prefix, check : true)
endif
geant4_dep = dependency('geant4', version : '>=11.3.2', method : 'pkg-config', include_type : 'system') # treat as system include paths - no warnings
geant4_core_dep = dependency('geant4_core', version : '>=11.3.2', method : 'pkg-config')
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
opt_var = cmake.subproject_options()

opt_var.add_cmake_defines({
                              'BUILD_SHARED_LIBS' : 'OFF',
                              'BUILD_STATIC_LIBS' : 'ON',
                              'CMAKE_POLICY_VERSION_MINIMUM' : '4.0',
                          })

# TODO: remove temp workaround for _LIBCPP_ENABLE_ASSERTIONS deprecation
opt_var.append_compile_args('cpp',
                            '-Wno-shadow',
                            '-U_LIBCPP_ENABLE_ASSERTIONS',
                            '-D_LIBCPP_HARDENING_MODE_DEBUG=true',
)

assimp_proj = cmake.subproject('assimp', options : opt_var)
assimp_dep = assimp_proj.dependency('assimp')

# Platform-specific: Add Homebrew paths on macOS for zstd and openssl
# Needed by ccdb
if host_machine.system() == 'darwin'

    zstd_lib = run_command('brew', '--prefix', 'zstd').stdout().strip() + '/lib'
    openssl_lib = run_command('brew', '--prefix', 'openssl').stdout().strip() + '/lib'

    opt_var.append_link_args('-L' + zstd_lib, '-L' + openssl_lib)

    message('Using zstd lib dir: ' + zstd_lib)
    message('Using openssl lib dir: ' + openssl_lib)
endif

ccdb_proj = cmake.subproject('ccdb', options : opt_var)
ccdb_dep = ccdb_proj.dependency('ccdb', include_type : 'system')


# passing dataframes=false,no need for ROOT support
hipo_cpp_sp = subproject('hipo-cpp',
                         default_options : [
                             'buildtype=release',
                             'default_library=static',
                             'cpp_std=c++17',
                             'dataframes=false',
                         ])
hipo_cpp_dep = hipo_cpp_sp.get_variable('hipo_dep')

clas12_cmag_dep = dependency('clas12-cmag')
