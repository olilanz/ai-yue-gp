# YuE AI Song Composer for the GPU Poor (YuEGP)

Containerized version of the YuEGP music generator. It is based on the YuE project, with deepmeepbeep's optimizations for GPU-poor environments. It allows you to run a quantized version of the full model on smaller GPUs, such as those with 12GB of VRAM or less.

Currently, only NVIDIA CPUs are supported, as the code relies on CUDA for processing.

The container includes all dependencies, meaning it is "batteries included." However, during startup, it will acquire the latest model and code from [deepmeepbeep's repo](https://github.com/deepbeepmeep/YuEGP) and the latest xcodec-mini-inference model from [Huggingface](https://huggingface.co/m-a-p/xcodec_mini_infer).

## Disk Size and Startup Time
The container consumes considerable disk space for storing the AI models. On my setup, I observe 7GB for the Docker image itself, plus 27GB for cached data. Building the cache occurs the first time you start the container, which can easily take 20 minutes or more. After that, any restart should be faster.

It may be advisable to store the cache outside of the container, for example, by mounting a volume to /workspace.

## Variables
YUEGP_PROFILE: Dependent on your available hardware, specifically VRAM (default: 1).
 - 1: Fastest model, but requires 16GB or more.
 - 2: Undefined/undocumented.
 - 3: Slower, up to 12GB VRAM.
 - 4: Slowest, but works with less than 10GB.

YUEGP_CUDA_IDX: Index of the GPU being used for the inference (default: 0).

YUEGP_ENABLE_ICL: Enable audio input prompt (default: 1).
 - 0: Provide input prompt in text form, i.e. describe the style using keywords.
 - 1: Allows you to send one or two audio clips as reference for the style.

YUEGP_TRANSFORMER_PATCH: Patch the transformers for additional speed on lower VRAM configurations (default: 0).
 - 0: Run with the original transformers, without deepmeepbeep's optimizations.
 - 1: Apply the patches - may give unintended side effects in certain configurations.

YUEGP_AUTO_UPDATE: Automatically updates the models and inference scripts to the latest version upon container startup (default: 0).
 - 0: Don't update automatically. Use the scripts that are bundled.
 - 1: Update and use the latest features/models, but also accept that this may bring breaking changes.

More documentation on the effects of these parameters can be found in the [originator's repo](https://github.com/deepbeepmeep/YuEGP).

### Fixing Caching Issues
As the container updates the models to the latest available version, there is no guarantee that the cached files from previous start-ups are compatible with updated versions. I haven't encountered any issues yet. However, should you run into issues, just removing the cache folder will cause the startup script to rebuild the cache from scratch, thereby fixing any inconsistencies.

## Command Reference

### Build the Container
Building the container is straightforward. It will build the container based on NVIDIA's CUDA development container and add required Python dependencies for bootstrapping YuEGP.
```bash
docker build -t olilanz/ai-yue-gp .
```

### Running the Container
On my setup, I am using the following parameters:
```bash
docker run -it --rm --name ai-yue-gp \
  --shm-size 24g --gpus all \
  -p 7860:7860 \
  -v /mnt/cache/appdata/ai-yue-gp:/workspace \
  -e YUEGP_PROFILE=3 \
  -e YUEGP_ENABLE_ICL=0 \
  -e YUEGP_TRANSFORMER_PATCH=0 \
  -e YUEGP_AUTO_UPDATE=1 \
  olilanz/ai-yue-gp
```
Note that you need to have an NVIDIA GPU installed, including all dependencies for Docker.

### Environment Reference
I am running on a computer with an AMD Ryzen 7 3700X, 128GB RAM, an RTX 3060 with 12GB VRAM. CPU and RAM are plentiful. The GPU is the bottleneck. It runs stable in that configuration. For a song with 6 sections, the inference takes about 90 minutes to complete, resulting in a song of over 2 minutes in length.

Deepmeepbeep mentions in his documentation that with an RTX 4090, he can generate a similar song using profile 1 in just about 4 minutes. So, a good GPU should work wonders.

## Resources
* For the GPU-Poor: https://github.com/deepbeepmeep/YuEGP
* For the non-GPU-Poor: https://github.com/multimodal-art-projection/YuE

## Alternative
If you have plenty of VRAM, there is another container available, which runs the full model, i.e. without deepmeepbeep's optimizations. You may want to check this out.
```bash
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
```
This hasn't worked on my hardware though. It is just for reference.