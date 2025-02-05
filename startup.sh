#!/bin/bash

export HF_HOME=/data/cache/huggingface
export TORCH_HOME=/data/cache/torch
export INFERENCE_HOME=/data/cache/YuEGP

export SERVER_PORT=7860
export SERVER_NAME=0.0.0.0

echo "🔧 Starting YuEGP container startup script..."
set -e  # Exit on error

echo "📂 Setting up cache in /data/cache..."
mkdir -p ${HF_HOME}
mkdir -p ${TORCH_HOME}
mkdir -p ${INFERENCE_HOME}
mkdir -p /data/input
mkdir -p /data/output

rsync -a ./YuEGP/inference/* ${INFERENCE_HOME}/
cd ${INFERENCE_HOME}
echo "✅ Cache is ready."

echo "🚀 Initializing the environment and starting the YuEGP service..."
python3 gradio_server.py --profile 3 --compile \
    --cuda_idx 0 \
    --stage1_model m-a-p/YuE-s1-7B-anneal-en-cot \
    --stage2_model m-a-p/YuE-s2-1B-general \
    --genre_txt /data/input/genre.txt \
    --lyrics_txt /data/input/lyrics.txt \
    --run_n_segments 4 \
    --stage2_batch_size 4 \
    --output_dir /data/output \
    --max_new_tokens 3000 
echo "❌ The YuEGP service has terminated."

#python3 infer.py \
#    --cuda_idx 0 \
#    --stage1_model m-a-p/YuE-s1-7B-anneal-en-cot \
#    --stage2_model m-a-p/YuE-s2-1B-general \
#    --genre_txt /data/input/genre.txt \
#    --lyrics_txt /data/input/lyrics.txt \
#    --run_n_segments 2 \
#    --stage2_batch_size 4 \
#    --output_dir /data/output \
#    --max_new_tokens 3000 \
#    --seed 42
#echo "✅ YuE inference completed successfully."