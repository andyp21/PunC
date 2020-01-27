//==============================================================================
// Datapath for PUnC LC3 Processor
//==============================================================================
 
`include "Memory.v"
`include "RegisterFile.v"
`include "Defines.v"
 
module PUnCDatapath(
   // External Inputs
   input  wire        clk,            // Clock
   input  wire        rst,            // Reset
 
   // DEBUG Signals
   input  wire [15:0] mem_debug_addr,
   input  wire [2:0]  rf_debug_addr,
   output wire [15:0] mem_debug_data,
   output wire [15:0] rf_debug_data,
   output wire [15:0] pc_debug_data,
 
   	// controller inputs (from controller)
	input wire write_mem,
	input wire jsr_s,
	input wire [1:0] alu_s,
	input wire write_ir,
	input wire write_status,
	input wire write_rf,
	input wire ldi_ld,
	input wire mem_s,
	input wire pc_ld,
	input wire inc_pc,
	input wire [1:0] op1_s,
	input wire [2:0] op2_s,
	input wire rf_s,
	input wire rf_raddr0_s,
	input wire rf_raddr1_s,
	
 
	// controller outputs (to controller)
	output reg n,
	output reg z,
	output reg p,
	output reg [15:0] ir_out
 
  	
);
 
 
   // Local Registers
   reg  [15:0] pc;
   reg  [15:0] ir;
 
   reg  [15:0] ldi;
 
   reg  [15:0] muxop1_data;
   reg  [15:0] muxop2_data;
   reg  [2:0] muxrf_writeaddr;
   reg  [15:0] muxmem_addr;
   reg  [15:0] muxrf_data;
   reg  [2:0] muxrf_readaddr0;
   reg  [2:0] muxrf_readaddr1;
 
   wire [15:0] off11;
   wire [15:0] off9;
   wire [15:0] off6;
   wire [15:0] imm5;
 
   reg [15:0] alu_val;
 
   // Declare other local wires and registers here
 
   // Assign PC debug net
   assign pc_debug_data = pc;
 
	// Assign sign extend upper bits.
	assign off11 = {{5{ir[10]}}, ir[10:0]};
	assign off9 = {{7{ir[8]}}, ir[8:0]};
	assign off6 = {{10{ir[5]}}, ir[5:0]};
	assign imm5 = {{11{ir[4]}}, ir[4:0]};
 
   //----------------------------------------------------------------------
   // Memory Module
   //----------------------------------------------------------------------
 
   // 1024-entry 16-bit memory (connect other ports)
   Memory mem(
       .clk      (clk),
       .rst      (rst),
       .r_addr_0 (muxmem_addr),
       .r_addr_1 (mem_debug_addr),
       .w_addr   (muxmem_addr),
       .w_data   (rfile.r_data_0),
       .w_en     (write_mem),
       .r_data_0 (),
       .r_data_1 (mem_debug_data)
   );
 
   //----------------------------------------------------------------------
   // Register File Module
   //----------------------------------------------------------------------
 
   // 8-entry 16-bit register file (connect other ports)
   RegisterFile rfile(
       .clk      (clk),
       .rst      (rst),
       .r_addr_0 (muxrf_readaddr0),
       .r_addr_1 (muxrf_readaddr1),
       .r_addr_2 (rf_debug_addr),
       .w_addr   (muxrf_writeaddr),
       .w_data   (muxrf_data),
       .w_en     (write_rf),
       .r_data_0 (),
       .r_data_1 (),
       .r_data_2 (rf_debug_data)
   );

	//----------------------------------------------------------------------
	// Send ir to controller.
	//----------------------------------------------------------------------
	always @( * ) begin
		ir_out = ir;
	end

 
	//----------------------------------------------------------------------
   	// Mux between R7 and IR[11:9] for write address of rf
   	//----------------------------------------------------------------------
	always @( * ) begin
		if (jsr_s) begin
			muxrf_writeaddr = 3'b111;
		end
		else begin
			muxrf_writeaddr = ir[11:9];
		end
	end

//----------------------------------------------------------------------
   	// Mux between different options for operand 2.
   	//----------------------------------------------------------------------
	always @( * ) begin
		muxop2_data = 0;
		if (op2_s == `SR2) begin
			muxop2_data = rfile.r_data_1;
		end
		else if (op2_s == `IMM5) begin
			muxop2_data = imm5;
		end
		else if (op2_s == `OFF6) begin
			muxop2_data = off6;
		end
		else if (op2_s == `OFF9) begin
			muxop2_data = off9;
		end
		else if (op2_s == `OFF11) begin
			muxop2_data = off11;
		end
	end

	//----------------------------------------------------------------------
   	// Mux between different options for operand 1.
   	//----------------------------------------------------------------------
	always @( * ) begin
		muxop1_data = 0;
		if (op1_s == `PC) begin
			muxop1_data = pc;
		end
		else if (op1_s == `RF_0) begin
			muxop1_data = rfile.r_data_0;
		end
		else if (op1_s == `RF_1) begin
			muxop1_data = rfile.r_data_1;
		end
	end

	//----------------------------------------------------------------------
	// Mux for write_data RF   	     
	//----------------------------------------------------------------------
	always @( * ) begin
		if (rf_s == `MEM) begin
			muxrf_data= mem.r_data_0;

		end
		else if (rf_s == `ALU) begin
			muxrf_data= alu_val;
		end
	end

	//----------------------------------------------------------------------
		// Mux for address to read/write in memory	     
	//----------------------------------------------------------------------
	always @( * ) begin
		if (mem_s == `LDI) begin
			muxmem_addr= ldi;
		end
		else if (mem_s == `ALU) begin
			muxmem_addr= alu_val;
		end
	end

	//----------------------------------------------------------------------
		// Mux for r_addr_0 of rf	     
	//----------------------------------------------------------------------
	always @( * ) begin
		if (rf_raddr0_s) begin
			muxrf_readaddr0 = ir[11:9];
		end
		else begin
			muxrf_readaddr0 = ir[8:6];
		end
	end

	//----------------------------------------------------------------------
	// Mux for r_addr_1 of rf     
	//----------------------------------------------------------------------
	always @( * ) begin
		if (rf_raddr1_s) begin
			muxrf_readaddr1 = ir[8:6];
		end
		else begin
			muxrf_readaddr1 = ir[2:0];
		end
	end


	//----------------------------------------------------------------------
   	// All sequential logic for registered variables.    
	//----------------------------------------------------------------------
	always @(posedge clk) begin
		if (rst) begin
			pc<=0;
			ldi<=0;
			z<=0;
			n<=0;
			p<=0;
		end
	
		else begin
		
			// LDI
			if (ldi_ld) begin
				ldi <= mem.r_data_0;
			end
			
			// IR
			if (write_ir) begin
				ir <= mem.r_data_0;
			end
			
			// PC
			if (pc_ld) begin
				pc<=alu_val;
			end
			else if (inc_pc) begin
				pc <= pc + 1;
			end
			
			// COND FLAGS
			if (write_status && (muxrf_data == 0)) begin
				z<= 1; 
				p<= 0;
				n<= 0;
			end
			else if (write_status && (muxrf_data[15] == 0)) begin
				z<=0;
				p<=1;
				n<=0;
			end
			else if (write_status && (muxrf_data[15] == 1)) begin
				z<=0;
				p<=0;
				n<=1;
			end
	
		end
		
	end
		
	//----------------------------------------------------------------------
	// ALU   
	//----------------------------------------------------------------------
	always @( * ) begin
		if (alu_s == `ADD) begin
			alu_val = muxop1_data + muxop2_data;
		end
		else if (alu_s == `AND) begin
			alu_val = muxop1_data & muxop2_data;
		end
		else if (alu_s == `NOT) begin
			alu_val = ~muxop1_data;
		end
		else if (alu_s == `THRU) begin
			alu_val = muxop1_data;
		end
	end
 
 
endmodule
 

