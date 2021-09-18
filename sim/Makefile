.PHONY: sim
sim:
	vsim -do ../scripts/sim.tcl

.PHONY: create_simlib
create_simlib:
	vivado -mode batch -script ../scripts/sim_build_xilinx_lib.tcl

.PHONY: clean
	rm -rf work modelsim.ini transcript vsim.wlf
