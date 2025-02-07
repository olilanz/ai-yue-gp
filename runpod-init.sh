#!/bin/bash

set -euo pipefail  # Exit on error, show commands, handle pipes safely

apt update
apt install -y git-lfs
apt install htop nvtop

export YUEGP_PROFILE=1
export YUEGP_CUDA_IDX=0
export YUEGP_ICL_MODE=1

./startup.sh