# Web-based UI for Stable Diffusion by Zuiho

## Forked from [stable-diffusion-webui](https://github.com/sd-webui/stable-diffusion-webui)

There are mainly changed points:

1. Use virtual environment to replace Anaconda. The default CUDA version of PyTorch is 11.6 (compatible with 11.3 to 11.7) and you could modify it in the line 117 of `webui.sh`.
2. Fix gpu switching bugs. Now you could choose other gpus in your machine freedomly by change the environment variable of CUDA_VISIBLE_DEVICES in the line 123 of `webui.sh`.
3. Only optimize for streamlit. The default listening address is set to `0.0.0.0` and default port is set to 18888, you could modify them in the line 123 of `webui.sh`.
4. Default configurations are optimized for max efficiency (12GB to 40GB VRAM usage for the model without pruned).


## BibTeX

```
@misc{rombach2021highresolution,
      title={High-Resolution Image Synthesis with Latent Diffusion Models}, 
      author={Robin Rombach and Andreas Blattmann and Dominik Lorenz and Patrick Esser and Björn Ommer},
      year={2021},
      eprint={2112.10752},
      archivePrefix={arXiv},
      primaryClass={cs.CV}
}

```
