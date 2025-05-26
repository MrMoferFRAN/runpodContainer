#!/usr/bin/env python3
"""
Download script for BAGEL-7B-MoT model from Hugging Face
Optimized for RunPod environment
"""

import os
import sys
from pathlib import Path
from huggingface_hub import snapshot_download

def download_bagel_model(model_dir="models/BAGEL-7B-MoT", cache_dir=None):
    """
    Download BAGEL-7B-MoT model from Hugging Face Hub
    
    Args:
        model_dir (str): Directory to save the model
        cache_dir (str): Cache directory for Hugging Face downloads
    """
    
    # Ensure model directory exists
    Path(model_dir).mkdir(parents=True, exist_ok=True)
    
    # Set cache directory
    if cache_dir is None:
        cache_dir = os.path.join(model_dir, "cache")
    
    repo_id = "ByteDance-Seed/BAGEL-7B-MoT"
    
    print(f"Downloading BAGEL-7B-MoT model to {model_dir}")
    print(f"Repository: {repo_id}")
    print(f"Cache directory: {cache_dir}")
    
    try:
        snapshot_download(
            repo_id=repo_id,
            local_dir=model_dir,
            cache_dir=cache_dir,
            local_dir_use_symlinks=False,
            resume_download=True,
            allow_patterns=[
                "*.json", 
                "*.safetensors", 
                "*.bin", 
                "*.py", 
                "*.md", 
                "*.txt"
            ],
        )
        print(f"✅ Model downloaded successfully to {model_dir}")
        
        # Verify essential files exist
        essential_files = [
            "llm_config.json",
            "vit_config.json", 
            "ae.safetensors",
            "ema.safetensors"
        ]
        
        missing_files = []
        for file in essential_files:
            if not os.path.exists(os.path.join(model_dir, file)):
                missing_files.append(file)
        
        if missing_files:
            print(f"⚠️  Warning: Missing essential files: {missing_files}")
            return False
        else:
            print("✅ All essential model files verified")
            return True
            
    except Exception as e:
        print(f"❌ Error downloading model: {e}")
        return False

def main():
    """Main function"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Download BAGEL-7B-MoT model")
    parser.add_argument(
        "--model_dir", 
        type=str, 
        default="models/BAGEL-7B-MoT",
        help="Directory to save the model (default: models/BAGEL-7B-MoT)"
    )
    parser.add_argument(
        "--cache_dir",
        type=str,
        default=None,
        help="Cache directory for Hugging Face downloads"
    )
    
    args = parser.parse_args()
    
    success = download_bagel_model(args.model_dir, args.cache_dir)
    
    if success:
        print("\n🎉 Model download completed successfully!")
        print(f"You can now run the app with: python app.py --model_path {args.model_dir}")
    else:
        print("\n❌ Model download failed!")
        sys.exit(1)

if __name__ == "__main__":
    main() 