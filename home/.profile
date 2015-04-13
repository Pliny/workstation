OS=`uname`

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function

[[ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]] && \
  . /usr/share/git-core/contrib/completion/git-prompt.sh

export REDISTOGO_URL='redis://localhost:6379'

export ANDROID_HOME="/usr/share/android-sdk-macosx"

alias h='history'

# TMUX
if [ $OS == "Linux" -a `id -u` != 0 ]; then
  if which tmux 2>&1 >/dev/null; then
    test -z "$TMUX" && (tmux attach || tmux new-session)
  fi
fi

if [ $OS == "Linux" ]; then
  alias ls='ls --color'
else
  alias ls='ls -G'
fi

alias d='git difftool'
alias gst='git status'
alias gbr='git branch'
gl() { if [ $1 ]; then LINE=`echo $1 | sed 's/-//'`; else LINE=16; fi; git log -$LINE --graph --pretty='%h %Cblue%an %ai %C(yellow) %s'; }

alias tw='task'
alias twc='task complete rc.report.complete.sort=Complete'

if [ $OS == "Linux" ]; then
  alias psc='ps xawf -eo pid,user,cgroup,args'
fi

Yellow="\[\033[0;33m\]"       # Yellow
Green="\[\033[0;32m\]"        # Green
IRed="\[\033[0;91m\]"         # Red
IBlack="\[\033[0;90m\]"       # Black
Purple="\[\033[0;35m\]"       # Purple
Color_Off="\[\033[0m\]"       # Text Reset
PathShort="\w"
Time12h="\T"

if [ `id -u` == 0 ]; then
  PS1_COLOR=$Purple
  PS1_MARK="$) "
else
  PS1_COLOR=$Green
  PS1_MARK="$> "
fi

export PS1=$PS1_COLOR[$Time12h]:$Color_Off'$(
  if /usr/bin/git branch &>/dev/null; then
    if /usr/bin/git status | /usr/bin/grep "nothing to commit" &> /dev/null; then
      /usr/bin/echo "'$PS1_COLOR'"$(__git_ps1 "(%s)");
    else
      /usr/bin/echo "'$IRed'"$(__git_ps1 "{%s}");
    fi
  fi
)'$PS1_COLOR:$PathShort$PS1_MARK$Color_Off

PS2='. '
export PROMPT_DIRTRIM=3
export PS1 PS2

export WORKON_HOME=$HOME/.virtualenvs
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true

[ -d ~/Documents/MorseProject ] && cd ~/Documents/MorseProject
