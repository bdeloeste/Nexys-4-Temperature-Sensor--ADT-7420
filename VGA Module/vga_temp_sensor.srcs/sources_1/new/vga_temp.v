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
    output reg [11:0] led
	);
	
parameter hpixels = 800;
parameter vlines = 521;
parameter hpulse = 96;
parameter vpulse = 2;
parameter hbp = 144;
parameter hfp = 784;
parameter vbp = 31;
parameter vfp = 511;

reg [28:0] counter;
reg [18:0] tick;
reg [9:0] hc;
reg [9:0] vc;
reg [1:0] pxclk;

always @ (posedge clk)
begin
    pxclk <= pxclk + 1;
    if (counter == 20'hF4240)
    begin
        tick = tick + 1;
        counter = 0;
    end
    else if (tick == 400)
        tick <= 0;
    else
        counter <= counter + 1;
end

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
            if (vc >= (vbp + 210) && vc < (vbp + 212) && hc >= (hbp + (102)) && hc < (hbp + (104 + tick)))
            begin
                red = 4'b1111;
                green = 4'b0000;
                blue = 4'b0000;
            end
            else if (hc >= (hbp + 100) && hc < (hbp + 102)) //y-axis
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
        else if (vc >= (vfp - 100) && vc < (vfp - 98) && hc >= (hbp + 100) && hc < (hbp + 500)) //x-axis
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
    else
    begin
        red = 0;
        green = 0;
        blue = 0;
    end
end

endmodule