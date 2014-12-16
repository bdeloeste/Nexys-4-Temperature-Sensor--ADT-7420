`timescale 1ns / 1ps

module vh_sync (
	input wire clk,
	input wire clr,
	output wire hsync,
	output wire vsync,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue,
	
	inout SDA,
	output SCL,
	output [15:0] led,
	output reg [6:0] sseg_temp,
	output reg [7:0] an,
	output reg dp
    );
	
/*
* These are the parameters for a 640x480 px display (60Hz refresh rate)
*/
parameter hpixels = 800;
parameter vlines = 521;
parameter hpulse = 96;
parameter vpulse = 2;
parameter hbp = 144;
parameter hfp = 784;
parameter vbp = 31;
parameter vfp = 511;

reg [22:0] counter;
reg [9:0] tick;
reg [9:0] hc;
reg [9:0] vc;
reg [1:0] pxclk;

wire inH = (hc < 640);
wire inV = (vc < 480);
wire inDisplay = inH && inV;

always @ (posedge clk)
begin
    pxclk <= pxclk + 1;
    if (counter == 2000000)
        counter <= 0;
    else
        counter <= counter + 1;
end

wire pclk;
wire click;

assign pclk = pxclk[1]; // 25MHz Pixel Clock
assign click = (counter == 2000000) ? 1 : 0;

/*
 * Enable the horizontal and vertical counters to count when they are in the
 * range of the display.
 */
 
always @ (posedge pclk or posedge clr)
begin
	if (clr == 1)
	begin
		hc <= 0;
		vc <= 0;
	end
	else
	begin
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
	end
end

assign hsync = (hc < hpulse) ? 0:1; 
assign vsync = (vc < vpulse) ? 0:1;

reg [11:0] r = 12'h00F;
reg [11:0] g = 12'h0F0;
reg [11:0] b = 12'hF00;
reg [11:0] w = 12'hFFF;

wire [7:0] data;
assign data = {sixth, fifth};

always @ (posedge click)
begin
    if (tick == 200)
        tick <= 0;
    else
        tick <= tick + 1;
end

/*
* This always block is used to display all characters (A-Z, 0-9)
*/
always @ (*)
begin
    if ((vc >= vbp & vc < vfp & hc >= hbp & hc < hfp))
    begin
        // X, Y Axis
        draw(100, 100, 102, 300, w);
        draw(100, 100, 300, 102, w);
        // X-labels
        char(35, 90, 90);
        // TIME 
        char(19, 150, 80);
        char(8, 160, 80);
        char(12, 168, 80);
        char(4, 178, 80);
        // TEMPERATURE
        char(19, 108, 302);
        char(4, 120, 302);
        char(12, 130, 302);
        char(15, 140, 302);
        char(4, 150, 302);
        char(17, 160, 302);
        char(0, 170, 302);
        char(19, 180, 302);
        char(20, 190, 302);
        char(17, 200, 302);
        char(4, 210, 302);
        // DATA
        draw(103 + tick, 200 + data, 105 + tick, 202 + data, r);
    end
    if (!inDisplay)
    begin
        red = 0;
        green = 0;
        blue = 0;
    end
end

/*
* Implemented a function to draw a white line whenever vc and hc are
* in the domain of the x-start, y-start and x-end, and y-end coordinates.
*/
function draw;
input [9:0] xStart;
input [9:0] yStart;
input [9:0] xEnd; 
input [9:0] yEnd;
input [11:0] color;
begin
    if (vc >= (vbp + yStart) && vc < (vbp + yEnd) && hc >= (hbp + xStart) && hc < (hbp + xEnd))
    begin
        red = color[3:0];
        green = color[7:4];
        blue = color[11:8];
    end
    if (!inDisplay)
    begin
        red = 0;
        green = 0;
        blue = 0;
    end
end
endfunction

/*
* char function to manually draw each character on a 9x9 pixel block
*/
function char;
input [5:0] charVal;
input [9:0] x, y;
reg [11:0] white = 12'hFFF;
begin
    case(charVal)
        6'b000000: // A
            begin
                draw(x + 2, y, x + 5, y + 1, white);
                draw(x + 1, y + 1, x + 6, y + 2, white);
                draw(x, y + 2, x + 2, y + 9, white);
                draw(x + 2, y + 4, x + 5, y + 6, white);
                draw(x + 5, y + 2, x + 7, y + 9, white);
            end
        6'b000001: // B
            begin
                draw(x, y, x + 5, y + 2, white);
                draw(x, y + 2, x + 2, y + 9, white);
                draw(x + 5, y + 2, x + 7, y + 4, white);
                draw(x + 2, y + 4, x + 5, y + 5, white);
                draw(x + 5, y + 5, x + 7, y + 8, white);
                draw(x + 2, y + 8, x + 5, y + 9, white);
            end
        6'b000010: // C
            begin
                draw(x + 2, y, x + 6, y + 1, white);
                draw(x + 1, y + 1, x + 2, y + 2, white);
                draw(x + 6, y + 1, x + 7, y + 2, white);
                draw(x, y + 2, x + 2, y + 8, white);
                draw(x + 1, y + 8, x + 6, y + 9, white);
                draw(x + 6, y + 7, x + 7, y + 8, white);
            end
        6'b000011: // D
            begin
                draw(x, y, x + 5, y + 1, white);
                draw(x, y + 1, x + 2, y + 9, white);
                draw(x + 5, y + 1, x + 6, y + 2, white);
                draw(x + 6, y + 2, x + 7, y + 7, white);
                draw(x + 5, y + 7, x + 6, y + 8, white);
                draw(x + 2, y + 8, x + 5, y + 9, white);
            end
        6'b000100: // E
            begin
                draw(x, y, x + 7, y + 1, white);
                draw(x, y + 1, x + 2, y + 9, white);
                draw(x + 2, y + 4, x + 5, y + 5, white);
                draw(x + 2, y + 8, x + 7, y + 9, white);
            end
        6'b000101: // F
            begin
                draw(x, y, x + 7, y + 1, white);
                draw(x, y + 1, x + 2, y + 9, white);
                draw(x + 2, y + 3, x + 5, y + 4, white);
            end
        6'b000110: // G
            begin
                draw(x + 1, y, x + 6, y + 1, white);
                draw(x, y + 1, x + 2, y + 8, white);
                draw(x + 6, y + 1, x + 7, y + 2, white);
                draw(x + 1, y + 8, x + 6, y + 9, white);
                draw(x + 5, y + 5, x + 7, y + 8, white);
                draw(x + 4, y + 5, x + 5, y + 6, white);
            end
        6'b000111: // H
            begin
                draw(x, y, x + 2, y + 9, white);
                draw(x + 2, y + 4, x + 5, y + 5, white);
                draw(x + 5, y, x + 7, y + 9, white);
            end
        6'b001000: // I
            begin
                draw(x, y, x + 2, y + 9, white);
            end
        6'b001001: // J
            begin
                draw(x + 5, y, x + 7, y + 8, white);
                draw(x, y + 6, x + 1, y + 8, white);
                draw(x + 1, y + 8, x + 6, y + 9, white);
            end
        6'b001010: // K
            begin
                draw(x, y, x + 2, y + 9, white);
                draw(x + 2, y + 4, x + 5, y + 5, white);
                draw(x + 5, y + 3, x + 6, y + 4, white);
                draw(x + 5, y + 5, x + 6, y + 6, white);
                draw(x + 6, y, x + 7, y + 3, white);
                draw(x + 6, y + 6, x + 7, y + 9, white);
            end
        6'b001011: // L
            begin
                draw(x, y, x + 2, y + 9, white);
                draw(x + 2, y + 7, x + 7, y + 9, white);
            end
        6'b001100: // M
            begin
                draw(x + 1, y, x + 3, y + 1, white);
                draw(x + 4, y, x + 6, y + 1, white);
                draw(x, y + 1, x + 7, y + 2, white);
                draw(x, y + 2, x + 2, y + 9, white);
                draw(x + 3, y + 2, x + 4, y + 9, white);
                draw(x + 5, y + 2, x + 7, y + 9, white);
            end
        6'b001101: // N
            begin
                draw(x, y, x + 2, y + 9, white);
                draw(x + 2, y + 1, x + 3, y + 2, white);
                draw(x + 3, y, x + 6, y + 1, white);
                draw(x + 6, y + 1, x + 7, y + 9, white);
            end
        6'b001110: // O
            begin
                draw(x, y + 1, x + 2, y + 8, white);
                draw(x + 5, y + 1, x + 7, y + 8, white);
                draw(x + 1, y, x + 6, y + 1, white);
                draw(x + 1, y + 8, x + 6, y + 9, white);
            end
        6'b001111: // P
            begin
                draw(x, y, x + 5, y + 1, white);
                draw(x, y + 1, x + 2, y + 9, white);
                draw(x + 5, y + 1, x + 6, y + 2, white);
                draw(x + 6, y + 2, x + 7, y + 4, white);
                draw(x + 5, y + 4, x + 6, y + 5, white);
                draw(x + 2, y + 5, x + 5, y + 6, white);
            end
        6'b010000: // Q
            begin
                draw(x + 1, y, x + 6, y + 1, white);
                draw(x, y + 1, x + 2, y + 8, white);
                draw(x + 5, y + 1, x + 7, y + 7, white);
                draw(x + 1, y + 8, x + 7, y + 9, white);
                draw(x + 3, y + 6, x + 4, y + 7, white);
                draw(x + 4, y + 7, x + 6, y + 8, white);
                draw(x + 1, y + 8, x + 7, y + 9, white);
            end
        6'b010001: // R
            begin
                draw(x, y, x + 5, y + 1, white);
                draw(x, y + 1, x + 2, y + 9, white);
                draw(x + 5, y + 1, x + 6, y + 2, white);
                draw(x + 6, y + 2, x + 7, y + 4, white);
                draw(x + 5, y + 4, x + 6, y + 5, white);
                draw(x + 2, y + 5, x + 6, y + 6, white);
                draw(x + 6, y + 6, x + 7, y + 9, white);
            end
        6'b010010: // S
            begin
                draw(x + 1, y, x + 6, y + 1, white);
                draw(x, y + 1, x + 1, y + 4, white);
                draw(x + 6, y + 1, x + 7, y + 3, white);
                draw(x + 1, y + 4, x + 6, y + 5, white);
                draw(x + 6, y + 5, x + 7, y + 8, white);
                draw(x, y + 6, x + 1, y + 8, white);
                draw(x + 2, y + 8, x + 7, y + 9, white);
            end
        6'b010011: // T
            begin
                draw(x, y, x + 7, y + 2, white);
                draw(x + 3, y + 2, x + 5, y + 9, white);
            end
        6'b010100: // U
            begin
                draw(x, y, x + 2, y + 8, white);
                draw(x + 5, y, x + 7, y + 8, white);
                draw(x + 1, y + 7, x + 6, y + 9, white);
            end
        6'b010101: // V
            begin
                draw(x, y, x + 1, y + 5, white);
                draw(x + 6, y, x + 7, y + 5, white);
                draw(x + 1, y + 4, x + 2, y + 7, white);
                draw(x + 5, y + 4, x + 6, y + 7, white);
                draw(x + 3, y + 6, x + 4, y + 8, white);
                draw(x + 5, y + 6, x + 6, y + 8, white);
                draw(x + 4, y + 8, x + 5, y + 9, white);
            end
        6'b010110: // W
            begin
                draw(x, y, x + 1, y + 8, white);
                draw(x + 6, y, x + 7, y + 8, white);
                draw(x + 3, y + 3, x + 4, y + 8, white);
                draw(x, y + 8, x + 7, y + 9, white);
            end
        6'b010111: // X
            begin
                draw(x, y, x + 1, y + 3, white);
                draw(x + 6, y, x + 7, y + 3, white);
                draw(x + 1, y + 2, x + 2, y + 4, white);
                draw(x + 5, y + 2, x + 6, y + 4, white);
                draw(x + 2, y + 4, x + 5, y + 5, white);
                draw(x + 1, y + 5, x + 2, y + 7, white);
                draw(x + 5, y + 5, x + 6, y + 7, white);
                draw(x, y + 6, x + 1, y + 9, white);
                draw(x + 6, y + 6, x + 7, y + 9, white);              
            end
        6'b011000: // Y
            begin
                draw(x, y, x + 2, y + 4, white);
                draw(x + 5, y, x + 7, y + 8, white);
                draw(x + 1, y + 4, x + 5, y + 5, white);
                draw(x, y + 7, x + 2, y + 8, white);
                draw(x + 1, y + 8, x + 6, y + 9, white);
            end
        6'b011001: // Z
            begin
                draw(x, y, x + 7, y + 2, white);
                draw(x + 5, y + 2, x + 7, y + 3, white);
                draw(x + 4, y + 3, x + 5, y + 4, white);
                draw(x + 3, y + 4, x + 4, y + 5, white);
                draw(x + 2, y + 5, x + 3, y + 6, white);
                draw(x, y + 6, x + 2, y + 7, white);
                draw(x + 1, y + 7, x + 8, y + 9, white);
            end
        6'b011010: // 1
            begin
                draw(x + 3, y, x + 5, y + 9, white);
                draw(x + 2, y + 1, x + 3, y + 3, white);
                draw(x + 1, y + 2, x + 2, y + 3, white);
                draw(x + 1, y + 7, x + 6, y + 9, white);
            end
        6'b011011: // 2
            begin
                draw(x, y + 1, x + 2, y + 3, white);
                draw(x + 1, y, x + 3, y + 2, white);
                draw(x + 3, y, x + 6, y + 1, white);
                draw(x + 5, y + 1, x + 7, y + 4, white);
                draw(x + 1, y + 4, x + 6, y + 5, white);
                draw(x, y + 5, x + 2, y + 8, white);
                draw(x + 2, y + 8, x + 8, y + 9, white);
            end
        6'b011100: // 3
            begin
                draw(x, y + 1, x + 1, y + 2, white);
                draw(x + 1, y, x + 6, y + 1, white);
                draw(x + 6, y + 1, x + 7, y + 4, white);
                draw(x + 2, y + 4, x + 6, y + 5, white);
                draw(x + 6, y + 5, x + 7, y + 8, white);
                draw(x, y + 7, x + 1, y + 8, white);
                draw(x + 1, y + 8, x + 6, y + 9, white);
            end
        6'b011101: // 4
            begin
                draw(x + 4, y, x + 7, y + 2, white);
                draw(x + 3, y + 1, x + 4, y + 2, white);
                draw(x + 2, y + 2, x + 3, y + 3, white);
                draw(x + 1, y + 3, x + 2, y + 4, white);
                draw(x, y + 4, x + 5, y + 6, white);
                draw(x + 4, y + 2, x + 7, y + 9, white);
            end
        6'b011110: // 5
            begin
                draw(x, y, x + 7, y + 2, white);
                draw(x, y + 2, x + 2, y + 5, white);
                draw(x + 2, y + 3, x + 7, y + 5, white);
                draw(x + 5, y + 5, x + 7, y + 9, white);
                draw(x, y + 7, x + 7, y + 9, white);
            end
        6'b011111: // 6
            begin
                draw(x + 1, y, x + 6, y + 1, white);
                draw(x, y + 1, x + 2, y + 8, white);
                draw(x + 5, y + 1, x + 7, y + 2, white);
                draw(x + 2, y + 4, x + 6, y + 5, white);
                draw(x + 5, y + 5, x + 7, y + 8, white);
                draw(x + 1, y + 8, x + 6, y + 9, white);
            end
        6'b100000: // 7
            begin
                draw(x, y, x + 7, y + 2, white);
                draw(x, y + 2, x + 2, y + 3, white);
                draw(x + 5, y + 2, x + 7, y + 9, white);
            end
        6'b100001: // 8
            begin
                draw(x + 1, y, x + 6, y + 2, white);
                draw(x, y + 1, x + 2, y + 4, white);
                draw(x + 5, y + 1, x + 7, y + 4, white);
                draw(x + 1, y + 4, x + 6, y + 5, white);
                draw(x, y + 5, x + 2, y + 8, white);
                draw(x + 6, y + 5, x + 8, y + 8, white);
                draw(x + 2, y + 7, x + 7, y + 9, white);
            end
        6'b100010: // 9
            begin
                draw(x + 1, y, x + 6, y + 1, white);
                draw(x, y + 1, x + 2, y + 4, white);
                draw(x + 1, y + 4, x + 5, y + 5, white);
                draw(x + 5, y + 1, x + 7, y + 8, white);
                draw(x, y + 7, x + 1, y + 8, white);
                draw(x + 1, y + 8, x + 6, y + 9, white);
            end
        6'b100011: // 0
            begin
                draw(x + 1, y, x + 6, y + 1, white);
                draw(x, y + 1, x + 7, y + 2, white);
                draw(x, y + 2, x + 2, y + 7, white);
                draw(x + 5, y + 2, x + 7, y + 7, white);
                draw(x, y + 7, x + 7, y + 8, white);
                draw(x + 1, y + 8, x + 6, y + 9, white);
            end
        default:
            begin
                red = 0;
                green = 0;
                blue = 0;
            end
    endcase
end
endfunction

reg [5:0] SD_COUNTER = 6'd0;//counter used for the sending all the signals to the temperature sensor
reg [31:0] count= 32'h00000000;//counter used for slow clock
//since we are using SDA as inout we cannot use it inside the always block. I created a temp. reg SDI
reg SDI;//register used for sending signals to temperature sensor inside the always block
reg SCLK; // clock used inside the always block which is equated to the SCL at the end.
reg dp = 1'b1;//decimal point for 7 segment display
reg [18:0] Counter; // temp. counter for multiplexing seven segment display
// these are the registers used for 7 segment display
reg [3:0] first;
reg [3:0] second;
reg [3:0] third;
reg [3:0] fourth;
reg [3:0] fifth;
reg [3:0] sixth;
reg [3:0] seg;
reg [15:0] led_temp = 16'b0000000000000000;//temp reg used in always block to asssign sda values
reg CLK = 0;//slow clock
// code for slow clock(200k)
always @ (posedge clk)
begin
    count <= count + 1;
    Counter <= Counter + 1;
    
if (count == 32'h00030D40)//200k in hex
    begin
        count  <= 0;
        CLK <= ~CLK;
    end
 else 
    count <= count + 1;
 end
always @ (posedge CLK) //always on 200k clock
begin
    if (SD_COUNTER == 49)
        SD_COUNTER <= 1;
    else
        SD_COUNTER <= SD_COUNTER + 1;
end

always @ (posedge CLK)
begin

	case (SD_COUNTER)
		6'd0   :   begin SDI <= 1; SCLK <= 1; end //initial condition
		//START signal for I2C protocol
		6'd1    :   SDI <= 0;
		6'd2    :   SCLK <= 1;
//		SLAVE ADDRESS 0x4B
		6'd3    :   SDI <= 1;
		6'd4    :   SDI <= 0;
		6'd5    :   SDI <= 0;
		6'd6    :   SDI <= 1;
		6'd7    :   SDI <= 0;
		6'd8    :   SDI <= 1;
		6'd9    :   SDI <= 1;
		6'd10   :   SDI <= 0; //write (R/W =1'b0 bit)
		6'd11   :   SDI <= 1'bz; //ACK (acknowledge from slave) 
		// Address of register inside the temperature sensor (0x00, temperature register)
		6'd12   :   SDI <= 0;
		6'd13   :   SDI <= 0;
		6'd14   :   SDI <= 0;
		6'd15   :   SDI <= 0;
		6'd16   :   SDI <= 0;
		6'd17   :   SDI <= 0;
		6'd18   :   SDI <= 0;
		6'd19   :   SDI <= 0;
		6'd20   :   SDI <= 1'bz; //acknowledge from the slave
		//Re-Start signal for I2C protocol
		6'd21   : begin SDI <= 1; SCLK <= 1;end
		6'd22   :   SDI <= 0;
		6'd23   :   SCLK <= 1;
		//Slave Address 0x4B
		
		6'd24   :   SDI <= 1;
		6'd25   :   SDI <= 0;
		6'd26   :   SDI <= 0;
		6'd27   :   SDI <= 1;
		6'd28   :   SDI <= 0;
		6'd29   :   SDI <= 1;
		6'd30   :   SDI <= 1;
		6'd31   :   SDI <= 1;//read (R/W=1'b1 bit)(read from the temp. sensor)
		6'd32   :   SDI <= 1'bz;//acknowledge from the slave
//we are storing in the values in a temporary led register, so that we can see the values on the leds.
		//Reading and storing the temperature on led_temp(MSB)
		6'd33   :   led_temp[15] <= SDI;
		6'd34   :   led_temp[14] <= SDI;
		6'd35   :   led_temp[13] <= SDI;
		6'd36   :   led_temp[12] <= SDI;
		6'd37   :   led_temp[11] <= SDI;
		6'd38   :   led_temp[10] <= SDI;
		6'd39   :   led_temp[9]  <= SDI;
		6'd40   :   led_temp[8]  <= SDI;
		6'd41   :   SDI <= 1'bz; // acknowledge from the slave
		
		//Reading and storing the temperature on led_temp(LSB)
		6'd42   :   led_temp[7]  <= SDI;
		6'd43   :   led_temp[6]  <= SDI;
        6'd44   :   led_temp[5]  <= SDI;
		6'd45   :   led_temp[4]  <= SDI;
		6'd46   :   led_temp[3]  <= SDI;
		6'd47   :   led_temp[2]  <= SDI;
		6'd48   :   led_temp[1]  <= SDI;
		6'd49   :   led_temp[0]  <= SDI;
		6'd50   :   SDI     <= 1'b1; //acknowledge from the master 
		
		//STOP signal for I2C protocol
		6'd51  :   begin SDI <= 1'b0; SCLK <= 1'b1; end
		6'd52   :   SDI <= 1'b1;
	   endcase

end
//assigning led_temp to led 
assign led = led_temp;  
//assigning the SCL(I2C clock) to either slow clock(200k) or SCLK. 
assign SCL = ((SD_COUNTER >= 4) & (SD_COUNTER <= 20) | ((SD_COUNTER >= 25) & (SD_COUNTER <= 49)))  ? ~CLK : SCLK;
//assignin SDA(I2C Serial data) to SDI
assign SDA = SDI;
//This segment of the code does the seven segment display
always @ (*)
begin
 
    case (Counter[17:15])
    
    3'b000: begin
                seg <= first;
                an <= 8'b11111110;
                dp <= 1'b1;
            end
    3'b001: begin
                seg <= second;
                an <= 8'b11111101;
                dp <= 1'b1;
            end
    3'b010: begin
                seg <= third;
                an <= 8'b11111011;
                dp <= 1'b1;
            end
    3'b011: begin
                seg <= fourth;
                an <= 8'b11110111;
                dp <= 1'b1;
            end
    3'b100: begin
                seg <= fifth;
                an <= 8'b11101111;
                dp <= 1'b0;
           end
    3'b101: begin
                seg <= sixth;
                an <= 8'b11011111;
                dp <= 1'b1;
           end
    default: begin an <=8'b11111111; dp <= 1'b1;end
    endcase
end
//case statement for displaying 0 to 1. 
always @ (*)
begin
    case(seg)
    0 : sseg_temp = 7'b1000000; //0
    1 : sseg_temp = 7'b1111001; //1
    2 : sseg_temp = 7'b0100100; //2
    3 : sseg_temp = 7'b0110000; //3
    4 : sseg_temp = 7'b0011001; //4
    5 : sseg_temp = 7'b0010010; //5
    6 : sseg_temp = 7'b0000010; //6
    7 : sseg_temp = 7'b1111000; //7
    8 : sseg_temp = 7'b0000000; //8
    9 : sseg_temp = 7'b0011000; //9
    10: sseg_temp = 7'b0001000; //A
    11: sseg_temp = 7'b0000011; //B
    12: sseg_temp = 7'b1000110; //C
    13: sseg_temp = 7'b0100001; //D
    14: sseg_temp = 7'b0000110; //E
    15: sseg_temp = 7'b0001110; //F
    default: sseg_temp = 7'b1111111;
    endcase
	//converting binary to decimal by shifting 4 bits to right. we were having problem for converting it with just shifting.
	// what we did was just scale our value. we did that by see the temperature at room temperature and round off accordingly.
	// at 23 Celsius it was showing us as 15 Celsius, therefore we started with 8 instead of 0(15+8=23).
    // Stating at 8 degrees.
	//this code is to present the decimal value on the fifth and sixth segment of seven segment display.
case (led[15:7])
    9'b000000000	:	begin fifth <= 4'b1000; sixth <= 4'b0000; end
    9'b000000001	:	begin fifth <= 4'b1001; sixth <= 4'b0000; end
    9'b000000010	:	begin fifth <= 4'b0000; sixth <= 4'b0001; end
    9'b000000011	:	begin fifth <= 4'b0001; sixth <= 4'b0001; end
    9'b000000100	:	begin fifth <= 4'b0010; sixth <= 4'b0001; end
    9'b000000101	:	begin fifth <= 4'b0011; sixth <= 4'b0001; end
    9'b000000110	:	begin fifth <= 4'b0100; sixth <= 4'b0001; end
    9'b000000111	:	begin fifth <= 4'b0101; sixth <= 4'b0001; end
    9'b000001000	:	begin fifth <= 4'b0110; sixth <= 4'b0001; end
    9'b000001001	:	begin fifth <= 4'b0111; sixth <= 4'b0001; end
    9'b000001010	:	begin fifth <= 4'b1000; sixth <= 4'b0001; end
    9'b000001011	:	begin fifth <= 4'b1001; sixth <= 4'b0001; end
    9'b000001100	:	begin fifth <= 4'b0000; sixth <= 4'b0010; end
    9'b000001101	:	begin fifth <= 4'b0001; sixth <= 4'b0010; end
    9'b000001110	:	begin fifth <= 4'b0010; sixth <= 4'b0010; end
    9'b000001111	:	begin fifth <= 4'b0011; sixth <= 4'b0010; end
    9'b000010000	:	begin fifth <= 4'b0100; sixth <= 4'b0010; end
    9'b000010001	:	begin fifth <= 4'b0101; sixth <= 4'b0010; end
    9'b000010010	:	begin fifth <= 4'b0110; sixth <= 4'b0010; end
    9'b000010011	:	begin fifth <= 4'b0111; sixth <= 4'b0010; end
    9'b000010100	:	begin fifth <= 4'b1000; sixth <= 4'b0010; end
    9'b000010101	:	begin fifth <= 4'b1001; sixth <= 4'b0010; end
    9'b000010110	:	begin fifth <= 4'b0000; sixth <= 4'b0011; end
    9'b000010111	:	begin fifth <= 4'b0001; sixth <= 4'b0011; end
    9'b000011000	:	begin fifth <= 4'b0010; sixth <= 4'b0011; end
    9'b000011001	:	begin fifth <= 4'b0011; sixth <= 4'b0011; end
    9'b000011010	:	begin fifth <= 4'b0100; sixth <= 4'b0011; end
    9'b000011011	:	begin fifth <= 4'b0101; sixth <= 4'b0011; end
    9'b000011100	:	begin fifth <= 4'b0110; sixth <= 4'b0011; end
    9'b000011101	:	begin fifth <= 4'b0111; sixth <= 4'b0011; end
    9'b000011110	:	begin fifth <= 4'b1000; sixth <= 4'b0011; end
    9'b000011111	:	begin fifth <= 4'b1001; sixth <= 4'b0011; end
    9'b000100000	:	begin fifth <= 4'b0000; sixth <= 4'b0100; end
    9'b000100001	:	begin fifth <= 4'b0001; sixth <= 4'b0100; end
    9'b000100010	:	begin fifth <= 4'b0010; sixth <= 4'b0100; end
    9'b000100011	:	begin fifth <= 4'b0011; sixth <= 4'b0100; end
    9'b000100100	:	begin fifth <= 4'b0100; sixth <= 4'b0100; end
    9'b000100101	:	begin fifth <= 4'b0101; sixth <= 4'b0100; end
    9'b000100110	:	begin fifth <= 4'b0110; sixth <= 4'b0100; end
    9'b000100111	:	begin fifth <= 4'b0111; sixth <= 4'b0100; end
    9'b000101000	:	begin fifth <= 4'b1000; sixth <= 4'b0100; end
    9'b000101001	:	begin fifth <= 4'b1001; sixth <= 4'b0100; end
    9'b000101010	:	begin fifth <= 4'b0000; sixth <= 4'b0101; end
    9'b000101011	:	begin fifth <= 4'b0001; sixth <= 4'b0101; end
    9'b000101100	:	begin fifth <= 4'b0010; sixth <= 4'b0101; end
    9'b000101101	:	begin fifth <= 4'b0011; sixth <= 4'b0101; end
    9'b000101110	:	begin fifth <= 4'b0100; sixth <= 4'b0101; end
    9'b000101111	:	begin fifth <= 4'b0101; sixth <= 4'b0101; end
    9'b000110000	:	begin fifth <= 4'b0110; sixth <= 4'b0101; end
    9'b000110001	:	begin fifth <= 4'b0111; sixth <= 4'b0101; end
    9'b000110010	:	begin fifth <= 4'b1000; sixth <= 4'b0101; end
    9'b000110011	:	begin fifth <= 4'b1001; sixth <= 4'b0101; end
    9'b000110100	:	begin fifth <= 4'b0000; sixth <= 4'b0110; end
    9'b000110101	:	begin fifth <= 4'b0001; sixth <= 4'b0110; end
    9'b000110110	:	begin fifth <= 4'b0010; sixth <= 4'b0110; end
    9'b000110111	:	begin fifth <= 4'b0011; sixth <= 4'b0110; end
    9'b000111000	:	begin fifth <= 4'b0100; sixth <= 4'b0110; end
    9'b000111001	:	begin fifth <= 4'b0101; sixth <= 4'b0110; end
    9'b000111010	:	begin fifth <= 4'b0110; sixth <= 4'b0110; end
    9'b000111011	:	begin fifth <= 4'b0111; sixth <= 4'b0110; end
    9'b000111100	:	begin fifth <= 4'b1000; sixth <= 4'b0110; end
    9'b000111101	:	begin fifth <= 4'b1001; sixth <= 4'b0110; end
    9'b000111110	:	begin fifth <= 4'b0000; sixth <= 4'b0111; end
    9'b000111111	:	begin fifth <= 4'b0001; sixth <= 4'b0111; end
    9'b001000000	:	begin fifth <= 4'b0010; sixth <= 4'b0111; end
    default 		:	begin fifth <= 4'b1111; sixth <= 4'b1111; end

endcase
//this code converts the four bit that were shifted right to decimal point value by starting at 0 and 
//then multiplying it with 16 every time it increments. that will give us the decimal point value
//Working on the decimal point values.

case (led[6:3])

4'b0000: begin first  <= 4'b0000;
               second <= 4'b0000;
               third  <= 4'b0000;
               fourth <= 4'b0000;end
4'b0001: begin first  <= 4'b0101;
               second <= 4'b0010;
               third  <= 4'b0110;
               fourth <= 4'b0000;end
4'b0010: begin first  <= 4'b0000;
               second <= 4'b0101;
               third  <= 4'b0010;
               fourth <= 4'b0001;end
4'b0011: begin first  <= 4'b0101;
               second <= 4'b0111;
               third  <= 4'b1000;
               fourth <= 4'b0001;end
4'b0100: begin first  <= 4'b0000;
               second <= 4'b0000;
               third  <= 4'b0101;
               fourth <= 4'b0010;end
4'b0101: begin first  <= 4'b0101;
               second <= 4'b0010;
               third  <= 4'b0001;
               fourth <= 4'b0011;end
4'b0110: begin first  <= 4'b0000;
               second <= 4'b0101;
               third  <= 4'b0111;
               fourth <= 4'b0011;end
4'b0111: begin first  <= 4'b0101;
               second <= 4'b0111;
               third  <= 4'b0011;
               fourth <= 4'b0100;end
4'b1000: begin first  <= 4'b0000;
               second <= 4'b0000;
               third  <= 4'b0000;
               fourth <= 4'b0101;end               
4'b1001: begin first  <= 4'b0101;
               second <= 4'b0010;
               third  <= 4'b0110;
               fourth <= 4'b0101;end
4'b1010: begin first  <= 4'b0000;
               second <= 4'b0101;
               third  <= 4'b0010;
               fourth <= 4'b0110;end
4'b1011: begin first  <= 4'b0101;
               second <= 4'b0111;
               third  <= 4'b1000;
               fourth <= 4'b0110;end
4'b1100: begin first  <= 4'b0000;
               second <= 4'b0000;
               third  <= 4'b0101;
               fourth <= 4'b0111;end
4'b1101: begin first  <= 4'b0101;
               second <= 4'b0010;
               third  <= 4'b0001;
               fourth <= 4'b1000;end
4'b1110: begin first  <= 4'b0000;
               second <= 4'b0101;
               third  <= 4'b0111;
               fourth <= 4'b1000;end
4'b1111: begin first  <= 4'b0101;
               second <= 4'b0111;
               third  <= 4'b0011;
               fourth <= 4'b1001;end
default: begin first  <= 4'b0000;
               second <= 4'b0000;
               third  <= 4'b0000;
               fourth <= 4'b0000;end
   endcase

end


endmodule 