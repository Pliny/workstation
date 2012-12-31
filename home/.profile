OS=`uname`

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function

export REDISTOGO_URL='redis://localhost:6379'

export ANDROID_HOME="/usr/share/android-sdk-macosx"

alias h='history'

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
alias twc='task complete rc.report.complete.sort=Complete project:Morse'

alias restart_guard='launchctl stop com.davesdesrochers.guard'
alias stop_guard='launchctl unload -w ~/Library/LaunchAgents/com.davesdesrochers.guard.plist'
alias start_guard='rm -f /tmp/guard.std*; launchctl load -w ~/Library/LaunchAgents/com.davesdesrochers.guard.plist'

PS1='\[\e[1;32m\]\h:[\T][\!]:\w\$ >\[\e[0m\] '
PS2='> '
export PS1 PS2

export WORKON_HOME=$HOME/.virtualenvs
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true
