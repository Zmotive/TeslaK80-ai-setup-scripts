# AI CUDA Docker Setup for Tesla K80

Complete installation scripts for setting up a minimal Ubuntu 22.04 LTS system optimized for AI workloads using NVIDIA Tesla K80 GPU with CUDA and Docker.

## ✅ **Tesla K80 Status: FULLY FUNCTIONAL**
- **NVIDIA Driver 470**: ✅ Installed and working
- **Dual GPU Detection**: ✅ Both Tesla K80 units detected (24GB total)  
- **CUDA 11.4 Support**: ✅ Compatible containers running
- **PyTorch**: ✅ GPU acceleration verified
- **TensorFlow**: ✅ GPU acceleration verified
- **Docker Integration**: ✅ NVIDIA Container Toolkit configured

## System Requirements

- **Ubuntu 22.04 LTS** (Jammy Jellyfish)
- **NVIDIA Tesla K80 GPU**
- **Minimum 8GB RAM** (16GB+ recommended for AI workloads)
- **50GB+ free disk space**
- **Internet connection** for package downloads
- **sudo privileges**

## Supported NVIDIA GPUs

- Tesla K80 (Kepler architecture) - **Primary Target**
- Tesla K40, K20 (Kepler series)
- GTX/RTX series with compute capability 3.0+

## Why Ansible?

This project uses **Ansible** for infrastructure as code, providing several key benefits:

### ✅ **Idempotent Operations**
- **Safe to run multiple times** - Won't break if re-executed
- **Only changes what's needed** - Skips already-configured items
- **No side effects** - Predictable, consistent results

### 🎯 **Declarative Configuration**
- **Describe desired state** - Not step-by-step instructions
- **Self-documenting** - YAML clearly shows what's configured
- **Version controlled** - Track all changes in Git

### 🏷️ **Modular Execution**
- **Tagged tasks** - Run only specific components
- **Granular control** - Install CUDA without Docker, etc.
- **Easy debugging** - Test individual sections

### 📊 **Professional Reporting**
- **Detailed output** - See exactly what changed
- **Task-level feedback** - Know which steps succeeded/failed
- **Dry-run capability** - Preview changes before applying

## What Gets Installed

### System Components
- **CUDA 12.2** - NVIDIA CUDA platform for GPU computing
- **cuDNN 8.9** - Deep learning primitives library
- **Docker CE** - Latest Docker Community Edition
- **Docker Compose** - Container orchestration
- **NVIDIA Container Toolkit** - GPU access in containers
- **Base development tools** - build-essential, git, python3, etc.

### CUDA Packages
- Core CUDA runtime and libraries
- CUDA development toolkit
- cuBLAS, cuFFT, cuSolver (math libraries)
- NCCL (communication library)
- Thrust (parallel algorithms library)

### Docker Configuration
- NVIDIA GPU device access in containers
- Proper group permissions (docker)
- Optimized daemon configuration with nvidia-runtime
- AI-focused container templates

### Workspace Organization
- **Structured directories** - Organized project layout
- **Template files** - Ready-to-use Docker Compose configurations
- **Test scripts** - Verify everything works correctly

## Quick Start

### Option 1: One-Command Install (Recommended)
```bash
# Download and run the quick installer
curl -fsSL https://raw.githubusercontent.com/Zmotive/TeslaK80-ai-setup-scripts/main/quick-install.sh | bash
```

### Option 2: Manual Clone and Install
```bash
git clone https://github.com/Zmotive/TeslaK80-ai-setup-scripts.git ai-setup-scripts
cd ai-setup-scripts/ansible
./bootstrap.sh
```

> **🎯 Why Ansible?** Idempotent, declarative, safe to run multiple times, and industry-standard for infrastructure management.

### ✅ **Universal User Support**
- **Works for any username** - No hardcoded paths or usernames
- **Auto-detects current user** - Uses `$(whoami)` and `$HOME` dynamically
- **Safe for multi-user systems** - Each user gets their own workspace setup

### 2. After Installation
**IMPORTANT**: Reboot your system after installation
```bash
sudo reboot
```

### 3. Verify Installation
```bash
cd ai-setup-scripts/ansible
ansible-playbook verify-setup.yml
```

Or run comprehensive Docker and CUDA testing:
```bash
cd ai-setup-scripts
./ansible/tests/test-cuda-docker.sh
```

## Ansible Playbook Features

### Run Complete Setup
```bash
cd ansible/
./bootstrap.sh  # Installs Ansible and runs full setup
```

### Run Specific Components
```bash
# Only install CUDA
ansible-playbook setup-ai-system.yml --tags cuda --ask-become-pass

# Only setup Docker
ansible-playbook setup-ai-system.yml --tags docker --ask-become-pass

# Only create workspace directories
ansible-playbook setup-ai-system.yml --tags workspace --ask-become-pass

# Only cleanup old installations
ansible-playbook setup-ai-system.yml --tags cleanup --ask-become-pass
```

