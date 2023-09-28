# Llama 2 Everywhere (L2E)

Standalone, Binary Portable, Bootable Llama 2

This is a Unikraft-centric setup of [Llama 2 Everywhere (L2E)](https://github.com/trholding/llama2.c).

## Quick Set Up (aka TLDR)

For a quick setup, run the commands below.
Note that you still need to install the [requirements](#requirements).

For building and running everything for `x86_64`, follow the steps below:

```console
git clone https://github.com/unikraft/app-llama2-c llama2-c
cd llama2-c/
./scripts/setup.sh
UK_DEFCONFIG=$(pwd)/defconfigs/qemu-x86_64 make defconfig
make -j $(nproc)
qemu-system-x86_64 -enable-kvm -nographic -m 256M -kernel workdir/build/llama2-c_qemu-x86_64
```

This will configure, build and run the `L2E` application.

## Requirements

In order to set up, configure, build and run L2E on Unikraft, the following packages are required:

* `build-essential` / `base-devel` / `@development-tools` (the meta-package that includes `make`, `gcc` and other development-related packages)
* `sudo`
* `flex`
* `bison`
* `git`
* `wget`
* `uuid-runtime`
* `qemu-system-x86`
* `qemu-system-arm`
* `qemu-kvm`
* `sgabios`
* `gcc-aarch64-linux-gnu`

GCC >= 8 is required to build L2E on Unikraft.

On Ubuntu/Debian or other `apt`-based distributions, run the following command to install the requirements:

```console
sudo apt install -y --no-install-recommends \
  build-essential \
  sudo \
  gcc-aarch64-linux-gnu \
  libncurses-dev \
  libyaml-dev \
  flex \
  bison \
  git \
  wget \
  uuid-runtime \
  qemu-kvm \
  qemu-system-x86 \
  qemu-system-arm \
  sgabios
```

## Set Up

The following repositories are required for L2e:

* The application repository (this repository): [`app-llama2-c`](https://github.com/unikraft/app-llama2-c)
* The Unikraft core repository: [`unikraft`](https://github.com/unikraft/unikraft)
* Library repositories:
  * The Musl libc library: [`lib-musl`](https://github.com/unikraft/lib-musl)

Follow the steps below for the setup:

  1. First clone the [`app-llama2-c` repository](https://github.com/unikraft/app-llama2-c) in the `llama2-c/` directory:

     ```console
     git clone https://github.com/unikraft/app-llama2-c llama-c
     ```

     Enter the `llama2-c/` directory:

     ```console
     cd llama2-c/

     ls -F
     ```

     This will print the contents of the repository:

     ```text
     defconfigs/  LICENSE  Makefile  Makefile.uk  README.md  run.c  scripts/  strliteral.c  tokenizer.bin
     ```

  1. While inside the `llama-2/` directory, use the `scripts/setup.sh` to set repositories and required files:

     ```console
     ./scripts/setup.sh
     ```

     It will download required model files and it will clone the repositories in the workdir directory:

     ```text
     workdir/
     |-- libs/
     |   `-- musl/
     `-- unikraft/
         |-- ADOPTERS.md
         |-- arch/
         |-- Config.uk
         |-- CONTRIBUTING.md
         |-- COPYING.md
         |-- drivers/
         |-- include/
         |-- lib/
         |-- Makefile
         |-- Makefile.uk
         |-- plat/
         |-- README.md
         |-- support/
         `-- version.mk
     ```

## Build

Use the commands below to build:

```console
UK_DEFCONFIG=$(pwd)/defconfigs/qemu-x86_64 make defconfig
make -j $(nproc)
```

It uses the default configuration file `defconfigs/qemu-x86_64` to configure the application.
And then `make` to build the Unikraft image.

## Run

Run the Unikraft image with `qemu-system-x86_64`:

```console
qemu-system-x86_64 -enable-kvm -nographic -m 256M -kernel workdir/build/llama2-c_qemu-x86_64
```
