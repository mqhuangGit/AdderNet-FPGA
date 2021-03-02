`include "conv_defines.vh"

module sim;
reg clk;
reg rst_n;
reg start;

// Instantiate the Unit Under Test (UUT)
Top_conv uut (
	.clk     (clk), 		
	.rst_n	 (rst_n),
	.start   (start)
);

initial 
begin
	// Initialize Inputs
	clk = 0;
	rst_n = 0;
	start = 0;

	// Wait 100 ns for global reset to finish
	#10;
        rst_n = 1;
    #100;
        start = 1;
    #10;
        start = 0;

    #80000 $finish;
 end

always #5 clk = ~ clk;   //10ns, 100MHz clk

endmodule
