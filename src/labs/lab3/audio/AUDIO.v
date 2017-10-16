module AUDIO (
	SW,
	CLK,
	RESET,
	SOUND
);

localparam ONE_SEC = 25000000; // one second in 25MHz clock cycles

input [1:0] SW;
input CLK;
input RESET;

reg  [31:0] phase_accumulator;
reg  [31:0] phase_increment;

reg [32:0] tones[3:0];

output reg [7:0] SOUND;

reg [24:0] time_counter;
reg [1:0] tone_counter;

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
	tones[0] <= 75591;
	tones[1] <= 151182;
	tones[2] <= 302365;
	tones[3] <= 151182;
end
	
always @(posedge CLK) begin
	if (RESET) begin
		time_counter = 0;
		tone_counter = 0;
		phase_accumulator = 0;
		phase_increment = tones[tone_counter]; // 1 kHz
	end
	if (~SW[1]) begin
		if (time_counter == ONE_SEC) begin
			time_counter = 0;
			tone_counter = tone_counter + 1;
			phase_accumulator = 0;
			phase_increment = tones[tone_counter];
			phase_accumulator = phase_accumulator + phase_increment;
			SOUND = rom[phase_accumulator[31:24]];
		end
		else begin
			phase_accumulator = phase_accumulator + phase_increment;
			SOUND = rom[phase_accumulator[31:24]];
			time_counter = time_counter + 1;
		end
	end
	else begin
		time_counter = 0;
		tone_counter = 0;
		phase_accumulator = 0;
		phase_increment = tones[tone_counter]; // 1 kHz
	end
end

endmodule
