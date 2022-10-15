#!/usr/bin/env bash
set -x

if [ ! -d "CC-Tweaked" ]; then
  git clone https://github.com/SquidDev-CC/CC-Tweaked.git
else
  git -C CC-Tweaked pull -q
fi

find switchcraft -type f | sed -e 's/switchcraft\///' | while read file; do
  if [ -f "CC-Tweaked/src/main/resources/$file" ]; then
    diff -u "switchcraft/$file" "CC-Tweaked/src/main/resources/$file"
  fi
done
