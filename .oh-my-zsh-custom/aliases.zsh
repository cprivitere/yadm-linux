alias tf=tofu
alias kns=kubens
alias kctx=kubectx
alias less="bat"
alias cat="bat -pp"
#eval "$(batman --export-env)"
export MANPAGER="env BATMAN_IS_BEING_MANPAGER=yes /bin/bash $HOMEBREW_PREFIX/bin/batman"
export MANROFFOPT="-c"

[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases

#Update brew and shell stuff
alias upallthethings="brew update;brew outdated;brew upgrade;brew cleanup;fd -i -I --glob -H \*.zwc -x rm;cd ~/.oh-my-zsh-custom/plugins/fast-syntax-highlighting;git pull;cd ~/.oh-my-zsh-custom/plugins/zsh-autocomplete;git pull;cd ~/.oh-my-zsh-custom/plugins/zsh-autosuggestions;git pull;cd ~/.oh-my-zsh-custom/plugins/zsh-syntax-highlighting;git pull;cd ~/.oh-my-zsh-custom/themes/powerlevel10k;git pull;cd ~;omz update;omz reload"
