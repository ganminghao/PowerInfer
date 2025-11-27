#!/bin/bash
# 定义 workspaceFolder 变量，根据实际情况修改为你的工作区路径
workspaceFolder=$(pwd)
export PATH=$PATH:/opt/nvidia/nsight-compute/2024.1.1/host/target-linux-x64
# original powerinfer
main_prosparse() {
    #nsys profile --trace=cuda,nvtx\
    "${workspaceFolder}/build/bin/main" \
        -m "/root/autodl-tmp/models/prosparse-llama-2-7b-gguf/prosparse-llama-2-7b.gguf" \
        -p "write a story of Little Red Riding Hood." \
        --n-predict 128 \
        -t 16 \
        -c 0 \
        --vram-budget 12
}

# sd-llama2-7b-llama160m
# --temp 0.8 //not used now
# powerinfer not support flash attention "-fa"
# -ngld 99 -ngl 99 // sparse inference ignores n_gpu_layers, you can use --vram-budget option instead 
# "--p_accept","0.0f",// used for sd draft token generate, if >0 draft token num may be less than --draft, deafult is 0.5
sd_simple_llama2_7b_llama160m() {

    "${workspaceFolder}/build/bin/speculative" \
        -m "/mnt/models/Llama-2-7b-hf/Llama-2-7B-hf-F16.gguf" \
        -md "/mnt/models/llama-160m/llama-160M-F16.gguf" \
        -p "Below are a story of Little Red Riding Hood." \
        --n-predict 512 \
        -c 0 \
        --color \
        -t 8 \
        --vram-budget 12 \
        --top-k 5 --temp 0.8 \
        -ngld 99 -ngl 99 \
        --draft 5 \
        --seed 42 \
        --p_accept 0.0f
}

# sparse-sd-prosparse-llama2-7b-llama160m
sparse_sd_llama2_7b_llama160m() {
    #nsys profile --trace=cuda,nvtx\
    "${workspaceFolder}/build/bin/speculative" \
        -m "/root/autodl-tmp/models/prosparse-llama-2-7b-gguf/prosparse-llama-2-7b.gguf" \
        -md "/root/autodl-tmp/models/llama-160m-GGUF/llama-160m.fp16.gguf" \
        -p "Below are a short story of Peter Pan. " \
        --n-predict 128 \
        -c 0 \
        --color \
        -t 8 \
        --vram-budget 12 \
        --top-k 5 --temp 0.8 \
        --draft 5 \
        -ngld 99 \
        --seed 42 \
        --p_accept 0.0f
}

# 调用函数
main_prosparse
# sd_simple_llama2_7b_llama160m
# sparse_sd_llama2_7b_llama160m
