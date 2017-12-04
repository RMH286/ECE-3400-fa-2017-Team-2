module AUDIO (
	SW,
	CLK,
	RESET,
	SOUND
);

localparam ONE_SEC = 25000000; // one second in 25MHz clock cycles
localparam EIGHTH_SEC = 3125000; // one eighth of a second

input SW;
input CLK;
input RESET;

reg  [31:0] phase_accumulator;
reg  [31:0] phase_increment;

//reg [32:0] tones[3:0];
reg [32:0] tones[63:0];

output reg [7:0] SOUND;

reg [24:0] time_counter;
//reg [1:0] tone_counter;
reg [5:0] tone_counter;

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
//	tones[0] <= 75591;
//	tones[1] <= 151182;
//	tones[2] <= 302365;
//	tones[3] <= 151182;
//	tones[0] <= 56624;
//	tones[1] <= 56624;
//	tones[2] <= 56624;
//	tones[3] <= 0;
//	tones[4] <= 56624;
//	tones[5] <= 56624;
//	tones[6] <= 56624;
//	tones[7] <= 0;
//	tones[8] <= 56624;
//	tones[9] <= 56624;
//	tones[10] <= 56624;
//	tones[11] <= 56624;
//	tones[12] <= 56624;
//	tones[13] <= 56624;
//	tones[14] <= 56624;
//	tones[15] <= 0;
//	tones[16] <= 56624;
//	tones[17] <= 56624;
//	tones[18] <= 56624;
//	tones[19] <= 0;
//	tones[20] <= 56624;
//	tones[21] <= 56624;
//	tones[22] <= 56624;
//	tones[23] <= 0;
//	tones[24] <= 56624;
//	tones[25] <= 56624;
//	tones[26] <= 56624;
//	tones[27] <= 56624;
//	tones[28] <= 56624;
//	tones[29] <= 56624;
//	tones[30] <= 56624;
//	tones[31] <= 0;
//	tones[32] <= 56624;
//	tones[33] <= 56624;
//	tones[34] <= 56624;
//	tones[35] <= 0;
//	tones[36] <= 67344;
//	tones[37] <= 67344;
//	tones[38] <= 67344;
//	tones[39] <= 0;
//	tones[40] <= 44942;
//	tones[41] <= 44942;
//	tones[42] <= 44942;
//	tones[43] <= 44942;
//	tones[44] <= 44942;
//	tones[45] <= 0;
//	tones[46] <= 50439;
//	tones[47] <= 0;
//	tones[48] <= 56624;
//	tones[49] <= 56624;
//	tones[50] <= 56624;
//	tones[51] <= 56624;
//	tones[52] <= 56624;
//	tones[53] <= 56624;
//	tones[54] <= 56624;
//	tones[55] <= 56624;
//	tones[56] <= 56624;
//	tones[57] <= 56624;
//	tones[58] <= 56624;
//	tones[59] <= 56624;
//	tones[60] <= 56624;
//	tones[61] <= 56624;
//	tones[62] <= 56624;
//	tones[63] <= 0;
	tones[0] <= 113249;
	tones[1] <= 113249;
	tones[2] <= 113249;
	tones[3] <= 0;
	tones[4] <= 113249;
	tones[5] <= 113249;
	tones[6] <= 113249;
	tones[7] <= 0;
	tones[8] <= 113249;
	tones[9] <= 113249;
	tones[10] <= 113249;
	tones[11] <= 113249;
	tones[12] <= 113249;
	tones[13] <= 113249;
	tones[14] <= 113249;
	tones[15] <= 0;
	tones[16] <= 113249;
	tones[17] <= 113249;
	tones[18] <= 113249;
	tones[19] <= 0;
	tones[20] <= 113249;
	tones[21] <= 113249;
	tones[22] <= 113249;
	tones[23] <= 0;
	tones[24] <= 113249;
	tones[25] <= 113249;
	tones[26] <= 113249;
	tones[27] <= 113249;
	tones[28] <= 113249;
	tones[29] <= 113249;
	tones[30] <= 113249;
	tones[31] <= 0;
	tones[32] <= 113249;
	tones[33] <= 113249;
	tones[34] <= 113249;
	tones[35] <= 0;
	tones[36] <= 134689;
	tones[37] <= 134689;
	tones[38] <= 134689;
	tones[39] <= 0;
	tones[40] <= 89994;
	tones[41] <= 89884;
	tones[42] <= 89884;
	tones[43] <= 89884;
	tones[44] <= 89884;
	tones[45] <= 0;
	tones[46] <= 100897;
	tones[47] <= 0;
	tones[48] <= 113249;
	tones[49] <= 113249;
	tones[50] <= 113249;
	tones[51] <= 113249;
	tones[52] <= 113249;
	tones[53] <= 113249;
	tones[54] <= 113249;
	tones[55] <= 113249;
	tones[56] <= 113249;
	tones[57] <= 113249;
	tones[58] <= 113249;
	tones[59] <= 113249;
	tones[60] <= 113249;
	tones[61] <= 113249;
	tones[62] <= 113249;
	tones[63] <= 0;
	
end
	
always @(posedge CLK) begin
	if (RESET) begin
		time_counter = 0;
		tone_counter = 0;
		phase_accumulator = 0;
		phase_increment = tones[tone_counter]; // 1 kHz
	end
	if (SW) begin
		//if (time_counter == ONE_SEC) begin
		if (time_counter == EIGHTH_SEC) begin	
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
