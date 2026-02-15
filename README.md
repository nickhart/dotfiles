# dotfiles

Personal development environment configuration — shell, git, and editor settings

> **⚠️ SECURITY WARNING**: This is a **PUBLIC** repository. **NEVER** commit API keys, tokens, passwords, private keys, or any sensitive information. All secrets should be stored in `.local` files which are gitignored.

## Features

- **Shell Configuration**: zsh with sensible defaults and useful aliases
- **Git Configuration**: Helpful aliases and workflow commands
- **VSCode Settings**: Editor preferences and keybindings
- **Container-Ready**: Auto-detects dev containers and adapts installation
- **Security-First**: Multiple layers of secret detection and prevention

## Quick Start

```bash
# Clone the repository
git clone https://github.com/nickhart/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run the installation script
./install.sh

# Restart your shell
exec zsh
```

The install script will:
- ✅ Auto-detect if running in a container or bare metal
- ✅ Backup existing dotfiles
- ✅ Create symlinks to configuration files
- ✅ Prompt for your git user info
- ✅ Install VSCode settings (if applicable)
- ✅ Display security reminders

## What's Included

### Shell Configuration

- **`.zshrc`**: Main zsh configuration
  - PATH management
  - Package manager integration (Homebrew, NVM, pnpm)
  - Useful aliases for common tasks
  - Git, Ruby, and development shortcuts

- **`.zprofile`**: Login shell configuration
  - Homebrew environment setup

### Git Configuration

- **`.gitconfig`**: Git aliases and settings
  - Shortcuts: `co`, `br`, `ci`, `st`
  - Useful commands: `undo`, `amend`, `lg` (pretty log)
  - Branch management: `push-current`, `syncmain`, `gomain`

### VSCode Configuration

- **`vscode/settings.json`**: Editor preferences
  - Auto-save, tab size, trailing whitespace trimming
  - Language-specific formatting rules
  - Git integration settings

- **`vscode/keybindings.json`**: Custom keyboard shortcuts
  - Shift+Enter for line continuation in terminal

## Security Features

This repository has **multiple layers** of protection against accidentally committing secrets:

### 1. Gitignore Protection

The `.gitignore` file blocks:
- `*.local` files (your secrets go here)
- Environment files (`.env`, `.env.*`)
- SSH keys, private keys, certificates
- Cloud provider credentials
- Common secret file patterns

### 2. Pre-commit Hooks

Install pre-commit hooks to scan for secrets before every commit:

```bash
# Install pre-commit (macOS)
brew install pre-commit gitleaks

# Or using pip
pip install pre-commit

# Install the git hooks
pre-commit install
```

Now every `git commit` will automatically:
- ✅ Scan for secrets with gitleaks
- ✅ Detect private keys
- ✅ Check for large files
- ✅ Fix trailing whitespace and line endings

### 3. CI/CD Security Scanning

GitHub Actions automatically scans every push and pull request:
- Gitleaks secret detection
- Pre-commit hook validation
- ShellCheck for script quality

### 4. Local File Pattern

Store all secrets in `.local` files which are automatically sourced but never committed:

**Example `~/.zshrc.local`:**
```bash
# API Keys
export OPENAI_API_KEY=sk-...
export ANTHROPIC_API_KEY=sk-ant-...
export GITHUB_TOKEN=ghp_...

# AWS Credentials
export AWS_ACCESS_KEY_ID=AKIA...
export AWS_SECRET_ACCESS_KEY=...

# Other secrets
export RESEND_API_KEY=re_...
export DATABASE_URL=postgresql://...
```

**Example `~/.zprofile.local`:**
```bash
export TODOIST_API_TOKEN=...
export OTHER_SECRET=...
```

These files are:
- ✅ Automatically sourced by the shell
- ✅ Gitignored (never committed)
- ✅ Machine-specific
- ✅ Easy to manage

## Manual Secret Scanning

You can manually scan for secrets at any time:

