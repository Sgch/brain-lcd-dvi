`timescale 1ns / 1ns

module tb_brain_lcd(
    output wire         o_lcd_wr,
    output wire         o_lcd_rs,
    output wire         o_lcd_cs_n,
    output wire         o_lcd_rst_n,
    output wire [15: 0] o_lcd_data
);

parameter T_PON               =   10 * 1000;        // 10us
parameter T_START_SEQ         =   46 * 1000 * 1000; // 46ms
parameter T_TRANSFER_INTERVAL = 4724 * 1000;        // 4.7ms

reg         wr    = 1'bz;
reg         rs    = 1'bz;
reg         cs_n  = 1'bz;
reg         rst_n = 1'bz;
reg [15: 0] data  = 16'hzzzz;

`include "brain_lcd_tasks.vh"

initial begin
    #(T_PON);
    task_reset();

    #(T_START_SEQ);
    task_write(1'b0, 8'h2c);
    #(T_TRANSFER_INTERVAL);
    task_write(1'b1, 8'h00);
    #(T_TRANSFER_INTERVAL);

    #(1000);
    write_column_address_set(16'h0000, 16'h013f);
    write_page_address_set  (16'h0000, 16'h01df);
    wirte_start_transfer();
    send_screen(16'd480, 16'd320);
end

assign o_lcd_wr    = wr;
assign o_lcd_rs    = rs;
assign o_lcd_cs_n  = cs_n;
assign o_lcd_rst_n = rst_n;
assign o_lcd_data  = data;

endmodule
