MODEL_PATH="/root/autodl-tmp/models/prosparse-llama-2-7b-gguf/prosparse-llama-2-7b.gguf"  
PROMPT="Explain_how_the_Large_Language_Model_works_to_elementary_school_students_(500_words)."
THREADS=6
VRAM_BUDGET=10
# BATCHSIZE=8
LEN=64

for BATCHSIZE in 1 4 8 12 16 20; do
    ./build/bin/batched \
        ${MODEL_PATH} \
        ${PROMPT} \
        ${BATCHSIZE} \
        ${LEN} \
        ${THREADS} \
        ${VRAM_BUDGET}
done