#!/bin/bash

set -e

# ============================================================================
# Dotfiles Installation Script
# ============================================================================
# WARNING: This script will symlink dotfiles from this repository to your
# home directory. Any existing files will be backed up.
#
# IMPORTANT: Never commit secrets to this repository!
# Use *.local files for sensitive data (they are gitignored).
# ============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo -e "${BLUE}==============================================================================${NC}"
echo -e "${BLUE}Dotfiles Installation${NC}"
echo -e "${BLUE}==============================================================================${NC}"
echo ""

# Detect if running in a container
IN_CONTAINER=false
if [ -f "/.dockerenv" ] || [ -f "/run/.containerenv" ]; then
  IN_CONTAINER=true
  echo -e "${YELLOW}📦 Container environment detected${NC}"
else
  echo -e "${GREEN}💻 Bare metal environment detected${NC}"
fi
echo ""

# Allow override with flags
while [[ $# -gt 0 ]]; do
  case $1 in
    --container)
      IN_CONTAINER=true
      shift
      ;;
    --bare-metal)
      IN_CONTAINER=false
      shift
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Usage: $0 [--container|--bare-metal]"
      exit 1
      ;;
  esac
done

# Function to create backup and symlink
symlink_file() {
  local source="$1"
  local target="$2"

  # Create parent directory if it doesn't exist
  mkdir -p "$(dirname "$target")"

  # Backup existing file if it exists and is not a symlink
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mkdir -p "$BACKUP_DIR"
    echo -e "${YELLOW}  Backing up existing: $target${NC}"
    mv "$target" "$BACKUP_DIR/"
  fi

  # Remove existing symlink if it exists
  if [ -L "$target" ]; then
    rm "$target"
  fi

  # Create symlink
  ln -s "$source" "$target"
  echo -e "${GREEN}  ✓ Linked: $target -> $source${NC}"
}

# ============================================================================
# Install shell configuration
# ============================================================================
echo -e "${BLUE}Installing shell configuration...${NC}"
symlink_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
symlink_file "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
echo ""

# ============================================================================
# Install git configuration
# ============================================================================
echo -e "${BLUE}Installing git configuration...${NC}"
symlink_file "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

# Prompt for git user info if placeholders are still present
GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ "$GIT_NAME" = "YOUR_NAME" ] || [ -z "$GIT_NAME" ]; then
  read -p "Enter your Git user name: " GIT_NAME
  git config --global user.name "$GIT_NAME"
fi

if [ "$GIT_EMAIL" = "YOUR_EMAIL" ] || [ -z "$GIT_EMAIL" ]; then
  read -p "Enter your Git email: " GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
fi

echo -e "${GREEN}  ✓ Git configured with: $GIT_NAME <$GIT_EMAIL>${NC}"
echo ""

# ============================================================================
# Install VSCode settings (if VSCode is installed or in container)
# ============================================================================
VSCODE_USER_DIR=""

# Determine VSCode settings location
if [ "$(uname)" = "Darwin" ]; then
  VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
elif [ "$(uname)" = "Linux" ]; then
  VSCODE_USER_DIR="$HOME/.config/Code/User"
fi

if [ -n "$VSCODE_USER_DIR" ]; then
  echo -e "${BLUE}Installing VSCode settings...${NC}"

  # Create VSCode user directory if it doesn't exist (common in containers)
  mkdir -p "$VSCODE_USER_DIR"

  symlink_file "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"
  symlink_file "$DOTFILES_DIR/vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
  echo ""
fi

# ============================================================================
# Container-specific vs bare metal setup
# ============================================================================
if [ "$IN_CONTAINER" = true ]; then
  echo -e "${YELLOW}Container mode: Skipping package manager installations${NC}"
  echo -e "${YELLOW}The following should be pre-installed in your dev container:${NC}"
  echo "  - git, zsh, curl, wget"
  echo "  - Node.js/nvm (if needed)"
  echo "  - Language-specific tools"
else
  echo -e "${BLUE}Bare metal mode: Additional setup available${NC}"
  echo ""
  echo "You may want to install:"
  echo "  - Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  echo "  - NVM: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
  echo "  - pnpm: curl -fsSL https://get.pnpm.io/install.sh | sh -"
fi
echo ""

# ============================================================================
# Security reminders
# ============================================================================
echo -e "${RED}==============================================================================${NC}"
echo -e "${RED}⚠️  SECURITY REMINDER ⚠️${NC}"
echo -e "${RED}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}Never commit secrets to this dotfiles repository!${NC}"
echo ""
echo "To store secrets and machine-specific configuration, create these files:"
echo ""
echo -e "  ${GREEN}~/.zshrc.local${NC}     - Shell environment variables and secrets"
echo -e "  ${GREEN}~/.zprofile.local${NC}  - Login shell secrets"
echo ""
echo "Example ~/.zshrc.local content:"
echo "  export OPENAI_API_KEY=sk-..."
echo "  export AWS_ACCESS_KEY_ID=AKIA..."
echo "  export GITHUB_TOKEN=ghp_..."
echo ""
echo -e "${YELLOW}These .local files are gitignored and will never be committed.${NC}"
echo ""

if [ -d "$BACKUP_DIR" ]; then
  echo -e "${BLUE}==============================================================================${NC}"
  echo -e "${YELLOW}Backup created at: $BACKUP_DIR${NC}"
  echo -e "${BLUE}==============================================================================${NC}"
  echo ""
fi

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Restart your shell or run: source ~/.zshrc"
echo "  2. Create ~/.zshrc.local and ~/.zprofile.local for your secrets"
echo "  3. Customize settings as needed"
echo ""
