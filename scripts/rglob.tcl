# based on: https://stackoverflow.com/questions/43610524/how-to-exclude-particular-directory-and-all-files-under-that-directory-in-tcl
proc rglob {path {pattern "*"} {exclude_path ""}} {
    set dirpath [file normalize $path]
    set exclude [file normalize $exclude_path]
    set rlist [glob -nocomplain -types f -directory $dirpath $pattern]
    foreach dir [glob -nocomplain -types d -directory $dirpath *] {
        if {$dir ni $exclude} {
            lappend rlist {*}[rglob $dir $pattern {*}$exclude]
        }
    }
    return $rlist
}