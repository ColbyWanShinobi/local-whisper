#!/usr/bin/env python

import sys
import os
import subprocess
import argparse
from pathlib import Path

def check_and_activate_environment():
    """Check if we're in the correct conda environment and re-execute if needed."""
    script_dir = Path(__file__).parent.absolute()
    env_path = script_dir / "env"
    
    # Check if the local conda environment exists
    if not env_path.exists():
        print("Error: Local conda environment not found.")
        print("Please run './setup.sh' first to create the environment.")
        sys.exit(1)
    
    # Check if we're already using the correct Python executable
    current_python = Path(sys.executable).resolve()
    expected_python = (env_path / "bin" / "python").resolve()
    
    # If we're not using the conda environment's Python, switch to it
    if current_python != expected_python:
        print(f"Activating conda environment: {env_path}")
        if expected_python.exists():
            # Re-run the script with the conda environment's Python
            result = subprocess.run([str(expected_python)] + sys.argv, 
                                  cwd=str(script_dir))
            sys.exit(result.returncode)
        else:
            print("Error: Conda environment Python not found.")
            print("Please run './setup.sh' to fix the environment.")
            sys.exit(1)

# Check environment before importing whisper
check_and_activate_environment()

# Now we can safely import whisper
try:
    import whisper
except ImportError:
    print("Error: whisper module not found.")
    print("Please run './setup.sh' to install dependencies.")
    sys.exit(1)

def generate_subtitles(audio_file, model_size="base"):
    """
    Generate subtitle file from audio using Whisper.

    Args:
        audio_file (str): Path to the audio file
        model_size (str): Whisper model size (tiny, base, small, medium, large)
    """
    # Check if audio file exists
    if not os.path.exists(audio_file):
        print(f"Error: Audio file '{audio_file}' not found.")
        return False

    # Load Whisper model
    print(f"Loading Whisper model ({model_size})...")
    model = whisper.load_model(model_size)

    # Transcribe audio
    print(f"Transcribing audio file: {audio_file}")
    result = model.transcribe(audio_file)

    # Generate subtitle file path (same directory as audio file)
    audio_path = Path(audio_file)
    subtitle_file = audio_path.parent / f"{audio_path.stem}.srt"

    # Convert to SRT format
    print(f"Generating subtitle file: {subtitle_file}")
    with open(subtitle_file, 'w', encoding='utf-8') as f:
        for i, segment in enumerate(result['segments'], 1):
            start_time = format_time(segment['start'])
            end_time = format_time(segment['end'])
            text = segment['text'].strip()

            f.write(f"{i}\n")
            f.write(f"{start_time} --> {end_time}\n")
            f.write(f"{text}\n\n")

    print(f"Subtitle file created: {subtitle_file}")
    return True

def format_time(seconds):
    """Convert seconds to SRT time format (HH:MM:SS,mmm)"""
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    milliseconds = int((seconds - int(seconds)) * 1000)
    return f"{hours:02d}:{minutes:02d}:{secs:02d},{milliseconds:03d}"

def main():
    parser = argparse.ArgumentParser(description='Generate subtitle files from audio using Whisper')
    parser.add_argument('audio_file', help='Path to the audio file')
    parser.add_argument('--model', '-m', default='base',
                       choices=['tiny', 'base', 'small', 'medium', 'large'],
                       help='Whisper model size (default: base)')

    args = parser.parse_args()

    success = generate_subtitles(args.audio_file, args.model)

    if not success:
        sys.exit(1)

if __name__ == "__main__":
    main()
