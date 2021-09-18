PROJECT_NAME=brain-lcd

.PHONY: build
build:
	if [ ! -d build ]; then mkdir build; fi
	cd build; vivado -mode batch -log vivado.log -jou vivado.jou -source ../scripts/build.tcl -tclargs ${PROJECT_NAME}; cd ..

.PHONY: open
open:
	cd build; vivado ${PROJECT_NAME}.xpr; cd ..

.PHONY: sim
sim:
	make -C sim sim

.PHONY: clean
clean:
	rm -rf build
