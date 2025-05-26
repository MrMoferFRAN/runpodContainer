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

# Install Python dependencies
echo "📚 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Install PyTorch with CUDA 12.8 support
echo "🔥 Installing PyTorch 2.7.0 with CUDA 12.8..."
pip install torch==2.7.0+cu128 torchvision==0.22.0+cu128 --index-url https://download.pytorch.org/whl/cu128

# Install flash-attention
echo "⚡ Installing flash-attention..."
pip install flash-attn==2.7.4.post1 --no-build-isolation

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p models/BAGEL-7B-MoT offload cache

# Download model
echo "⬇️  Downloading BAGEL-7B-MoT model..."
python download_model.py --model_dir models/BAGEL-7B-MoT

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
echo "   python app.py --server_name 0.0.0.0 --server_port 7860 --share"
echo ""
echo "🌐 The app will be available at:"
echo "   - Local: http://localhost:7860"
echo "   - Public: Check the Gradio output for the public URL"
echo ""
echo "💡 Tips for RunPod:"
echo "   - Use port 7860 for Gradio interface"
echo "   - The --share flag creates a public URL"
echo "   - Model files are in models/BAGEL-7B-MoT/"
echo "   - Offload directory is used for memory optimization" 