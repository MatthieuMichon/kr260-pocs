`timescale 1ns/1ps
`default_nettype none

module shell (
    output logic som240_1_d13, // user_led_uf1
    output logic som240_1_d14 // user_led_uf2
);

localparam int JTAG_USER_ID = 4;
localparam int DATA_WIDTH = 32;
localparam int UPSTREAM_BYPASS_BITS = 2;

typedef logic [DATA_WIDTH-1:0] tap_data_t;

logic tck, tms, tdi, tdo, drck;
logic test_logic_reset, run_test_idle, ir_is_user;
logic capture_dr, shift_dr, update_dr;

logic inbound_alignment_error;
logic tap_valid;
tap_data_t tap_data;

assign som240_1_d13 = ir_is_user;
assign som240_1_d14 = run_test_idle;

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

tap_decoder #(
    .INBOUND_DATA_WIDTH(DATA_WIDTH),
    .UPSTREAM_BYPASS_BITS(UPSTREAM_BYPASS_BITS)
) tap_decoder_i (
    // JTAG TAP Controller Signals
        .tck(tck),
        .tms(tms),
        .tdi(tdi),
        .test_logic_reset(test_logic_reset),
        .ir_is_user(ir_is_user),
        .shift_dr(shift_dr),
        .update_dr(update_dr),
    // Deserialized Data
        .inbound_alignment_error(inbound_alignment_error),
        .inbound_valid(tap_valid),
        .inbound_data(tap_data));

tap_encoder #(
    .OUTBOUND_DATA_WIDTH(DATA_WIDTH)
) tap_encoder_i (
    // Deserialized Signals
        .outbound_valid(tap_valid),
        .outbound_data(tap_data),
    // JTAG TAP Controller Signals
        .tck(tck),
        .test_logic_reset(test_logic_reset),
        .ir_is_user(ir_is_user),
        .capture_dr(capture_dr),
        .shift_dr(shift_dr),
        .tdo(tdo));

wire _unused_ok = 1'b0 && &{1'b0,
    inbound_alignment_error,
    run_test_idle,
    1'b0};

endmodule
`default_nettype wire
