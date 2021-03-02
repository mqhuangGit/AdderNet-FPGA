`include "conv_defines.vh"
module conv_ctrl
(
    input                           clk,
    input                           rst_n,
    input                           conv_start,
    input [`log2_HinxWin-1:0]       image_raddr,		// 28*28, input image
    input [`CHin*`DW-1 : 0]         image_rdata,		// [H],[W],[CHin,8bit]
    input [3 : 0]                   wt_raddr,		
    input [`CHin*`CHout*`DW - 1:0]  wt_rdata,           // [ky],[kx],[CHout,CHin,8bit]
    output reg                      conv_done,
    output [(`DW+`log2_KyKx)*`CHout-1 :0]      conv_out_dat,
    output                          conv_out_vld
);

reg working;
wire conv_rdy = 1'b1;

reg [1:0] kx;
wire kx_en = working&conv_rdy;
wire kx_ovfl=(kx==`Kx-1);
always @(posedge clk or negedge rst_n)
if(~rst_n)
	kx<=0;
else
	if(kx_en)
	begin
		if(kx_ovfl)
			kx<=0;
		else
			kx<=kx+1;
	end

reg [1:0] ky;
wire ky_en = kx_en&kx_ovfl;
wire ky_ovfl=(ky==`Ky-1);
always @(posedge clk or negedge rst_n)
if(~rst_n)
	ky<=0;
else
	if(ky_en)
	begin
		if(ky_ovfl)
			ky<=0;
		else
			ky<=ky+1;
	end
	
reg [`log2_dw_Win-1:0] w;
wire w_en = ky_en&ky_ovfl;
wire w_ovfl=(w==`Win-1);
always @(posedge clk or negedge rst_n)
if(~rst_n)
	w<=0;
else
	if(w_en)
	begin
		if(w_ovfl)
			w<=0;
		else
			w<=w+1;
	end

reg [`log2_dw_Hin-1:0] h;
wire h_en = w_en&w_ovfl;
wire h_ovfl=(h==`Hin-1);

always @(posedge clk or negedge rst_n)
if(~rst_n)
    h<=0;
else
    if(h_en)
    begin
        if(h_ovfl)
            h<=0;
        else
            h<=h+1;
    end	

wire in_dat_done=h_en&h_ovfl;
always @(posedge clk or negedge rst_n)
if(~rst_n)
	working<=1'b0;
else
	if(conv_start)
		working<=1'b1;
	else
		if(in_dat_done)
			working<=1'b0;

wire signed [`log2_dw_Hin+1-1:0] in_h = $unsigned(h)+$signed(-1)+$unsigned(ky);
wire signed [`log2_dw_Win+1-1:0] in_w = $unsigned(w)+$signed(-1)+$unsigned(kx);
wire signed [`log2_HinxWin-1 :0] image_in_raddr = ($signed(in_h*(`Win)) + $signed(in_w));
wire pad_region = (working&(in_w<0 | in_w>=`Win | in_h<0 | in_h>=`Hin))? 1'b1:1'b0;
assign image_raddr = (pad_region)? 784:image_in_raddr;
assign wt_raddr = ky*`Kx + kx;

wire signed [`DW-1 :0] conv_dat [`CHin-1 : 0];
wire signed [`DW-1 :0] conv_wt [`CHout-1 :0][`CHin-1 : 0];

generate
	genvar i,j;		// j for CHin, i for CHout=16
	                // wt:[ky],[kx],[CHout,CHin,8bit]
	                // image: [H],[W],[CHin,8bit]
	for(i=`CHout-1;i>=0;i=i-1) // i for CHout
	begin
		for(j=`CHin-1;j>=0;j=j-1) //	j for CHin=16
		begin
		    assign conv_dat [j] = image_rdata[j*`DW+:`DW];
            assign conv_wt[i][j] = wt_rdata[i*`DW*`CHin+j*`DW+`DW-1 : i*`DW*`CHin+`DW*j];
        end
    end
endgenerate

reg signed [`DW2-1:0] tp_abs0 [`CHout-1 :0][`CHin-1 : 0];
reg signed [`DW2-1:0] tp_abs1 [`CHout-1 :0][`CHin-1 : 0];
reg signed [`DW2-1:0] tp_sum  [`CHout-1 :0][`CHin-1 : 0];

