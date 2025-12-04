#!/bin/bash
# ./build/bin/main -m /root/autodl-tmp/models/prosparse-llama-2-7b-gguf/prosparse-llama-2-7b.gguf \
#  -n 128 \
#  -t 12  \
#  -p "Bubble sort algorithm in python:" \
#  --vram-budget 12

export CUDA_VISIBLE_DEVICES=0

# rm /root/autodl-tmp/models/PowerInfer/prosparse-llama-2-7b-gguf/prosparse-llama-2-7b.gguf.generated.gpuidx

# ---------------- Model Paths -----------------
model="/root/autodl-tmp/models/prosparse-llama-2-7b-gguf/prosparse-llama-2-7b.gguf"

prompt="Bubble sort algorithm in python: \n \`\`\`python"
# prompt="# Dijkstra's shortest path algorithm in CPP (4 spaces indentation) + complexity analysis:\n\n"
prompt="Explain the theory of relativity in simple terms for elementary school students (500 words, Please list some vivid and simple examples for kids to understand the complex idea of relativity). \n\n"
# prompt="Explain how the Large Language Model works to elementary school students (500 words). \n\n"
# prompt=" Summarize the main ideas of Jeff Walker's Product Launch Formula into bullet points as it pertains to a growth marketing agency implementing these strategies and tactics for their clients..."


vram_budget=5
threads=12
seed=1234
ctx_size=2048
max_tokens=128

common_opts=(
    --no-mmap
    --vram-budget "$vram_budget"
    -t "$threads"
    -s "$seed"
    -p "$prompt"
    -c "$ctx_size"
    -n "$max_tokens"
    # --temp 0.7
    # --top-k 10
    # --top-p 0.9
    # --min-p 0.05
    --repeat-penalty 1.1
    # for coding
    # --dry-multiplier 0.8  
    # --dry-base 1.75
    # --dry-allowed-length 2  
    # --dry-penalty-last-n -1
)


cli_opts=(
    -m "$model"
)

speculative_opts=(
    -md "$draft_model" -m "$model"
    -ngld 999 -ngl 999 -kvu
    -co --draft-min 3 --draft-max 3
    # -np 3
    # -kvu 
)

usage() {
    echo "usage: $0 [release|debug] [cli|speculative] [nvtx]"
    exit 1
}

mode=${1-}
kind=${2-}
nvtx_flag=${3-}

case "$mode" in
release)
    bin_dir="./build/bin"
    ;;
debug)
    bin_dir="./build/bin"
    ;;
*)
    usage
    ;;
esac

case "$kind" in
cli)
    bin="$bin_dir/main"
    inference_opts=("${cli_opts[@]}" "${common_opts[@]}")
    ;;
speculative)
    bin="$bin_dir/llama-speculative"
    inference_opts=("${speculative_opts[@]}" "${common_opts[@]}")
    ;;
*)
    usage
    ;;
esac

if [[ -z ${nvtx_flag-} ]]; then
    "$bin" "${inference_opts[@]}"
elif [[ $nvtx_flag == "nvtx" ]]; then
    nsys profile --trace=cuda,nvtx "$bin" "${inference_opts[@]}"
else
    usage
fi
