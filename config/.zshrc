#!/usr/bin/zsh
if [ -z "$NEKO" ]; then
  export NEKO="$HOME/neko"
  PATH="$PATH:$NEKO/bin"
fi

source "$NEKO/shell/commonrc"

# Options
setopt \
  append_history \
  auto_menu \
  brace_ccl \
  no_clobber \
  no_correct \
  extended_history \
  no_flow_control \
  hist_ignore_dups \
  hist_ignore_space \
  hist_no_functions \
  no_hist_verify \
  inc_append_history_time \
  pushd_ignore_dups \
  rc_quotes

# Environment variables / settings
export HISTFILE="$HOME/.history"
export HISTSIZE=1000000
export SAVEHIST="$HISTSIZE"

alias help='info zsh "Shell Builtin Commands"'
alias mobile-mode='source $NEKO/mobile/zsh-mobile'

# global aliases
alias -g 'G+'='| grep' # Grep
alias -g 'J+'='| to-json'
alias -g 'L+'='| lines' # Lines
alias -g 'NE+'='2>/dev/null' # no error, or NULL error
alias -g 'NS+'='--name-status' # git option
alias -g 'Q+'='> /dev/null 2>&1' # Quiet - no stdout or stderr
alias -g 'X+'='| xargs -n1 -i' # Xargs

alt_widgets=(forward-word backward-word backward-delete-word)

for wname in ${alt_widgets}; do
  eval "
  alt-${wname} () {
    OLD_WORDCHARS=\"\$WORDCHARS\"
    WORDCHARS=\"\"

    # Do something
    zle ${wname}

    WORDCHARS=\"\$OLD_WORDCHARS\"
  }
  zle -N alt-${wname}
  "
done

kitsune-pushd () {
  if [ "$(pwd)" = "$HOME/projects/kitsune" ]; then
    pushd "$HOME/projects/kitsune-web" > /dev/null
  else
    pushd "$HOME/projects/kitsune" > /dev/null
  fi
  zle reset-prompt
}
zle -N kitsune-pushd

neko-pushd () {
  pushd $NEKO > /dev/null
  zle reset-prompt
}
zle -N neko-pushd

reload-config () {
  source ~/.zshrc > /dev/null
  zle -M "Config reloaded"
}
zle -N reload-config

# keymap
bindkey -e # emacs
bindkey "^[[A" up-line-or-search
bindkey "^[[B" down-line-or-search
bindkey "^N" neko-pushd
bindkey "^[k" kitsune-pushd
bindkey "^[r" reload-config

bindkey "^[[3~" delete-char # del key

bindkey "^[[1;5C" forward-word # ctrl-right
bindkey "^[[1;5D" backward-word # ctrl-left

bindkey "^[[1;3C" alt-forward-word # alt-right
bindkey "^[^[[C" alt-forward-word # alt-right (tmux)

bindkey "^[[1;3D" alt-backward-word # alt-left
bindkey "^[^[[D" alt-backward-word # alt-left (tmux)

bindkey "^[w" alt-backward-delete-word # alt-w

PROMPT='
%(?..%F{red}=> %?
)%F{white}%B[%h]%b %(#.%F{red}.%F{cyan})%n%f at %F{green}%M%f in %F{yellow}%~%f
$ '


# completion
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select=1
zstyle ':completion:*' rehash true

autoload -Uz compinit
compinit

auto_source=(
  "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  "$HOME/.neko/.zshrc"
)

for file in $auto_source; do
  if [ -f "$file" ]; then
    source "$file"
  fi
done

# extra

# highlight stderr in red
# exec 2>>( while read X; do print "\e[91m${X}\e[0m" > /dev/tty; done & )
