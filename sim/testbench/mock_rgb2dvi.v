// mock Digilent DVI output IP
`timescale 1ns / 1ns
`default_nettype none
module rgb2dvi #(
    parameter kClkRange,
    parameter kRstActiveHigh
)(
    input  wire         PixelClk,
    input  wire         SerialClk,
    input  wire         aRst,
    input  wire         aRst_n,

    input  wire [23: 0] vid_pData,
    input  wire         vid_pHSync,
    input  wire         vid_pVSync,
    input  wire         vid_pVDE,

    output wire         TMDS_Clk_p,
    output wire         TMDS_Clk_n,
    output wire [ 2: 0] TMDS_Data_p,
    output wire [ 2: 0] TMDS_Data_n
);
    assign TMDS_Clk_p  = 1'bz;
    assign TMDS_Clk_n  = 1'bz;
    assign TMDS_Data_p = 3'bzzz;
    assign TMDS_Data_n = 3'bzzz;
endmodule
`default_nettype wire