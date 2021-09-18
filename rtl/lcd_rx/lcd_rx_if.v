`default_nettype none
module lcd_rx_if (
    input  wire         i_clk,
    input  wire         i_rst_n,

    input  wire         i_lcd_wr_async,
    input  wire         i_lcd_rs_async,
    input  wire         i_lcd_cs_n_async,
    input  wire         i_lcd_rst_n_async,
    input  wire [15: 0] i_lcd_data_async,

    output wire [ 7: 0] o_command,
    output wire         o_command_latch,
    output wire [ 7: 0] o_param,
    output wire         o_param_latch,
    output wire [15: 0] o_rgb565,
    output wire         o_rgb565_latch
);
    // synchorizer
    wire [15: 0] lcd_data;
    wire         lcd_wr;
    wire         lcd_rs;
    wire         lcd_cs_n;
    wire         lcd_rst_n;
    synchronizer #(
        .WIDTH(4),
        .INIT(4'b1111)
    ) u_sync_lcd_ctrl(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),

        .i_async({i_lcd_wr_async, i_lcd_rs_async, i_lcd_cs_n_async, i_lcd_rst_n_async}),
        .o_sync( {lcd_wr        , lcd_rs        , lcd_cs_n        , lcd_rst_n        })
    );
    synchronizer #(
        .WIDTH(16),
        .INIT(16'h0000)
    ) u_sync_lcd_data(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),

        .i_async(i_lcd_data_async),
        .o_sync( lcd_data)
    );

    lcd_rx u_lcd_rx(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        
        .i_lcd_wr(lcd_wr),
        .i_lcd_rs(lcd_rs),
        .i_lcd_cs_n(lcd_cs_n),
        .i_lcd_rst_n(lcd_rst_n),
        .i_lcd_data(lcd_data),

        .o_command(o_command),
        .o_command_latch(o_command_latch),
        .o_param(o_param),
        .o_param_latch(o_param_latch),
        .o_rgb565(o_rgb565),
        .o_rgb565_latch(o_rgb565_latch)
    );
    
//    ila_lcd_rx u_ila_lcd_rx(
//        .clk(i_clk),
//        .probe0(lcd_rst_n),
//        .probe1(o_command_latch),
//        .probe2(o_command),
//        .probe3(o_param_latch),
//        .probe4(o_param),
//        .probe5(o_rgb565_latch),
//        .probe6(o_rgb565)
//    );

endmodule
`default_nettype wire
