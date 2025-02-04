# Some apps require nvcc (NVIDIA Cuda Compiler). The runtime container from NVIDIA does not include it. 
# Hence we use the development container which includes nvcc.
FROM nvidia/cuda:12.8.0-devel-ubuntu22.04
#FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

# Set system variables
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

ENV CUDA_HOME=/usr/local/cuda
ENV PATH="$CUDA_HOME/bin:$PATH"
ENV LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"

# Install system dependencies required by Pinokio and VNC
RUN apt update
RUN apt install -y \
        git git-lfs curl rsync \
        python3 python3-pip
RUN rm -rf /var/lib/apt/lists/*

#RUN pip install torch torchvision torchaudio

RUN mkdir /app
WORKDIR /app
RUN git clone --depth 1 https://github.com/multimodal-art-projection/YuE.git
RUN pip install -r YuE/requirements.txt --no-build-isolation
RUN pip install flash-attn --no-build-isolation

WORKDIR /app/YuE/inference/
RUN git lfs install
RUN git clone --depth 1 https://huggingface.co/m-a-p/xcodec_mini_infer

WORKDIR /app
COPY startup.sh startup.sh
RUN chmod +x startup.sh

#ENTRYPOINT ["./startup.sh"]