`define DW 8          //data width
//`define AdderNet

`ifdef AdderNet
    `define DW2 `DW+1 //if kernel is adder
`else
    `define DW2 `DW*2 //if kernel is adder
`endif

`define Pin 16
`define Pout 16
`define log2_Pin 4
`define log2_dw_Pout 5
`define Wino_L 16
`define CHin 16
`define CHout 16
`define log2_dw_CHout 5

`define Hin 28
`define Win 28
`define log2_dw_Hin 5
`define Win_div_2 14
`define log2_dw_Win 5
`define log2_HinxWin 10 //30*30=900
`define Kx 3
`define Ky 3
`define log2_KyKx 4
`define Sx 1
`define Sy 1
`define Px 1
`define Py 1
//`define Hout (`Hin-`Ky+2*`Py)/`Sy + 1
//`define Wout (`Win-`Kx+2*`Px)/`Sx + 1
`define Hout 28
`define Wout 28

`define Hin_div_2 14
`define log2_dw_Hin2 4
`define Win_div_2 14
`define log2_dw_Win2 4
`define HinWin_div4 196
`define log2_HinWin_div4 8 //14*14=196

`define scale 6
`define delay 5




