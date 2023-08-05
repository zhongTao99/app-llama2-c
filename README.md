## Llama 2 Everywhere

<p align="center">
  <img src="assets/llamas_everywhere.jpg" width="600" height="454" alt="LLamas Everywhere!">
</p>

Standalone and 64bit Binary Portable Llama 2 Inference in one file of C

A friendly fork of the excellent [llama2.c](https://github.com/karpathy/llama2.c)

Our goal is to mirror the progress of https://github.com/karpathy/llama2.c, add improvements such as as OpenCL / Vulkan GPU inference, webserver etc which certainly would not fit in the upstream do to the minimal / simplicity / elegance requirements constraints there.

# Features

## Portability Features

+ Single Executable that runs on
  + GNU/Systemd
  + BSD
  ++ FreeBSD
  ++ OpenBSD
  ++ NetBSD
  + XNU's Not UNIX (Mac)
  + Bare Metal (Not fully functional yet but almost...)
  + Windows

+ Runs on ARM64 (aarch64), x86_64

+ Standalone
  + Embedded model

These combined features depend on a specific cosmocc toolchain: https://github.com/jart/cosmopolitan

Building this with gcc or clang would result in normal binaries similar to upstream.

Read more:
[How to build](https://github.com/trholding/llama2.c#portable-binary-build)

### Performance Features

**CPU**

- [x] OpenBLAS
- [x] CBLAS
- [x] BLIS
- [ ] Intel MKL (WIP)
- [ ] ArmPL (WIP)

**CPU/GPU**

- [x] OpenMP 
- [x] OpenACC

Both OpenMP and OpenACC builds currently use host CPU and do not offload GPU.

**GPU**

- [x] OpenCL (via CLBlast)
- [ ] Vulkan
- [ ] CUDA

Download the prebuilt run.com binary from releases

## llama2.c

<p align="left">
  <img src="assets/llama_cute.jpg" width="150" height="150" alt="Cute Llama">
</p>

A friendly fork of the excellent [llama2.c](https://github.com/karpathy/llama2.c)

The original repository offers a full-stack solution for training and inferring the Llama 2 LLM architecture using PyTorch and a simple 500-line C file. The focus is on minimalism and simplicity, and the repo is a young project that is still being actively developed. The author recommends looking at the TinyStories paper for inspiration, as small LLMs can have strong performance in narrow domains. The C inference engine in run.c was the main focus of the project, and the Llama 2 architecture is hard-coded with no dependencies.

## Feel the Magic

```bash
git clone https://github.com/trholding/llama2.c.git
cd llama2.c
make runfast
wget https://huggingface.co/karpathy/tinyllamas/resolve/main/stories15M.bin
./run stories15M.bin
```
You can also prompt the model with a prefix:

```bash
./run stories42M.bin -t 1.0 -s 256 -p "A big dog"
```

When prompting, the temperature and steps parameters are needed since we use simple positional arguments.

**Output**

> A big dog named Zip. He loved to run and play in the sun. He was a happy dog. One day, Zip saw a little bird on the ground. The bird looked helpless. Zip wanted to help the bird. He ran to the bird and lay down next to it. Zip and the bird became friends. They played together every day. Zip would carry the bird to play in the trees. The bird would fly around, and Zip would bark. They were very happy together.


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
A converted **Meta's Llama 2 7b** model can be inferenced at a slow speed.

## Usage

**Full Usage**

```bash
./run <checkpoint_file> -t [temperature] -s [steps] -b [buffertokens] -p [prompt]
```

Where 
 
 <checkpoint_file> is the **mandatory** checkpoint / model file.\
  E.g. `stories15M.bin` or `stories42M.bin` or `stories110M.bin`.
 
 -t is the *optional* temperature in the range `0.0` to `1.0` and a default of **0.9**.\
  `0` makes outputs with same or no prompt reproducible.
 
 -s is the *optional* number of steps in the range `1` to `256` and a default of **256**.\
  `0` sets it to context length of model.\
  This option defines the number of tokens to infer and output.
  
 -b is the *optional* number of tokens to buffer from a range 1 to context length and a default of **1**.\
  `0` sets it to context length of model.\
  This increases the interactive performance. Use values such as `4`, `8`, `16`, `32`, `64`, `128` ... YMMV!
 
 -p is the *optional* prompt such as `"A car"` to pass on to guide inference.\
  If omitted the model will infer on its own.

**Minimal Usage**

```bash
./run <checkpoint_file>
```

## Platforms

**Multi OS build**

`make cosmorun`

The binary will boot on baremetal and also run on any 64 Bit OS such as Linux, *BSD, Windows and slower on Aarch64 Mac & Linux.

Currently when used to boot, it won't be able to find the models. It's a toolchain issue with an anticipated fix.

The performance of this build is more than twice of the basic build.

**Linux**

Centos 7 / Amazon Linux 2018

`make rungnu` or `make runompgnu` to use openmp.

**Other Linux Distros / Mac**

`make runfast` or `make runomp` to use openmp.

**Windows**

Build on windows: 

`build_msvc.bat` in a Visual Studio Command Prompt 

The MSVC build will use openmp and max threads suitable for your CPU unless you set `OMP_NUM_THREADS` env.

Build on Linux and Windows:

`make win64` to use the mingw compiler toolchain.

## Performance

**Basic**

This build does not enable any optimizations.

```bash
make run
```
This can be used as baseline build against which performance of other builds can be compared.

**Fast**

This build enables basic performance boost with compiler provided optimizations.

```bash
make runfast
```
### Build wth Acceleration

**OpenMP**

This build enables acceleration via OpenMP

```bash
make runomp
```

Requires [OpenMP](https://www.openmp.org/) libraries and compiler with OpenMP support to be available on system.
E.g. `apt install clang libomp-dev` on ubuntu

When you run inference make sure to use OpenMP flags to set the number of threads, e.g.:

```bash
OMP_NUM_THREADS=4 ./run out/model.bin
```
More threads is not always better.

**OpenACC**

This build enables acceleration via OpenACC

```bash
make runoacc
```

Requires [OpenACC](https://www.openacc.org/) libraries and compiler with OpenACC support to be available on system.

**OpenBLAS**

This build enables acceleration via OpenBLAS

```bash
make runopenblas
```

Requires [OpenBLAS](https://github.com/xianyi/OpenBLAS) to be installed on system.

**BLIS**

This build enables acceleration via BLIS

```bash
make runblis
```
Requires [BLIS](https://github.com/flame/blis) compiled with `./configure --enable-cblas -t openmp,pthreads auto` to be installed on system.

**Generic CBLAS**

This build enables acceleration with any Netlib CBLAS interface compatible libraries

```bash
make runblas
```

Requires any BLAS library with Netlib CBLAS interface such as [LAPACK](https://www.netlib.org/lapack) to be installed on system.

**CLBlast (GPU/OpenCL)**

This build enables tuned GPU acceleration via OpenCL with CLBlast

```bash
make runclblast
```

Requires [ClBlast](https://github.com/CNugteren/CLBlast) compiled with `cmake -DNETLIB=ON` to be installed on system.

Note: Currently runs much slower than CPU! Requires investigation or memory is a bottle neck on the test system.

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

```bash
make cosmorun
```

Run or copy to any supported system and run:

If model is embedded:

```bash
./run.com
```

Else

```bash
/run.com model.bin
```

## TODO

- [ ] CLI Chat
- [ ] Web Chat
- [ ] Fix baremetal cosmo boot model loading
- [ ] Alt model embedding
- [ ] NetBSD Rump Kernel Boot
- [ ] GNU/Linux Linux Minimal Boot
- [ ] Intel MKL Acceleration (WIP)
- [ ] Arm Performance Libraries (WIP)
- [ ] EFI Capsule
- [ ] OpenCL pure
- [ ] Vulkan
- [ ] CUDA
- [ ] SIMD
- [ ] Optimize OpenMP & OpenACC
- [ ] Documentation
 
## Changelog

See commits.

## Contributing

- All pull requests that are merged to upstream will be automatically applied here as we closely mirror upstream. 
- I merge pull requests that improves performance even if they are rejected upstream.
- Performance and usability improvement contriubutions are welcome.

## Notable projects
- [llama.cpp](https://github.com/ggerganov/llama.cpp)
- [llama2.c](https://github.com/karpathy/llama2.c)
## License

MIT
