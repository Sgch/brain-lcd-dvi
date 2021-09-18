
`default_nettype none
module framebuffer (
    input  wire         i_clk,
    input  wire         i_rst_n,

    input  wire [ 7: 0] i_command,
    input  wire         i_command_latch,
    input  wire [ 7: 0] i_param,
    input  wire         i_param_latch,
    input  wire [15: 0] i_rgb565,
    input  wire         i_rgb565_latch,

    input  wire         i_hblank,
    input  wire         i_vblank,
    input  wire         i_hsync,
    input  wire         i_vsync,
    input  wire         i_vde,

    output wire [15: 0] o_rgb565,
    output wire         o_hsync,
    output wire         o_vsync,
    output wire         o_vde
);
    // writer
    wire [17: 0] write_address;
    wire [15: 0] write_data;
    wire         write_enable;
    framebuffer_writer u_fb_writer(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),

        .i_command(i_command),
        .i_command_latch(i_command_latch),
        .i_param(i_param),
        .i_param_latch(i_param_latch),
        .i_rgb565(i_rgb565),
        .i_rgb565_latch(i_rgb565_latch),

        .o_write_address(write_address),
        .o_write_data(write_data),
        .o_write_enable(write_enable)
    );

    // reader
    wire [17: 0] read_address;
    wire [15: 0] read_data;
    wire         read_enable;
    framebuffer_reader u_fb_reader(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),

        .i_hblank(i_hblank),
        .i_vblank(i_vblank),
        .i_hsync(i_hsync),
        .i_vsync(i_vsync),
        .i_vde(i_vde),

        .o_hsync(o_hsync),
        .o_vsync(o_vsync),
        .o_vde(o_vde),

        .o_read_address(read_address),
        .o_read_enable(read_enable)
    );

    // framebuffer
    blk_mem_framebuffer u_blkmem_fb (
        // Write-side
        .clka(i_clk),
        .ena(1'b1),
        .wea(write_enable),
        .addra(write_address),
        .dina(write_data),

        // Read-side
        .clkb(i_clk),
        .enb(read_enable),
        .addrb(read_address),
        .doutb(read_data)
    );

    assign o_rgb565 = read_data;

endmodule
`default_nettype wire
