# Libraries
# BLIS
BLIS_PREFIX = /usr/local
BLIS_INC    = $(BLIS_PREFIX)/include/blis
BLIS_LIB    = $(BLIS_PREFIX)/lib/libblis.a

# Model / Tokenizer Paths
MOD_PATH    = out/model.bin
TOK_PATH    = tokenizer.bin

#  -L${MKLROOT}/lib/intel64 -lmkl_rt -Wl,--no-as-needed -lpthread -lm -ldl
#  -m64  -I"${MKLROOT}/include" 


# choose your compiler, e.g. gcc/clang
# example override to clang: make run CC=clang

CC = gcc

# the most basic way of building that is most likely to work on most systems
.PHONY: run
run: run.c
	$(CC) -O3 -o run run.c -lm

# useful for a debug build, can then e.g. analyze with valgrind, example:
# $ valgrind --leak-check=full ./run out/model.bin -n 3
rundebug: run.c
	$(CC) -g -o run run.c -lm

# https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
# https://simonbyrne.github.io/notes/fastmath/
# -Ofast enables all -O3 optimizations.
# Disregards strict standards compliance.
# It also enables optimizations that are not valid for all standard-compliant programs.
# It turns on -ffast-math, -fallow-store-data-races and the Fortran-specific
# -fstack-arrays, unless -fmax-stack-var-size is specified, and -fno-protect-parens.
# It turns off -fsemantic-interposition.
# In our specific application this is *probably* okay to use
.PHONY: runfast
runfast: run.c
	$(CC) -Ofast -o run run.c -lm

# additionally compiles with OpenMP, allowing multithreaded runs
# make sure to also enable multiple threads when running, e.g.:
# OMP_NUM_THREADS=4 ./run out/model.bin
.PHONY: run_cc_openmp
run_cc_openmp: run.c
	$(CC) -D OPENMP -Ofast -fopenmp -foffload-options="-Ofast -lm" -march=native run.c  -lm  -o run
	
.PHONY: run_cc_openacc
run_cc_openacc: run.c
	$(CC) -D OPENACC -Ofast -fopenacc -foffload-options="-Ofast -lm" -march=native run.c  -lm  -o run	

.PHONY: win64
win64: run.c
	x86_64-w64-mingw32-gcc -Ofast -D_WIN32 -o run.exe -I. run.c win.c

# compiles with gnu99 standard flags for amazon linux, coreos, etc. compatibility
.PHONY: rungnu
rungnu:
	$(CC) -Ofast -std=gnu11 -o run run.c -lm

.PHONY: runompgnu
runompgnu:
	$(CC) -Ofast -fopenmp -std=gnu11 run.c  -lm  -o run

.PHONY: run_cc_clblast
run_cc_clblast: run.c
	$(CC) -D CLBLAST -Ofast -fopenmp -march=native run.c -lm -lclblast -o run

.PHONY: run_cc_openblas
run_cc_openblas: run.c
	$(CC) -D OPENBLAS -Ofast -fopenmp -march=native run.c -lm -lopenblas -o run

.PHONY: run_cc_cblas
run_cc_cblas: run.c
	$(CC) -D CBLAS -Ofast -fopenmp -march=native run.c -lm -lcblas -o run

.PHONY: run_cc_blis
run_cc_blis: run.c
	$(CC) -D BLIS -Ofast -fopenmp -march=native -I$(BLIS_INC) run.c -lm -lblis -o run
	
.PHONY: run_cc_armpl
run_cc_armpl: run.c
	$(CC) -D ARMPL -Ofast -fopenmp -march=native run.c -lm -larmpl_lp64_mp -o run

# amd64 (x86_64) / intel mac (WIP) Do not use!
.PHONY: run_cc_mkl 
run_cc_mkl: run.c
	$(CC) -D MKL -Ofast -fopenmp -march=native run.c -lm -lblis -o run	

.PHONY: run_cc_mac_accel
runaccel: run.c
	$(CC) -D AAF -Ofast -fopenmp -march=native run.c -lm -framework Accelerate -o run


# Cosmocc + embedded model & tokenizer

.PHONY: run_cosmocc_zipos
run_cosmocc_zipos: run.c
	cosmocc -Ofast -D COSMO_BLINK -D COSMO_METAL -D COSMO_ZIP run.c -lm -o run.com
	zip run.com $(MOD_PATH)
	zip run.com $(TOK_PATH)
	
.PHONY: run_cosmocc_incbin
run_cosmocc_incbin:
	cosmocc -Ofast -D COSMO_BLINK -D COSMO_METAL -D INC_BIN -D MODPATH=$(MOD_PATH) -D TOKPATH=$(TOK_PATH) -D LLOOP run.c -lm -o run.com

