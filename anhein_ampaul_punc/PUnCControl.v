//==============================================================================
// Control Unit for PUnC LC3 Processor
//==============================================================================
 
`include "Defines.v"
 
module PUnCControl(
   // External Inputs
   input  wire        clk,            // Clock
   input  wire        rst,            // Reset
 
   // Datapath input (from datapath)
   input wire  p,
   input wire n,
   input wire z,
   input wire [15:0] ir,
 
   // Datapath output (to datapath)
   output wire write_mem,
   output wire jsr_s,
   output reg [1:0] alu_s,
   output wire write_ir,
   output wire write_status,
   output wire write_rf,
   output wire ld_ldi,
   output reg mem_s,
   output wire pc_ld,
   output wire inc_pc,
   output reg [1:0] op1_s,
   output reg [2:0] op2_s,
   output reg rf_s,
   output wire rf_raddr0_s,
   output wire rf_raddr1_s
 
 
);
 
   // FSM States
   // Add your FSM State values as localparams here
   localparam STATE_FETCH     = 5'd0;
   localparam STATE_DECODE     = 5'd1;
   localparam STATE_ADDREG     = 5'd2;
   localparam STATE_ADDIMM    = 5'd3;
   localparam STATE_ANDREG     = 5'd4;
   localparam STATE_ANDIMM     = 5'd5;
   localparam STATE_BR        = 5'd6;
   localparam STATE_JMP       = 5'd7;
   localparam STATE_JSRPR     = 5'd8;
   localparam STATE_JSR        = 5'd9;
   localparam STATE_JSRR      = 5'd10;
   localparam STATE_LD        = 5'd11;
   localparam STATE_LDIPT1     =5'd12;
   localparam STATE_LDIPT2     = 5'd13;
   localparam STATE_LDR        = 5'd14;
   localparam STATE_LEA        = 5'd15;
   localparam STATE_NOT        = 5'd16;
   localparam STATE_RET        = 5'd17;
   localparam STATE_ST         = 5'd18;
   localparam STATE_STIPT1     = 5'd19;
   localparam STATE_STIPT2     = 5'd20;
   localparam STATE_STR       =5'd21;
   localparam STATE_HALT     = 5'd22;
 
 
   // State, Next State
   reg [4:0] state, next_state;
 
   // Output Combinational Logic
   // Continuous (outputs without width.
   assign write_mem = (state == STATE_ST) || (state == STATE_STR) || (state == STATE_STIPT2);
   assign jsr_s = (state == STATE_JSRPR);
   assign write_ir = (state == STATE_FETCH);
   assign write_status = (state == STATE_ADDREG) || (state == STATE_ADDIMM) || (state == STATE_ANDREG) || (state == STATE_ANDIMM) 
   || (state == STATE_LD) || (state == STATE_LDIPT1) || (state == STATE_LDIPT2) || (state == STATE_LDR) || (state == STATE_LEA) || (state == STATE_NOT);
   assign write_rf = (state == STATE_ADDREG) || (state == STATE_ADDIMM) || (state == STATE_ANDREG) || (state == STATE_ANDIMM) 
   || (state == STATE_LD) || (state == STATE_LDIPT1) || (state == STATE_LDIPT2) || (state == STATE_LDR) || (state == STATE_LEA) 
   || (state == STATE_NOT) || (state == STATE_JSRPR);
   assign ld_ldi = (state == STATE_LDIPT1) || (state == STATE_LDIPT2);
   assign pc_ld = (state == STATE_BR) || (state == STATE_JMP) || (state == STATE_JSR) || (state == STATE_JSRR) || (state == STATE_RET);
   assign inc_pc = (state == STATE_DECODE);
   assign rf_raddr0_s = (state == STATE_ST) || (state == STATE_STIPT1) || (state == STATE_STIPT2) || (state == STATE_STR);
   assign rf_raddr1_s = (state == STATE_STR);
 
	// Procedural, some multi-bit and selects
	always @( * ) begin
		// Set default values for outputs here (prevents implicit latching)
		alu_s = `THRU;
		rf_s = `ALU;
		mem_s = `ALU;
		op1_s = `RF_0;
		op2_s = `OFF9;

		// Add your output logic here
		case (state)
			STATE_FETCH: begin
				op1_s = `PC;
			end
			STATE_ADDREG: begin
				alu_s = `ADD;
				op2_s = `SR2;    
			end
			STATE_ADDIMM: begin
				alu_s = `ADD;
				op2_s = `IMM5; 
			end
			STATE_ANDREG: begin
				alu_s = `AND;
				op2_s = `SR2; 
			end
			STATE_ANDIMM: begin
				alu_s = `AND;
				op2_s = `IMM5; 
			end
			STATE_BR: begin
				alu_s = `ADD;
				op1_s = `PC;
			end
			STATE_JSRPR: begin
				op1_s = `PC;
			end
			STATE_JSR: begin
				alu_s = `ADD;
				op1_s = `PC;
				op2_s = `OFF11; 
			end
			STATE_LD: begin
				alu_s = `ADD;
				rf_s = `MEM;
				op1_s = `PC;
			end
			STATE_LDIPT1: begin
				alu_s = `ADD;
				rf_s = `MEM;
				op1_s = `PC;
			end
			STATE_LDIPT2: begin
				alu_s = `ADD;
				rf_s = `MEM;
				mem_s = `LDI;
				op1_s = `PC;
			end
			STATE_LDR: begin
				alu_s = `ADD;
				rf_s = `MEM;
				op2_s = `OFF6; 
			end
			STATE_LEA: begin
				alu_s = `ADD;
				op1_s = `PC;
			end
			STATE_NOT : begin
				alu_s = `NOT; 
			end
			STATE_ST : begin
				alu_s = `ADD;
				op1_s = `PC;
			end
			STATE_STIPT1 : begin
				alu_s = `ADD;
				op1_s = `PC;
			end
			STATE_STIPT2 : begin
				alu_s = `ADD;
				mem_s = `LDI;
				op1_s = `PC;
			end
			STATE_STR : begin
				alu_s = `ADD;
				op1_s = `RF_1;
				op2_s = `OFF6; 
			end
		endcase
	end
 
	// Next State Combinational Logic
	always @( * ) begin
		// Set default value for next state here
		next_state = STATE_FETCH;

		// Add your next-state logic here
		case (state)

			STATE_FETCH: begin
				next_state = STATE_DECODE;
			end

			STATE_DECODE: begin

			case (ir[15:12])

				`OC_ADD: begin
					if (ir[`IMM_BIT_NUM]) begin
						next_state = STATE_ADDIMM;
					end
					else begin
						next_state = STATE_ADDREG;
					end
				end

				`OC_AND: begin
					if (ir[`IMM_BIT_NUM]) begin
						next_state = STATE_ANDIMM;
					end
					else begin
						next_state = STATE_ANDREG;
					end
				end

				`OC_BR: begin
					if ((ir[`BR_N] && n) || (ir[`BR_Z] && z) || (ir[`BR_P] && p)) begin
						next_state = STATE_BR;
					end
				end
				`OC_JMP: begin
					next_state = STATE_JMP;
				end
				`OC_JSR: begin
					next_state = STATE_JSRPR;
				end
				`OC_LD: begin
					next_state = STATE_LD;
				end
				`OC_LDI: begin
					next_state = STATE_LDIPT1;
				end
				`OC_LDR: begin
					next_state = STATE_LDR;
				end
				`OC_LEA: begin
					next_state = STATE_LEA;
				end
				`OC_NOT: begin
					next_state = STATE_NOT;
				end
				`OC_ST: begin
					next_state = STATE_ST;
				end
				`OC_STI: begin
					next_state = STATE_STIPT1;
				end
				`OC_STR: begin
					next_state = STATE_STR;
				end
				`OC_HLT: begin
					next_state = STATE_HALT;
				end
			endcase

			end

			STATE_JSRPR: begin
				if (ir[`JSR_BIT_NUM]) begin
					next_state = STATE_JSR;
				end
				else begin
					next_state = STATE_JSRR;
				end
			end
			STATE_LDIPT1: begin
				next_state = STATE_LDIPT2;
			end
			STATE_STIPT1 : begin
				next_state = STATE_STIPT2;
			end
			STATE_HALT : begin
				next_state = STATE_HALT;
			end
		endcase
	end

   // State Update Sequential Logic
   always @(posedge clk) begin
       if (rst) begin 
    		// initial state
			state <= STATE_FETCH;
       end
       else begin
           // next state 
           state <= next_state;
       end
   end
 
endmodule
 

