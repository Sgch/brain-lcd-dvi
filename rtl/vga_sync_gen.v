
`default_nettype none
// default parameters: 640x480@60fps, pclk:25.175 MHz
module vga_sync_gen #(
    parameter H_SYNC     = 11'd96,
    parameter H_BACK     = 11'd48,
    parameter H_ACT      = 11'd640,
    parameter H_FRONT    = 11'd16,
    parameter H_SYNC_INV = 1'b1,

    parameter V_SYNC     = 11'd2,
    parameter V_BACK     = 11'd33,
    parameter V_ACT      = 11'd480,
    parameter V_FRONT    = 11'd10,
    parameter V_SYNC_INV = 1'b1
)(
    input  wire i_clk,
    input  wire i_rst_n,

    output wire o_hblank,
    output wire o_vblank,
    output wire o_hsync,
    output wire o_vsync,
    output wire o_vde
);
    localparam [11: 0] H_TOTAL      = H_SYNC + H_BACK + H_ACT + H_FRONT - 11'd1;
    localparam [11: 0] V_TOTAL      = V_SYNC + V_BACK + V_ACT + V_FRONT - 11'd1;
    localparam [11: 0] HSYNC_BEGIN  = H_ACT + H_BACK;
    localparam [11: 0] HSYNC_END    = HSYNC_BEGIN + H_SYNC;
    localparam [11: 0] VSYNC_BEGIN  = V_ACT + V_BACK;
    localparam [11: 0] VSYNC_END    = VSYNC_BEGIN + V_SYNC;

    // h count
    reg [11: 0] h_count;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            h_count <= 11'd0;
        end
        else begin
            if (h_count < H_TOTAL) begin
                h_count <= h_count + 11'd1;
            end
            else begin
                h_count <= 11'd0;
            end
        end
    end

    // v count
    reg [11: 0] v_count;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            v_count <= 11'd0;
        end
        else begin
            if (h_count == H_TOTAL) begin
                if (v_count < V_TOTAL) begin
                    v_count <= v_count + 11'd1;
                end
                else begin
                    v_count <= 11'd0;
                end
            end
            else begin
                v_count <= v_count; // hold
            end
        end
    end
    
    // hblank
    reg hblank;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            hblank <= 1'b0;
        end
        else begin
            hblank <= (h_count < H_ACT) ? 1'b0 : 1'b1;
        end
    end

    // vblank
    reg vblank;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            vblank <= 1'b0;
        end
        else begin
            vblank <= (v_count < V_ACT) ? 1'b0 : 1'b1;
        end
    end

    // vden
    reg vden;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            vden <= 1'b0;
        end
        else begin
            vden <= ((h_count < H_ACT) && (v_count < V_ACT)) ? 1'b1 : 1'b0;
        end
    end

    // hsync
    reg hsync;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            hsync <= 1'b0 ^ H_SYNC_INV;
        end
        else begin
            hsync <= ((HSYNC_BEGIN <= h_count && h_count < HSYNC_END) ? 1'b1 : 1'b0) ^ H_SYNC_INV;
        end
    end

    // vsync
    reg vsync;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            vsync <= 1'b0 ^ H_SYNC_INV;
        end
        else begin
            vsync <= ((VSYNC_BEGIN <= v_count && v_count < VSYNC_END) ? 1'b1 : 1'b0) ^ V_SYNC_INV;
        end
    end

    assign o_hblank = hblank;
    assign o_vblank = vblank;
    assign o_hsync  = hsync;
    assign o_vsync  = vsync;
    assign o_vde    = vden;

endmodule
`default_nettype wire
