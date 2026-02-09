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
                          'Sql'
                      ], include_type : 'system')

# check system: pkg-config --cflags --libs gl
ogl_deps = dependency('opengl', required : true)

# pkg-config --cflags --libs gl
sqlite_dep = dependency('sqlite3', required : true)

# pkg-config --modversion expat
expat_dep = dependency('expat', required : true)

# pkg-config --cflags --libs zlib
zlib_dep = dependency('zlib', static : false, required : true)  # Use shared libz.so instead of libz.a

# pkg-config --cflags --libs liblz4
# needed by hipo
lz4_dep = dependency('liblz4', required: true)

# sqlite
sqlite_dep = dependency('sqlite3', required : true)

# clhep: pkg-config
clhep_deps = dependency('clhep', version : '>=2.4.7.1')

# xercesc: pkg-config
xercesc_deps = dependency('xerces-c', version : '>=3.2.5')

# clas12 cmag: pkg-config
clas12_cmag_deps = dependency('clas12_cmag', version : '>=1.1')

#  geant4.pc if not found
fs = import('fs')
gemc_prefix = get_option('prefix')
geant4_pc = gemc_prefix / 'lib/pkgconfig/geant4.pc'
script_path = meson.project_source_root() / 'meson/install_geant4_root_pkgconfig.py'
if not fs.exists(geant4_pc)
    message('geant4.pc not found in ' + geant4_pc + ', running install script...')
    run_command(script_path, gemc_prefix, check : true)
endif

# root: pkg-config created manually by./meson/install_geant4_root_pkgconfig.py
root_deps = dependency('root', version : '>=6.28/02')

# geant4: pkg-config created manually by ./meson/install_geant4_root_pkgconfig.py
geant4_deps = dependency('geant4', version : '>=11.3.1')
# this also works,but ONLY if the dynamic libraries are present
# geant4_deps = dependency('Geant4', method : 'cmake', static : true)

# hipo is a meson subproject - not working yet: ROOT not found
# hipo_proj = subproject('hipo')
# hipo_deps = hipo_proj.get_variable('hipo_dep', default_value: null)

hipo_deps = dependency('hipo', version : '>=4.2.0')

cmake = import('cmake')
opt_var = cmake.subproject_options()
opt_var.add_cmake_defines({ 'BUILD_SHARED_LIBS' : 'OFF', 'BUILD_STATIC_LIBS' : 'ON', 'CMAKE_POLICY_VERSION_MINIMUM' : '4.0' })
opt_var.append_compile_args('cpp', '-Wno-shadow')

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
ccdb_deps = ccdb_proj.dependency('ccdb')

# sanitizer settings
project_test_env = environment()
project_test_env.set(
    'UBSAN_OPTIONS',
    'halt_on_error=1',
    'abort_on_error=1',
    'print_summary=1',
    'print_stacktrace=1',
    'verbosity=10',
    'suppressions=' + meson.project_source_root() / 'meson' / 'ubsan.supp',
)
project_test_env.set(
    'ASAN_OPTIONS',
    'halt_on_error=1',
    'abort_on_error=1',
    'print_summary=1',
    'verbosity=10',
    'suppressions=' + meson.project_source_root() / 'meson' / 'asan.supp',
)

project_test_env.set(
    'LSAN_OPTIONS',
    'verbosity=10',
    'suppressions=' + meson.project_source_root() / 'meson' / 'lsan.supp',
)

# allocator_may_return_null=1: Allows TSan to return NULL on allocation failure instead of crashing,
# which might give you more information about where the allocation problem is happening.
project_test_env.set(
    'TSAN_OPTIONS',
    'verbosity=10',
    'heap_size=512M',
    'allocator_may_return_null=1',
    'suppressions=' + meson.project_source_root() / 'meson' / 'tsan.supp',
)
