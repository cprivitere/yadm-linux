alias tf=tofu
alias kns=kubens
alias kctx=kubectx
alias less="bat"
alias cat="bat -pp"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANPAGER='nvim +Man!'

[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases

#Update brew and shell stuff
alias upallthethings="brew update;brew outdated;brew upgrade;brew cleanup;fd -i -I --glob -H \*.zwc -x rm;cd ~/.oh-my-zsh-custom/plugins/fast-syntax-highlighting;git pull;cd ~/.oh-my-zsh-custom/plugins/zsh-autocomplete;git pull;cd ~/.oh-my-zsh-custom/plugins/zsh-autosuggestions;git pull;cd ~/.oh-my-zsh-custom/plugins/zsh-syntax-highlighting;git pull;cd ~/.oh-my-zsh-custom/themes/powerlevel10k;git pull;cd ~;omz update;omz reload"