### Verify Installation
```bash
# Full verification
ansible-playbook verify-setup.yml

# Check specific components
ansible-playbook verify-setup.yml --tags cuda,docker
```

## Usage Examples

### Start PyTorch Container
```bash
docker run -it \
  --gpus all \
  -v ~/Projects:/workspace/projects \
  -v ~/Models:/workspace/models \
  -v ~/DockerVolumes/jupyter:/workspace/jupyter \
  pytorch/pytorch:latest
```

### Use Docker Compose Template
```bash
### Use Pre-configured Workspace
The installation automatically creates an organized folder structure:
```bash
# Folders created during installation:
~/DockerVolumes/     # Docker container persistent storage
├── jupyter/         # Jupyter notebooks and configs
├── tensorboard/     # TensorBoard logs
├── datasets/        # Training datasets
├── checkpoints/     # Model checkpoints
└── logs/           # Training logs

~/Models/           # AI models and weights
├── pytorch/        # PyTorch models
├── tensorflow/     # TensorFlow models
├── onnx/          # ONNX format models
└── huggingface/   # Hugging Face models

~/Projects/         # Your AI projects
├── ai-experiments/ # Experimental projects
├── training/      # Training scripts
└── inference/     # Inference projects

~/venvs/           # Python virtual environments
```

### Start with Docker Compose
```bash
cd ~/Projects
# Copy the template created by Ansible
cp ~/ai-setup-scripts/templates/docker-compose.ai-template.yml docker-compose.yml
docker compose up -d pytorch-cuda
docker compose exec pytorch-cuda bash
```

### Test GPU in PyTorch
```python
import torch
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"GPU device: {torch.cuda.get_device_name(0)}")

# Test GPU computation
x = torch.randn(1000, 1000).cuda()
y = torch.randn(1000, 1000).cuda()
z = torch.mm(x, y)
print(f"GPU computation successful: {z.shape}")
```

## Troubleshooting

### Common Issues

1. **No CUDA devices detected**
   - Ensure NVIDIA drivers are properly installed
   - Reboot after installation
   - Check GPU compatibility with `nvidia-smi`

2. **Docker permission denied**
   - Ensure you're in the `docker` group
   - Log out and back in after installation
   - Or use `newgrp docker`

3. **Container can't access GPU**
   - Verify `--gpus all` flag is used
   - Check NVIDIA Container Toolkit installation
   - Ensure nvidia-runtime is configured

### Verification Commands
```bash
# Check CUDA installation
nvidia-smi
nvcc --version

# Check Docker access
docker run --rm hello-world

# Check GPU access in container
docker run --rm --gpus all nvidia/cuda:12.2-runtime-ubuntu22.04 nvidia-smi
```

### Clean Reinstallation
If you need to start over:
```bash
# Remove Docker
sudo apt remove -y docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker

# Remove CUDA
sudo apt remove -y cuda-*
sudo rm -rf /usr/local/cuda*

# Run Ansible setup again
cd ansible/
ansible-playbook setup-ai-system.yml --ask-become-pass
```

### Preview Changes Before Applying
```bash
# See what would change without making changes
cd ansible/
ansible-playbook setup-ai-system.yml --check --diff
```

## File Structure

### Installation Scripts
```
ai-setup-scripts/
├── ansible/                        # Ansible playbooks for system setup
│   ├── bootstrap.sh                # Auto-install Ansible and run setup
│   ├── setup-ai-system.yml        # Main Ansible playbook
│   ├── verify-setup.yml           # Verification playbook
│   ├── inventory                   # Ansible inventory
│   ├── ansible.cfg                 # Ansible configuration
│   └── README.md                   # Ansible documentation
├── quick-install.sh                # One-command installer
├── setup.log                       # Installation log (from previous runs)
├── .gitignore                      # Git ignore file
└── README.md                       # This file

# Created by Ansible during installation:
├── templates/                      # Docker Compose templates (auto-generated)
│   └── docker-compose.ai-template.yml
└── tests/                          # Test scripts (auto-generated)
    └── test-cuda-docker.sh         # Comprehensive Docker & CUDA testing
```

### Created Workspace Structure
```
$HOME/
├── DockerVolumes/          # Docker volume mounts
│   ├── pytorch/           # PyTorch container data
│   ├── tensorflow/        # TensorFlow container data
│   ├── jupyter/           # Jupyter Lab data
│   └── shared/            # Shared data between containers
├── Models/                # AI model storage
├── Projects/              # Project workspaces
└── venvs/                 # Python virtual environments
```

## Support

- **CUDA Documentation**: https://docs.nvidia.com/cuda/
- **Docker Documentation**: https://docs.docker.com/
- **PyTorch CUDA**: https://pytorch.org/get-started/locally/

## Notes

- Installation requires internet connection for package downloads
- Total installation time: 20-40 minutes depending on internet speed
- Disk space required: ~15GB for full CUDA and AI framework installation
- System reboot required after installation for all changes to take effect
- Tesla K80 requires CUDA compute capability 3.7 support