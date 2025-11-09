# AI CUDA Docker Setup - Ansible Edition for Tesla K80

This directory contains **Ansible playbooks** that provide automated setup for Tesla K80 systems with CUDA and Docker, offering **idempotent**, **declarative**, and **version controlled** infrastructure management.

## 🚀 Quick Start

### Option 1: Bootstrap Script (Recommended)
```bash
cd ansible/
./bootstrap.sh
```

### Option 2: Manual Ansible Installation
```bash
# Install Ansible
sudo apt update
sudo apt install -y ansible

# Run the playbook
cd ansible/
ansible-playbook setup-ai-system.yml --ask-become-pass
```

## 📁 Files Overview

```
ansible/
├── bootstrap.sh              # Auto-installs Ansible and runs setup
├── setup-ai-system.yml       # Main setup playbook for Tesla K80
├── verify-setup.yml          # Verification playbook
├── inventory                 # Ansible inventory (localhost)
├── ansible.cfg              # Ansible configuration
└── README.md                # This file

# Files created by the playbook:
../templates/docker-compose.ai-template.yml  # Docker Compose template
../tests/test-cuda-docker.sh                 # CUDA Docker test script
```

## 🎯 What the Playbook Does

### ✅ **Idempotent Operations**
- **System updates** - Only updates if needed
- **Package installation** - Skips if already installed
- **User groups** - Only adds if not already member
- **Directory creation** - Creates only if missing
- **Configuration files** - Updates only if changed

### 🔧 **Components Installed**
1. **System Preparation**
   - Updates Ubuntu 22.04 packages
   - Installs development tools
   - Cleans up old installations

2. **NVIDIA Driver Installation**
   - Installs Tesla K80 compatible drivers (470.x series)
   - Configures proper kernel modules

3. **CUDA 12.2 Installation**
   - Adds NVIDIA CUDA repository
   - Installs CUDA toolkit and runtime
   - Configures environment variables
   - Installs cuDNN for deep learning

4. **Docker Installation**
   - Installs Docker CE with NVIDIA runtime support
   - Configures daemon for GPU access
   - Sets up Docker Compose
   - Installs NVIDIA Container Toolkit

5. **User Permissions**
   - Adds user to `docker` group
   - Configures proper GPU access

6. **Workspace Setup**
   - Creates organized directory structure
   - Sets up templates and test scripts

## 🏃‍♂️ Running Specific Parts

### Run with tags to execute only specific sections:
```bash
# Only install CUDA
ansible-playbook setup-ai-system.yml --tags cuda --ask-become-pass

# Only setup Docker
ansible-playbook setup-ai-system.yml --tags docker --ask-become-pass

# Only create workspace directories
ansible-playbook setup-ai-system.yml --tags workspace --ask-become-pass

# Only install NVIDIA drivers
ansible-playbook setup-ai-system.yml --tags nvidia --ask-become-pass

# Only cleanup old installations
ansible-playbook setup-ai-system.yml --tags cleanup --ask-become-pass
```

## 🔍 Verification

### Run the verification playbook:
```bash
ansible-playbook verify-setup.yml
```

### Run specific verification checks:
```bash
# Check only CUDA
ansible-playbook verify-setup.yml --tags cuda

# Check only Docker
ansible-playbook verify-setup.yml --tags docker

# Check only permissions
ansible-playbook verify-setup.yml --tags permissions
```

## 🆚 Ansible vs Shell Scripts

| Feature | Shell Scripts | Ansible Playbook |
|---------|---------------|-------------------|
| **Idempotent** | ❌ May cause issues if run twice | ✅ Safe to run multiple times |
| **Rollback** | ❌ Manual cleanup required | ✅ Can remove packages/configs |
| **State tracking** | ❌ No knowledge of current state | ✅ Checks current state |
| **Debugging** | 🟡 Log files and manual checks | ✅ Detailed task output |
| **Modularity** | 🟡 Separate scripts | ✅ Tags for specific sections |
| **Learning curve** | ✅ Bash knowledge | 🟡 YAML and Ansible concepts |

## 🔄 Making Changes

### To modify the setup:

1. **Edit the playbook**: `setup-ai-system.yml`
2. **Test your changes**: `ansible-playbook setup-ai-system.yml --check`
3. **Run the updated playbook**: `ansible-playbook setup-ai-system.yml --ask-become-pass`

### Common modifications:

#### Change CUDA version:
```yaml
vars:
  cuda_version: "12.3"  # Change from 12.2
  cuda_version_full: "12-3"
```

#### Add new packages:
```yaml
- name: Install additional packages
  apt:
    name:
      - htop
      - neovim
      - your-package-here
    state: present
```

#### Create additional directories:
```yaml
- name: Create custom directories
  file:
    path: "{{ home_dir }}/{{ item }}"
    state: directory
  loop:
    - MyCustomDir
    - AnotherDir
```

## 🐛 Troubleshooting

### Common issues and solutions:

#### Playbook fails with permission errors:
```bash
# Make sure you use --ask-become-pass
ansible-playbook setup-ai-system.yml --ask-become-pass
```

#### CUDA installation fails:
```bash
# Run only CUDA installation with verbose output
ansible-playbook setup-ai-system.yml --tags cuda --ask-become-pass -vv
```

#### Docker group membership not working:
```bash
# Log out and back in, or run:
newgrp docker

# Or reboot the system
sudo reboot
```

#### NVIDIA driver issues:
```bash
# Check if drivers are loaded
nvidia-smi

# If not working, reboot after installation
sudo reboot
```

#### Check what would change without making changes:
```bash
ansible-playbook setup-ai-system.yml --check --diff
```

## 🔄 Advanced Usage

### Run on remote machines:
1. **Update inventory file**:
```ini
[ai_systems]
192.168.1.100 ansible_user=username
192.168.1.101 ansible_user=username
```

2. **Run playbook**:
```bash
ansible-playbook setup-ai-system.yml -i inventory --ask-become-pass
```

### Use with Ansible Vault for sensitive data:
```bash
# Create encrypted variables
ansible-vault create group_vars/all/vault.yml

# Run with vault password
ansible-playbook setup-ai-system.yml --ask-vault-pass --ask-become-pass
```

## 🎯 Benefits of This Approach

1. **📋 Declarative** - Describe what you want, not how to get there
2. **🔄 Idempotent** - Safe to run repeatedly
3. **📊 Reporting** - Clear output of what changed
4. **🧩 Modular** - Run only specific parts
5. **📝 Version controlled** - Track all changes in Git
6. **🔧 Extensible** - Easy to add new functionality
7. **🌐 Scalable** - Can manage multiple machines

## 📚 Next Steps

1. **Learn Ansible basics**: https://docs.ansible.com/ansible/latest/user_guide/basic_concepts.html
2. **Explore Ansible modules**: https://docs.ansible.com/ansible/latest/collections/
3. **Set up Ansible AWX/Tower** for web-based management
4. **Create custom roles** for reusable components
5. **Add CI/CD integration** with GitHub Actions

This Ansible approach provides a **professional, maintainable, and scalable** way to manage your Tesla K80 AI development environment!