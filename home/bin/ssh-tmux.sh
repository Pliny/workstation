#!/bin/sh

if [ -n "$TMUX" ]; then
  echo Already in tmux
  exit 1
fi

if [ -n "$STY" ]; then
  echo Already in screen
  exit 1
fi

ARGS="$@"
while true; do
  # echo "ssh -t $ARGS \"tmux -2 -L default attach || tmux -2 -L default\""
  ssh -t $ARGS "tmux -2 -L default attach || tmux -2 -L default"

  stty sane
  echo "Dropped, press Enter to reconnect."
  if read x; then
    echo "Reconnecting..."
  else
    # Something bad happened to our tty. We'd better exit.
    exit 1
  fi
done

