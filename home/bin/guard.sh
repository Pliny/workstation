#!/usr/bin/env bash

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function

which rvm > /dev/null && \
  rvm use ruby-1.9.3-p327 && \
  rvm gemset use score-tracker && \

  bundle exec guard start --no-interactions
