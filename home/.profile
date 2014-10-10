OS=`uname`

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function

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

alias restart_guard='launchctl stop com.davesdesrochers.guard'
alias stop_guard='launchctl unload -w ~/Library/LaunchAgents/com.davesdesrochers.guard.plist'
alias start_guard='rm -f /tmp/guard.std*; launchctl load -w ~/Library/LaunchAgents/com.davesdesrochers.guard.plist'

if [ `id -u` == 0 ]; then
  PS1_COLOR=35
  PS1_MARK="$)"
else
  PS1_COLOR=32
  PS1_MARK="$>"
fi

PS1="\\[\\e[1;${PS1_COLOR}m\\]\\u@[\\A][\\!]:\\w\\${PS1_MARK}\\[\\e[0m\\] "
PS2='. '
export PROMPT_DIRTRIM=3
export PS1 PS2

export WORKON_HOME=$HOME/.virtualenvs
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true
