# YuE AI Song Composer for the GPU Poor (YuEGP)

Containerised version of the YuEGP music generator. It is based on the YuE project, with deepmeepbeep's optimizations for the GPU-poor. It lets you run a quantized version of the full model on your smaller GPU, e.g. with 12GM of VRAM or even less.

Currently, only NVIDIA CPU's are supported, as the code releis on CUDA for the processing. 

The container is contains all dependencies, i.e. batteries included. Though, during start-up it will acquire the latest model and code from [deepmeepbeep's repo](https://github.com/deepbeepmeep/YuEGP.git) and the latest mini-inference model from [Huggingface](https://huggingface.co/m-a-p/xcodec_mini_infer.git). 

## Disk size and startup time

The container consumes considerable disk space for storage of the AI models. On my setup I observe 7GB for the docker image itsef, plus 27GB for cached data. Building the cache will happen the first time when you start the container. After that any restart should be faster.

It may be advisable to store the cache outside of the conatiner, e.g. by mounting a volume to /workspace.

## Variables

YUEGP_PROFILE: Dependent on your evailable hardware, i.e. VRAM (default: 1).
 - 1: Fastest model, but requires 16GB or more.
 - 2: Undefined/undocumented.
 - 3: Slower, up to 12GB VRAM.
 - 4: Slowest, but works with less than 10GB.

YUEGP_CUDA_IDX: Index of the GPU being used for the inference (default: 0).

YUEGP_ENABLE_ICL: Enable audio input prompt (defailt: 1).
 - 0: Provide input prompt in text form, i.e. describe the style using keywords.
 - 1: Allows you to send one or 2 audio clips as reference for the style.

YUEGP_TRANSFORMER_PATCH: Patch the transformers for additional speed on lower VRAM configurations (default: 0).
 - 0: Run with the original transformers, without deepmeepbeep's optimizations.
 - 1: Apply the patches - may give unintended side effects in certain configurations.

More documentation on the effect of these parameters can be found in the [originator's repo](https://github.com/deepbeepmeep/YuEGP.git).

### Fixing caching issues

As the container updates the models to the latest available version, there is no guarantee that the cached files from previous start-ups are compatible with updated versions. I haven't encountered any issue yet. Though, should you run into issues, just removing the cache folder will caus the startup script to rebuild it from scratch, and thereby fix issues caused by version specific incompatibilities.

## Command reference

### Build the container

Building the container is straight forward. It will build the container, based on NVIDIA's CUDA development container, and add required Python dependencies for bootstrapping YuEGP. 

```bash
docker build -t olilanz/ai-yue-gp .
```

### Running the container

On my setup I am using the following parameters: 

```bash
docker run -it --rm --name ai-yue-gp \
  --shm-size 24g --gpus all \
  -p 7860:7860 \
  -v /mnt/cache/appdata/ai-yue-gp:/workspace \
  -e YUEGP_PROFILE=3 \
  -e YUEGP_ICL_MODE=1 \
  -e YUEGP_TRANSFORMER_PATCH=0 \
  --network host \
  olilanz/ai-yue-gp
```
Note that you need to have an NVIDIA GPU installed, including all dependencies for Docker.

### Environment reference

I am running on a computer with an AMD Ryzen 7 3700X, 128GB Ram, an RTX 3060 with 12GB VRAM. CPU and Ram are plentiful. The GPU is the bottleneck. It runs stable in that configuration. Though, for a song with 6 sections, the inference takes about 90 minutes to complete - resulting in a song of over 2 mins length.

Deepmeepbeep mentions in his documentation that with an RTX4090, he can generate a similar song using profile 1 in just about 4 minutes. So, a good GPU works wonders :-D

## Resources
* For the GPU-Poor: https://github.com/deepbeepmeep/YuEGP

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