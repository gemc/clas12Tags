sub_dir_name = meson.current_source_dir().split('/').get(-1)
LD += {
    'name' : sub_dir_name,
    'sources' : files(
        'goptions.cc'
    ),
    'headers' : files(
        'goptions.h'
    ),
    'dependencies' : [qt6_deps],

}
