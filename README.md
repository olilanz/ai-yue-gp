# ai-YuE
Containerised version of YuE music generator

# commands
docker build -t olilanz/ai-yue-gp .
docker run -it --rm --name ai-yue-gp --shm-size 24g --gpus all -p 7860:7860  -e YUEGP_PROFILE=3 -e YUEGP_ICL_MODE=1 --network host -v /mnt/cache/appdata/ai-yue-gp:/data olilanz/ai-yue-gp

# Resources
* For the GPU-Poor: https://github.com/deepbeepmeep/YuEGP

# Alternative

docker run --gpus all -it \
  --name YuE \
  --rm \
  -v /mnt/models:/mnt/cache/appdata/yue-interface/models \
  -v /mnt/outputs:/mnt/cache/appdata/yue-interface/outputs \
  --shm-size 24g \
  --network host \
  -p 7860:7860 \
  -p 8888:8888 \
  -e DOWNLOAD_MODELS=YuE-s2-1B-general,YuE-s1-7B-anneal-en-cot \
  alissonpereiraanjos/yue-interface:latest

# runpod.io

apt update
apt install git git-lfs
