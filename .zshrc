# ---------- P10K ----------
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---------- OH-MY-ZSH ----------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source $ZSH/oh-my-zsh.sh # omz default theme

# ---------- OTHER STUFF ----------
# localisation
export LANG="en_US.UTF-8"
export LC_MONETARY="de_DE.UTF-8"
export LC_NUMERIC="de_DE.UTF-8"
export LC_TIME="de_DE.UTF-8"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# zoxide
eval "$(zoxide init zsh --cmd cd)"

# cargo
export PATH="~/.cargo/bin:$PATH"

# scripts folder
export PATH="~/.scripts:$PATH"

# ---------- ALIASES ----------
alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -almhF --icons --color=always --group-directories-first --time-style long-iso'
alias la='eza -a --icons --color=always --group-directories-first' 
alias l.='eza -a | egrep "^\."'
alias lt='eza -aT --icons --color=always --group-directories-last'
alias py='python3'
alias terminal_colors='for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done'
alias q9='ping 9.9.9.9'
alias vi='nvim'
alias vim='nvim'
alias zshrc='source ~/.zshrc'
alias sudo='sudo '

# ---------- ZSH-PLUGINS ----------
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
plugins=(zsh-you-should-use)
