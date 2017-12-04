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
	 
	 reg [15:0]  DIN;
	 wire [15:0] DOUT;
	 wire 		 DONE;
	 reg [15:0]	 LAST_POS;
	 reg [15:0]  CURR_POS;
	 
	 reg doneaudio;
	 
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
			.SW(doneaudio),
			.SOUND({GPIO_1_D[8],GPIO_1_D[10],GPIO_1_D[12],GPIO_1_D[14],GPIO_1_D[16],GPIO_1_D[18],GPIO_1_D[20],GPIO_1_D[22]})
	  );
	 
	 assign reset = ~KEY[0]; // reset when KEY0 is pressed
	 
	 assign LED[0] = led_state;
	 
	 reg[7:0] red = 8'b111_000_00;
	 reg[7:0] white = 8'b111_111_11;
	 reg[7:0] blue = 8'b000_000_11;
	 reg[7:0] green = 8'b000_111_00;
	 reg[7:0] black = 8'b000_000_00;
	 reg[7:0] turqoise = 8'b000_111_11;
	 reg[7:0] yellow = 8'b111_111_00;
	 reg[7:0] purple = 8'b111_000_11;
	 
	 assign colors[0] = turqoise; //unvisited or unreachable
	 assign colors[1] = yellow; //current position
	 assign colors[2] = purple; //already visited
 	 assign colors[3] = white; //no wall
	 assign colors[4] = black; //wall
	 assign colors[5] = red; //7 kHz treasure
	 assign colors[6] = green; //12 kHz treasure
	 assign colors[7] = blue; //17 kHz treasure
	 
	 wire [7:0] colors[7:0];
 
	 reg[5:0] newx; //update position with 9x11
	 reg[5:0] newy;
	 
	 reg[2:0] wall_grid[36:0][45:0];
	 
	 reg [2:0] ypos;
	 reg [1:0] xpos;
	 
	 reg [1:0] xlast;
	 reg [2:0] ylast;
	 
	 reg [2:0] donecheck;
	 reg [1:0] treasure;
	 reg visited;
	 reg unreach;
	 reg wallw;
	 reg walle;
	 reg walls;
	 reg walln;
	 
	 reg [3:0] bigy;
	 reg [3:0] bigx;
	 
	 reg [3:0] lastbigx;
	 reg [3:0] lastbigy;
	 
	 reg [2:0] data_struc[8:0][10:0];
	 
	 integer i;
	 integer j;
	 
	 reg [2:0] state;
	 
	 reg check;

	 
	 
	 
    //=======================================================
    //  Structural coding
    //=======================================================
 
	 // Always checking for pixel position
	
	always @ (posedge CLOCK_25) begin
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
						else begin
							wall_grid[i][j] = wall_grid[i][j];
						end
					end
				end
				
				xpos = 3;
				ypos = 4;
				state = 3'b001;
				check = 1'b0;
				LAST_POS = 16'bxxx10011xxxxxxxx;
		end
		
		else if (DONE == 1'b1 && state == 3'b001) begin
			//Parse input data
			CURR_POS = DOUT;
			donecheck = (CURR_POS[15:13]);
			ypos = (CURR_POS[12:10]);
			xpos = (CURR_POS[9:8]);
			treasure = CURR_POS[7:6];
			visited = CURR_POS[5];
			unreach = CURR_POS[4];
			wallw = CURR_POS[3];
			walle = CURR_POS[2];
			walls = CURR_POS[1];
			walln = CURR_POS[0];
			state = 3'b010;
			
		end
		
		else if (state == 3'b010) begin
			
			
			bigy = (ypos << 1) + 1;
			bigx = (xpos << 1) + 1;
			
			//Treasure & Current Position
			if (treasure == 2'b01) begin
				data_struc[bigx][bigy] = 3'b101;
			end
			else if (treasure == 2'b10) begin
				data_struc[bigx][bigy] = 3'b110;
			end
			else if (treasure == 2'b11) begin
				data_struc[bigx][bigy] = 3'b111;
			end
			else begin
				data_struc[bigx][bigy] = 3'b001;
			end
			
			//Grid Space!
			wall_grid[(9*((bigx-1)>> 1))+1][(9*((bigy-1)>> 1))+1] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+1][(9*((bigy-1)>> 1))+2] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+1][(9*((bigy-1)>> 1))+3] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+1][(9*((bigy-1)>> 1))+4] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+1][(9*((bigy-1)>> 1))+5] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+1][(9*((bigy-1)>> 1))+6] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+1][(9*((bigy-1)>> 1))+7] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+1][(9*((bigy-1)>> 1))+8] = data_struc[bigx][bigy];
			
			wall_grid[(9*((bigx-1)>> 1))+2][(9*((bigy-1)>> 1))+1] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+2][(9*((bigy-1)>> 1))+2] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+2][(9*((bigy-1)>> 1))+3] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+2][(9*((bigy-1)>> 1))+4] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+2][(9*((bigy-1)>> 1))+5] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+2][(9*((bigy-1)>> 1))+6] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+2][(9*((bigy-1)>> 1))+7] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+2][(9*((bigy-1)>> 1))+8] = data_struc[bigx][bigy];
			
			wall_grid[(9*((bigx-1)>> 1))+3][(9*((bigy-1)>> 1))+1] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+3][(9*((bigy-1)>> 1))+2] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+3][(9*((bigy-1)>> 1))+3] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+3][(9*((bigy-1)>> 1))+4] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+3][(9*((bigy-1)>> 1))+5] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+3][(9*((bigy-1)>> 1))+6] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+3][(9*((bigy-1)>> 1))+7] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+3][(9*((bigy-1)>> 1))+8] = data_struc[bigx][bigy];
			
			wall_grid[(9*((bigx-1)>> 1))+4][(9*((bigy-1)>> 1))+1] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+4][(9*((bigy-1)>> 1))+2] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+4][(9*((bigy-1)>> 1))+3] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+4][(9*((bigy-1)>> 1))+4] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+4][(9*((bigy-1)>> 1))+5] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+4][(9*((bigy-1)>> 1))+6] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+4][(9*((bigy-1)>> 1))+7] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+4][(9*((bigy-1)>> 1))+8] = data_struc[bigx][bigy];
			
			wall_grid[(9*((bigx-1)>> 1))+5][(9*((bigy-1)>> 1))+1] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+5][(9*((bigy-1)>> 1))+2] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+5][(9*((bigy-1)>> 1))+3] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+5][(9*((bigy-1)>> 1))+4] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+5][(9*((bigy-1)>> 1))+5] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+5][(9*((bigy-1)>> 1))+6] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+5][(9*((bigy-1)>> 1))+7] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+5][(9*((bigy-1)>> 1))+8] = data_struc[bigx][bigy];
			
			wall_grid[(9*((bigx-1)>> 1))+6][(9*((bigy-1)>> 1))+1] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+6][(9*((bigy-1)>> 1))+2] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+6][(9*((bigy-1)>> 1))+3] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+6][(9*((bigy-1)>> 1))+4] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+6][(9*((bigy-1)>> 1))+5] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+6][(9*((bigy-1)>> 1))+6] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+6][(9*((bigy-1)>> 1))+7] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+6][(9*((bigy-1)>> 1))+8] = data_struc[bigx][bigy];
			
			wall_grid[(9*((bigx-1)>> 1))+7][(9*((bigy-1)>> 1))+1] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+7][(9*((bigy-1)>> 1))+2] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+7][(9*((bigy-1)>> 1))+3] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+7][(9*((bigy-1)>> 1))+4] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+7][(9*((bigy-1)>> 1))+5] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+7][(9*((bigy-1)>> 1))+6] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+7][(9*((bigy-1)>> 1))+7] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+7][(9*((bigy-1)>> 1))+8] = data_struc[bigx][bigy];
			
			wall_grid[(9*((bigx-1)>> 1))+8][(9*((bigy-1)>> 1))+1] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+8][(9*((bigy-1)>> 1))+2] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+8][(9*((bigy-1)>> 1))+3] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+8][(9*((bigy-1)>> 1))+4] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+8][(9*((bigy-1)>> 1))+5] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+8][(9*((bigy-1)>> 1))+6] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+8][(9*((bigy-1)>> 1))+7] = data_struc[bigx][bigy];
			wall_grid[(9*((bigx-1)>> 1))+8][(9*((bigy-1)>> 1))+8] = data_struc[bigx][bigy];
			
			
			state = 3'b011;
			
		end
			
		else if (state == 3'b011) begin
			
			
			
			//Walls
			//West Wall
			if (wallw == 1'b1) begin
				data_struc[bigx-1][bigy] = 3'b100;
			end
//			else if (wallw == 0 && (bigx-1) == 0) begin
//				data_struc[bigx-1][bigy] = 3'b100;
//			end
			else begin
				data_struc[bigx-1][bigy] = 3'b011;
				
			end
			
			wall_grid[9*((bigx-1)>> 1)][(9*((bigy-1)>> 1))+1] = data_struc[bigx-1][bigy];
			wall_grid[9*((bigx-1)>> 1)][(9*((bigy-1)>> 1))+2] = data_struc[bigx-1][bigy];
			wall_grid[9*((bigx-1)>> 1)][(9*((bigy-1)>> 1))+3] = data_struc[bigx-1][bigy];
			wall_grid[9*((bigx-1)>> 1)][(9*((bigy-1)>> 1))+4] = data_struc[bigx-1][bigy];
			wall_grid[9*((bigx-1)>> 1)][(9*((bigy-1)>> 1))+5] = data_struc[bigx-1][bigy];
			wall_grid[9*((bigx-1)>> 1)][(9*((bigy-1)>> 1))+6] = data_struc[bigx-1][bigy];
			wall_grid[9*((bigx-1)>> 1)][(9*((bigy-1)>> 1))+7] = data_struc[bigx-1][bigy];
			wall_grid[9*((bigx-1)>> 1)][(9*((bigy-1)>> 1))+8] = data_struc[bigx-1][bigy];
			
			state = 3'b100;
			
		end
		
		else if (state == 3'b100) begin
			
			//East Wall
			if (walle == 1) begin
				data_struc[bigx+1][bigy] = 3'b100;
			end
	//		else if (walle == 0 && (bigx+1) == 8) begin
	//			data_struc[bigx+1][bigy] = 3'b100;
	//		end
			else begin
				data_struc[bigx+1][bigy] = 3'b011;
			end
			wall_grid[9*((bigx+1)>> 1)][9*((bigy-1)>> 1)+1] = data_struc[bigx+1][bigy];
			wall_grid[9*((bigx+1)>> 1)][9*((bigy-1)>> 1)+2] = data_struc[bigx+1][bigy];
			wall_grid[9*((bigx+1)>> 1)][9*((bigy-1)>> 1)+3] = data_struc[bigx+1][bigy];
			wall_grid[9*((bigx+1)>> 1)][9*((bigy-1)>> 1)+4] = data_struc[bigx+1][bigy];
			wall_grid[9*((bigx+1)>> 1)][9*((bigy-1)>> 1)+5] = data_struc[bigx+1][bigy];
			wall_grid[9*((bigx+1)>> 1)][9*((bigy-1)>> 1)+6] = data_struc[bigx+1][bigy];
			wall_grid[9*((bigx+1)>> 1)][9*((bigy-1)>> 1)+7] = data_struc[bigx+1][bigy];
			wall_grid[9*((bigx+1)>> 1)][9*((bigy-1)>> 1)+8] = data_struc[bigx+1][bigy];
			
			state = 3'b101;
		end
			
		else if (state == 3'b101) begin
			//South Wall
			if (walls == 1) begin
				data_struc[bigx][bigy+1] = 3'b100;
			end	
//			else if (walls == 0 && (bigy+1) == 10) begin
//				data_struc[bigx][bigy+1] = 3'b100;
//			end
			else begin
				data_struc[bigx][bigy+1] = 3'b011;
			end
			
			wall_grid[(9*((bigx-1)>> 1))+1][9*((bigy+1)>> 1)] = data_struc[bigx][bigy+1];
			wall_grid[(9*((bigx-1)>> 1))+2][9*((bigy+1)>> 1)] = data_struc[bigx][bigy+1];
			wall_grid[(9*((bigx-1)>> 1))+3][9*((bigy+1)>> 1)] = data_struc[bigx][bigy+1];
			wall_grid[(9*((bigx-1)>> 1))+4][9*((bigy+1)>> 1)] = data_struc[bigx][bigy+1];
			wall_grid[(9*((bigx-1)>> 1))+5][9*((bigy+1)>> 1)] = data_struc[bigx][bigy+1];
			wall_grid[(9*((bigx-1)>> 1))+6][9*((bigy+1)>> 1)] = data_struc[bigx][bigy+1];
			wall_grid[(9*((bigx-1)>> 1))+7][9*((bigy+1)>> 1)] = data_struc[bigx][bigy+1];
			wall_grid[(9*((bigx-1)>> 1))+8][9*((bigy+1)>> 1)] = data_struc[bigx][bigy+1];
			
			state = 3'b110;
		end
		
		else if (state == 3'b110) begin
			//North Wall
			if (walln == 1) begin
				data_struc[bigx][bigy-1] = 3'b100;
			end
	//		else if (walln == 0 && (bigy-1) == 0) begin
	//			data_struc[bigx][bigy-1] = 3'b100;
	//		end
			else begin
				data_struc[bigx][bigy-1] = 3'b011;
			end
			
			wall_grid[(9*((bigx-1)>> 1))+1][9*((bigy-1)>> 1)] = data_struc[bigx][bigy-1];
			wall_grid[(9*((bigx-1)>> 1))+2][9*((bigy-1)>> 1)] = data_struc[bigx][bigy-1];
			wall_grid[(9*((bigx-1)>> 1))+3][9*((bigy-1)>> 1)] = data_struc[bigx][bigy-1];
			wall_grid[(9*((bigx-1)>> 1))+4][9*((bigy-1)>> 1)] = data_struc[bigx][bigy-1];
			wall_grid[(9*((bigx-1)>> 1))+5][9*((bigy-1)>> 1)] = data_struc[bigx][bigy-1];
			wall_grid[(9*((bigx-1)>> 1))+6][9*((bigy-1)>> 1)] = data_struc[bigx][bigy-1];
			wall_grid[(9*((bigx-1)>> 1))+7][9*((bigy-1)>> 1)] = data_struc[bigx][bigy-1];
			wall_grid[(9*((bigx-1)>> 1))+8][9*((bigy-1)>> 1)] = data_struc[bigx][bigy-1];
			
			
			state = 3'b111;
		end
		
		else if (state == 3'b111) begin
			//save coordinates
			
			if (check == 1'b1) begin
				ylast = (LAST_POS[12:10]);
				xlast = (LAST_POS[9:8]);
				
				lastbigx = (2*xlast) + 1;
				lastbigy = (2*ylast) + 1;
				data_struc[lastbigx][lastbigy] = 3'b010;
				
				wall_grid[9*((lastbigx-1)/2)+1][9*((lastbigy-1)/2)+1] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+1][9*((lastbigy-1)/2)+2] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+1][9*((lastbigy-1)/2)+3] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+1][9*((lastbigy-1)/2)+4] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+1][9*((lastbigy-1)/2)+5] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+1][9*((lastbigy-1)/2)+6] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+1][9*((lastbigy-1)/2)+7] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+1][9*((lastbigy-1)/2)+8] = data_struc[lastbigx][lastbigy];
				
				wall_grid[9*((lastbigx-1)/2)+2][9*((lastbigy-1)/2)+1] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+2][9*((lastbigy-1)/2)+2] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+2][9*((lastbigy-1)/2)+3] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+2][9*((lastbigy-1)/2)+4] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+2][9*((lastbigy-1)/2)+5] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+2][9*((lastbigy-1)/2)+6] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+2][9*((lastbigy-1)/2)+7] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+2][9*((lastbigy-1)/2)+8] = data_struc[lastbigx][lastbigy];
				
				wall_grid[9*((lastbigx-1)/2)+3][9*((lastbigy-1)/2)+1] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+3][9*((lastbigy-1)/2)+2] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+3][9*((lastbigy-1)/2)+3] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+3][9*((lastbigy-1)/2)+4] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+3][9*((lastbigy-1)/2)+5] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+3][9*((lastbigy-1)/2)+6] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+3][9*((lastbigy-1)/2)+7] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+3][9*((lastbigy-1)/2)+8] = data_struc[lastbigx][lastbigy];
				
				wall_grid[9*((lastbigx-1)/2)+4][9*((lastbigy-1)/2)+1] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+4][9*((lastbigy-1)/2)+2] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+4][9*((lastbigy-1)/2)+3] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+4][9*((lastbigy-1)/2)+4] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+4][9*((lastbigy-1)/2)+5] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+4][9*((lastbigy-1)/2)+6] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+4][9*((lastbigy-1)/2)+7] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+4][9*((lastbigy-1)/2)+8] = data_struc[lastbigx][lastbigy];
				
				wall_grid[9*((lastbigx-1)/2)+5][9*((lastbigy-1)/2)+1] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+5][9*((lastbigy-1)/2)+2] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+5][9*((lastbigy-1)/2)+3] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+5][9*((lastbigy-1)/2)+4] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+5][9*((lastbigy-1)/2)+5] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+5][9*((lastbigy-1)/2)+6] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+5][9*((lastbigy-1)/2)+7] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+5][9*((lastbigy-1)/2)+8] = data_struc[lastbigx][lastbigy];
				
				wall_grid[9*((lastbigx-1)/2)+6][9*((lastbigy-1)/2)+1] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+6][9*((lastbigy-1)/2)+2] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+6][9*((lastbigy-1)/2)+3] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+6][9*((lastbigy-1)/2)+4] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+6][9*((lastbigy-1)/2)+5] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+6][9*((lastbigy-1)/2)+6] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+6][9*((lastbigy-1)/2)+7] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+6][9*((lastbigy-1)/2)+8] = data_struc[lastbigx][lastbigy];
				
				wall_grid[9*((lastbigx-1)/2)+7][9*((lastbigy-1)/2)+1] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+7][9*((lastbigy-1)/2)+2] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+7][9*((lastbigy-1)/2)+3] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+7][9*((lastbigy-1)/2)+4] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+7][9*((lastbigy-1)/2)+5] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+7][9*((lastbigy-1)/2)+6] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+7][9*((lastbigy-1)/2)+7] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+7][9*((lastbigy-1)/2)+8] = data_struc[lastbigx][lastbigy];
				
				wall_grid[9*((lastbigx-1)/2)+8][9*((lastbigy-1)/2)+1] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+8][9*((lastbigy-1)/2)+2] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+8][9*((lastbigy-1)/2)+3] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+8][9*((lastbigy-1)/2)+4] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+8][9*((lastbigy-1)/2)+5] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+8][9*((lastbigy-1)/2)+6] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+8][9*((lastbigy-1)/2)+7] = data_struc[lastbigx][lastbigy];
				wall_grid[9*((lastbigx-1)/2)+8][9*((lastbigy-1)/2)+8] = data_struc[lastbigx][lastbigy];
			
				LAST_POS = CURR_POS;
			end
			check = 1'b1;
			if (donecheck == 3'b111) begin
				state = 3'b000;
			end
			else begin
				state = 3'b001;
			end
		end
		
		else if (state == 3'b000) begin
			integer i;
			integer j;
			
			for (i = 0; i < 37; i=i+1) begin
				for (j = 0; j < 46; j=j+1) begin
			
					if (i%36 == 0) begin
							wall_grid[i][j] = 3'b110;
					end
					if (j%45 == 0) begin
							wall_grid[i][j] = 3'b110;
					end
				end
			end
			doneaudio = 1'b1;
			state = 3'b000;
		end
		

		
		else begin
				integer i;
				integer j;
	
				for (i = 0; i < 37; i=i+1) begin
					for (j = 0; j < 46; j=j+1) begin
						wall_grid[i][j] = wall_grid[i][j];
					end
				end
		end
		
		newx = PIXEL_COORD_X/10'd10;
		newy = PIXEL_COORD_Y/10'd10;
		if (PIXEL_COORD_X > 369 || PIXEL_COORD_Y > 459) begin
			PIXEL_COLOR = colors[3];
		end
		else begin
			PIXEL_COLOR = colors[wall_grid[newx][newy]];
		end
		
		
		
//		
		
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
