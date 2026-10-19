FC = gfortran
FFLAGS ?= -O2 -Wall -Wextra -std=legacy
TARGET = build/contra_rotating_propeller
SOURCE = src/contra_rotating_propeller.f90

.PHONY: all run run-corrected test clean
all: $(TARGET)

$(TARGET): $(SOURCE)
	mkdir -p build
	$(FC) $(FFLAGS) -o $@ $<

run: all
	cd examples/typical-case && ../../$(TARGET)
	@echo 'Created examples/typical-case/FA8.OUT and FA88.OUT'

run-corrected: all
	cd examples/typical-case && ../../$(TARGET) --corrected-bound-angle
	@echo 'Generated corrected-bound-angle outputs (experimental mode)'

test: all
	python3 tests/test_example.py $(abspath $(TARGET))

clean:
	rm -rf build
	rm -f examples/typical-case/FA8.OUT examples/typical-case/FA88.OUT
