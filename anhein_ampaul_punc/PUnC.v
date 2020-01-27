//==============================================================================
// Module for PUnC LC3 Processor
//==============================================================================

`include "PUnCDatapath.v"
`include "PUnCControl.v"

module PUnC(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// Debug Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data
);

	//----------------------------------------------------------------------
	// Interconnect Wires
	//----------------------------------------------------------------------

	// Declare your wires for connecting the datapath to the controller here

	//----------------------------------------------------------------------
	// Control Module
	//----------------------------------------------------------------------
	PUnCControl ctrl(
		.clk             (clk),
		.rst             (rst),

		// Add more ports here
		// Datapath input (from datapath)
		.p (dpath.p),
		.n (dpath.n),
		.z (dpath.z),
		.ir (dpath.ir_out),
		
		// Datapath output (to datapath)
		.write_mem (),
		.jsr_s (),
		.alu_s (),
		.write_ir (),
		.write_status (),
		.write_rf (),
		.ld_ldi (),
		.mem_s (),
		.pc_ld (),
		.inc_pc (),
		.op1_s (),
		.op2_s (),
		.rf_s (),
		.rf_raddr0_s (),
		.rf_raddr1_s ()
	);

	//----------------------------------------------------------------------
	// Datapath Module
	//----------------------------------------------------------------------
	PUnCDatapath dpath(
		.clk             (clk),
		.rst             (rst),

		.mem_debug_addr   (mem_debug_addr),
		.rf_debug_addr    (rf_debug_addr),
		.mem_debug_data   (mem_debug_data),
		.rf_debug_data    (rf_debug_data),
		.pc_debug_data    (pc_debug_data),

		// Add more ports here
		// controller inputs (from controller)
		.write_mem (ctrl.write_mem),
		.jsr_s (ctrl.jsr_s),
		.alu_s (ctrl.alu_s),
		.write_ir (ctrl.write_ir),
		.write_status (ctrl.write_status),
		.write_rf (ctrl.write_rf),
		.ldi_ld (ctrl.ld_ldi),
		.mem_s (ctrl.mem_s),
		.pc_ld (ctrl.pc_ld),
		.inc_pc (ctrl.inc_pc),
		.op1_s (ctrl.op1_s),
		.op2_s (ctrl.op2_s),
		.rf_s (ctrl.rf_s),
		.rf_raddr0_s (ctrl.rf_raddr0_s),
		.rf_raddr1_s (ctrl.rf_raddr1_s),


		// controller outputs (to controller)
		.n (),
		.z (),
		.p (),
		.ir_out ()
	);

endmodule
