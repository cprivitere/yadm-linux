alias kns=kubens
alias kctx=kubectx

[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases

#Update brew and shell stuff
alias upallthethings="brew update;brew outdated;brew upgrade;brew cleanup;cd ~/.oh-my-zsh-custom/plugins/fast-syntax-highlighting;git pull;cd ~/.oh-my-zsh-custom/plugins/zsh-autocomplete;git pull;cd ~/.oh-my-zsh-custom/plugins/zsh-autosuggestions;git pull;cd ~/.oh-my-zsh-custom/plugins/zsh-syntax-highlighting;git pull;cd ~/.oh-my-zsh-custom/themes/powerlevel10k;git pull;cd ~;omz update;omz reload"
