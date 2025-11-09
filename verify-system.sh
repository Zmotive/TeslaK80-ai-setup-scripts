#!/bin/bash

# Tesla K80 AI System Verification Script
# This script runs the Ansible verification as the current user to ensure proper path resolution

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Tesla K80 AI System Verification${NC}"
echo -e "${BLUE}======================================${NC}"
echo

# Get current user info
CURRENT_USER=$(whoami)
CURRENT_HOME=$HOME

echo -e "${YELLOW}Running verification as user: ${CURRENT_USER}${NC}"
echo -e "${YELLOW}Home directory: ${CURRENT_HOME}${NC}"
echo

# Change to ansible directory
cd "$(dirname "$0")/ansible"

# Create missing workspace directories if they don't exist
echo -e "${BLUE}Creating workspace directories if needed...${NC}"
mkdir -p "$CURRENT_HOME"/{DockerVolumes,Models,Projects,venvs}
mkdir -p "$CURRENT_HOME"/ai-workspace/{pytorch,tensorflow,jupyter,shared,datasets,models,projects}

echo -e "${GREEN}✓ Workspace directories ensured${NC}"
echo

# Run the verification with proper user context
echo -e "${BLUE}Running Ansible verification...${NC}"
echo

# Set the home directory explicitly for Ansible
export ANSIBLE_USER_HOME="$CURRENT_HOME"

# Run verification without become (as current user)
if ansible-playbook -i inventory verify-setup.yml \
    --extra-vars "ansible_user_dir=$CURRENT_HOME" \
    --connection=local \
    --ask-become-pass; then
    
    echo
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}✅ VERIFICATION SUCCESSFUL!${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo
    echo -e "${GREEN}Your Tesla K80 AI system is fully operational:${NC}"
    echo -e "${GREEN}• NVIDIA Tesla K80 GPUs: Working${NC}"
    echo -e "${GREEN}• NVIDIA Driver 470: Working${NC}"
    echo -e "${GREEN}• CUDA 11.7: Working${NC}"
    echo -e "${GREEN}• Docker with GPU support: Working${NC}"
    echo -e "${GREEN}• Workspace directories: Created${NC}"
    echo
    echo -e "${BLUE}You can now start using your AI development environment!${NC}"
    
else
    echo
    echo -e "${RED}======================================${NC}"
    echo -e "${RED}❌ VERIFICATION FAILED${NC}"
    echo -e "${RED}======================================${NC}"
    echo
    echo -e "${RED}Some components may need attention. Check the output above for details.${NC}"
    exit 1
fi