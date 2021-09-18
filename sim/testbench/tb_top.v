`timescale 1ns / 1ns
`default_nettype none
module tb_top ();
     parameter SYSCLK = 125000000;

     reg            sysclk   = 1'b0;
     reg            sysrst_n = 1'b1;

     // IO
     wire           lcd_wr;
     wire           lcd_rs;
     wire           lcd_cs_n;
     wire           lcd_rst_n;
     wire [15: 0]   lcd_data;

     wire [ 3: 0]   zybo_btn;
     wire [ 3: 0]   zybo_sw;

     // sysclk
     always #(500000000 / SYSCLK) begin
          sysclk <= ~sysclk;
     end

     // sysrst_n
     initial begin
          sysrst_n = 1'b1;
          #1000;
          sysrst_n = 1'b0;
          #1000;
          sysrst_n = 1'b1;
     end

     // sharp brain source lcd model
     tb_brain_lcd u_tb_brain_lcd (
          .o_lcd_wr(lcd_wr),
          .o_lcd_rs(lcd_rs),
          .o_lcd_cs_n(lcd_cs_n),
          .o_lcd_rst_n(lcd_rst_n),
          .o_lcd_data(lcd_data)
     );

     // DUT
     top u_dut (
          .i_mclk_125m(sysclk),

          .i_lcd_wr(lcd_wr),
          .i_lcd_rs(lcd_rs),
          .i_lcd_cs_n(lcd_cs_n),
          .i_lcd_rst_n(lcd_rst_n),
          .i_lcd_data(lcd_data),

          .i_zybo_z2_btn(zybo_btn),
          .i_zybo_z2_sw(zybo_sw),
          .o_zybo_z2_led(),

          .o_dvi_clk_p(),
          .o_dvi_clk_n(),
          .o_dvi_data_p(),
          .o_dvi_data_n()
     );

     assign zybo_btn[0] = ~sysrst_n;

endmodule
`default_nettype wire
