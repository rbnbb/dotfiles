# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/). Supports macOS and Arch Linux.

## Quick Start

```bash
# Install chezmoi and apply dotfiles in one command
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply rbnbb/dotfiles
```

You'll be prompted for:
- Machine type (personal/headless)
- Whether to use age encryption (answer **N** for a minimal, no-passphrase install — see below)
- Age passphrase (only if you answered Y above; needed for SSH keys and private configs)
- Tool installations (zsh, oh-my-zsh, fzf, etc.)

## Minimal install (no passphrase)

For a fresh box / ephemeral container where you just want a nice shell and don't have the age passphrase, answer **N** to the encryption prompt. This:

- skips age key decryption entirely (no passphrase asked)
- chezmoiignores all encrypted files (`.zshrc.private`, `.ssh/config`, ssh keys)
- skips overwriting `.bashrc`, `.gitconfig`, `.config/nvim`
- installs only zsh + oh-my-zsh + powerlevel10k + fzf + autojump-rs

Try it in a throwaway Docker container:

```bash
docker run --rm -it archlinux bash -c '
  pacman -Sy --noconfirm git curl sudo &&
  sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply rbnbb/dotfiles
'
# Answer: personal=n, headless=y, useEncryption=n
```

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
