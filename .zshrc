# ============================================================================
# WARNING: DO NOT STORE SECRETS IN THIS FILE
# This is a PUBLIC dotfiles repository. Never commit:
# - API keys, tokens, passwords
# - Private keys, certificates
# - Personal information
#
# Store secrets in ~/.zshrc.local (gitignored) instead:
#   export MY_SECRET_KEY=abc123
#   export MY_API_TOKEN=xyz789
# ============================================================================

# Path configuration
export PATH="$HOME/bin:$PATH"

# Homebrew (if installed)
if [ -f "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# NVM (Node Version Manager) - if installed
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Ruby (rbenv) - if installed
if command -v rbenv &> /dev/null; then
  eval "$(rbenv init - zsh)"
fi

# Homebrew Ruby (if installed)
if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
  export PATH=/opt/homebrew/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi

# ============================================================================
# Aliases
# ============================================================================

# CLI helpers
alias curloj='curl -O -J -L -# --fail'
alias stripws-preview='perl -pe "s/\s+$//"'
alias stripws='perl -pi -e "s/\s+$//"'

# Ruby helpers
alias rspec='bundle exec rspec'
alias rubocop='bundle exec rubocop'
alias railsc='bundle exec rails console'
alias railsr='bundle exec rails server'
alias railsm='bundle exec rails db:migrate'
alias railsrout='bundle exec rails routes'
alias railsdbclean='rails db:drop db:create db:migrate ; RAILS_ENV=test rails db:drop db:create db:migrate'

# ============================================================================
# Git aliases (set via git config)
# ============================================================================
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'

# ============================================================================
# iTerm2 shell integration (if installed)
# ============================================================================
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# ============================================================================
# LOCAL OVERRIDES - Store secrets and machine-specific config here!
# ============================================================================
# Example ~/.zshrc.local content:
#   export RESEND_API_KEY=re_your_key_here
#   export OPENAI_API_KEY=sk-your_key_here
#   export AWS_ACCESS_KEY_ID=your_id_here
#   export AWS_SECRET_ACCESS_KEY=your_secret_here
#
# This file is gitignored and should never be committed.
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
