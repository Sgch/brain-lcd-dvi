`default_nettype none
module top (
    // master clock source
    input  wire         i_mclk_125m,
//  input  wire         i_rst,

    // Sharp Brain 2ndgen lcd
    input  wire [15: 0] i_lcd_data,
    input  wire         i_lcd_wr,
    input  wire         i_lcd_rs,
    input  wire         i_lcd_cs_n,
    input  wire         i_lcd_rst_n,

    // ZYBO-Z2 inputs / outputs
    input  wire [ 3: 0] i_zybo_z2_btn,
    input  wire [ 3: 0] i_zybo_z2_sw,
    output wire [ 3: 0] o_zybo_z2_led,

    // DVI output
    output wire         o_dvi_clk_p,
    output wire         o_dvi_clk_n,
    output wire [ 2: 0] o_dvi_data_p,
    output wire [ 2: 0] o_dvi_data_n
);
    // system reset
    wire sys_rst_n;
    sync_reset_gen u_sysrst(
        .i_clk(i_mclk_125m),
        .i_rst_n(~i_zybo_z2_btn[0]),
        .o_rst_n(sys_rst_n)
    );

    // video clock
    wire clk_video_locked;
    wire clk_video;
    clk_video u_clk_video(
        .clk_in1(i_mclk_125m),
        .resetn(sys_rst_n),
        .locked(clk_video_locked),
        .clk_out1(clk_video)
    );
    // video modules reset
    wire   rst_video_n;
    assign rst_video_n = clk_video_locked;

    // VGA sync generator
    wire vga_hblank;
    wire vga_vblank;
    wire vga_hsync;
    wire vga_vsync;
    wire vga_vde;
    vga_sync_gen #(
    // VGA pamarameters: 1280x720p 60fps @74.25MHz
        .H_SYNC    (11'd40  ),
        .H_BACK    (11'd220 ),
        .H_ACT     (11'd1280),
        .H_FRONT   (11'd110 ),
        .H_SYNC_INV(1'b1    ),

        .V_SYNC    (11'd5   ),
        .V_BACK    (11'd20  ),
        .V_ACT     (11'd720 ),
        .V_FRONT   (11'd5   ),
        .V_SYNC_INV(1'b1    )
    ) u_vga_sync_gen(
        .i_clk(clk_video),
        .i_rst_n(rst_video_n),

        .o_hblank(vga_hblank),
        .o_vblank(vga_vblank),
        .o_hsync(vga_hsync),
        .o_vsync(vga_vsync),
        .o_vde(vga_vde)
    );

    // lcdrxif
    wire [ 7: 0] lcd_command;
    wire         lcd_command_latch;
    wire [ 7: 0] lcd_param;
    wire         lcd_param_latch;
    wire [15: 0] lcd_rgb565;
    wire         lcd_rgb565_latch;
    lcd_rx_if u_lcd_rx_if(
        .i_clk(clk_video),
        .i_rst_n(rst_video_n),
        
        .i_lcd_data_async(i_lcd_data),
        .i_lcd_wr_async(i_lcd_wr),
        .i_lcd_rs_async(i_lcd_rs),
        .i_lcd_cs_n_async(i_lcd_cs_n),
        .i_lcd_rst_n_async(1'b1),
        
        .o_command(lcd_command),
        .o_command_latch(lcd_command_latch),
        .o_param(lcd_param),
        .o_param_latch(lcd_param_latch),
        .o_rgb565(lcd_rgb565),
        .o_rgb565_latch(lcd_rgb565_latch)
    );

    // Framebuffer
    wire [15: 0] fb_rgb565;
    wire         fb_hsync;
    wire         fb_vsync;
    wire         fb_vde;
    framebuffer u_fb(
        .i_clk(clk_video),
        .i_rst_n(rst_video_n),

        .i_command(lcd_command),
        .i_command_latch(lcd_command_latch),
        .i_param(lcd_param),
        .i_param_latch(lcd_param_latch),
        .i_rgb565(lcd_rgb565),
        .i_rgb565_latch(lcd_rgb565_latch),

        .i_hblank(vga_hblank),
        .i_vblank(vga_vblank),
        .i_hsync(vga_hsync),
        .i_vsync(vga_vsync),
        .i_vde(vga_vde),

        .o_rgb565(fb_rgb565),
        .o_hsync(fb_hsync),
        .o_vsync(fb_vsync),
        .o_vde(fb_vde)
    );

    // RGB565 => RBG888
    wire [23: 0] rbg24_data;
    assign       rbg24_data = {
        fb_rgb565[15:11], 3'b000, // R
        fb_rgb565[ 4: 0], 3'b000, // B
        fb_rgb565[10: 5], 2'b00   // G
    };

    // Digilent DVI output IP
    rgb2dvi #(
        .kClkRange(3),
        .kRstActiveHigh(1'b0)
    ) u_rgb2dvi(
        .PixelClk(clk_video),
        .SerialClk(1'b0), // unused

        .aRst(1'b0), // unused
        .aRst_n(rst_video_n),

        .vid_pData(rbg24_data),
        .vid_pHSync(fb_hsync),
        .vid_pVSync(fb_vsync),
        .vid_pVDE(fb_vde),

        .TMDS_Clk_p(o_dvi_clk_p),
        .TMDS_Clk_n(o_dvi_clk_n),
        .TMDS_Data_p(o_dvi_data_p),
        .TMDS_Data_n(o_dvi_data_n)
    );

    assign o_zybo_z2_led[0] = rst_video_n;
    assign o_zybo_z2_led[1] = 1'b0;
    assign o_zybo_z2_led[2] = i_lcd_wr;
    assign o_zybo_z2_led[3] = i_lcd_cs_n;

endmodule
`default_nettype wire
