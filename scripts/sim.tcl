vlib work
vmap work work

vlib xilinxlib/unisim
vmap unisim xilinxlib/unisim

vlib xilinxlib/unisims_ver
vmap unisims_ver xilinxlib/unisims_ver

vlib xilinxlib/secureip
vmap secureip xilinxlib/secureip

vlog \
    -L work \
    -work work \
    -timescale "1ns/1ns" \
    -f filelist.txt

vsim \
    -L unisims_ver \
    -L unisim \
    -wlf vsim.wlf -wlfcachesize 512 \
    glbl tb_top

configure wave -namecolwidth 200
configure wave -valuecolwidth 100
configure wave -signalnamewidth 1

#add wave -radix hexadecimal -group tb_top       /tb_top/*
#add wave -radix hexadecimal -group lcd_rx       /tb_top/u_dut/u_lcd_rx/*
#add wave -radix hexadecimal -group fb           /tb_top/u_dut/u_fb/*
add wave -radix hexadecimal -group fb_reader    /tb_top/u_dut/u_fb/u_fb_reader/*
#add wave -radix hexadecimal -group fb_writer    /tb_top/u_dut/u_fb/u_fb_writer/*
add wave -radix hexadecimal -group vga_sync_gen /tb_top/u_dut/u_vga_sync_gen/*

set sim_time {150 ms}
run $sim_time
WaveRestoreZoom {0 ns} $sim_time
