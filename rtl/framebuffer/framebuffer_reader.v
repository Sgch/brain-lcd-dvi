`timescale 1ns / 1ps

module framebuffer_reader (
    input  wire         i_clk,
    input  wire         i_rst_n,

    input  wire         i_hblank,
    input  wire         i_vblank,
    input  wire         i_hsync,
    input  wire         i_vsync,
    input  wire         i_vde,
    
    output wire         o_hsync,
    output wire         o_vsync,
    output wire         o_vde,

    output wire [17: 0] o_read_address,
    output wire         o_read_enable
);
    localparam FB_H = 11'd480;
    localparam FB_V = 10'd320;

    // nedge hblank
    wire nedge_hblank;
    reg  hblank_1d;
    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            hblank_1d <= 1'b0;
        end
        else begin
            hblank_1d <= i_hblank;
        end
    end
    assign nedge_hblank = ~i_hblank & hblank_1d;

    // nedge vblank
    wire nedge_vblank;
    reg  vblank_1d;
    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            vblank_1d <= 1'b0;
        end
        else begin
            vblank_1d <= i_vblank;
        end
    end
    assign nedge_vblank = ~i_vblank & vblank_1d;

    // internal h count
    reg [10: 0] h_count;
    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            h_count <= 11'd0;
        end
        else begin
            if (nedge_hblank) begin
               h_count <= 10'd0; 
            end
            else begin
                if (~i_hblank) begin
                    h_count <= h_count + 11'd1;
                end
                else begin
                    h_count <= h_count; // hold
                end
            end
        end
    end
    
    // internal v count
    reg [9: 0] v_count;
    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            v_count <= 10'd0;
        end
        else begin
            if (nedge_vblank) begin
               v_count <= 10'd0; 
            end
            else begin
                if (nedge_hblank) begin
                    v_count <= v_count + 11'd1;
                end
                else begin
                    v_count <= v_count; // hold
                end
            end
        end
    end

    // read range flag
    wire   read_h_range;
    wire   read_v_range;
    wire   read_in_range;
    assign read_h_range  = (h_count < FB_H) ? 1'b1 : 1'b0;
    assign read_v_range  = (v_count < FB_V) ? 1'b1 : 1'b0;
    assign read_in_range = read_h_range & read_v_range & ~i_vblank;

    // read address
    reg [17 :0] read_addr;
    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            read_addr <= 18'd0;
        end
        else begin
            if (i_vblank) begin
                read_addr <= 18'd0;
            end
            else begin
                if (read_in_range) begin
                    read_addr <= read_addr + 18'd1;
                end
                else begin
                    read_addr <= read_addr; // hold
                end
            end
        end
    end

    assign o_read_address = read_addr;
    assign o_read_enable  = read_in_range;

    // delayed hsync
    reg [1:0] hsync_deleayed;
    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            hsync_deleayed <= 2'b11;
        end
        else begin
            hsync_deleayed <= {hsync_deleayed[0], i_hsync};
        end
    end

    // delayed vsync
    reg [1:0] vsync_deleayed;
    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            vsync_deleayed <= 2'b11;
        end
        else begin
            vsync_deleayed <= {vsync_deleayed[0], i_vsync};
        end
    end

    // delayed vde
    reg [1:0] vde_deleayed;
    always @(posedge i_clk) begin
        if (!i_rst_n) begin
            vde_deleayed <= 2'b00;
        end
        else begin
            vde_deleayed <= {vde_deleayed[0], i_vde};
        end
    end

    assign o_hsync = hsync_deleayed[1];
    assign o_vsync = vsync_deleayed[1];
    assign o_vde   = vde_deleayed[1];

endmodule