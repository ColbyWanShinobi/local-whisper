#!/bin/bash

# Setup script for Whisper subtitle generation
echo "Setting up Whisper subtitle generation environment..."

ENV_PATH="./env"
PYTHON_VERSION="3.12"

# Check if conda is available
if ! command -v conda &> /dev/null; then
    echo "Error: Conda is not installed on this system."
    echo "Please install Anaconda or Miniconda first, then run this script again."
    exit 1
fi

# Initialize conda for this shell session
eval "$(conda shell.bash hook)"

# Check for and remove old global environment if it exists
if conda env list | grep -q "^whisper-env "; then
    echo "Found old global 'whisper-env' environment. Removing it..."
    conda env remove -n whisper-env -y
    echo "Old environment removed."
fi

# Check if local environment exists
if [ -d "$ENV_PATH" ]; then
    echo "Local environment '$ENV_PATH' already exists. Checking if updates are needed..."
    
    # Activate existing environment
    conda activate $ENV_PATH
    
    # Check Python version
    CURRENT_PYTHON=$(python --version 2>&1 | grep -oE '[0-9]+\.[0-9]+')
    if [ "$CURRENT_PYTHON" != "$PYTHON_VERSION" ]; then
        echo "Python version mismatch. Current: $CURRENT_PYTHON, Required: $PYTHON_VERSION"
        echo "Updating Python to version $PYTHON_VERSION..."
        conda install python=$PYTHON_VERSION -y
    else
        echo "Python $PYTHON_VERSION is already installed."
    fi
    
    # Check if whisper is installed
    if ! python -c "import whisper" &> /dev/null; then
        echo "Whisper not found. Installing missing packages..."
        NEED_INSTALL=true
    else
        echo "Whisper is already installed. Checking for updates..."
        NEED_INSTALL=false
    fi
    
else
    echo "Creating new local conda environment at '$ENV_PATH' with Python $PYTHON_VERSION..."
    conda create -p $ENV_PATH python=$PYTHON_VERSION -y
    conda activate $ENV_PATH
    NEED_INSTALL=true
fi

# Always upgrade pip
echo "Upgrading pip..."
python -m pip install --upgrade pip

# Install or update packages if needed
if [ "$NEED_INSTALL" = true ]; then
    # Check for GPU support and install appropriate PyTorch version
    if command -v rocm-smi &> /dev/null; then
        echo "ROCm detected. Checking compatibility..."
        # Try to get ROCm version from installed packages (more reliable)
        ROCM_VERSION=$(rpm -qa | grep "^rocm-runtime-" | grep -oE '[0-9]+\.[0-9]+' | head -1 2>/dev/null || dnf list installed | grep rocm-runtime | grep -oE '[0-9]+\.[0-9]+' | head -1 2>/dev/null)
        
        if [ -n "$ROCM_VERSION" ]; then
            echo "ROCm runtime version detected: $ROCM_VERSION"
            
            # Use appropriate PyTorch build based on ROCm version
            if [[ "$ROCM_VERSION" == "6.3"* ]] || [[ "$ROCM_VERSION" == "6.2"* ]]; then
                echo "Installing PyTorch with ROCm 6.2 support..."
                python -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.2
            elif [[ "$ROCM_VERSION" == "6.1"* ]] || [[ "$ROCM_VERSION" == "6.0"* ]]; then
                echo "Installing PyTorch with ROCm 6.1 support..."
                python -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.1
            else
                echo "ROCm version $ROCM_VERSION - using ROCm 5.7 build for compatibility..."
                python -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.7
            fi
        else
            echo "ROCm version detection failed. Installing CPU-only PyTorch for stability..."
            python -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
        fi
    elif nvidia-smi &> /dev/null 2>&1; then
        echo "NVIDIA GPU detected. Installing PyTorch with CUDA support..."
        python -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    else
        echo "No GPU acceleration detected. Installing CPU-only PyTorch..."
        python -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
    fi
    
    echo "Installing requirements from requirements.txt..."
    python -m pip install -r requirements.txt
else
    echo "Updating existing packages..."
    # For updates, be more conservative and use CPU version if there are issues
    echo "Note: If you're experiencing GPU-related errors, consider reinstalling with CPU-only PyTorch"
    echo "Run: pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu"
    python -m pip install --upgrade -r requirements.txt
fi

# Make the generate_subtitles.py script executable
chmod +x generate_subtitles.py

echo ""
echo "Setup complete! To use the whisper subtitle generator:"
echo "1. Activate the local conda environment: conda activate $ENV_PATH"
echo "2. Run the script: ./generate_subtitles.py <audio_file>"
echo ""
echo "Usage example:"
echo "  conda activate $ENV_PATH"
echo "  ./generate_subtitles.py '/path/to/your/video.mp4'"
echo ""
echo "Note: The conda environment is located at $ENV_PATH in this project folder."
