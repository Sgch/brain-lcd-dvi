set script_base [file dirname [info script]]
source [file join $script_base "rglob.tcl"]

set project_name      [lindex $argv 0]
set device_part       "xc7z020clg400-1"

create_project -force $project_name -part $device_part

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
    create_fileset -srcset sources_1
}
# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
set files {} 
set files [concat $files [rglob "../rtl"    "*.v"   "../rtl/ip"]]
set files [concat $files [rglob "../rtl"    "*.vhd" "../rtl/ip"]]
set files [concat $files [rglob "../rtl/ip" "*.xci"            ]]
add_files -norecurse -fileset $obj $files

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
    create_fileset -constrset constrs_1
}
# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]
set files {}
set files [concat $files [rglob "../rtl" "*.xdc" "../rtl/ip"]]
add_files -norecurse -fileset $obj $files 

update_compile_order -fileset sources_1

# synth
launch_runs synth_1
wait_on_run synth_1
open_run synth_1 -name netlist_1

# impl -> write-bitstream
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1 
open_run impl_1

# write reports
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file ./impl_timing.rpt
report_power -file ./impl_power.rpt
