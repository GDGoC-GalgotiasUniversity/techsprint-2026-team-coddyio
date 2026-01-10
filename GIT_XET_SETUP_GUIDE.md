# Git-Xet Setup Guide

**Date**: January 10, 2026  
**Status**: ✅ Model already downloaded - git-xet optional for future updates

## What is Git-Xet?

Git-Xet is a Git extension for handling large files efficiently. It's an alternative to Git LFS (Large File Storage) that provides better performance for large model files.

## Current Status

✅ **Plant Disease Detection model already downloaded** (200.66 MB)  
✅ **No need for git-xet right now** - model is ready to use  
⏳ **git-xet useful for future updates** - if model is updated on Hugging Face

## Installation Options

### Option 1: Using Scoop (Recommended for Windows)

```powershell
# Install Scoop if not already installed
iwr -useb get.scoop.sh | iex

# Install git-xet
scoop install git-xet

# Verify installation
git xet --version
```

### Option 2: Manual Download

```powershell
# Download git-xet executable
$url = "https://github.com/xetdata/xet-core/releases/download/v0.15.0/git-xet-windows-x86_64.exe"
$output = "C:\Program Files\Git\usr\local\bin\git-xet.exe"

# Create directory if needed
New-Item -ItemType Directory -Path "C:\Program Files\Git\usr\local\bin" -Force

# Download
Invoke-WebRequest -Uri $url -OutFile $output

# Verify
& $output --version
```

### Option 3: Using Chocolatey

```powershell
# Install via Chocolatey (if available)
choco install git-xet

# Verify
git xet --version
```

## Setup Git-Xet

### 1. Initialize Git-Xet

```bash
git xet install
```

### 2. Clone Repository with Git-Xet

```bash
# Clone with large file support
git clone https://huggingface.co/gopalkumr/Plant-disease-detection

# Or clone without downloading large files (just pointers)
GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/gopalkumr/Plant-disease-detection
```

### 3. Configure Git-Xet

```bash
# Set up git-xet for your repository
cd plant-disease-detection
git xet init

# Configure for large files
git config xet.maxfilesize 100m
```

## Current Model Status

### Downloaded Files

```
plant-disease-model/
├── plant_disease_model_1_latest.pt (200.66 MB) ✅
├── CNN.py ✅
├── inference.py ✅
├── disease_info.csv ✅
├── supplement_info.csv ✅
├── app.py ✅
├── requirements.txt ✅
└── ... (other files)
```

### Verification

```bash
# Check model file
ls -lh plant-disease-model/plant_disease_model_1_latest.pt

# Verify file integrity
# (Model should be ~200MB)
```

## Using the Model Without Git-Xet

Since the model is already downloaded, you can use it immediately:

### 1. Python Service

```bash
python server/plant_disease_service.py path/to/image.jpg
```

### 2. Node.js API

```bash
npm start
# Then POST to /api/plant-disease/detect
```

### 3. Flutter App

```bash
flutter run
# Use plant disease detection feature
```

## When to Use Git-Xet

### Use Git-Xet When:
- ✅ Cloning repositories with large model files
- ✅ Updating models from Hugging Face
- ✅ Collaborating on projects with large files
- ✅ Need efficient large file handling

### Don't Need Git-Xet When:
- ✅ Model already downloaded (like ours)
- ✅ Using Hugging Face CLI (already installed)
- ✅ Using direct downloads

## Hugging Face CLI (Already Installed)

We already have the Hugging Face CLI installed, which is sufficient for:

```bash
# Download models
hf download gopalkumr/Plant-disease-detection

# List files
hf ls-remote gopalkumr/Plant-disease-detection

# Upload models
hf upload gopalkumr/Plant-disease-detection ./model.pt
```

## Troubleshooting

### "git xet not found"
```bash
# Check if installed
git xet --version

# If not installed, use Scoop
scoop install git-xet
```

### "Large file not downloading"
```bash
# Use Hugging Face CLI instead
hf download gopalkumr/Plant-disease-detection --local-dir ./model

# Or use git-xet
git xet clone https://huggingface.co/gopalkumr/Plant-disease-detection
```

### "Git LFS conflicts"
```bash
# If you have Git LFS installed, you might need to disable it
git config --global lfs.disable true

# Then use git-xet
git xet install
```

## Comparison: Git-Xet vs Git LFS vs Hugging Face CLI

| Feature | Git-Xet | Git LFS | HF CLI |
|---------|---------|---------|--------|
| Large file support | ✅ | ✅ | ✅ |
| Performance | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Ease of use | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Model hosting | GitHub | GitHub | Hugging Face |
| Already installed | ❌ | ❌ | ✅ |

## Current Setup Summary

✅ **Hugging Face CLI**: Installed and working  
✅ **Plant Disease Model**: Downloaded (200.66 MB)  
✅ **Python Service**: Ready to use  
✅ **Node.js API**: Ready to use  
✅ **Flutter Service**: Ready to use  
⏳ **Git-Xet**: Optional (for future updates)

## Next Steps

### If You Want to Use Git-Xet:

1. Install Scoop: `iwr -useb get.scoop.sh | iex`
2. Install git-xet: `scoop install git-xet`
3. Initialize: `git xet install`
4. Clone: `git xet clone https://huggingface.co/gopalkumr/Plant-disease-detection`

### If You Want to Keep Current Setup:

1. Model is ready to use
2. Start server: `npm start`
3. Run app: `flutter run`
4. Detect plant diseases

## References

- **Git-Xet**: https://github.com/xetdata/xet-core
- **Git LFS**: https://git-lfs.com/
- **Hugging Face CLI**: https://huggingface.co/docs/hub/cli-basics
- **Hugging Face Hub**: https://huggingface.co/

---

**Status**: ✅ Model ready - git-xet optional  
**Date**: January 10, 2026
