`include "conv_defines.vh"

module Top_conv
(
    input clk,
    input rst_n,
    input start,
    output [(`DW+`log2_KyKx)*`CHout-1 :0] conv_out_dat,
    output  conv_done,
    output conv_out_vld
);

// layer1 conv: read data from RAM image and RAM wt, f*w
wire [`log2_HinxWin-1:0] image_raddr;		// 28*28, input image
wire [`CHin*`DW-1 : 0]image_rdata;		    // [H],[W],[CHin,8bit]
wire [3 : 0] weight_raddr;	                // ky*kx
wire [`CHin*`CHout*`DW - 1:0]weight_rdata;	// [ky],[kx],[CHout,CHin,8bit]

wire conv_start;

image_ram image_ram
(
    .clka(),
    .ena(),
    .dina(),
    .addra(),
    .wea(),
    .clkb(clk),
    .addrb(image_raddr),
    .doutb(image_rdata)                        
);

weight_ram weight_ram
(
    .clka(),
    .ena(),
    .dina(),
    .addra(),
    .wea(),
    .clkb(clk),
    .addrb(weight_raddr),
    .doutb(weight_rdata)                        
);


conv_ctrl conv_ctrl
(
    .clk(clk),          
    .rst_n(rst_n),        
    .conv_start(conv_start),  
    .image_raddr(image_raddr),
    .image_rdata(image_rdata),
    .wt_raddr(weight_raddr),
    .wt_rdata(weight_rdata),                    
    .conv_done(conv_done),
    .conv_out_dat(conv_out_dat),
    .conv_out_vld(conv_out_vld)
);

assign conv_start = start;

endmodule
