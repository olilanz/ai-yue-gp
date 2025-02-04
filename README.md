# ai-YuE
Containerised version of YuE music generator

# commands
docker build -t olilanz/ai-yue-gp .
docker run -it --rm --name ai-yue-gp --shm-size 24g --gpus all -p 7860:7860 --network host -v ./example-data:/data olilanz/ai-yue-gp

# Resources
* For the GPU-Poor: https://github.com/deepbeepmeep/YuEGP
