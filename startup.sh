#!/bin/bash

#echo "🔧 Starting Pinokio container startup script..."
#echo "🔄 Starting system D-Bus..."
#echo "✅ System D-Bus started."
#echo "🚀 Starting Pinokio (container port 42000)..."
#echo "❌ Pinokio has stopped running. Check logs for details."

echo "🔧 Starting YuE container startup script..."

#/opt/nvidia/nvidia_entrypoint.sh 

export HF_HOME=/data/cache/huggingface
export TORCH_HOME=/data/cache/torch

mkdir -p ${HF_HOME}
mkdir -p ${TORCH_HOME}
mkdir -p /data/input
mkdir -p /data/output

#rsync -av ./YuE/inference /data/cache


# This is the CoT mode.
#cd /data/cache/
cd ./YuE/inference
python3 infer.py \
    --cuda_idx 0 \
    --stage1_model m-a-p/YuE-s1-7B-anneal-en-cot \
    --stage2_model m-a-p/YuE-s2-1B-general \
    --genre_txt /data/input/genre.txt \
    --lyrics_txt /data/input/lyrics.txt \
    --run_n_segments 2 \
    --stage2_batch_size 4 \
    --output_dir /data/output \
    --max_new_tokens 3000 \
    --seed 42
