# Llama 2 Everywhere (L2E)

Standalone, Binary Portable, Bootable Llama 2

This is a Unikraft-centric setup of [Llama 2 Everywhere (L2E)](https://github.com/trholding/llama2.c).
It exposes a very basic HTTP service that can be queried to provide a reply from Llama 2.

## Quick Set Up (aka TLDR)

For a quick setup, run the commands below.
Note that you still need to install the [requirements](#requirements).

For building and running everything for `x86_64`, follow the steps below:

```console
git clone https://github.com/unikraft/app-llama2-c llama2-c
cd llama2-c/
./scripts/setup.sh
wget https://raw.githubusercontent.com/unikraft/app-testing/staging/scripts/generate.py -O scripts/generate.py
chmod a+x scripts/generate.py
./scripts/generate.py
./scripts/build/make-qemu-x86_64.sh
./scripts/run/qemu-x86_64.sh
```

This will configure, build and run the `L2E` service.
It listens for connections on port `8080` of address `172.44.0.2`.

Open another console to query the service and get a story:

```console
curl 172.44.0.2:8080
```

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

The following repositories are required for L2E:

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

## Build and Run

To build and run Unikraft images, it's easiest to generate build and running scripts and use those.

First of all, grab the [`generate.py` script](https://github.com/unikraft/app-testing/blob/staging/scripts/generate.py) and place it in the `scripts/` directory by running:

```console
wget https://raw.githubusercontent.com/unikraft/app-testing/staging/scripts/generate.py -O scripts/generate.py
chmod a+x scripts/generate.py
```

Now, run the `generate.py` script.
You must run it in the root directory of this repository:

```console
./scripts/generate.py
```

Running the script will generate build and run scripts in the `scripts/build/` and the `scripts/run/` directories:

```text
scripts/
|-- build/
|   |-- kraft-fc-arm64.sh*
|   |-- kraft-fc-x86_64.sh*
|   |-- kraft-qemu-arm64.sh*
|   |-- kraft-qemu-x86_64.sh*
|   |-- make-fc-x86_64.sh*
|   `-- make-qemu-x86_64.sh*
|-- generate.py*
|-- run/
|   |-- fc-x86_64.json
|   |-- fc-x86_64.sh*
|   |-- kraft-fc-arm64.sh*
|   |-- kraft-fc-x86_64.sh*
|   |-- kraft-qemu-arm64.sh*
|   |-- kraft-qemu-x86_64.sh*
|   `-- qemu-x86_64.sh*
|-- run.yaml
`-- setup.sh*
```

You can now build and run images for different configurations.

For example, to build and run for QEMU on x86_64, run:

```console
./scripts/build/make-qemu-x86_64.sh
./scripts/run/qemu-x86_64.sh
```

This will 

To build and run for Firecracker on x86_64 using KraftKit, run:

```console
./scripts/build/kraft-fc-x86_64.sh
./scripts/run/kraft-fc-x86_64.sh
```

The run script will start the `L2E` service.
It listens for connections on port `8080` of address `172.44.0.2`.

Open another console to query the service and get a story:

```console
curl 172.44.0.2:8080
```

Close the QEMU instance by using the `Ctrl+a x` keyboard combination.
That is, press `Ctrl` and `a` simultaneously, then release and press `x`.

For Firecracker, you would have to kill the process by issuing a command.
Simplest is to open up another console and run:

```console
pkill -f firecracker
```

Note that Firecracker networking support is not yet enabled, so that will not work.
