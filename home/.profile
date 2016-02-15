OS=`uname`

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function

[[ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]] && \
  . /usr/share/git-core/contrib/completion/git-prompt.sh
[[ -f /usr/local/git/contrib/completion/git-prompt.sh ]] && \
  . /usr/local/git/contrib/completion/git-prompt.sh
[[ -f /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash ]] && \
  . /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash
[[ -f /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh ]] && \
  . /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh

export REDISTOGO_URL='redis://localhost:6379'

export ANDROID_HOME="/usr/share/android-sdk-macosx"

alias h='history'

# TMUX
if [ $OS == "Linux" -a `id -u` != 0 ]; then
  if which tmux 2>&1 >/dev/null; then
    test -z "$TMUX" && (tmux attach || tmux -2 new-session)
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
gl() { if [ $1 ]; then LINE=`echo $1 | sed 's/-//'`; else LINE=16; fi; git log -$LINE --graph --pretty='%h %Cgreen%an %ai %C(yellow) %s'; }

alias tw='task'
alias twc='task complete rc.report.complete.sort=Complete'

if [ $OS == "Linux" ]; then
  alias psc='ps xawf -eo pid,user,cgroup,args'
fi

alias lsu='ls /dev/ttyU*'
alias msg='G_MESSAGES_DEBUG=all'
alias kmake='make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-'


Yellow="\[\033[0;33m\]"       # Yellow
Green="\[\033[0;32m\]"        # Green
IGreen="\[\033[0;92m\]"       # Green
BIGreen="\[\033[1;92m\]"      # Green
IRed="\[\033[0;91m\]"         # Red
IBlack="\[\033[0;90m\]"       # Black
BIPurple="\[\033[1;95m\]"     # Purple
Color_Off="\[\033[0m\]"       # Text Reset
PathShort="\w"
Time12h="\A"

DEFAULT_COLOR=$BIGreen

if [ `id -u` == 0 ]; then
  PS1_COLOR=$BIPurple
  PS1_MARK="$) "
else
  PS1_COLOR=$DEFAULT_COLOR
  PS1_MARK="$> "
fi

GIT_PS1_SHOWUPSTREAM="verbose"

export PS1=$IBlack[$Time12h]$'$(
  if [ "${PROMPT_COMMAND/navdy}" != "$PROMPT_COMMAND" ]; then
    echo "'$Color_Off'(nenv)";
  fi
)'$PS1_COLOR:'$(
  if git branch &>/dev/null; then
    if git status | grep "nothing to commit" &> /dev/null; then
      echo "'$PS1_COLOR'"$(__git_ps1 "(%s)");
    else
      echo "'$IRed'"$(__git_ps1 "{%s}");
    fi
  fi
)'$PS1_COLOR:$PathShort$PS1_MARK$Color_Off

PS2='. '
export PROMPT_DIRTRIM=3
export PS1 PS2

export WORKON_HOME=$HOME/.virtualenvs
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

[ "$OS" = "Linux" -a -d "/opt/gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux/bin" ] && \
  export PATH="/opt/gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux/bin/:$PATH"

[ "$OS" = "Darwin" -a -d "$HOME/Library/Android/sdk/platform-tools" ] && \
  export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
