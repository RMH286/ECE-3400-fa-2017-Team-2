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
    reg [7:0]  PIXEL_COLOR;   // input 8-bit pixel color for current coords
	 
	 reg [24:0] led_counter; // timer to keep track of when to toggle LED
	 reg 			led_state;   // 1 is on, 0 is off
	 
	 reg [10:0] 	DIN;
	 wire [10:0] DOUT;
	 wire 		DONE;
	 reg [10:0]	LAST_POS;
	 reg [10:0] 	CURR_POS;
	 
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
	 
	 spi_slave slave(
			.clk(CLOCK_25),
			.rst(reset),
			.ss(GPIO_1_D[32]),
			.mosi(GPIO_1_D[30]),
			.miso(GPIO_1_D[28]),
			.sck(GPIO_1_D[26]),
			.done(DONE),
			.din(DIN),
			.dout(DOUT),
	  );
	 
	 assign reset = ~KEY[0]; // reset when KEY0 is pressed
	 
	 
	 //Use to change background screen color
	 //assign PIXEL_COLOR = 8'b000_111_00; // Green
	 //assign PIXEL_COLOR = 8'b000_000_11; // Blue
	 //assign PIXEL_COLOR = 8'b111_000_00; // Red
	 //assign PIXEL_COLOR = 8'b0 // Black
	 
	 assign LED[0] = led_state;
	 
	 reg[7:0] red = 8'b111_000_00;
	 reg[7:0] white = 8'b111_111_11;
	 reg[7:0] blue = 8'b000_000_11;
	 reg[7:0] green = 8'b000_111_00;
	 reg[7:0] black = 8'b000_000_00;
	 
	 reg[1:0] my_grid[3:0][4:0];
	 reg[7:0] colors[4:0];
 
	 reg[4:0] newx; //update position with 9x11
	 reg[4:0] newy;
	 
	 reg[2:0] wall_grid[8:0][10:0];
	 
//	 reg test;
	 
	// assign GPIO_1_D[1] = test;
	 
	 
	 
    //=======================================================
    //  Structural coding
    //=======================================================
 
	 // Always checking for pixel position
	 always @ (*) begin
//		if (reset) begin
//			for (i = 0; i < 4; i=i+1) begin
//				for (j = 0; j < 5; j=j+1) begin 
//					my_grid[i][j] = 2'b00;
//				end
//			end
//			colors[0] = red;
//			colors[1] = green;
//			colors[2] = blue;
//			LAST_POS = 7'b1111111;
//		end
//		
//		my_grid[LAST_POS[7:6]][LAST_POS[5:3]] = 2'b10;
//		my_grid[DOUT[7:6]][DOUT[5:3]] = 2'b01;
//		//LAST_POS = DOUT;
//	 
//		newx = PIXEL_COORD_X/10'd100;
//		newy = PIXEL_COORD_Y/10'd100;
//		if (PIXEL_COORD_X > 399 | PIXEL_COORD_Y > 499) begin
//			PIXEL_COLOR = 8'd0;
//		end
//		else begin
//			PIXEL_COLOR = colors[my_grid[newx][newy]];
//		end
//		
//		end
	
	if (reset) begin
	
			integer i;
			integer j;

			for (i = 0; i < 9; i=i+1) begin
				for (j = 0; j < 11; j=j+1) begin 
				
					wall_grid[i][j] = 3'b000;
					
					if ( i%2 == 0) begin
						wall_grid[i][j] = 3'b011;
					end
						
					if ( j%2 == 0) begin
						wall_grid[i][j] = 3'b011;
					end
			
				end
			end
			
			
			colors[0] = red;
			colors[1] = green;
			colors[2] = blue;
			colors[3] = white;
			colors[4] = black;
			LAST_POS = 7'b1111111;
		end
		
		wall_grid[LAST_POS[10:7]][LAST_POS[6:3]] = 2'b10;
		wall_grid[DOUT[10:7]][DOUT[6:3]] = 2'b01;
		//LAST_POS = DOUT;
	 
		newx = PIXEL_COORD_X/10'd40;
		newy = PIXEL_COORD_Y/10'd40;
		if (PIXEL_COORD_X > 359 | PIXEL_COORD_Y > 439) begin
			PIXEL_COLOR = 8'd0;
		end
		else begin
			PIXEL_COLOR = colors[wall_grid[newx][newy]];
		end
		
		end
		
		
		
		
	

 
 
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
	 

endmodule
