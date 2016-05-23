# Add ~/bin and a few ~/opt/__/bin folder to PATH
export PATH=~/bin:~/opt/java/bin:~/opt/sbt/bin:~/opt/play:~/opt/maven/bin:$PATH
export JAVA_HOME=~/opt/java

# Use vim as the default command line editor
export EDITOR=$(which vim)

if [ "normandy" = ${HOSTNAME} ]
then
  export PS1='\u@\h:\w> '
fi

alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias lla='ls -al'
# shortcut to launch throwaway eclipse
alias test-eclipse='./eclipse/eclipse -data workspace -vmargs -Xmx1048m'
