`timescale 1ns/1ps
`default_nettype none

module shell;
localparam int JTAG_USER_ID = 4;

logic tck, tms, tdi, tdo, drck;
logic test_logic_reset, run_test_idle, ir_is_user;
logic capture_dr, shift_dr, update_dr;

BSCANE2 #(.JTAG_CHAIN(JTAG_USER_ID)) bscan_i (
    // raw JTAG signals
        .TCK(tck),
        .TMS(tms),
        .TDI(tdi),
        .TDO(tdo), // muxed by TAP if IR matches USER(JTAG_CHAIN)
        .DRCK(drck), // tck when SEL and (CAPTURE or SHIFT) else '1'
    // TAP controller states
        .RESET(test_logic_reset),
        .RUNTEST(run_test_idle),
        .SEL(ir_is_user),
        .CAPTURE(capture_dr),
        .SHIFT(shift_dr),
        .UPDATE(update_dr));

always_ff @(posedge tck) begin
    tdo <= tdi;
end

wire _unused_ok = 1'b0 && &{1'b0,
    test_logic_reset,
    run_test_idle,
    ir_is_user,
    capture_dr,
    shift_dr,
    update_dr,
    1'b0};

endmodule
`default_nettype wire
