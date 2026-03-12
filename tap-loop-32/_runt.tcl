package require Vivado

open_hw_manager
connect_hw_server
open_hw_target
set_property PROGRAM.FILE {fpga.bit} [current_hw_device]
program_hw_devices [current_hw_device]

close_hw_target
open_hw_target -jtag_mode on

set zynqmp_ir_length 12
set zynqmp_ir_user4 0x923
run_state_hw_jtag RESET; # this clears instruction register
run_state_hw_jtag IDLE
scan_ir_hw_jtag $zynqmp_ir_length -tdi $zynqmp_ir_user4
