#!/bin/bash

# WSL Setup Script

# This script automates the setup and configuration of a Windows Subsystem for Linux (WSL) environment.
# It performs the following tasks:

# - Updates the package list and upgrades installed packages.
# - Installs essential utilities for an enhanced Bash experience.
# - Configures WSL settings, including memory allocation and port forwarding.
# - Sets up Bash autocompletion and defines common command aliases.
# - Creates symbolic links for easy access to Windows home directories.
# - Configures DNS settings for internet connectivity.
# - Facilitates clipboard sharing between WSL and Windows.
# - Installs and configures the Telegram CLI.

# Run this script to streamline your WSL setup process. Make sure to restart your WSL session after running the script for all changes to take effect.

# Author        : Daniel sol
# Git           : github.com/szolll
# Email         : daniel.sol@gmail.com
# Version       : 1.1

# Define the Windows username and WSL environment variable
USERNAME="dsol"

# ANSI color codes for green and red
GREEN='\033[0;32m'
RED='\033[0;31m'
NO_COLOR='\033[0m'

# Initialize a checklist to track task success/failure
declare -A checklist

# Function to update the system and install packages
function install_packages() {
  sudo apt-get update -y
  sudo apt-get upgrade -y
  sudo apt-get install -y "$@"
  if [[ $? -eq 0 ]]; then
    checklist["Install Packages"]="${GREEN}✔️${NO_COLOR}"
  else
    checklist["Install Packages"]="${RED}❌${NO_COLOR}"
  fi
}

# Install basic packages and utilities for enhanced Bash and WSL integration
install_packages git curl wget vim tmux htop build-essential
install_packages bash-completion fzf bat thefuck xclip jq ripgrep  # Additional packages for Bash enhancements and common utilities

# WSL-Specific Configuration
function configure_wsl() {
  cat > /mnt/c/Users/$USERNAME/.wslconfig <<EOL
[wsl2]
memory=4GB
processors=2
swap=2GB
localhostForwarding=true
EOL
  if [[ $? -eq 0 ]]; then
    checklist["Configure WSL"]="${GREEN}✔️${NO_COLOR}"
  else
    checklist["Configure WSL"]="${RED}❌${NO_COLOR}"
  fi
}

# Setup Bash Autocompletion
function setup_bash_autocompletion() {
  # Ensure bash-completion is installed and sourced in .bashrc
  grep -q "source /usr/share/bash-completion/bash_completion" ~/.bashrc || {
    echo "source /usr/share/bash-completion/bash_completion" >> ~/.bashrc
  }

  if [[ $? -eq 0 ]]; then
    checklist["Setup Bash Autocompletion"]="${GREEN}✔️${NO_COLOR}"
  else
    checklist["Setup Bash Autocompletion"]="${RED}❌${NO_COLOR}"
  fi
}

# Setup tldr
function setup_tldr() {
  install_packages tldr
  tldr --update
  if [[ $? -eq 0 ]]; then
    checklist["Setup tldr"]="${GREEN}✔️${NO_COLOR}"
  else
    checklist["Setup tldr"]="${RED}❌${NO_COLOR}"
  fi
}

# Install Telegram CLI
function install_telegram_cli() {
  install_packages libreadline-dev libconfig-dev libssl-dev lua5.2 lua5.2-dev liblua5.2-dev
  install_packages libevent-dev make libjansson-dev autoconf
  git clone --recursive https://github.com/vysheng/tg.git ~/telegram-cli
  cd ~/telegram-cli
  ./configure && make && sudo make install
  cd ~
  if [[ $? -eq 0 ]]; then
    checklist["Install Telegram CLI"]="${GREEN}✔️${NO_COLOR}"
  else
    checklist["Install Telegram CLI"]="${RED}❌${NO_COLOR}"
  fi
}

# Create symbolic links for Windows integration
function create_symlinks() {
  ln -s /mnt/c/Users/$USERNAME ~/windows_home
  if [[ $? -eq 0 ]]; then
    checklist["Create Symlinks"]="${GREEN}✔️${NO_COLOR}"
  else
    checklist["Create Symlinks"]="${RED}❌${NO_COLOR}"
  fi
}

# Configure DNS with search domains
function configure_dns() {
  sudo bash -c 'cat > /etc/resolv.conf <<EOL
nameserver 8.8.8.8
nameserver 1.1.1.1
nameserver 4.2.2.2
search danielsol.nl
EOL'
  if [[ $? -eq 0 ]]; then
    checklist["Configure DNS"]="${GREEN}✔️${NO_COLOR}"
  else
    checklist["Configure DNS"]="${RED}❌${NO_COLOR}"
  fi
}

# Configure port forwarding
function setup_port_forwarding() {
  sudo bash -c 'cat > /etc/wsl.conf <<EOL
[network]
forwarding=true
EOL'
  if [[ $? -eq 0 ]]; then
    checklist["Port Forwarding"]="${GREEN}✔️${NO_COLOR}"
  else
    checklist["Port Forwarding"]="${RED}❌${NO_COLOR}"
  fi
}

# Setup common aliases
function setup_common_aliases() {
  # File Management
  alias ll="ls -la"
  alias la="ls -a"
  alias c="clear"
  alias cd..="cd .."

  # Git Aliases
  alias gs="git status"
  alias ga="git add"
  alias gc="git commit"
  alias gd="git diff"

  # Package Management
  alias update="sudo apt-get update"
  alias upgrade="sudo apt-get upgrade"

  # Additional Utilities
  alias df="df -h"

  if [[ $? -eq 0 ]]; then
    checklist["Setup Common Aliases"]="${GREEN}✔️${NO_COLOR}"
  else
    checklist["Setup Common Aliases"]="${RED}❌${NO_COLOR}"
  fi
}

# Clipboard sharing and Windows integration
alias copy="clip.exe"
alias paste="powershell.exe Get-Clipboard"
alias code="/mnt/c/Program Files/Microsoft VS Code/Code.exe"
alias codium="/mnt/c/Program Files/VSCodium/VSCodium.exe"

# Run all configuration functions
configure_wsl
setup_bash_autocompletion
setup_tldr
install_telegram_cli
create_symlinks
configure_dns
setup_port_forwarding
setup_common_aliases

# Display the checklist with success and failure marks
echo "=== Checklist ==="
for key in "${!checklist[@]}"; do
  echo "$key: ${checklist[$key]}"
done

echo "Personalization script completed. Restart your WSL session for all changes to take effect."
