#!/bin/bash
# Create Standalone Tesla K80 Backup Repository

set -e

echo "🏗️  Creating Tesla K80 Backup Repository"
echo "========================================"

# Create the new repository directory
BACKUP_REPO_DIR="$HOME/TeslaK80-dependency-backups"

if [ -d "$BACKUP_REPO_DIR" ]; then
    echo "⚠️  Directory $BACKUP_REPO_DIR already exists!"
    read -p "Remove and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$BACKUP_REPO_DIR"
    else
        echo "❌ Aborting"
        exit 1
    fi
fi

mkdir -p "$BACKUP_REPO_DIR"
cd "$BACKUP_REPO_DIR"

echo "📁 Created: $BACKUP_REPO_DIR"

# Initialize git repository
git init
echo "✅ Git repository initialized"

# Create directory structure
mkdir -p {scripts,docs,backups}

# Create main README
cat > README.md << 'EOF'
# Tesla K80 Dependency Backups

🚨 **Critical Archive for Tesla K80 AI Systems**

This repository contains offline backups of all packages and Docker images required to run AI workloads on NVIDIA Tesla K80 GPUs, which use legacy drivers and CUDA versions that may be removed from public repositories.

## ⚠️ Repository Status
- **Target Hardware**: NVIDIA Tesla K80 (Kepler Architecture)
- **Required Driver**: nvidia-driver-470.x 
- **CUDA Version**: 11.7.1 (Tesla K80 compatible)
- **Ubuntu Version**: 22.04 LTS

## 📦 Contents

### `/backups/`
- **APT Packages**: .deb files for offline installation
- **Docker Images**: Tesla K80 compatible container images
- **Repository Keys**: GPG keys for package repositories

### `/scripts/`
- **backup-create.sh**: Create new dependency backups
- **backup-restore.sh**: Restore from backups (offline installation)
- **health-check.sh**: Monitor dependency availability

### `/docs/`
- Installation guides and troubleshooting

## 🚀 Quick Start

### Create Fresh Backup
```bash
./scripts/backup-create.sh
```

### Restore on New System
```bash
sudo ./scripts/backup-restore.sh
```

### Check Dependency Health
```bash
./scripts/health-check.sh
```

## 🎯 Use Cases

1. **Future-Proofing**: Ensure Tesla K80 systems work years from now
2. **Offline Installation**: Set up systems without internet
3. **Disaster Recovery**: Rebuild systems from known-good packages
4. **Air-Gapped Systems**: Deploy in secure environments

## 📋 Backup Contents

### APT Packages (~500MB)
- nvidia-driver-470
- cuda-toolkit-11-7
- docker-ce, docker-ce-cli
- nvidia-container-toolkit
- All dependencies

### Docker Images (~6GB)
- `nvidia/cuda:11.7.1-devel-ubuntu20.04`
- `pytorch/pytorch:1.13.1-cuda11.6-cudnn8-runtime`
- `tensorflow/tensorflow:2.11.0-gpu-jupyter`
- `codercom/code-server:latest`

### Repository Files (~10MB)
- NVIDIA CUDA repository keys
- Docker repository keys
- NVIDIA Container Toolkit keys

## ⏰ Maintenance Schedule

- **Weekly**: Check dependency availability
- **Monthly**: Test backup integrity  
- **Quarterly**: Refresh backups if needed
- **Annually**: Full backup recreation

## 🔗 Related Repositories