.PHONY: run_cosmocc_strlit
run_cosmocc_strlit: run.c
	# Uses https://github.com/mortie/strliteral to embed files
	gcc -Ofast strliteral.c -o strlit
	./strlit -i emb_Model_data $(MOD_PATH) model.h
	./strlit -i emb_Tokenizer_data $(TOK_PATH) tokenizer.h
	cosmocc -Ofast -D COSMO_BLINK -D COSMO_METAL -D STRLIT -D LLOOP run.c -lm -o run.com


# GCC OpenMP + embedded model & tokenizer	

.PHONY: run_gcc_openmp_incbin
run_gcc_openmp_incbin: run.c
	gcc -D OPENMP -Ofast -fopenmp -foffload-options="-Ofast -lm" -march=native -D INC_BIN -D MODPATH=$(MOD_PATH) -D TOKPATH=$(TOK_PATH) -D LLOOP run.c  -lm  -o run	

.PHONY: run_gcc_openmp_strlit
run_gcc_openmp_strlit: run.c
	# Uses https://github.com/mortie/strliteral to embed files
	gcc -Ofast strliteral.c -o strlit
	./strlit -i emb_Model_data $(MOD_PATH) model.h
	./strlit -i emb_Tokenizer_data $(TOK_PATH) tokenizer.h
	gcc -D OPENMP -Ofast -fopenmp -foffload-options="-Ofast -lm" -march=native -D STRLIT -D LLOOP run.c  -lm  -o run	
	
	
# Clang OpenMP + embedded model & tokenizer	

.PHONY: run_clang_openmp_incbin
run_clang_openmp_incbin: run.c
	clang -D OPENMP -Ofast -fopenmp -march=native -D INC_BIN -D MODPATH=$(MOD_PATH) -D TOKPATH=$(TOK_PATH) -D LLOOP run.c  -lm  -o run	

.PHONY: run_clang_openmp_strlit
run_clang_openmp_strlit: run.c
	# Uses https://github.com/mortie/strliteral to embed files
	clang -Ofast strliteral.c -o strlit
	./strlit -i emb_Model_data $(MOD_PATH) model.h
	./strlit -i emb_Tokenizer_data $(TOK_PATH) tokenizer.h
	clang -D OPENMP -Ofast -fopenmp -march=native -D STRLIT -D LLOOP run.c  -lm  -o run		

# GCC static + embedded model & tokenizer

.PHONY: run_gcc_static_incbin
run_gcc_static_incbin: run.c
	gcc -Ofast -static -march=native -D INC_BIN -D MODPATH=$(MOD_PATH) -D TOKPATH=$(TOK_PATH) -D LLOOP run.c  -lm  -o run	

.PHONY: run_gcc_static_strlit
run_gcc_static_strlit: run.c
	# Uses https://github.com/mortie/strliteral to embed files
	gcc -Ofast strliteral.c -o strlit
	./strlit -i emb_Model_data $(MOD_PATH) model.h
	./strlit -i emb_Tokenizer_data $(TOK_PATH) tokenizer.h
	gcc -Ofast -static -march=native -D STRLIT -D LLOOP run.c  -lm  -o run

# Clang static + embedded model & tokenizer
.PHONY: run_clang_static_incbin
run_clang_static_incbin: run.c
	clang -Ofast -static -march=native -D INC_BIN -D MODPATH=$(MOD_PATH) -D TOKPATH=$(TOK_PATH) -D LLOOP run.c  -lm  -o run	

.PHONY: run_clang_static_strlit
run_clang_static_strlit: run.c
	# Uses https://github.com/mortie/strliteral to embed files
	clang -Ofast strliteral.c -o strlit
	./strlit -i emb_Model_data $(MOD_PATH) model.h
	./strlit -i emb_Tokenizer_data $(TOK_PATH) tokenizer.h
	clang -Ofast -static -march=native -D STRLIT -D LLOOP run.c  -lm  -o run
	
# Unikraft Unikernel build
.PHONY: run_unik_qemu_x86_64
run_unik_qemu_x86_64: run.c
	make -f Makefile.unikernel

# run all tests
.PHONY: test
test:
	pytest

# run only tests for run.c C implementation (is a bit faster if only C code changed)
.PHONY: testc
testc:
	pytest -k runc

.PHONY: clean
clean:
	rm -f run run.com model.h tokenizer.h strlit run.com.dbg *~
	make -f Makefile.unikernel clean
	
.PHONY: distclean
distclean:
	rm -f run run.com model.h tokenizer.h strlit run.com.dbg *~
	make -f Makefile.unikernel distclean	
