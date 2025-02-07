#!/bin/bash

# Update package list and install required dependencies
echo "[INFO] Updating package list and installing required dependencies..."
apt update -y && apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "[INFO] Adding Docker's official GPG key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | tee /etc/apt/keyrings/docker.asc > /dev/null

echo "[INFO] Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[INFO] Installing Docker..."
apt update -y && apt install -y docker-ce docker-ce-cli containerd.io

echo "[INFO] Enabling and starting Docker service..."
systemctl enable --now docker

echo "[INFO] Installing NVIDIA Container Toolkit..."
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | apt-key add -
curl -s -L https://nvidia.github.io/libnvidia-container/ubuntu20.04/libnvidia-container.list | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
apt update -y && apt install -y nvidia-container-toolkit

echo "[INFO] Configuring Docker to use NVIDIA runtime..."
nvidia-ctk runtime configure --runtime=docker
systemctl restart docker

echo "[SUCCESS] Docker and NVIDIA container runtime installed successfully!"
