`timescale 1ns / 1ps

module vh_sync (
	input wire clk,
	input wire clr,
	input [11:0] sw,
	output wire hsync,
	output wire vsync,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue,
    output reg [11:0] led,
	);
	
parameter hpixels = 800;
parameter vlines = 521;
parameter hpulse = 96;
parameter vpulse = 2;
parameter hbp = 144;
parameter hfp = 784;
parameter vbp = 31;
parameter vfp = 511;

reg [9:0] hc;
reg [9:0] vc;

reg [28:0] count;
reg [11:0] counter;
wire tick;

reg [1:0] pxclk;

always @ (posedge clk) pxclk <= pxclk + 1;

reg [3:0] redcount;
reg [3:0] greencount;
reg [3:0] bluecount;

wire pclk;

assign pclk = pxclk[1];

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

always @ (*)
begin
    if (vc >= vbp && vc < vfp)
    begin
        if (vc >= (vbp + 100) && vc < (vfp - 100))
        begin
            if (vc >= (vbp + 411 - (redcount * 15)) && hc >= (hbp + 120) && hc < (hbp + 140))
            begin
                red = 4'b1111;
                green = 4'b0000;
                blue = 4'b0000;
            end
            else if (hc >= (hbp + 100) && hc < (hbp + 105)) //y-axis
            begin
                red = 4'b1111;
                green = 4'b1111;
                blue = 4'b1111;
            end
            else
            begin
                red = 0;
                green = 0;
                blue = 0;
            end
        end
        else if (vc >= (vfp - 100) && vc < (vfp - 95) && hc >= (hbp + 100) && hc < (hbp + 500)) //x-axis
        begin
            red = 4'b1111;
            green = 4'b1111;
            blue = 4'b1111;
        end
        else
        begin
            red = 0;
            green = 0;
            blue = 0;
        end
    end
end
    else
    begin
        red = 0;
        green = 0;
        blue = 0;
    end
end

endmodule