# Libraries
# BLIS
BLIS_PREFIX = /usr/local
BLIS_INC    = $(BLIS_PREFIX)/include/blis
BLIS_LIB    = $(BLIS_PREFIX)/lib/libblis.a
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
# $ valgrind --leak-check=full ./run out/model.bin 1.0 3
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
.PHONY: runomp
runomp: run.c
	$(CC) -D OPENMP -Ofast -fopenmp -foffload-options="-Ofast -lm" -march=native run.c  -lm  -o run
	
.PHONY: runoacc
runoacc: run.c
	$(CC) -D OPENACC -Ofast -fopenacc -foffload-options="-Ofast -lm" -march=native run.c  -lm  -o run	

.PHONY: win64
win64: 
	x86_64-w64-mingw32-gcc -Ofast -D_WIN32 -o run.exe -I. run.c win.c

# compiles with gnu99 standard flags for amazon linux, coreos, etc. compatibility
.PHONY: rungnu
rungnu:
	$(CC) -Ofast -std=gnu11 -o run run.c -lm

.PHONY: runompgnu
runompgnu:
	$(CC) -Ofast -fopenmp -std=gnu11 run.c  -lm  -o run

.PHONY: runclblast
runclblast: run.c
	$(CC) -D CLBLAST -Ofast -fopenmp -march=native run.c -lm -lclblast -o run

.PHONY: runopenblas
runopenblas: run.c
	$(CC) -D OPENBLAS -Ofast -fopenmp -march=native run.c -lm -lopenblas -o run

.PHONY: runblas
runblas: run.c
	$(CC) -D CBLAS -Ofast -fopenmp -march=native run.c -lm -lcblas -o run

.PHONY: runblis
runblis: run.c
	$(CC) -D BLIS -Ofast -fopenmp -march=native -I$(BLIS_INC) run.c -lm -lblis -o run
	
.PHONY: runarmpl
runarmpl: run.c
	$(CC) -D ARMPL -Ofast -fopenmp -march=native run.c -lm -larmpl_lp64_mp -o run
	
.PHONY: runmkl
runmkl: run.c
	$(CC) -D MKL -Ofast -fopenmp -march=native -I$(BLIS_INC) run.c -lm -lblis -o run	

.PHONY: cosmorun
cosmorun:
	cosmocc -Ofast -D COSMO_BLINK -D COSMO_METAL -D COSMO_ZIP run.c -lm -o run.com
	zip run.com out/model.bin
	zip run.com tokenizer.bin

.PHONY: clean
clean:
	rm -f run
