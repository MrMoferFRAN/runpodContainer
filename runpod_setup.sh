#!/bin/bash

# BAGEL RunPod Setup Script
# This script sets up the BAGEL environment on RunPod with A100 GPU

set -e  # Exit on error

echo "🚀 Starting BAGEL RunPod Setup..."

# Check if we're running on RunPod
if [ ! -z "$RUNPOD_POD_ID" ]; then
    echo "✅ Running on RunPod Pod: $RUNPOD_POD_ID"
else
    echo "⚠️  Not running on RunPod, but continuing..."
fi

# Check GPU availability
if command -v nvidia-smi &> /dev/null; then
    echo "🎮 GPU Information:"
    nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader,nounits
else
    echo "❌ No NVIDIA GPU detected!"
    exit 1
fi

# Check CUDA version
if command -v nvcc &> /dev/null; then
    echo "🔧 CUDA Version:"
    nvcc --version | grep "release"
else
    echo "⚠️  NVCC not found, but continuing..."
fi

# Update system packages
echo "📦 Updating system packages..."
apt-get update -qq && apt-get install -y -qq git wget curl ffmpeg

# Check Python version
echo "🐍 Python version:"
python --version

# Clean previous installation attempts (optional)
echo "🧹 Cleaning previous installation attempts..."
pip uninstall -y decord accelerate || true

# Install Python dependencies
echo "📚 Installing Python dependencies..."
pip install --upgrade pip

# Install PyTorch with CUDA 12.1 support (using --extra-index-url instead of --index-url)
echo "🔥 Installing PyTorch 2.5.1 with CUDA 12.1..."
pip install --upgrade --no-cache-dir \
  --extra-index-url https://download.pytorch.org/whl/cu121 \
  torch==2.5.1+cu121 torchvision==0.20.1+cu121

# Install specific Python dependencies from fixer.txt (excluding torch/torchvision)
echo "📚 Installing specific Python dependencies..."
pip install --no-cache-dir \
  transformers==4.49.0 accelerate==0.34.0 einops==0.8.1 safetensors==0.4.5 \
  numpy==1.24.4 scipy==1.10.1 matplotlib==3.7.0 pyyaml requests==2.32.3

# Install decord (CPU version)
echo "🎬 Installing decord..."
pip install --no-cache-dir decord==0.6.0

# Install additional requirements from requirements.txt (excluding conflicting packages)
echo "📚 Installing additional requirements..."
pip install --no-cache-dir \
  huggingface_hub==0.29.1 opencv_python==4.7.0.72 pyarrow==11.0.0 \
  sentencepiece==0.1.99 wandb gradio==4.44.1 gradio_client

# Install flash-attention for A100 performance optimization
echo "⚡ Installing flash-attention..."
pip install --no-build-isolation flash_attn==2.7.4.post1

# Fix pydantic version conflicts
echo "🔧 Fixing pydantic version conflicts..."
pip uninstall -y pydantic pydantic_core || true
pip install --no-cache-dir "pydantic==2.10.6"

# Create necessary directories (using /workspace path for RunPod)
echo "📁 Creating directories..."
mkdir -p /workspace/offload /workspace/cache

# Check if model exists (assuming it's already downloaded)
echo "🔍 Checking if BAGEL-7B-MoT model exists..."
if [ -d "/workspace/models/BAGEL-7B-MoT" ] && [ "$(ls -A /workspace/models/BAGEL-7B-MoT)" ]; then
    echo "✅ Model found at /workspace/models/BAGEL-7B-MoT"
else
    echo "⚠️  Model not found at /workspace/models/BAGEL-7B-MoT"
    echo "   Please ensure the model is downloaded before running the app"
fi

# Verify installation
echo "🔍 Verifying installation..."
python -c "
import torch
print(f'PyTorch version: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'CUDA version: {torch.version.cuda}')
    print(f'GPU count: {torch.cuda.device_count()}')
    for i in range(torch.cuda.device_count()):
        print(f'GPU {i}: {torch.cuda.get_device_name(i)}')

try:
    import flash_attn
    print(f'Flash Attention version: {flash_attn.__version__}')
except ImportError:
    print('❌ Flash Attention not installed correctly')
    exit(1)

try:
    from modeling.bagel import Bagel
    print('✅ BAGEL model imports work')
except ImportError as e:
    print(f'❌ BAGEL model import failed: {e}')
    exit(1)
"

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "🚀 To start BAGEL:"
echo "   python app.py --server_name 0.0.0.0 --server_port 7860 --model_path /workspace/models/BAGEL-7B-MoT"
echo ""