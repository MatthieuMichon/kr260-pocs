package require Vivado

create_project -part xck26-sfvc784-2LV-c -in_memory
read_verilog -sv [lsearch -all -inline -not [glob ../*.sv] *_tb.sv]
read_xdc [glob ../*.xdc]
# Synthesize Design

set directive RuntimeOptimized; # speed-run the build process

set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugAdderCollapsingWireImproved {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugBusGraph {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugConstProp {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugConstPropLvl {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugCrossBoundaryCprop {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugExtractRamWordEnable {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugGenControl {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugGenomeCP {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugGenomeEquivalencies {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugGraph {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugIncrSynConnectivity {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugIncrementalNlOpt {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugLoopExitOpt {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugLoopOpt {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugMV {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugMarkingCarrySave {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugOptimizeComparators {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugPreElabScanFlow {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugRamFromRecordsAnd3D {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugRamPruning {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugRangeOpt {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugRangeSetOptimization {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugRedundantWireRemoval {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugRegenerateAdderInTiming {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugSBlocks {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugSecureStepNetlistWriter {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugSimplifyCM {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter oasisTimerDebug {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugTiming {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugTimingInformation {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter debugTimingReport {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter timingDebugRetiming {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter muxVerbose {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter collapseLutsVerbose {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter retimeHighFanoutVerbose {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter verboseCtrlExtraction {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter nlOptGatedClockVerbose {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter ioVerbose {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter optVerbose {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter ramSynVerbose {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter xilinxMuxDecompVerbose {true}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter ChopperVerbose {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter FPlaceVerbose {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter ExtractVerbose {1}"
set_param synth.elaboration.rodinMoreOptions "rt::set_parameter synVerbose {1}"

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
set_property BITSTREAM.CONFIG.USERID [dict get $arg_dict GIT_COMMIT] [current_design]
write_bitstream -force -logic_location_file -file fpga.bit
write_debug_probes -force [string map {bit ltx} [glob *.bit]] -verbose
