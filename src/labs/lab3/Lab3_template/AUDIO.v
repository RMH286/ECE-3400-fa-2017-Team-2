module AUDIO (
	FREQUENCY,
	CLK,
	RESET,
	AUDIO
);

input FREQUENCY;
input CLK;
input RESET;

reg  [31:0] phase_accumulator;
reg  [31:0] phase_increment;
reg [7:0] q;

output [7:0] AUDIO;

assign AUDIO = q;

// Declare the ROM variable
reg [7:0] rom[2**8-1:0];

// Initialize the ROM with $readmemb.  Put the memory contents
// in the file single_port_rom_init.txt.  Without this file,
// this design will not compile.

// See Verilog LRM 1364-2001 Section 17.2.8 for details on the
// format of this file, or see the "Using $readmemb and $readmemh"
// template later in this section.

initial
begin
	$readmemb("sin_init.txt", rom);
end
	
always @(posedge CLK) begin
	if (RESET) begin
		phase_accumulator <= 0;
		phase_increment = 2**32 * FREQUENCY / 25000000;
	end
   else begin
		phase_accumulator <= phase_accumulator + phase_increment;
		q <= rom[phase_accumulator[31:24]];
	end
end

endmodule
