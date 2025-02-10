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

# Package the startup script and the latest version of the YueGP repositories
WORKDIR /app
COPY startup.sh startup.sh

RUN git clone --single-branch --depth=1 https://github.com/olilanz/deepbeepmeep-YuEGP.git YuEGP && \
    tar -czf YuEGP.tar.gz YuEGP && \
    rm -rf YuEGP

RUN git clone --single-branch --depth=1 https://huggingface.co/m-a-p/xcodec_mini_infer.git xcodec_mini_infer && \
    tar -czf xcodec_mini_infer.tar.gz xcodec_mini_infer && \
    rm -rf xcodec_mini_infer

# Expose the required port (make sure it's used in the startup script)
EXPOSE 7860

# Parameters for the startup script
ENV YUEGP_PROFILE=1
ENV YUEGP_CUDA_IDX=0
ENV YUEGP_ENABLE_ICL=0
ENV YUEGP_TRANSFORMER_PATCH=0
ENV YUEGP_AUTO_UPDATE=0

# Default command to run the container
CMD ["bash", "./startup.sh"]
