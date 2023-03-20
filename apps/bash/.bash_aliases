# Add ~/opt/bin folder to PATH
export PATH=~/opt/bin:$PATH

# Use vim as the default command line editor
export EDITOR=$(which vim)

alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias lla='ls -al'

eval $(keychain --eval id_ed25519)

if [ -f "$HOME/.bash_aliases.platform" ]
then
  source "$HOME/.bash_aliases.platform"
fi

if [ -f "$HOME/.bash_aliases.context" ]
then
  source "$HOME/.bash_aliases.context"
fi

if [ -f "$HOME/.bash_aliases.local" ]
then
  source "$HOME/.bash_aliases.local"
fi

