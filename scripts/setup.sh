#!/bin/bash

MOD_PATH=out/model.bin
TOK_PATH=tokenizer.bin

[ ! -d "out/" ] && echo "Downloading model..." || true
[ ! -d "out/" ] && wget https://huggingface.co/karpathy/tinyllamas/resolve/main/stories15M.bin || true
[ ! -d "out/" ] && mkdir out || true
[ -f "stories15M.bin" ] && mv stories15M.bin out/model.bin || true
[ ! -d "workdir" ] && echo "Cloning unikraft and musl sources..." || true
[ ! -d "workdir/unikraft" ] && git clone https://github.com/unikraft/unikraft workdir/unikraft || true
[ ! -d "workdir/libs/musl" ] && git clone https://github.com/unikraft/lib-musl workdir/libs/musl || true
[ ! -d "workdir/libs/lwip" ] && git clone https://github.com/unikraft/lib-lwip.git workdir/libs/lwip || true
gcc -Ofast strliteral.c -o strlit
./strlit -i emb_Model_data $MOD_PATH model.h
./strlit -i emb_Tokenizer_data $TOK_PATH tokenizer.h
