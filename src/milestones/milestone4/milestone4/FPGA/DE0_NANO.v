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
	 
	 reg [15:0] 	DIN;
	 wire [15:0] DOUT;
	 wire 		DONE;
	 wire [15:0]	LAST_POS;
	 reg [15:0] CURR_POS;
	 
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
	  
	  AUDIO audio(
			.RESET(reset),
			.CLK(CLOCK_25),
			.SW(SW),
			.SOUND({GPIO_1_D[22],GPIO_1_D[20],GPIO_1_D[18],GPIO_1_D[16],GPIO_1_D[14],GPIO_1_D[12],GPIO_1_D[10],GPIO_1_D[8]})
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
	 reg[7:0] treasure1 = 8'b000_111_11;
	 reg[7:0] treasure2 = 8'b111_111_00;
	 reg[7:0] treasure3 = 8'b111_000_11;
	 
	 reg[1:0] my_grid[3:0][4:0];
	 reg[7:0] colors[7:0];
 
	 reg[5:0] newx; //update position with 9x11
	 reg[5:0] newy;
	 
	 reg[2:0] wall_grid[36:0][45:0];
	 
	 reg [3:0] ypos;
	 reg [3:0] xpos;
	 
	 integer k;
	 integer l;
	 
		
	 
	 

	 
	 
    //=======================================================
    //  Structural coding
    //=======================================================
 
	 // Always checking for pixel position
	 always @ (*) begin
	 
		if (reset) begin
		
				integer i;
				integer j;
	
				for (i = 0; i < 37; i=i+1) begin
					for (j = 0; j < 46; j=j+1) begin 
					
						wall_grid[i][j] = 3'b000;
						
						if (i%9 == 0) begin
							wall_grid[i][j] = 3'b011;
						end
							
						if (j%9 == 0) begin
							wall_grid[i][j] = 3'b011;
						end
						if (i%36 == 0) begin
							wall_grid[i][j] = 3'b100;
						end
						if (j%45 == 0) begin
							wall_grid[i][j] = 3'b100;
						end
//						else begin
//							wall_grid[i][j] = 3'b000;
//						end
					end
				end
				
				
				colors[0] = red; //unvisited or unreachable
				colors[1] = green; //current position
				colors[2] = blue; //already visited
				colors[3] = white; //no wall
				colors[4] = black; //wall
				colors[5] = treasure1; //7 kHz treasure
				colors[6] = treasure2; //12 kHz treasure
				colors[7] = treasure3; //17 kHz treasure
				
				
	//			CURR_POS = DIN;
	//			CURR_POS = 16'b0001001100001110; //new input data
	//			
	//			ypos = (CURR_POS[12:10] *2) +1;
	//			xpos = (CURR_POS[9:8] *2) +1;
	//	 
	//			wall_grid[xpos][ypos] = 3'b001;
	//			if (CURR_POS[7:6] != 2'b00) begin
	//				if (CURR_POS[7:6] == 2'b01) begin
	//					wall_grid[xpos][ypos] = 3'b101;
	//				end
	//				else if (CURR_POS[7:6] == 2'b10) begin
	//					wall_grid[xpos][ypos] = 3'b110;
	//				end
	//				else if (CURR_POS[7:6] == 2'b11) begin
	//					wall_grid[xpos][ypos] = 3'b111;
	//				end
	//			end
	//			
	//			if (CURR_POS[3:0] != 4'b0000) begin
	//				if (CURR_POS[3] == 1) begin
	//					wall_grid[xpos - 3'b001][ypos] = 3'b100;
	//				end
	//				if (CURR_POS[2] == 1) begin
	//					wall_grid[xpos + 3'b001][ypos] = 3'b100;
	//				end
	//				if (CURR_POS[1] == 1) begin
	//					wall_grid[xpos][ypos + 3'b001] = 3'b100;
	//				end
	//				if (CURR_POS[0] == 1) begin
	//					wall_grid[xpos][ypos - 3'b001] = 3'b100;
	//				end
	//			end
	//			LAST_POS = CURR_POS;		
		end //reset
		newx = PIXEL_COORD_X/10'd10;
		newy = PIXEL_COORD_Y/10'd10;
		if (PIXEL_COORD_X > 369 || PIXEL_COORD_Y > 459) begin
			PIXEL_COLOR = colors[3];
		end
		else begin
			PIXEL_COLOR = colors[wall_grid[newx][newy]];
		end
	end
//	
	always @ (posedge DIN) begin
//
//		//Color current position
//		CURR_POS <= DIN;
//		ypos = (CURR_POS[12:10]);
//		xpos = (CURR_POS[9:8]);
//		
//			for (k = (xpos*9) + 1; k < (xpos*9) + 9; k = k+1) begin
//				for (l = (ypos*9) + 1; l < (ypos*9) + 9; l = l+1) begin
//					wall_grid[k][l] = 3'b001;
//				end
//			end
		
//		//Color walls at current position
//		if (CURR_POS[3:0] != 4'b0000) begin
//		
//			if (CURR_POS[3] == 1) begin // West Wall
//			
//				integer k;
//				integer l;
//				for (k = (xpos*9); k < (xpos*9) + 1; k = k +1) begin
//					for (l = (ypos*9); l < (ypos*9) + 9; l = l+1) begin
//						wall_grid[k][l] = 3'b100;
//					end
//				end
//			end
//			
//			if (CURR_POS[2] == 1) begin // East Wall
//				
//				integer k;
//				integer l;
//				for (k = (xpos*9) + 9; k < (xpos*9) + 10; k = k +1) begin
//					for (l = (ypos*9); l < (ypos*9) + 9; l = l+1) begin
//						wall_grid[k][l] = 3'b100;
//					end
//				end
//			end
//			
//			if (CURR_POS[1] == 1) begin // South Wall
//			
//				integer k;
//				integer l;
//				for (k = (xpos*9); k < (xpos*9) + 9; k = k +1) begin
//					for (l = (ypos*9) + 1 ; l < (ypos*9) + 2; l = l+1) begin
//						wall_grid[k][l] = 3'b100;
//					end
//				end
//			end
//			
//			if (CURR_POS[0] == 1) begin // North Wall
//			
//				integer k;
//				integer l;
//				for (k = (xpos*9); k < (xpos*9) + 9; k = k +1) begin
//					for (l = (ypos*9) - 1 ; l < (ypos*9); l = l+1) begin
//						wall_grid[k][l] = 3'b100;
//					end
//				end
//			end
//			
//		end
//		
		//Color current location for Treasure
//		if (CURR_POS[7:6] != 2'b00) begin
//		
//			if (CURR_POS[7:6] == 2'b01) begin // 7kHz
//			
//				integer k;
//				integer l;
//				for (k = (xpos*9) + 1; k < (xpos*9) + 9; k = k+1) begin
//					for (l = (ypos*9) + 1; l < (ypos*9) + 9; l = l+1) begin
//						wall_grid[k][l] = 3'b101;
//					end
//				end
//			end
//			
//			else if (CURR_POS[7:6] == 2'b10) begin // 12 kHz
//				
//				integer k;
//				integer l;
//				for (k = (xpos*9) + 1; k < (xpos*9) + 9; k = k+1) begin
//					for (l = (ypos*9) + 1; l < (ypos*9) + 9; l = l+1) begin
//						wall_grid[k][l] = 3'b110;
//					end
//				end
//			end
//			
//			else if (CURR_POS[7:6] == 2'b11) begin // 17 kHz
//			
//				integer k;
//				integer l;
//				for (k = (xpos*9) + 1; k < (xpos*9) + 9; k = k+1) begin
//					for (l = (ypos*9) + 1; l < (ypos*9) + 9; l = l+1) begin
//						wall_grid[k][l] = 3'b111;
//					end
//				end
//			end
//			
//			
		
		//Color the Visited Last Position
	
		
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