- [TeslaK80-ai-setup-scripts](https://github.com/Zmotive/TeslaK80-ai-setup-scripts) - Main installation scripts

## ⚖️ License & Legal

This repository contains backup copies of packages for archival purposes. Original packages remain under their respective licenses:
- NVIDIA packages: NVIDIA Software License
- Docker packages: Apache 2.0
- Ubuntu packages: Various (see individual packages)

**Use responsibly and in compliance with all applicable licenses.**
EOF

# Move and adapt scripts
echo "📝 Creating backup scripts..."

# Create the backup creation script
cat > scripts/backup-create.sh << 'EOF'
#!/bin/bash
# Tesla K80 Dependency Backup Creation Script
# Standalone version for backup repository

set -e

echo "🏭 Tesla K80 Dependency Backup Creation"
echo "======================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$REPO_DIR/backups"

# Clear and recreate backup directory
rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"/{packages,docker-images,repositories}

echo "📁 Backup directory: $BACKUP_DIR"

# ===============================================
# 1. BACKUP APT PACKAGES
# ===============================================
echo
echo "📦 1. Backing up APT packages..."

# Create package list
cat > "$BACKUP_DIR/packages/tesla-k80-packages.list" << 'PKG_EOF'
# Tesla K80 Critical Packages (Ubuntu 22.04)
nvidia-driver-470
nvidia-utils-470
libnvidia-gl-470
libnvidia-compute-470
libnvidia-decode-470
libnvidia-encode-470
cuda-toolkit-11-7
cuda-drivers
docker-ce
docker-ce-cli
containerd.io
docker-buildx-plugin
docker-compose-plugin
nvidia-container-toolkit
nvidia-container-runtime
PKG_EOF

# Download packages
echo "Downloading APT packages..."
cd "$BACKUP_DIR/packages"

CORE_PACKAGES=(
    nvidia-driver-470
    cuda-toolkit-11-7
    docker-ce
    docker-ce-cli
    containerd.io
    nvidia-container-toolkit
)

for package in "${CORE_PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii.*$package"; then
        echo "  📥 Downloading $package..."
        apt download "$package" 2>/dev/null || echo "    ⚠️  Failed to download $package"
    else
        echo "  ⚠️  $package not installed - skipping"
    fi
done

# ===============================================
# 2. BACKUP DOCKER IMAGES
# ===============================================
echo
echo "🐳 2. Backing up Docker images..."

IMAGES=(
    "nvidia/cuda:11.7.1-devel-ubuntu20.04"
    "pytorch/pytorch:1.13.1-cuda11.6-cudnn8-runtime"
    "tensorflow/tensorflow:2.11.0-gpu-jupyter"
    "codercom/code-server:latest"
)

cd "$BACKUP_DIR/docker-images"

for image in "${IMAGES[@]}"; do
    echo "  📥 Saving $image..."
    filename=$(echo "$image" | tr '/' '_' | tr ':' '_')
    if docker pull "$image" 2>/dev/null; then
        docker save "$image" | gzip > "${filename}.tar.gz"
        echo "    ✅ Saved as ${filename}.tar.gz"
    else
        echo "    ❌ Failed to pull $image"
    fi
done

# ===============================================
# 3. BACKUP REPOSITORY KEYS AND SOURCES
# ===============================================
echo
echo "🔑 3. Backing up repository configurations..."

cd "$BACKUP_DIR/repositories"

# Download repository files
wget -q -O cuda-keyring.deb "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb" || echo "⚠️  Failed to download CUDA keyring"
wget -q -O docker.gpg "https://download.docker.com/linux/ubuntu/gpg" || echo "⚠️  Failed to download Docker key"
wget -q -O nvidia-container-toolkit.gpg "https://nvidia.github.io/libnvidia-container/gpgkey" || echo "⚠️  Failed to download NVIDIA Container Toolkit key"

# Create restoration script
cat > ../backup-restore.sh << 'RESTORE_EOF'
#!/bin/bash
# Tesla K80 Offline Installation from Backups

set -e

echo "🏭 Tesla K80 Offline Installation"
echo "================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backups"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Backup directory not found: $BACKUP_DIR"
    exit 1
fi

# Install repository configurations
echo "🔑 Installing repository configurations..."
cd "$BACKUP_DIR/repositories"

if [ -f cuda-keyring.deb ]; then
    sudo dpkg -i cuda-keyring.deb
fi

if [ -f docker.gpg ]; then
    sudo mkdir -p /etc/apt/keyrings
    gpg --dearmor < docker.gpg | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
fi

if [ -f nvidia-container-toolkit.gpg ]; then
    gpg --dearmor < nvidia-container-toolkit.gpg | sudo tee /etc/apt/keyrings/nvidia-container-toolkit.gpg > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/nvidia-container-toolkit.gpg] https://nvidia.github.io/libnvidia-container/stable/ubuntu18.04/\$(ARCH) /" | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
fi

# Update package lists
sudo apt update

# Install packages from local files
echo "📦 Installing packages from backup..."
cd "$BACKUP_DIR/packages"
if ls *.deb 1> /dev/null 2>&1; then
    sudo dpkg -i *.deb || true
    sudo apt-get install -f -y  # Fix any dependency issues
else
    echo "⚠️  No .deb packages found"
fi

# Restore Docker images
echo "🐳 Restoring Docker images..."
cd "$BACKUP_DIR/docker-images"
for image_file in *.tar.gz; do
    if [ -f "$image_file" ]; then
        echo "  📥 Loading $image_file..."
        gunzip -c "$image_file" | docker load
    fi
