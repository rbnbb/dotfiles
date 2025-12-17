# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/). Supports macOS and Arch Linux.

## Quick Start

```bash
# Install chezmoi and apply dotfiles in one command
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply rbnbb/dotfiles
```

You'll be prompted for:
- Machine type (personal/headless)
- Age encryption passphrase (for SSH keys and private configs)
- Tool installations (zsh, oh-my-zsh, fzf, etc.)

## What's Included

| Category | Tools |
|----------|-------|
| Shell | zsh + oh-my-zsh + powerlevel10k |
| Editor | neovim (with LSP), vim |
| Terminal | kitty |
| WM | hyprland (Linux), aerospace (macOS) |
| Git | delta with catppuccin theme |
| Other | fzf, autojump-rs, sioyek |

## Usage

```bash
chezmoi edit ~/.zshrc    # Edit a dotfile
chezmoi diff             # Preview changes
chezmoi apply            # Apply changes
chezmoi update           # Pull and apply latest
chezmoi add ~/.newfile   # Add new file to management
```

## Structure

```
home/
├── dot_*           # Dotfiles (dot_zshrc → ~/.zshrc)
├── encrypted_*     # Age-encrypted secrets
├── *.tmpl          # Templates (OS/host-specific)
└── .chezmoiscripts/  # Auto-run install scripts
```

## License

MIT
