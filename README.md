# Local Whisper Subtitle Generator

A Python script that uses OpenAI's Whisper to generate subtitle files from audio/video files. The script automatically manages its conda environment and supports GPU acceleration on AMD and NVIDIA systems.

## Features

- **Automatic Environment Management**: Creates and activates conda environment automatically
- **GPU Acceleration**: Supports AMD ROCm and NVIDIA CUDA
- **Progress Tracking**: Shows real-time transcription progress
- **Multiple Model Sizes**: Choose from tiny to large models for speed vs accuracy
- **Language Support**: Default English with option to specify other languages
- **SRT Output**: Generates standard subtitle files

## Setup

1. **Run the setup script** (only needed once):
   ```bash
   ./setup.sh
   ```
   This will:
   - Create a local conda environment in `./env`
   - Install Python 3.12
   - Install PyTorch with appropriate GPU support (ROCm/CUDA/CPU)
   - Install Whisper and all dependencies

2. **For AMD 6000 series GPUs** (if needed):
   If you encounter GPU compatibility issues, you may need to set:
   ```bash
   export HSA_OVERRIDE_GFX_VERSION=10.3.0
   ```

## Usage

### Basic Usage
```bash
# Generate subtitles with default settings (English, base model)
./generate_subtitles.py /path/to/your/video.mp4
```

### Advanced Options
```bash
# Specify model size and language
./generate_subtitles.py --model large --language es /path/to/video.mp4

# Use short form options
./generate_subtitles.py -m small -l fr /path/to/video.mp4

# Auto-detect language
./generate_subtitles.py --language auto /path/to/video.mp4
```

### Command Line Options

- `--model` / `-m`: Model size (default: `base`)
  - `tiny` - Fastest, least accurate
  - `base` - Good balance (default)
  - `small` - Better accuracy
  - `medium` - Higher accuracy
  - `large` - Best accuracy, slowest

- `--language` / `-l`: Language code (default: `en`)
  - `en` - English (default)
  - `es` - Spanish
  - `fr` - French
  - `de` - German
  - `it` - Italian
  - `pt` - Portuguese
  - `ru` - Russian
  - `ja` - Japanese
  - `zh` - Chinese
  - `ko` - Korean
  - `auto` - Automatic detection

### Help
```bash
./generate_subtitles.py --help
```

## Output

The script generates a `.srt` subtitle file in the same directory as your input file:
- Input: `/path/to/video.mp4`
- Output: `/path/to/video.srt`

## System Requirements

- **OS**: Linux (tested on Fedora)
- **Python**: 3.12 (automatically installed via conda)
- **GPU**: Optional but recommended
  - AMD: ROCm 6.x compatible GPUs
  - NVIDIA: CUDA compatible GPUs
- **Memory**: Varies by model size (base model ~1GB)

## Troubleshooting

### Re-run Setup
If you encounter issues, re-run the setup script:
```bash
./setup.sh
```

### GPU Issues
If you have GPU-related errors, the script will automatically fall back to CPU processing, or you can force CPU-only PyTorch:
```bash
conda activate ./env
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu --force-reinstall
```

### Environment Issues
The script automatically detects and activates the correct conda environment. No manual activation needed.

## Examples

```bash
# Movie subtitle generation
./generate_subtitles.py "/home/user/Movies/Movie.mp4"

# Podcast with small model for speed
./generate_subtitles.py -m tiny "/home/user/Podcasts/episode.mp3"

# Foreign language video with large model
./generate_subtitles.py -m large -l ja "/home/user/Videos/anime.mkv"

# Let Whisper detect the language automatically
./generate_subtitles.py -l auto "/home/user/Videos/multilingual.mp4"
```
