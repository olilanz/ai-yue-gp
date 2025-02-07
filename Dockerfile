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
    git git-lfs \
    python3.10 python3-pip python3.10-venv && \
    python3 -m pip install --upgrade pip && \
    git lfs install && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install PyTorch 2.5.1 (it's not released yet, so we need to use the test wheel)
#RUN pip install --no-cache-dir --index-url https://download.pytorch.org/whl/test/cu124 torch==2.5.1 torchvision torchaudio
# RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

# Copy startup script and make it executable
COPY startup.sh startup.sh

# Expose the required port (make sure it's used in the startup script)
EXPOSE 7860

# Parameters for the startup script
ENV YUEGP_PROFILE=1
ENV YUEGP_CUDA_IDX=0
ENV YUEGP_ICL_MODE=0

# Default command to run the container
CMD ["bash", "./startup.sh"]
