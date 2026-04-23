#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "$DIR"

before="$(git describe --tags --abbrev=0 2>/dev/null || echo '未知')"
git pull --ff-only
after="$(git describe --tags --abbrev=0 2>/dev/null || echo '未知')"

if [ "$before" = "$after" ]; then
  echo "qu-ai-wei $after — 已是最新"
else
  echo "qu-ai-wei: $before → $after"
  echo "本版变更：https://github.com/hzblacksmith/qu-ai-wei/releases/tag/$after"
fi
