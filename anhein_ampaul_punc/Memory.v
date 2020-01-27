//==============================================================================
// Memory with 2 read ports, 1 write port
//==============================================================================

module Memory
#(
	parameter N_ELEMENTS = 128,      // Number of Memory Elements
	parameter ADDR_WIDTH = 16,        // Address Width (in bits)
	parameter DATA_WIDTH = 16         // Data Width (in bits)
)(
	// Clock + Reset
	input                   clk,      // Clock
	input                   rst,      // Reset (All entries -> 0)

	// Read Address Channel
	input  [ADDR_WIDTH-1:0] r_addr_0, // Read Address 0
	input  [ADDR_WIDTH-1:0] r_addr_1, // Read Address 1

	// Write Address, Data Channel
	input  [ADDR_WIDTH-1:0] w_addr,   // Write Address
	input  [DATA_WIDTH-1:0] w_data,   // Write Data
	input                   w_en,     // Write Enable

	// Read Data Channel
	output [DATA_WIDTH-1:0] r_data_0, // Read Data 0
	output [DATA_WIDTH-1:0] r_data_1  // Read Data 1

);

	// Memory Unit
	reg [DATA_WIDTH-1:0] mem[N_ELEMENTS-1:0];


	//---------------------------------------------------------------------------
	// BEGIN MEMORY INITIALIZATION BLOCK
	//   - Paste the code you generate for memory initialization in synthesis
	//     here, deleting the current code.
	//   - Use the LC3 Assembler on Blackboard to generate your Verilog.
	//---------------------------------------------------------------------------

	localparam PROGRAM_LENGTH = 22;
	wire [DATA_WIDTH-1:0] mem_init[PROGRAM_LENGTH-1:0];

	assign mem_init[0] = 16'h2011;   // LD R0,  #17
	assign mem_init[1] = 16'hE210;   // LEA R1, #16
	assign mem_init[2] = 16'h14A3;   // ADD R2, R2, #3
	assign mem_init[3] = 16'h4800;   // JSR #0
	assign mem_init[4] = 16'h96BF;   // NOT R3, R2
	assign mem_init[5] = 16'h16E1;   // ADD R3, R3, #1
	assign mem_init[6] = 16'h16C0;   // ADD R3, R3, R0
	assign mem_init[7] = 16'h0809;   // BRn #9
	assign mem_init[8] = 16'h1681;   // ADD R3, R2, R1
	assign mem_init[9] = 16'h18FF;   // ADD R4, R3, #-1
	assign mem_init[10] = 16'h6900;   // LDR R4, R4, #0
	assign mem_init[11] = 16'h1AFE;   // ADD R5, R3, #-2
	assign mem_init[12] = 16'h6B40;   // LDR R5, R5, #0
	assign mem_init[13] = 16'h1D44;   // ADD R6 R5, R4
	assign mem_init[14] = 16'h7CC0;   // STR R6, R3, #0
	assign mem_init[15] = 16'h14A1;   // ADD R2, R2, #1
	assign mem_init[16] = 16'hC1C0;   // JMP R7
	assign mem_init[17] = 16'hF000;   // HALT
	assign mem_init[18] = 16'h0019;   // 0019
	assign mem_init[19] = 16'h0000;   // 0000
	assign mem_init[20] = 16'h0001;   // 0001
	assign mem_init[21] = 16'h0000;   // 0000

	//---------------------------------------------------------------------------
	// END MEMORY INITIALIZATION BLOCK
	//---------------------------------------------------------------------------

	// Continuous Read
	assign r_data_0 = mem[r_addr_0];
	assign r_data_1 = mem[r_addr_1];

	// Synchronous Reset + Write
	genvar i;
	generate
		for (i = 0; i < N_ELEMENTS; i = i + 1) begin : wport
			always @(posedge clk) begin
				if (rst) begin
					if (i < PROGRAM_LENGTH) begin
						`ifndef SIM
							mem[i] <= mem_init[i];
						`endif
					end
					else begin
						`ifndef SIM
							mem[i] <= 0;
						`endif
					end
				end
				else if (w_en && w_addr == i) begin
					mem[i] <= w_data;
				end
			end
		end
	endgenerate

endmodule
