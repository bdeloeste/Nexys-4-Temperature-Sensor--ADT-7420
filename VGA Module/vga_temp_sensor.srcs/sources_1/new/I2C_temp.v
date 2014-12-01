`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2014 03:46:42 PM
// Design Name: 
// Module Name: temp
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module temp2(
	input clk,
	inout SDA,
	output SCL,
	output [15:0] led,
	output reg [6:0] sseg_temp,
	output reg [7:0] an,
	output reg dp
	
	);

parameter MUP = 0.0625;
reg [5:0] SD_COUNTER = 6'd0;
reg [31:0] count= 32'h00000000;
reg SDI;
reg SCLK;
reg dp = 1'b1;
reg [18:0] Counter;
reg [3:0] first;
reg [3:0] second;
reg [3:0] third;
reg [3:0] fourth;
reg [3:0] fifth;
reg [3:0] sixth;
//reg [3:0] seventh;
//reg [3:0] eigth;
reg [3:0] seg;
reg [15:0] led_temp = 16'b0000000000000000;
reg CLK = 0;
always @ (posedge clk)
begin
    count <= count + 1;
    Counter <= Counter + 1;
    
if (count == 32'h00030D40)
    begin
        count  <= 0;
        CLK <= ~CLK;
    end
 else 
    count <= count + 1;
 end
always @ (posedge CLK)
begin
    if (SD_COUNTER == 49) //BULLSHIT
        SD_COUNTER <= 1;
    else
        SD_COUNTER <= SD_COUNTER + 1;
end

always @ (posedge CLK)
begin

	case (SD_COUNTER)
		6'd0   :   begin SDI <= 1; SCLK <= 1; end
		//START
		6'd1    :   SDI <= 0;
		6'd2    :   SCLK <= 1;
//		SLAVE ADDRESS 4B
		6'd3    :   SDI <= 1;
		6'd4    :   SDI <= 0;
		6'd5    :   SDI <= 0;
		6'd6    :   SDI <= 1;
		6'd7    :   SDI <= 0;
		6'd8    :   SDI <= 1;
		6'd9    :   SDI <= 1;
		6'd10   :   SDI <= 0; //write
		6'd11   :   SDI <= 1'bz; //ACK
		// Temp Sens Register
		6'd12   :   SDI <= 0;
		6'd13   :   SDI <= 0;
		6'd14   :   SDI <= 0;
		6'd15   :   SDI <= 0;
		6'd16   :   SDI <= 0;
		6'd17   :   SDI <= 0;
		6'd18   :   SDI <= 0;
		6'd19   :   SDI <= 0;
		6'd20   :   SDI <= 1'bz;
		//Start
		6'd21   : begin SDI <= 1; SCLK <= 1;end
		6'd22   :   SDI <= 0;
		6'd23   :   SCLK <= 1;
		//Slave Address
		
		6'd24   :   SDI <= 1;
		6'd25   :   SDI <= 0;
		6'd26   :   SDI <= 0;
		6'd27   :   SDI <= 1;
		6'd28   :   SDI <= 0;
		6'd29   :   SDI <= 1;
		6'd30   :   SDI <= 1;
		6'd31   :   SDI <= 1;//read
		6'd32   :   SDI <= 1'bz;
		//Data Read MSB
		6'd33   :   led_temp[15] <= SDI;
		6'd34   :   led_temp[14] <= SDI;
		6'd35   :   led_temp[13] <= SDI;
		6'd36   :   led_temp[12] <= SDI;
		6'd37   :   led_temp[11] <= SDI;
		6'd38   :   led_temp[10] <= SDI;
		6'd39   :   led_temp[9]  <= SDI;
		6'd40   :   led_temp[8]  <= SDI;
		6'd41   :   SDI <= 1'bz;
		
		//Data Read LSB
		6'd42   :   led_temp[7]  <= SDI;
		6'd43   :   led_temp[6]  <= SDI;
        6'd44   :   led_temp[5]  <= SDI;
		6'd45   :   led_temp[4]  <= SDI;
		6'd46   :   led_temp[3]  <= SDI;
		6'd47   :   led_temp[2]  <= SDI;
		6'd48   :   led_temp[1]  <= SDI;
		6'd49   :   led_temp[0]  <= SDI;
		6'd50   :   SDI     <= 1'b1;
		
//		//STOP
		6'd51  :   begin SDI <= 1'b0; SCLK <= 1'b1; end
		6'd52   :   SDI <= 1'b1;
	   endcase
//led <= (led >> 3)/16;
end

assign led = led_temp;  // (led_temp >> 3) / (5'b10000);


//bcd BD (.([7:0] binary({second,first})), 
assign SCL = ((SD_COUNTER >= 4) & (SD_COUNTER <= 20) | ((SD_COUNTER >= 25) & (SD_COUNTER <= 49)))  ? ~CLK : SCLK;
assign SDA = SDI;

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
//    3'b110: begin
//                seg <= seventh;
//                an <= 8'b10111111;
//            end
//    3'b111: begin
//                seg <= eigth;
//                an <= 8'b01111111;
//            end
    endcase
end

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
    
    endcase
    //conerting from 9 digit binary to decimal value 
    // Stating at 8 degrees.
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
