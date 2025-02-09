#!/bin/bash

set -euo pipefail  # Exit on error, show commands, handle pipes safely

export SERVER_PORT=7860
export SERVER_NAME=0.0.0.0

CACHE_HOME="/data/cache"
export HF_HOME="${CACHE_HOME}/huggingface"
export TORCH_HOME="${CACHE_HOME}/torch"

echo "🔧 Starting YuEGP container startup script..."

echo "📂 Setting up cache directories..."
mkdir -p "${CACHE_HOME}" "${HF_HOME}" "${TORCH_HOME}" /data/output

# Clone or update YuEGP
YUEGP_HOME="${CACHE_HOME}/YuEGP"
YUEGP_REPO_URL="https://github.com/deepbeepmeep/YuEGP.git"

if [ ! -d "$YUEGP_HOME" ]; then
    echo "📥 Cloning YuEGP repository..."
    git clone --depth 1 "$YUEGP_REPO_URL" "$YUEGP_HOME"
else
    echo "🔄 Updating YuEGP repository..."
    cd "$YUEGP_HOME" || exit 1
    git reset --hard
    git pull origin main
fi

# Clone or update xcodec_mini_infer
XCODEC_HOME="${CACHE_HOME}/xcodec_mini_infer"
XCODEC_REPO_URL="https://huggingface.co/m-a-p/xcodec_mini_infer.git"

if [ ! -d "$XCODEC_HOME" ]; then
    echo "📥 Cloning xcodec_mini_infer repository..."
    git clone --depth 1 "$XCODEC_REPO_URL" "$XCODEC_HOME"
else
    echo "🔄 Updating xcodec_mini_infer repository..."
    cd "$XCODEC_HOME" || exit 1
    git reset --hard
    git pull origin main
fi

# Link xcodec_mini_infer
INFERENCE_HOME="${YUEGP_HOME}/inference"
ln -sfn "${XCODEC_HOME}" "${INFERENCE_HOME}/xcodec_mini_infer"

# Install dependencies
VENV_HOME="${CACHE_HOME}/venv"
echo "📦 Installing dependencies..."
if [ ! -d "$VENV_HOME" ]; then
    python3 -m venv "$VENV_HOME"
fi

source "${VENV_HOME}/bin/activate"
pip install --no-cache-dir --upgrade pip
pip install torch==2.5.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/test/cu124
pip install --no-cache-dir --root-user-action=ignore -r "$YUEGP_HOME/requirements.txt"
pip install --no-cache-dir wheel
pip install --no-cache-dir --root-user-action=ignore flash-attn --no-build-isolation

# Set up arguments
YUEGP_PROFILE=${YUEGP_PROFILE:-1}
YUEGP_CUDA_IDX=${YUEGP_CUDA_IDX:-0}
YUEGP_ENABLE_ICL=${YUEGP_ENABLE_ICL:-1}
YUEGP_TRANSFORMER_PATCH=${YUEGP_TRANSFORMER_PATCH:-0}
YUEGP_STAGE_2_BATCH_SIZE=${YUEGP_STAGE_2_BATCH_SIZE:-2}

# Applying transformer patch as per YuEGP documentation
if [[ "$YUEGP_TRANSFORMER_PATCH" == "1" ]]; then
    echo "🔨 Applying transformer patch..."
    ln -sfn "${VENV_HOME}" "${YUEGP_HOME}/venv"
    cd "$YUEGP_HOME" || exit 1
    source patchtransformers.sh
fi

# Build command line argds and start the service
echo "🚀 Starting YuEGP service..."
YUEGP_ARGS=" \
    --profile ${YUEGP_PROFILE} \
    --cuda_idx ${YUEGP_CUDA_IDX} \
    --stage2_batch_size ${YUEGP_STAGE_2_BATCH_SIZE} \
    --output_dir /data/output \
    --keep_intermediate"

if [[ "$YUEGP_ENABLE_ICL" == "1" ]]; then
    echo "🔨 Enabling audio prompt..."
    YUEGP_ARGS="$YUEGP_ARGS --icl"
fi

cd "$INFERENCE_HOME" || exit 1
python3 gradio_server.py ${YUEGP_ARGS}
echo "❌ The YuEGP service has terminated."

#python3 infer.py \
#    --cuda_idx 0 \
#    --stage2_batch_size 4 \
#    --output_dir /data/output \
#    --max_new_tokens 3000 \
#    --seed 42
#echo "✅ YuE inference completed successfully."