#!/bin/bash

# Setup script for Whisper subtitle generation
echo "Setting up Whisper subtitle generation environment..."

# Check if conda is available
if ! command -v conda &> /dev/null; then
    echo "Error: Conda is not installed on this system."
    echo "Please install Anaconda or Miniconda first, then run this script again."
    exit 1
fi

# Create conda environment with Python 3.12
conda create -n whisper-env python=3.12 -y

# Activate conda environment
source $(conda info --base)/etc/profile.d/conda.sh
conda activate whisper-env

# Upgrade pip
pip install --upgrade pip

# Install PyTorch with ROCm support (matching your Dockerfile)
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.2.4

# Install other requirements
pip3 install -r requirements.txt

echo "Setup complete! To use the whisper subtitle generator:"
echo "1. Activate the conda environment: conda activate whisper-env"
echo "2. Run the script: python generate_subtitles.py <audio_file>"