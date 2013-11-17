export PATH=~/bin:~/opt/java/bin:~/opt/sbt/bin:~/opt/play:~/opt/maven/bin:$PATH

export EDITOR=$(which vim)

if [ "normandy" = ${HOSTNAME} ]
then
  export PS1='\u@\h:\w> '
fi

alias test-eclipse='./eclipse/eclipse -data workspace -vmargs -Xmx1048m'
