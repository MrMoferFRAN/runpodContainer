# RunPod optimized Dockerfile for BAGEL-7B-MoT
FROM pytorch/pytorch:2.7.0-cuda12.1-cudnn9-devel

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV CUDA_HOME=/usr/local/cuda
ENV PATH="$CUDA_HOME/bin:$PATH"
ENV LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy requirements first for better Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install specific PyTorch version with CUDA 12.8 support
RUN pip install --no-cache-dir torch==2.7.0+cu128 torchvision==0.22.0+cu128 --index-url https://download.pytorch.org/whl/cu128

# Install flash-attention from source for better compatibility
RUN pip install --no-cache-dir flash-attn==2.7.4.post1 --no-build-isolation

# Copy the application code
COPY . .

# Create directories for model storage and offloading
RUN mkdir -p models/BAGEL-7B-MoT offload cache

# Set permissions
RUN chmod +x app.py

# Expose Gradio port
EXPOSE 7860

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:7860/ || exit 1

# Default command
CMD ["python", "app.py", "--server_name", "0.0.0.0", "--server_port", "7860", "--share"] 