done

echo "✅ Offline installation completed!"
echo "📋 Next steps:"
echo "   1. Test: nvidia-smi"
echo "   2. Test: docker run --gpus all nvidia/cuda:11.7.1-devel-ubuntu20.04 nvidia-smi"
echo "   3. Run AI workloads with confidence!"
RESTORE_EOF

chmod +x ../backup-restore.sh

# ===============================================
# 4. CREATE BACKUP INFORMATION
# ===============================================
cd "$BACKUP_DIR"

cat > backup-info.md << INFO_EOF
# Backup Information

**Created**: $(date)
**System**: $(lsb_release -d | cut -f2)
**Kernel**: $(uname -r)
**NVIDIA Driver**: $(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | head -n1 2>/dev/null || echo "Not detected")

## File Sizes
$(du -sh packages/ docker-images/ repositories/ 2>/dev/null || echo "Calculating...")

## Package Versions
$(cd packages && ls -la *.deb 2>/dev/null || echo "No packages found")

## Docker Images
$(cd docker-images && ls -la *.tar.gz 2>/dev/null || echo "No images found")
INFO_EOF

echo
echo "📊 Backup Summary:"
echo "=================="
du -sh "$BACKUP_DIR"/* 2>/dev/null || echo "Calculating sizes..."
echo
echo "✅ Backup completed successfully!"
echo "📁 Location: $BACKUP_DIR"
echo
echo "💡 Next steps:"
echo "   1. Review: $BACKUP_DIR/backup-info.md"
echo "   2. Test: ../backup-restore.sh (on test system)"
echo "   3. Commit to git repository"
EOF

chmod +x scripts/backup-create.sh

# Create health check script
cp /home/zack/ai-setup-scripts/check-dependencies.sh scripts/health-check.sh

# Create docs
mkdir -p docs
cat > docs/INSTALLATION.md << 'EOF'
# Tesla K80 Offline Installation Guide

## Prerequisites
- Ubuntu 22.04 LTS
- NVIDIA Tesla K80 GPU installed
- sudo privileges
- This backup repository

## Installation Steps

1. **Prepare System**
   ```bash
   sudo apt update
   sudo apt upgrade -y
   ```

2. **Run Offline Installation**
   ```bash
   sudo ./backup-restore.sh
   ```

3. **Verify Installation**
   ```bash
   nvidia-smi
   docker run --gpus all nvidia/cuda:11.7.1-devel-ubuntu20.04 nvidia-smi
   ```

## Troubleshooting

### GPU Not Detected
- Check: `lspci | grep -i nvidia`
- Ensure Tesla K80 is properly seated
- Check power connections

### Driver Issues
- Use: `ubuntu-drivers devices`
- Install: `sudo apt install nvidia-driver-470`

### Docker Issues
- Add user to docker group: `sudo usermod -aG docker $USER`
- Restart session or run: `newgrp docker`
EOF

# Create .gitignore for backup repo
cat > .gitignore << 'EOF'
# Backup files (too large for git)
backups/packages/*.deb
backups/docker-images/*.tar.gz

# Keep structure but ignore large files
!backups/packages/.gitkeep
!backups/docker-images/.gitkeep
!backups/repositories/

# Logs
*.log
*.tmp

# OS files
.DS_Store
Thumbs.db
EOF

# Create placeholder files to maintain directory structure
touch backups/packages/.gitkeep
touch backups/docker-images/.gitkeep

# Create initial commit
echo "📝 Creating initial commit..."
git add .
git commit -m "Initial Tesla K80 backup repository structure

- Backup creation and restoration scripts
- Documentation and installation guides
- Directory structure for packages and images
- Health monitoring tools"

echo
echo "🎉 Tesla K80 Backup Repository Created!"
echo "======================================"
echo "📁 Location: $BACKUP_REPO_DIR"
echo
echo "🚀 Next Steps:"
echo "   1. cd $BACKUP_REPO_DIR"
echo "   2. ./scripts/backup-create.sh  # Create first backup"
echo "   3. git add backups/backup-info.md && git commit -m 'Add backup info'"
echo "   4. Create GitHub repository and push"
echo
echo "💡 GitHub Repository Suggestion:"
echo "   Repository: TeslaK80-dependency-backups"
echo "   Visibility: Private (contains proprietary packages)"
echo "   Description: Offline dependency backups for Tesla K80 AI systems"