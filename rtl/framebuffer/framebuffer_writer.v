// 

`default_nettype none
module framebuffer_writer (
    input  wire         i_clk,
    input  wire         i_rst_n,

    input  wire [ 7: 0] i_command,
    input  wire         i_command_latch,
    input  wire [ 7: 0] i_param,
    input  wire         i_param_latch,
    input  wire [15: 0] i_rgb565,
    input  wire         i_rgb565_latch,

    output wire [17: 0] o_write_address,
    output wire [15: 0] o_write_data,
    output wire         o_write_enable
);
    // command 2c latch
    wire   command_2c_latch;
    assign command_2c_latch = i_command_latch & ((i_command == 8'h2c) ? 1'b1 : 1'b0);

    // delayed latch
    reg [5:0] rgb565_latch_delay;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            rgb565_latch_delay <= 6'd0;
        end
        else begin
            rgb565_latch_delay <= {rgb565_latch_delay[4:0], i_rgb565_latch};
        end
    end
    wire   rgb565_latch_delayed;
    assign rgb565_latch_delayed = rgb565_latch_delay[5];

    // write address
    reg [17: 0] write_addr;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            write_addr <= 18'd0;
        end
        else begin
            if (command_2c_latch) begin
                write_addr <= 18'd0;
            end
            else begin
                if (rgb565_latch_delayed) begin
                    write_addr <= write_addr + 18'd1; 
                end
                else begin
                    write_addr <= write_addr; // hold
                end
            end
       end
    end

    // data delay
    reg [15: 0] rgb565_delayed;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            rgb565_delayed <= 16'h0000;
        end
        else begin
            rgb565_delayed <= i_rgb565;
       end
    end

    assign o_write_address = write_addr;
    assign o_write_data    = rgb565_delayed;
    assign o_write_enable  = rgb565_latch_delay[0];

endmodule
`default_nettype wire
