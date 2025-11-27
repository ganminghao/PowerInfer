# nsys profile --trace=cuda,nvtx \
./build/bin/main  \
-m /root/autodl-tmp/models/PowerInfer/prosparse-llama-2-7b-gguf/prosparse-llama-2-7b.gguf  \
-n 128 \
-t 12 \
-p "Explain how Large Language Model(LLM) works to elementary school students:" \
--vram-budget 7 \
