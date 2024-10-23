# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source global definitions
source /usr/local/configfiles/zshrc.default

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git)

source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export TERM=rxvt

alias sq='squeue -u $USER'
alias su='sreport cluster AccountUtilizationByUser start=2020-01-01 accounts=g2023a122c -t hours'
alias juliap='julia --project=.'
alias gup='git stash && git switch main-dev && git pull && git switch hpc-server && git stash pop'

module load julia

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
