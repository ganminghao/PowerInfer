#!/bin/bash

export CUDA_VISIBLE_DEVICES=0
rm /root/autodl-tmp/models/PowerInfer/prosparse-llama-2-7b-gguf/prosparse-llama-2-7b.gguf.generated.gpuidx

# ---------------- Model Paths -----------------
model="/root/autodl-tmp/models/PowerInfer/prosparse-llama-2-7b-gguf/prosparse-llama-2-7b.gguf"



# ---------------- Inference Settings -----------------
vram_budget=7
threads=12
seed=1234
ctx_size=1024
max_tokens=128
file="/root/autodl-tmp/dataset/ShareGPT/processed_prompts.txt"
n_prompts=20

common_opts=(
    -m "$model"
    --no-mmap
    --repeat-penalty 1.1

    --vram_budget "$vram_budget"
    -t "$threads"
    -s "$seed"
    -c "$ctx_size"
    -n "$max_tokens"
    --file "$file"
    --n-test-prompts "$n_prompts"
)

usage() {
    echo "usage: $0 [release|debug] [cli] [nvtx]"
    exit 1
}

bin=./build/bin/bench
"$bin" "${common_opts[@]}"