reg signed  [`DW2+`log2_Pin-1 :0] sum_1 [`CHout-1 :0];
reg signed  [`DW2+`log2_Pin-1 :0] sum_2 [`CHout-1 :0];
reg signed  [`DW2+`log2_Pin-1 :0] sum_3 [`CHout-1 :0];
reg signed  [`DW2+`log2_Pin-1 :0] sum_4 [`CHout-1 :0];
reg signed  [`DW2+`log2_Pin-1 :0] sum_5 [`CHout-1 :0];
reg signed  [`DW2+`log2_Pin-1 :0] sum_6 [`CHout-1 :0];
reg signed  [`DW2+`log2_Pin-1 :0] sum_7 [`CHout-1 :0];
reg signed  [`DW2+`log2_Pin-1 :0] sum_8 [`CHout-1 :0];

reg signed  [`DW2+`log2_Pin-1 :0] sum_9 [`CHout-1 :0];
reg signed  [`DW2+`log2_Pin-1 :0] sum_10[`CHout-1 :0];
reg signed  [`DW2+`log2_Pin-1 :0] sum_11[`CHout-1 :0];
reg signed  [`DW2+`log2_Pin-1 :0] sum_12[`CHout-1 :0];
reg signed  [`DW2+`log2_Pin-1 :0] sum_13[`CHout-1 :0];
reg signed  [`DW2+`log2_Pin-1 :0] sum_14[`CHout-1 :0];
reg signed  [`DW2+`log2_Pin-1 :0] sum_15[`CHout-1 :0];
generate
    genvar chin,L;
    for(L=0;L<`CHout;L=L+1)
    begin
        for(chin=0;chin<`CHin;chin=chin+1)
        begin
            always @(posedge clk)
            begin
            
`ifdef AdderNet
                tp_abs0[L][chin] = $signed(conv_dat[chin]) - $signed(conv_wt[chin][L]);
                tp_abs1[L][chin] = $signed(conv_wt[chin][L]) - $signed(conv_dat[chin]);
                tp_sum [L][chin] =((tp_abs0[L][chin][`DW2-1])? (tp_abs0[L][chin]):(tp_abs1[L][chin]));   
`else
                tp_abs0[L][chin] = $signed(conv_dat[chin]) * $signed(conv_wt[chin][L]);
                tp_sum [L][chin] = tp_abs0[L][chin];   
`endif
            end
        end
        
        always @(posedge clk)
        begin
            sum_1[L] <= $signed(tp_sum[L][0] ) + $signed(tp_sum[L][1]);
            sum_2[L] <= $signed(tp_sum[L][2] ) + $signed(tp_sum[L][3]);
            sum_3[L] <= $signed(tp_sum[L][4] ) + $signed(tp_sum[L][5]);
            sum_4[L] <= $signed(tp_sum[L][6] ) + $signed(tp_sum[L][7]);
            sum_5[L] <= $signed(tp_sum[L][8] ) + $signed(tp_sum[L][9]);
            sum_6[L] <= $signed(tp_sum[L][10]) + $signed(tp_sum[L][11]);
            sum_7[L] <= $signed(tp_sum[L][12]) + $signed(tp_sum[L][13]);
            sum_8[L] <= $signed(tp_sum[L][14]) + $signed(tp_sum[L][15]);
            sum_9 [L] <= $signed(sum_1[L]) + $signed(sum_2[L]);
            sum_10[L] <= $signed(sum_3[L]) + $signed(sum_4[L]);
            sum_11[L] <= $signed(sum_5[L]) + $signed(sum_6[L]);
            sum_12[L] <= $signed(sum_7[L]) + $signed(sum_8[L]);
            
            sum_13[L] <= $signed(sum_9[L]) + $signed(sum_10[L]);
            sum_14[L] <= $signed(sum_11[L]) + $signed(sum_12[L]);
            sum_15[L] <= $signed(sum_13[L]) + $signed(sum_14[L]);
        end
    end
endgenerate

integer l;
reg signed [`DW2+`log2_Pin-1:0] tp;
reg signed [`DW2+`log2_Pin-1:0] tp2;
reg signed [(`DW-1):0] tp_sat;
reg signed [(`DW-1) :0] chin_conv_sum [`CHout-1 :0];

always @(*)
begin
    for(l=0;l<=`CHout-1;l=l+1)
	begin
		tp=sum_15[l];
		tp2=$signed(tp)>>>`scale;
		if((`scale!=0)&&(tp2!={1'b0, {(`DW2+`log2_Pin-1){1'b1}} }))
			tp2=tp2+tp[`scale-1];

		if( (tp2[`DW2+`log2_Pin-1]) & (!(&tp2[(`DW2+`log2_Pin-2):(`DW-1)])) )
			tp_sat={1'b1,{(`DW-1){1'b0}}};
		else
			if( (!tp2[`DW2+`log2_Pin-1]) & (|tp2[(`DW2+`log2_Pin-2):(`DW-1)]) )
				tp_sat={1'b0,{(`DW-1){1'b1}}};
			else
				tp_sat=tp2[(`DW-1):0];	
		chin_conv_sum[l]=tp_sat;
	end
end

reg count_working;
reg [15:0] count;
always @(posedge clk or negedge rst_n)
if(~rst_n)
	count_working<=1'b0;
else
	if(conv_start)
		count_working<=1'b1;
	else
		if(count ==`Hout*`Wout*`Kx*`Ky + `delay)
			count_working<=1'b0;

always @(posedge clk or negedge rst_n)
if(~rst_n)
	count<=1'b0;
else
	if(count_working)
		count<=count+1;

reg count_out_vld;
always @(posedge clk or negedge rst_n)
if(~rst_n)
	count_out_vld<=1'b0;
else
	if(count >= `delay && count <`Hout*`Wout*`Kx*`Ky + `delay)
		count_out_vld<=1'b1;
	else
		count_out_vld<= 1'b0;

reg [`log2_dw_CHout-1:0] out_KyxKx;
wire out_KyxKx_en = count_working;
wire out_KyxKx_ovfl=(out_KyxKx==`Ky*`Kx-1);
always @(posedge clk or negedge rst_n)
if(~rst_n)
	out_KyxKx<=0;
else
	if(out_KyxKx_en & count >= `delay+1)
	begin
		if(out_KyxKx_ovfl)
			out_KyxKx<=0;
		else
			out_KyxKx<=out_KyxKx+1;
	end

reg signed [(`DW+`log2_KyKx)*`CHout-1 :0] KxCHin_sum;
always @(posedge clk or negedge rst_n)
begin
    for(l=0;l<=`CHout-1;l=l+1)
    begin
        if(~rst_n)
            KxCHin_sum <= 0;
        else
            if (count >= `delay)
            KxCHin_sum[(`DW+`log2_KyKx)*l+:(`DW+`log2_KyKx)]
             <= $signed(KxCHin_sum[(`DW+`log2_KyKx)*l+:(`DW+`log2_KyKx)]) + $signed(chin_conv_sum[l]);
    end
end

wire [(`DW+`log2_KyKx)*`CHout-1 :0] final_sum;
assign final_sum = (out_KyxKx_ovfl&count_working)? KxCHin_sum : 0;
assign conv_out_vld = out_KyxKx_ovfl;
assign conv_out_dat = final_sum;

always @(posedge clk or negedge rst_n)
if(~rst_n)
	conv_done<=1'b0;
else
	if(count ==`Hout*`Wout*`Kx*`Ky + `delay-1)
		conv_done<=1'b1;
	else
		conv_done <= 1'b0;
		
endmodule
