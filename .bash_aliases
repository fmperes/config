# General purpose
alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias more=less
alias grep='grep --color=auto'
alias da='date "+%A, %B %d, %Y [%T]"'
alias ..='cd ..'

alias mnt="mount | awk -F' ' '{ printf \"%s\t%s\n\",\$1,\$3; }' | column -t | egrep ^/dev/ | sort"
alias gh="history|grep"
alias cpv="rsync -ah --info=progress2"
alias untar='tar -zxvf'

alias updtweb="rsync -vrP --delete-after ~/Projects/Website/* root@franciscoperes.xyz:/var/www/website"
alias sshPI="ssh admin@192.168.1.110"

# Open programs with specific paths / settings
alias kanjitomo="java -Xmx1200m -server -jar $HOME/Programs/KanjiTomo/KanjiTomo.jar -run"
#alias gotop="gotop -l kitchensink"
alias 4ed="~/Programs/4coder/4ed"
alias odin="~/Programs/Odin/odin"
alias icat="kitty +kitten icat"
alias vim="nvim"
