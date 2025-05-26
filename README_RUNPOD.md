# BAGEL-7B-MoT for RunPod

This is an optimized fork of [BAGEL-7B-MoT](https://github.com/bytedance-seed/BAGEL) specifically configured for RunPod with NVIDIA A100 PCIe GPUs.

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)
```bash
# Run the automated setup script
chmod +x runpod_setup.sh
./runpod_setup.sh

# Start the Gradio app
python app.py --server_name 0.0.0.0 --server_port 7860 --share
```

### Option 2: Manual Setup
```bash
# Install dependencies
pip install -r requirements.txt

# Download model
python download_model.py

# Start the app
python app.py --server_name 0.0.0.0 --server_port 7860 --share
```

### Option 3: Docker (Advanced)
```bash
# Build the Docker image
docker build -t bagel-runpod .

# Run the container
docker run -it --gpus all -p 7860:7860 bagel-runpod
```

## 🔧 Key Modifications from Original

### Dependencies Updated
- **PyTorch**: Upgraded to `2.7.0+cu128` for better CUDA 12.x compatibility
- **Flash Attention**: Updated to `2.7.4.post1` for stability
- **Decord**: Relaxed version constraint from `==0.6.0` to `>=0.7.0` to avoid CUDA compilation issues
- **Gradio**: Added explicit dependency for web interface

### RunPod Optimizations
- Pre-configured for A100 PCIe GPUs
- Automatic device mapping with memory optimization
- Offloading support for large models
- Public URL sharing enabled by default
- Health checks and monitoring

## 📊 GPU Memory Requirements

| Model Component | GPU Memory | Notes |
|----------------|------------|-------|
| BAGEL-7B-MoT   | ~14-16 GB  | With offloading enabled |
| Flash Attention | ~2-4 GB   | During inference |
| **Total**      | **~18-20 GB** | Fits comfortably on A100 40GB |

## 🎯 Features

### Text-to-Image Generation
- High-quality image synthesis from text prompts
- Multiple aspect ratios (1:1, 4:3, 3:4, 16:9, 9:16)
- Advanced CFG controls and sampling options
- Optional "thinking" mode for chain-of-thought generation

### Image Understanding
- Visual question answering
- Image description and analysis
- Context-aware responses

### Image Editing
- Text-guided image modifications
- Inpainting and outpainting capabilities
- Fine-grained control over editing strength

## 🛠 Configuration

### Environment Variables
```bash
# Optional: Set custom model path
export MODEL_PATH="/workspace/models/BAGEL-7B-MoT"

# Optional: Enable debug mode
export BAGEL_DEBUG=1

# Optional: Custom offload directory
export OFFLOAD_DIR="/workspace/offload"
```

### App Arguments
```bash
python app.py \
  --server_name 0.0.0.0 \        # Bind to all interfaces
  --server_port 7860 \           # Gradio port
  --share \                      # Create public URL
  --model_path models/BAGEL-7B-MoT  # Model directory
```

## 🔍 Troubleshooting

### Common Issues

#### Flash Attention Installation
```bash
# If flash-attn fails to install
pip install flash-attn==2.7.4.post1 --no-build-isolation --force-reinstall
```

#### CUDA Out of Memory
```bash
# Enable gradient checkpointing (edit app.py)
# Or use smaller batch sizes
# The app includes automatic offloading
```

#### Model Download Issues
```bash
# Re-download model with verification
python download_model.py --model_dir models/BAGEL-7B-MoT
```

### Performance Tips

1. **Memory Optimization**
   - The app automatically uses device mapping for multi-GPU setups
   - Offloading is enabled by default to save GPU memory
   - Use `torch.cuda.empty_cache()` between generations if needed

2. **Speed Optimization**
   - Keep models on GPU when possible
   - Use appropriate precision (bfloat16 by default)
   - Consider batch processing for multiple images

3. **RunPod Specific**
   - Use persistent storage for models to avoid re-downloading
   - Monitor GPU memory with `nvidia-smi`
   - Use the public URL for remote access

## 📝 API Usage

### Programmatic Access
```python
from inferencer import InterleaveInferencer

# Initialize (after model loading)
result = inferencer(
    text="A beautiful sunset over mountains",
    think=False,  # Enable for chain-of-thought
    cfg_text_scale=4.0,
    num_timesteps=50,
    image_shapes=(1024, 1024)
)

image = result["image"]
```

### REST API
The Gradio interface automatically provides a REST API at `/api/predict/`

## 🏷 Model Information

- **Base Model**: BAGEL-7B-MoT (ByteDance-Seed)
- **Model Size**: ~7B parameters
- **License**: See original repository license
- **Paper**: [BAGEL: Bootstrapping Generators by Guiding Language Models with Language Models](https://arxiv.org/abs/XXXX.XXXXX)

## 🤝 Contributing

This fork focuses on RunPod compatibility. For core model improvements, please contribute to the original repository.

## 📄 License

This project maintains the same license as the original BAGEL repository.

## 🙏 Acknowledgments

- Original BAGEL team at ByteDance
- RunPod for providing excellent GPU infrastructure
- The open-source community for flash-attention and other dependencies 