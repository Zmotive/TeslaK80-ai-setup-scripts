#!/bin/bash
# AI CUDA Docker Setup - Quick Installer for Tesla K80
# This script clones the repo and runs the setup

set -eo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://github.com/Zmotive/TeslaK80-ai-setup-scripts.git"
TARGET_DIR="$HOME/ai-setup-scripts"

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║           AI CUDA Docker Setup - Quick Installer            ║
║               Ubuntu 22.04 LTS + Tesla K80                  ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check Ubuntu version
    if [[ $(lsb_release -rs) != "22.04" ]]; then
        error "This script requires Ubuntu 22.04 LTS. Current version: $(lsb_release -rs)"
    fi
    
    # Check internet connectivity
    if ! curl -s --connect-timeout 5 https://google.com > /dev/null 2>&1; then
        error "Internet connectivity required"
    fi
    
    # Check sudo access
    if ! sudo true; then
        error "This script requires sudo privileges"
    fi
    
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        log "Installing git..."
        sudo apt update
        sudo apt install -y git
    fi
    
    log "Prerequisites check passed"
}

clone_or_update_repo() {
    log "Setting up repository..."
    
    if [[ -d "$TARGET_DIR" ]]; then
        warn "Directory $TARGET_DIR already exists"
        read -p "Remove and re-clone? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$TARGET_DIR"
        else
            info "Using existing directory"
            cd "$TARGET_DIR"
            git pull
            return 0
        fi
    fi
    
    log "Cloning repository..."
    if ! git clone "$REPO_URL" "$TARGET_DIR"; then
        error "Failed to clone repository. Check your GitHub access."
    fi
    
    cd "$TARGET_DIR"
    log "Repository ready at $TARGET_DIR"
}

setup_github_auth() {
    info "For private repositories, you'll need GitHub authentication."
    echo -e "\n${YELLOW}Choose your authentication method:${NC}"
    echo -e "1. ${GREEN}SSH Key${NC} (recommended)"
    echo -e "2. ${BLUE}Personal Access Token${NC}"
    echo -e "3. ${YELLOW}GitHub CLI${NC}"
    echo -e ""
    
    read -p "Enter choice (1-3): " -n 1 -r
    echo
    
    case $REPLY in
        1)
            info "SSH Key authentication selected"
            echo -e "\n${BLUE}Setup Instructions:${NC}"
            echo -e "1. Generate SSH key: ${GREEN}ssh-keygen -t ed25519 -C \"your-email@example.com\"${NC}"
            echo -e "2. Add to ssh-agent: ${GREEN}ssh-add ~/.ssh/id_ed25519${NC}"
            echo -e "3. Copy public key: ${GREEN}cat ~/.ssh/id_ed25519.pub${NC}"
            echo -e "4. Add to GitHub: Settings → SSH and GPG keys → New SSH key"
            echo -e ""
            read -p "Press Enter when SSH key is configured..."
            ;;
        2)
            info "Personal Access Token authentication selected"
            echo -e "\n${BLUE}Setup Instructions:${NC}"
            echo -e "1. Go to GitHub → Settings → Developer settings → Personal access tokens"
            echo -e "2. Generate new token with 'repo' scope"
            echo -e "3. Use token as password when prompted"
            echo -e ""
            ;;
        3)
            info "GitHub CLI authentication selected"
            if ! command -v gh &> /dev/null; then
                log "Installing GitHub CLI..."
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                sudo apt update
                sudo apt install -y gh
            fi
            
            log "Authenticating with GitHub CLI..."
            gh auth login
            ;;
        *)
            warn "Invalid choice. Proceeding with default git authentication."
            ;;
    esac
}

run_ansible_setup() {
    log "Running Ansible setup..."
    
    cd "$TARGET_DIR/ansible"
    
    if [[ -f "bootstrap.sh" ]]; then
        chmod +x bootstrap.sh
        ./bootstrap.sh
    else
        error "bootstrap.sh not found in ansible directory"
    fi
}

show_completion_message() {
    echo -e "\n${GREEN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                 BOOTSTRAP COMPLETED!                         ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${BLUE}=== NEXT STEPS ===${NC}"
    echo -e "1. ${YELLOW}REBOOT YOUR SYSTEM${NC}"
    echo -e "2. Test the installation:"
    echo -e "   ${GREEN}cd $TARGET_DIR/tests${NC}"
    echo -e "   ${GREEN}./test-cuda-docker.sh${NC}"
    echo -e ""
    echo -e "3. Start using your AI environment:"
    echo -e "   ${GREEN}cd ~/Projects${NC}"
    echo -e "   ${GREEN}cp $TARGET_DIR/templates/docker-compose.ai-template.yml docker-compose.yml${NC}"
    echo -e "   ${GREEN}docker compose up -d pytorch-cuda${NC}"
}

main() {
    banner
    check_prerequisites
    
    # Try to clone first
    if ! git clone "$REPO_URL" "$TARGET_DIR" 2>/dev/null; then
        warn "Repository clone failed - likely needs authentication"
        setup_github_auth
        clone_or_update_repo
    else
        log "Repository cloned successfully"
        cd "$TARGET_DIR"
    fi
    
    run_ansible_setup
    show_completion_message
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
    main "$@"
fi