```bash
# Install gitleaks (macOS)
brew install gitleaks

# Scan all files
gitleaks detect --verbose

# Scan only staged changes
gitleaks protect --staged

# Scan with specific config
gitleaks detect --config .gitleaks.toml
```

## Container vs Bare Metal

The install script auto-detects your environment:

### In Dev Containers
- Skips package manager installations
- Assumes git, zsh, curl, wget are pre-installed
- Focuses on dotfile symlinks and VSCode settings

### On Bare Metal
- Provides guidance for installing Homebrew, NVM, pnpm
- Full environment setup

Override auto-detection:
```bash
./install.sh --container     # Force container mode
./install.sh --bare-metal    # Force bare metal mode
```

## Customization

### Adding Your Own Secrets

1. Create local override files:
   ```bash
   touch ~/.zshrc.local ~/.zprofile.local
   chmod 600 ~/.zshrc.local ~/.zprofile.local  # Restrict permissions
   ```

2. Add your secrets:
   ```bash
   echo 'export MY_API_KEY=...' >> ~/.zshrc.local
   ```

3. Verify they're not tracked:
   ```bash
   git status  # Should not show .local files
   ```

### Modifying Dotfiles

1. Edit files in the dotfiles repository
2. Changes take effect immediately (files are symlinked)
3. Commit and push your changes:
   ```bash
   cd ~/.dotfiles
   git add .
   git commit -m "Update shell aliases"
   git push
   ```

### Adding New Configuration Files

1. Add the file to the repository
2. Update `install.sh` to symlink it
3. Update `.gitignore` if needed
4. Update this README

## File Structure

```
dotfiles/
├── .github/
│   └── workflows/
│       └── security-scan.yml    # CI/CD security scanning
├── vscode/
│   ├── settings.json            # VSCode settings
│   └── keybindings.json         # VSCode keybindings
├── .gitconfig                   # Git configuration
├── .gitignore                   # Prevent committing secrets
├── .gitleaks.toml               # Secret scanning rules
├── .pre-commit-config.yaml      # Pre-commit hook config
├── .zprofile                    # Login shell config
├── .zshrc                       # Interactive shell config
├── install.sh                   # Installation script
└── README.md                    # This file
```

## Troubleshooting

### Pre-commit hook fails

If the pre-commit hook detects secrets:
1. **DO NOT** bypass the hook with `--no-verify`
2. Remove the secret from your commit
3. Add it to a `.local` file instead
4. Commit again

Emergency bypass (use sparingly):
```bash
SKIP=gitleaks git commit -m "..."
```

### Gitleaks false positives

If gitleaks incorrectly flags something as a secret:

1. Add it to the allowlist in `.gitleaks.toml`:
   ```toml
   [allowlist]
   regexes = [
       '''your-safe-pattern-here'''
   ]
   ```

2. Or use stopwords:
   ```toml
   stopwords = ["example", "test", "dummy"]
   ```

### Installation issues

If the install script fails:
1. Check file permissions: `ls -la ~/.dotfiles`
2. Ensure you can write to `~`: `touch ~/test && rm ~/test`
3. Check for existing symlinks: `ls -la ~ | grep dotfiles`

## Best Practices

1. **Never commit secrets** - Use `.local` files
2. **Review changes before committing** - Check `git diff`
3. **Run manual scans periodically** - `gitleaks detect`
4. **Keep dependencies updated** - Update pre-commit hooks regularly
5. **Document your changes** - Update README when adding new features
6. **Test in containers** - Ensure portability to dev containers
7. **Backup important configs** - Before running `install.sh`

## Contributing

This is a personal dotfiles repository, but you're welcome to:
- Fork it for your own use
- Suggest improvements via issues
- Share useful patterns and configurations

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Resources

- [gitleaks](https://github.com/gitleaks/gitleaks) - Secret scanning
- [pre-commit](https://pre-commit.com/) - Git hook framework
- [dotfiles.github.io](https://dotfiles.github.io/) - Dotfiles inspiration

---

**Remember**: If you accidentally commit a secret, consider it compromised. Rotate it immediately!
