MCC ?= $(HOME)/mcc/bin/mcc
LLVM_DIR ?= $(shell brew --prefix llvm@21)/lib/cmake/llvm
MONICELLI_SRC ?= .build/monicelli
MONICELLI_REV ?= 07d389c3bb5cd670f1aa3d543c9a29fa4369243e
# mcc non compila sorgenti oltre 1 MiB (buffer del lexer): vedi la spec di codfisc.
LIMITE_MCC = 1048576

antani: src/antani.mc
	$(MCC) src/antani.mc -o antani

codfisc: src/luoghi.mc src/codfisc.mc
	mkdir -p .build
	cat src/luoghi.mc src/codfisc.mc > .build/codfisc.mc
	@test $$(wc -c < .build/codfisc.mc) -lt $(LIMITE_MCC) || { echo "ERRORE: .build/codfisc.mc supera 1 MiB, mcc non lo compila"; exit 1; }
	$(MCC) .build/codfisc.mc -o codfisc

test: antani codfisc
	./tests/run.sh
	./tests/run.sh codfisc
	python3 -m unittest discover -s tools

luoghi:
	curl -fsSL -A "Mozilla/5.0" -o dati/ANPR_archivio_comuni.csv https://www.anagrafenazionale.interno.it/wp-content/uploads/ANPR_archivio_comuni.csv
	curl -fsSL -A "Mozilla/5.0" -o dati/tabella_2_statiesteri.xlsx https://www.anagrafenazionale.interno.it/wp-content/uploads/tabella_2_statiesteri.xlsx
	python3 tools/importa-luoghi.py

mcc:
	test -d $(MONICELLI_SRC) || git clone --depth 1 https://github.com/esseks/monicelli $(MONICELLI_SRC)
	git -C $(MONICELLI_SRC) fetch --depth 1 origin $(MONICELLI_REV)
	git -C $(MONICELLI_SRC) checkout $(MONICELLI_REV)
	cmake -S $(MONICELLI_SRC) -B $(MONICELLI_SRC)/build -DCMAKE_INSTALL_PREFIX=$(HOME)/mcc -DLLVM_DIR=$(LLVM_DIR)
	cmake --build $(MONICELLI_SRC)/build --target install

clean:
	rm -f antani codfisc

.PHONY: test luoghi mcc clean
