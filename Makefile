MCC ?= $(HOME)/mcc/bin/mcc
LLVM_DIR ?= $(shell brew --prefix llvm@21)/lib/cmake/llvm
MONICELLI_SRC ?= .build/monicelli

antani: src/antani.mc
	$(MCC) src/antani.mc -o antani

test: antani
	./tests/run.sh

mcc:
	test -d $(MONICELLI_SRC) || git clone --depth 1 https://github.com/esseks/monicelli $(MONICELLI_SRC)
	cmake -S $(MONICELLI_SRC) -B $(MONICELLI_SRC)/build -DCMAKE_INSTALL_PREFIX=$(HOME)/mcc -DLLVM_DIR=$(LLVM_DIR)
	cmake --build $(MONICELLI_SRC)/build --target install

clean:
	rm -f antani

.PHONY: test mcc clean
