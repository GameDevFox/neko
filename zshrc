source ~/royal-neko/commonrc
if [ -e ~/royal-neko/local/zshrc ]; then
	source ~/royal-neko/local/zshrc
fi

setopt autocd
setopt automenu
setopt autonamedirs
setopt braceccl
setopt cdablevars
setopt noclobber
setopt nocorrect
setopt extendedhistory
setopt nohistverify
setopt pushdignoredups
setopt rcquotes

alias help='info zsh "Shell Builtin Commands"'
alias mobile-mode='source ~/royal-neko/mobile/zsh-mobile'

alias -g SILENT='>/dev/null 2>&1'
