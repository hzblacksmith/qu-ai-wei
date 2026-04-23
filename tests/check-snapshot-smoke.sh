#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

for file in tests/after/01-output.md tests/after/02-output.md tests/after/03-output.md tests/after/04-output.md; do
  rg -q "【门检】" "$file" || {
    echo "$file 缺少门检行" >&2
    exit 1
  }
  rg -q "终稿" "$file" || {
    echo "$file 缺少终稿段" >&2
    exit 1
  }
  rg -q "打磨报告" "$file" || {
    echo "$file 缺少打磨报告" >&2
    exit 1
  }
done

rg -q "否定对举" tests/after/04-output.md || {
  echo "04-output.md 未覆盖 #48 否定对举" >&2
  exit 1
}
rg -q "两周" tests/after/04-output.md || {
  echo "04-output.md 未回落到原文已有的具体事实" >&2
  exit 1
}

rg -q "【门检】判断：真人文本（停手）" tests/after/05-output.md || {
  echo "05-output.md 未在门检停手" >&2
  exit 1
}

echo "snapshot smoke ok"
