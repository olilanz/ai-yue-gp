# Use the development container, which includes necessary CUDA libraries and the CUDA Compiler.
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

# Set system variables
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

ENV CUDA_HOME=/usr/local/cuda
ENV PATH="$CUDA_HOME/bin:$PATH"
ENV LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"

# Install system dependencies in a single step to reduce layer size
RUN apt update && apt install -y \
    git git-lfs rsync \
    python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Create application directory
WORKDIR /app

# Install Git Large File Storage and pull the project assets
RUN git lfs install && \
    git clone --depth 1 https://github.com/deepbeepmeep/YuEGP/ /app/YuEGP && \
    git clone --depth 1 https://huggingface.co/m-a-p/xcodec_mini_infer /app/YuEGP/inference/xcodec_mini_infer

# Install PyTorch (stable version for CUDA 12.4)
RUN pip install torch==2.5.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

# Install YuEGP dependencies
RUN pip install --no-cache-dir -r /app/YuEGP/requirements.txt

# Install FlashAttention without isolated build
RUN pip install --no-cache-dir flash-attn --no-build-isolation

# Return to app directory
WORKDIR /app

# Copy startup script and make it executable
COPY startup.sh startup.sh
RUN chmod +x startup.sh

# Expose the required port (make sure it's used in the startup script)
EXPOSE 7860

# Default command to run the container
CMD ["./startup.sh"]