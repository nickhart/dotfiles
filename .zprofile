# shellcheck shell=bash
# ============================================================================
# WARNING: DO NOT STORE SECRETS IN THIS FILE
# This is a PUBLIC dotfiles repository.
# Store secrets in ~/.zprofile.local (gitignored) instead.
# ============================================================================

# Homebrew environment setup
if [ -f "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ============================================================================
# LOCAL OVERRIDES - Store secrets and machine-specific config here!
# ============================================================================
# Example ~/.zprofile.local content:
#   export TODOIST_API_TOKEN=your_token_here
#   export OTHER_SECRET=your_secret_here
#
# This file is gitignored and should never be committed.
# shellcheck disable=SC1090
[ -f ~/.zprofile.local ] && source ~/.zprofile.local
