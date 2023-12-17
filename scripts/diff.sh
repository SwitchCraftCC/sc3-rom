#!/usr/bin/env bash
set -x

if [ ! -d "CC-Tweaked" ]; then
  git clone https://github.com/CC-Tweaked/CC-Tweaked.git
else
  git -C CC-Tweaked pull -q
fi

find switchcraft -type f | sed -e 's/switchcraft\///' | while read file; do
  if [ -f "CC-Tweaked/projects/core/src/main/resources/$file" ]; then
    grc diff -u "switchcraft/$file" "CC-Tweaked/projects/core/src/main/resources/$file"
  fi
done
