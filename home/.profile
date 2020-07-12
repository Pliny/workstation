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

[[ -f /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-prompt.sh ]] && \
  . /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-prompt.sh
[[ -f /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash ]] && \
  . /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash

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

alias mi='make install'
alias mc='make clean'
alias mm='make'
alias d='git difftool'
alias gst='git status'
alias gbr='git branch'
alias wb='west build'
alias wf='west flash --flash-opt="-e=chip"'
alias wa='west attach'
alias wd='west debug --flash-opt="-e=chip"'
gl() { if [ $1 ]; then LINE=`echo $1 | sed 's/-//'`; else LINE=16; fi; git log -$LINE --graph --pretty='%h %Cgreen%an %ai %C(yellow) %s'; }
ec2fetchimg() { if [ $1 ]; then image=`echo $1`; else image=`echo '*.{img.imx}'`; fi; outdir=$(mktemp -d); scp ${ec2}:/home/ubuntu/aosp/out/target/product/apollo/${image} ${outdir} && echo ${outdir}/${image}; }

alias tw='task'
alias twc='task complete rc.report.complete.sort=Complete'
function twp() { task project:${1}; }

if [ $OS == "Linux" ]; then
  alias psc='ps xawf -eo pid,user,cgroup,args'
fi

alias lsu='ls /dev/ttyU*'
alias msg='G_MESSAGES_DEBUG=all'
alias kmake='make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-'
alias adbshell='adb wait-for-device; adb shell'
alias awssync='aws s3 sync s3://navdy-manufacturing/foxconn .'

alias fast-ble="sudo hcitool lecup --handle \`hcitool conn | tail -1 | awk '{print \$5}'\` --min=8 --max=8 --latency=0 --timeout=500"
alias wccache="watch -n1 -d ccache -s"
alias r='fc -s'


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

function add_to_path_maybe()
{
  local requested_OS=$1
  local newpath=$2

  [ "$OS" = "$requested_OS" -a -d $newpath ] && \
    ! $(echo $PATH | grep -q $newpath) && \
    export PATH="${newpath}${PATH+:}${PATH}"
}

PS2='. '
export PROMPT_DIRTRIM=3
export PS1 PS2

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

add_to_path_maybe "Darwin" "$HOME/Library/Android/sdk/platform-tools" 
add_to_path_maybe "Linux" "$HOME/.local/bin"

export USE_CCACHE=1

# For Beaconhome
export ec2='ec2-52-43-38-248.us-west-2.compute.amazonaws.com'
alias ec2login="ssh ${ec2}"
