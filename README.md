## Llama 2 Everywhere

<p align="center">
  <img src="assets/llamas_everywhere.jpg" width="600" height="454" alt="LLamas Everywhere!">
</p>

Standalone and 64bit Binary Portable Llama 2 Inference in one file of C

A friendly fork of the excellent [llama2.c](https://github.com/karpathy/llama2.c)

Our goal is to mirror the progress of https://github.com/karpathy/llama2.c, add improvements such as as OpenCL / Vulkan GPU inference, webserver etc which certainly would not fit in the upstream do to the minimal / simplicity / elegance requirements constraints there.

# Features

## Portability Features

+ Executable that runs on
  + GNU/Systemd
  + BSD
  ++ FreeBSD
  ++ OpenBSD
  ++ NetBSD
  + XNU's Not UNIX
  + Bare Metal (Not fully functional yet but almost...)
  + Windows

+ Runs on ARM64 (aarch64), x86_64

+ Standalone
  + Embedded model

These features depend on a specific cosmocc toolchain: https://github.com/jart/cosmopolitan

Building this with gcc or clang would result in normal binaries similar to upstream.

Read more:
[How to build](https://github.com/trholding/llama2.c#portable-binary-build)

[x] Token buffer - faster interactive inference
[x] Openblas
[x] CLBLAST - GPU 

Download the prebuilt run.com binary from releases

## llama2.c

<p align="center">
  <img src="assets/llama_cute.jpg" width="300" height="300" alt="Cute Llama">
</p>

A friendly fork of the excellent [llama2.c](https://github.com/karpathy/llama2.c)

The original repository offers a full-stack solution for training and inferring the Llama 2 LLM architecture using PyTorch and a simple 500-line C file. The focus is on minimalism and simplicity, and the repo is a young project that is still being actively developed. The author recommends looking at the TinyStories paper for inspiration, as small LLMs can have strong performance in narrow domains. The C inference engine in run.c was the main focus of the project, and the Llama 2 architecture is hard-coded with no dependencies.

## feel the magic

Let's just run a baby Llama 2 model in C. You need a model checkpoint. Download this 15M parameter model I trained on the [TinyStories](https://huggingface.co/datasets/roneneldan/TinyStories) dataset (~60MB download):

```bash
wget https://huggingface.co/karpathy/tinyllamas/resolve/main/stories15M.bin
```

Compile and run the C code:

```bash
make run
./run stories15M.bin
```

You'll see the text stream a sample. On my M1 MacBook Air this runs at ~110 tokens/s. See [performance](#performance) or the Makefile for compile flags that can significantly speed this up. We can also try a bit bigger 42M parameter model:

```bash
wget https://huggingface.co/karpathy/tinyllamas/resolve/main/stories42M.bin
./run stories42M.bin
```

This still runs at interactive rates and samples more coherent and diverse stories:

> Once upon a time, there was a little girl named Lily. She loved playing with her toys on top of her bed. One day, she decided to have a tea party with her stuffed animals. She poured some tea into a tiny teapot and put it on top of the teapot. Suddenly, her little brother Max came into the room and wanted to join the tea party too. Lily didn't want to share her tea and she told Max to go away. Max started to cry and Lily felt bad. She decided to yield her tea party to Max and they both shared the teapot. But then, something unexpected happened. The teapot started to shake and wiggle. Lily and Max were scared and didn't know what to do. Suddenly, the teapot started to fly towards the ceiling and landed on the top of the bed. Lily and Max were amazed and they hugged each other. They realized that sharing was much more fun than being selfish. From that day on, they always shared their tea parties and toys.

You can also prompt the model with a prefix (sadly, because this is currently done via positional arguments, you also have to specify temperature 1.0 and 256 steps, before you enter the prompt):

```bash
./run stories42M.bin 1.0 256 "One day, Lily met a Shoggoth"
```

> One day, Lily met a Shoggoth. He was very shy, but was also very generous. Lily said “Hello Shoggy! Can I be your friend?” Shoggy was happy to have a friend and said “Yes, let’s explore the universe together!” So they set off on a journey to explore the universe. As they travelled, Shoggy was happy to explain to Lily about all the wonderful things in the universe. At the end of the day, Lily and Shoggy had gathered lots of wonderful things from the universe, and they both felt very proud. They promised to explore the universe as one big pair and to never stop being generous to each other.

There is also an even better 110M param model available, see [models](#models).


## Models

The original author trained a series of small models on TinyStories, which took a few hours to train on their setup. The 110M model took around 24 hours. The models are hosted on huggingface hub:

| model | dim | n_layers | n_heads | max context length | parameters | val loss | download
| --- | --- | --- | --- | --- | --- | --- | --- |
| OG | 288 | 6 | 6 | 256 | 15M | 1.072 | [stories15M.bin](https://huggingface.co/karpathy/tinyllamas/resolve/main/stories15M.bin) |
| 42M| 512 | 8 | 8 | 1024 | 42M | 0.847 | [stories42M.bin](https://huggingface.co/karpathy/tinyllamas/resolve/main/stories42M.bin) |
| 110M| 768 | 12 | 12 | 1024 | 110M | 0.760 | [stories110M.bin](https://huggingface.co/karpathy/tinyllamas/resolve/main/stories110M.bin) |

The upstream project owner trained the llama2.c storyteller models on a 4X A100 40GB box provided by [Lambda labs](https://lambdalabs.com/service/gpu-cloud).


```bash
./run llama2_7b.bin
```
Converted **Meta's Llama 2 7b** model cab be infered at a slow speed.

## Performance

There are many ways to potentially speed up this code depending on your system. Have a look at the [Makefile](Makefile), which contains a lot of notes. The `make run` command currently uses the `-O3` optimization by default, i.e.:

```bash
gcc -O3 -o run run.c -lm
```

-O3 includes optimizations that are expensive in terms of compile time and memory usage. Including vectorization, loop unrolling, and predicting branches.

To get a much better performance, try to compile with `make runfast`. This turns on the `-Ofast` flag, which includes additional optimizations that may break compliance with the C/IEEE specifications, in addition to `-O3`. See [the GCC docs](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html) for more information.

Try `-march=native` to compile the program to use the architecture of the machine you're compiling on rather than a more generic CPU. This may enable additional optimizations and hardware-specific tuning such as improved vector instructions/width.

The fastest throughput I saw so far on my MacBook Air (M1) so far is with `make runfast`. 

You can also experiment with replacing `gcc` with `clang`.

### OpenMP
Big improvements can also be achieved by compiling with OpenMP, which "activates" the `#pragma omp parallel for` inside the matmul and attention, allowing the work in the loops to be split up over multiple processors.
You'll need to install the OpenMP library and the clang compiler first (e.g. `apt install clang libomp-dev` on ubuntu). I was not able to get improvements from OpenMP on my MacBook, though. Then you can compile with `make runomp`, which does:

```bash
clang -Ofast -fopenmp -march=native run.c  -lm  -o run
```

When you run inference make sure to use OpenMP flags to set the number of threads, e.g.:

```bash
OMP_NUM_THREADS=4 ./run out/model.bin
```

Depending on your system resources you may want to tweak these hyperparameters and use more threads. But more is not always better, usually this is a bit U shaped.


## Platforms

**Multi OS build**

+ `make cosmorun`

The binary will boot on baremetal and also run on any 64 Bit OS such as Linux, *BSD, Windows and slower on Aarch64 Mac & Linux

**Linux**

Centos 7 / Amazon Linux 2018
+ `make rungnu` or `make runompgnu` to use openmp.

**Other Linux Distros / Mac**
+ `make runfast` or `make runomp` to use openmp.

**Windows**

Build on windows: 
+ `build_msvc.bat` in a Visual Studio Command Prompt 

Build on Linux and Windows:
+ `make win64` to use the mingw compiler toolchain.

The MSVC build will use openmp and max threads suitable for your CPU unless you set `OMP_NUM_THREADS` env.

## Portable Binary Build

Have you ever wanted to inference a baby Llama 2 model with a single executable on any OS or *as OS? No? Well, now you can!

By making use of the Cosmopolitan libc toolchain to build llama2.c we get the following features:

+ Executable that runs on
  + GNU/Systemd
  + FreeBSD
  + OpenBSD
  + NetBSD
  + XNU's Not UNIX
  + Bare Metal (-D COSMO_METAL) (*Not fully functional yet)
  + Windows

+ Runs on 
  + ARM64 via Blink x86-64 emulation (-D COSMO_BLINK) (Slow)
  + x86_64

+ Standalone
  + Embedded model in executable (-D COSMO_ZIP)

Instructions

Get and build the comopolitan libc toolchain:

Follow instructions at https://github.com/jart/cosmopolitan

Or do:

```
sudo mkdir -p /opt
sudo chmod 1777 /opt
git clone https://github.com/jart/cosmopolitan /opt/cosmo
cd /opt/cosmo
make -j8 toolchain
mkdir -p /opt/cosmos/bin
export PATH="/opt/cosmos/bin:$PATH"
echo 'PATH="/opt/cosmos/bin:$PATH"' >>~/.profile
sudo ln -sf /opt/cosmo/tool/scripts/cosmocc /opt/cosmos/bin/cosmocc
sudo ln -sf /opt/cosmo/tool/scripts/cosmoc++ /opt/cosmos/bin/cosmoc++
```

Example build to generate a Actually Portable Executable (APE):

```
$ cosmocc -O3 -Ofast -funsafe-math-optimizations -ffast-math -D COSMO_BLINK \
-D COSMO_METAL -D COSMO_ZIP -o run.com run.c -lm

Add model.bin and tokenizer.bin to executable:
$ zip run.com out/model.bin
$ zip run.com tokenizer.bin
```

Run or copy to any supported system and run:

```
If model is embedded:

$ ./run.com

Else

$ ./run.com model.bin
```

## contributing

- All pull requests that are merged to upstream will be automatically applied here as we closely mirror upstream. 
- I merge pull requests that improves performance even if they are rejected upstream.
- Performance and usability improvement contriubutions are welcome.

## Notable projects
- [llama.cpp](https://github.com/ggerganov/llama.cpp)
- [llama2.c](https://github.com/karpathy/llama2.c)
## License

MIT
