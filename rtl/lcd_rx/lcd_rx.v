
`default_nettype none
module lcd_rx (
    input  wire         i_clk,
    input  wire         i_rst_n,

    input  wire         i_lcd_wr,
    input  wire         i_lcd_rs,
    input  wire         i_lcd_cs_n,
    input  wire         i_lcd_rst_n,
    input  wire [15: 0] i_lcd_data,

    output wire [ 7: 0] o_command,
    output wire         o_command_latch,
    output wire [ 7: 0] o_param,
    output wire         o_param_latch,
    output wire [15: 0] o_rgb565,
    output wire         o_rgb565_latch
);
    reg  [ 7: 0] lcd_command;

    // edge detect
    reg lcd_wr_1d;
    reg lcd_rs_1d;
    reg lcd_cs_n_1d;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            lcd_wr_1d   <= 1'b1;
            lcd_rs_1d   <= 1'b1;
            lcd_cs_n_1d <= 1'b1;
        end
        else begin
            lcd_wr_1d   <= i_lcd_wr;
            lcd_rs_1d   <= i_lcd_rs;
            lcd_cs_n_1d <= i_lcd_cs_n;
        end
    end

    // pedge wr
    wire   pedge_wr;
    assign pedge_wr   =  i_lcd_wr   & ~lcd_wr_1d;

    // pedge cs_n
    wire   pedge_cs_n;
    assign pedge_cs_n =  i_lcd_cs_n & ~lcd_cs_n_1d;

    // nedge cs_n
    wire   nedge_cs_n;
    assign nedge_cs_n = ~i_lcd_cs_n &  lcd_cs_n_1d;

    // 2c command flag
    wire   command_2c;
    assign command_2c = (lcd_command == 8'h2c) ? 1'b1 : 1'b0;

    // latch signal
    wire   command_latch;
    wire   param_latch;
    wire   rgb565_latch;
    assign command_latch = pedge_wr & ~lcd_rs_1d & ~lcd_cs_n_1d;
    assign param_latch   = pedge_wr &  lcd_rs_1d & ~lcd_cs_n_1d & ~command_2c;
    assign rgb565_latch  = pedge_wr &  lcd_rs_1d & ~lcd_cs_n_1d &  command_2c;

    // latch command
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_lcd_rst_n || !i_rst_n) begin
            lcd_command <= 8'h00;
        end
        else begin
            if (command_latch) begin
                lcd_command <= i_lcd_data[7:0];
            end
            else begin
                lcd_command <= lcd_command; // hold
            end
        end
    end

    // latch param
    reg  [ 7: 0] lcd_param;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_lcd_rst_n || !i_rst_n) begin
            lcd_param <= 8'h00;
        end
        else begin
            if (param_latch) begin
                lcd_param <= i_lcd_data[7:0];
            end
            else begin
                lcd_param <= lcd_param; // hold
            end
        end
    end

    // latch rgb565
    reg [15: 0] lcd_rgb565;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_lcd_rst_n || !i_rst_n) begin
            lcd_rgb565 <= 16'h0000;
        end
        else begin
            if (rgb565_latch) begin
                lcd_rgb565 <= i_lcd_data;
            end
            else begin
                lcd_rgb565 <= lcd_rgb565; // hold
            end
        end
    end

    // delay command_latch
    reg command_latch_1d;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_lcd_rst_n || !i_rst_n) begin
            command_latch_1d <= 1'b0;
        end
        else begin
            command_latch_1d <= command_latch; // hold
        end
    end

    // delay param_latch_1d
    reg param_latch_1d;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_lcd_rst_n || !i_rst_n) begin
            param_latch_1d <= 1'b0;
        end
        else begin
            param_latch_1d <= param_latch; // hold
        end
    end

    // delay rgb565_latch_1d
    reg rgb565_latch_1d;
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_lcd_rst_n || !i_rst_n) begin
            rgb565_latch_1d <= 1'b0;
        end
        else begin
            rgb565_latch_1d <= rgb565_latch; // hold
        end
    end

    assign o_command       = lcd_command;
    assign o_command_latch = command_latch_1d;
    assign o_param         = lcd_param;
    assign o_param_latch   = param_latch_1d;
    assign o_rgb565        = lcd_rgb565;
    assign o_rgb565_latch  = rgb565_latch_1d;

endmodule
`default_nettype wire
