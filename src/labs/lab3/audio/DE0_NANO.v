//=======================================================
// ECE3400 Fall 2017
// Lab 3: Template top-level module
//
// Top-level skeleton from Terasic
// Modified by Claire Chen for ECE3400 Fall 2017
//=======================================================

`define ONE_SEC 25000000

module DE0_NANO(

	//////////// CLOCK //////////
	CLOCK_50,

	//////////// LED //////////
	LED,

	//////////// KEY //////////
	KEY,

	//////////// SW //////////
	SW,

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	GPIO_0_D,
	GPIO_0_IN,

	//////////// GPIO_0, GPIO_1 connect to GPIO Default //////////
	GPIO_1_D,
	GPIO_1_IN,
);

	 //=======================================================
	 //  PARAMETER declarations
	 //=======================================================

	 localparam ONE_SEC = 25000000; // one second in 25MHz clock cycles
	 localparam HALF_CYCLE = (25000000/1000)/2;
	 
	 //=======================================================
	 //  PORT declarations
	 //=======================================================

	 //////////// CLOCK //////////
	 input 		          		CLOCK_50;

	 //////////// LED //////////
	 output		     [7:0]		LED;

	 /////////// KEY //////////
	 input 		     [1:0]		KEY;

	 //////////// SW //////////
	 input 		     [3:0]		SW;

	 //////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	 inout 		    [33:0]		GPIO_0_D;
	 input 		     [1:0]		GPIO_0_IN;

	 //////////// GPIO_0, GPIO_1 connect to GPIO Default //////////
	 inout 		    [33:0]		GPIO_1_D;
	 input 		     [1:0]		GPIO_1_IN;

    //=======================================================
    //  REG/WIRE declarations
    //=======================================================
    reg         CLOCK_25;
    wire        reset; // active high reset signal 

    wire [9:0]  PIXEL_COORD_X; // current x-coord from VGA driver
    wire [9:0]  PIXEL_COORD_Y; // current y-coord from VGA driver
    wire [7:0]  PIXEL_COLOR;   // input 8-bit pixel color for current coords
	 
	 reg [24:0] led_counter; // timer to keep track of when to toggle LED
	 reg 			led_state;   // 1 is on, 0 is off
	 
	 reg tone_1000;
	 reg [15:0] counter;
	 assign GPIO_0_D[0] = tone_1000;
	 
	 reg [7:0] tri_1000;     // 1 kHz triangle wave
	 reg [5:0] tri_counter;
	 reg Incr;					 // Increasing/decresing state variable
	 //assign GPIO_0_D[22] = tri_1000[0];
	 //assign GPIO_0_D[20] = tri_1000[1];
	 //assign GPIO_0_D[18] = tri_1000[2];
	 //assign GPIO_0_D[16] = tri_1000[3];
	 //assign GPIO_0_D[14] = tri_1000[4];
	 //assign GPIO_0_D[12] = tri_1000[5];
	 //assign GPIO_0_D[10] = tri_1000[6];
	 //assign GPIO_0_D[8] = tri_1000[7];
	 
	 reg [7:0] sound;
	 //assign GPIO_0_D[22] = sound[0];
	 //assign GPIO_0_D[20] = sound[1];
	 //assign GPIO_0_D[18] = sound[2];
	 //assign GPIO_0_D[16] = sound[3];
	 //assign GPIO_0_D[14] = sound[4];
	 //assign GPIO_0_D[12] = sound[5];
	 //assign GPIO_0_D[10] = sound[6];
	 //assign GPIO_0_D[8] = sound[7];
	 
	 
    // Module outputs coordinates of next pixel to be written onto screen
    VGA_DRIVER driver(
		  .RESET(reset),
        .CLOCK(CLOCK_25),
        .PIXEL_COLOR_IN(PIXEL_COLOR),
        .PIXEL_X(PIXEL_COORD_X),
        .PIXEL_Y(PIXEL_COORD_Y),
        .PIXEL_COLOR_OUT({GPIO_0_D[9],GPIO_0_D[11],GPIO_0_D[13],GPIO_0_D[15],GPIO_0_D[17],GPIO_0_D[19],GPIO_0_D[21],GPIO_0_D[23]}),
        .H_SYNC_NEG(GPIO_0_D[7]),
        .V_SYNC_NEG(GPIO_0_D[5])
    );
	 
	 AUDIO audio(
			.RESET(reset),
			.CLK(CLOCK_25),
			.SW(SW),
			.SOUND({GPIO_0_D[8],GPIO_0_D[10],GPIO_0_D[12],GPIO_0_D[14],GPIO_0_D[16],GPIO_0_D[18],GPIO_0_D[20],GPIO_0_D[22]})
	 );
	 
	 assign reset = ~KEY[0]; // reset when KEY0 is pressed
	 
	 assign PIXEL_COLOR = 8'b000_111_00; // Green
	 assign LED[0] = led_state;
	 
    //=======================================================
    //  Structural coding
    //=======================================================
 
	 // Generate 25MHz clock for VGA, FPGA has 50 MHz clock
    always @ (posedge CLOCK_50) begin
        CLOCK_25 <= ~CLOCK_25; 
    end // always @ (posedge CLOCK_50)
	
	 // Simple state machine to toggle LED0 every one second
	 always @ (posedge CLOCK_25) begin
		  if (reset) begin
				led_state   <= 1'b0;
				led_counter <= 25'b0;
		  end
		  
		  if (led_counter == ONE_SEC) begin
				led_state   <= ~led_state;
				led_counter <= 25'b0;
		  end
		  else begin	
				led_state   <= led_state;
				led_counter <= led_counter + 25'b1;
		  end // always @ (posedge CLOCK_25)
	 end
	 
	 // State machine for 1 kHz square wave output
	 always @ (posedge CLOCK_25) begin
	   if (reset) begin
			tone_1000 <= 0;
			counter <= 0;
		end
		if (counter == 0) begin
			tone_1000 <= ~tone_1000;
			counter <= HALF_CYCLE - 1;
		end
		else begin
			tone_1000 <= tone_1000;
			counter <= counter - 1;
		end
	end
	
	//State machine for 1 kHz triangle wave output
	always @ (posedge CLOCK_25) begin
		if (reset) begin
			Incr <= 1;
			tri_1000 <= 0;
			tri_counter <= 0;
		end
		if (tri_counter == 0) begin
			if ((Incr == 1) && (tri_1000 < 254)) begin
				Incr <= Incr;
				tri_1000 <= tri_1000 + 1;
				tri_counter <= 48;
			end
			else if ((Incr == 1) && (tri_1000 == 254)) begin
				Incr <= ~Incr;
				tri_1000 <= tri_1000 + 1;
				tri_counter <= 48;
			end
			else if ((Incr == 0) && (tri_1000 > 1)) begin
				Incr <= Incr;
				tri_1000 <= tri_1000 - 1;
				tri_counter <= 48;
			end
			else begin
				Incr <= ~Incr;
				tri_1000 <= tri_1000 - 1;
				tri_counter <= 48;
			end
		end
		else begin
			tri_1000 <= tri_1000;
			tri_counter <= tri_counter - 1;
		end
	end

endmodule
