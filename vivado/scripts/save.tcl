set outfile [lindex $argv 0]
write_project_tcl \
    -paths_relative_to . \
    -origin_dir_override . \
    -target_proj_dir . \
    -force \
    $outfile
