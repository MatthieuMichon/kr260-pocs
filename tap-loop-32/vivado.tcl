package require Vivado

create_project -part xck26-sfvc784-2LV-c -in_memory
read_verilog -sv [lsearch -all -inline -not [glob ../*.sv] *_tb.sv]
read_xdc [glob ../*.xdc]

# Add ILA IP

save_project_as -force test_[lindex [find_top] 0]
set ila_tap [create_ip -name ila -vendor xilinx.com -module_name ila_tap]
set_property -dict [list \
    CONFIG.C_DATA_DEPTH 131072 \
    CONFIG.C_NUM_OF_PROBES 1 \
    CONFIG.C_PROBE0_WIDTH 36 \
    CONFIG.C_INPUT_PIPE_STAGES 1 \
    CONFIG.C_EN_STRG_QUAL False \
] [get_ips ila_tap]
generate_target {instantiation_template} [get_files $ila_tap]
generate_target -force synthesis [get_files $ila_tap]
config_ip_cache -export [get_ips -all ila_tap]
export_ip_user_files -of_objects [get_files $ila_tap] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $ila_tap]
launch_runs ila_tap_synth_1
wait_on_run ila_tap_synth_1

# Synthesize Design

set directive RuntimeOptimized; # speed-run the build process

synth_design -top [lindex [find_top] 0] \
    -directive $directive \
    -flatten_hierarchy none \
    -debug_log -verbose
report_utilization -file utilization-synth.txt
opt_design \
    -directive $directive \
    -debug_log -verbose
place_design \
    -directive $directive \
    -timing_summary \
    -debug_log -verbose
phys_opt_design \
    -verbose
route_design \
    -directive $directive \
    -tns_cleanup \
    -debug_log -verbose
phys_opt_design \
    -verbose
write_checkpoint -force project.dcp

# Generate Reports

report_clock_networks -endpoints_only -file clock_networks.txt
report_clock_utilization -file clock_utilization.txt
report_control_sets -hierarchical -file control_sets.txt
report_datasheet -show_all_corners -file datasheet.txt
report_design_analysis -file design_analysis.txt -quiet
report_disable_timing -user_disabled -file disable_timing.txt
report_drc -no_waivers -file drc.txt
report_exceptions -file exceptions.txt
::xilinx::designutils::report_failfast -detailed_reports synth -file failfast.txt
report_high_fanout_nets -timing -load_types -max_nets 99 -file high_fanout_nets.txt
report_methodology -no_waivers -file methodology.txt
report_power -file power.txt
#report_qor_assessment -file qor_assessment.txt -full_assessment_details -quiet
report_qor_suggestions -file qor_suggestions.txt -report_all_suggestions -quiet
report_ram_utilization -file ram_utilization.txt
report_timing_summary -slack_lesser_than 20 -max_paths 1 -file timing_summary.txt; # lol
report_utilization -file utilization.txt
catch {report_utilization -hierarchical -hierarchical_min_primitive_count 0 -file utilization_hierarchical.txt}

# Generate Bitstream and Probe Files

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]
write_bitstream -force -logic_location_file -file fpga.bit

open_hw_manager
connect_hw_server
open_hw_target
set_property PROGRAM.FILE {fpga.bit} [current_hw_device]
program_hw_devices [current_hw_device]

close_hw_target
open_hw_target -jtag_mode on
run_state_hw_jtag RESET; # this clears instruction register
set zynqmp_ir_length 12
set zynqmp_ir_user4 0x923
run_state_hw_jtag RESET; # this clears instruction register
run_state_hw_jtag IDLE
scan_ir_hw_jtag $zynqmp_ir_length -tdi $zynqmp_ir_user4
