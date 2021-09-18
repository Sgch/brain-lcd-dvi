# mclk
create_clock -add -name sys_clk_125m -period 8.00 -waveform {0 4} [get_ports { i_mclk_125m }];

# io sw
set_false_path -from [get_ports {i_zybo_z2_btn}]
# io btn
set_false_path -from [get_ports {i_zybo_z2_sw}]
# io led
set_false_path -to [get_ports {o_zybo_z2_led}]