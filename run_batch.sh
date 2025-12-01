MODEL_PATH="/root/autodl-tmp/models/PowerInfer/prosparse-llama-2-7b-gguf/prosparse-llama-2-7b.gguf"  
PROMPT="hello"
THREADS=10
VRAM_BUDGET=10
# BATCHSIZE=8
LEN=64

for BATCHSIZE in 1 4 8 16 32 64; do
    ./build/bin/batched \
        ${MODEL_PATH} \
        ${PROMPT} \
        ${BATCHSIZE} \
        ${LEN} \
        ${THREADS} \
        ${VRAM_BUDGET}
done