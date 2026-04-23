#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

version="$(
  awk '
    BEGIN { in_fm=0 }
    /^---$/ {
      if (in_fm==0) { in_fm=1; next }
      if (in_fm==1) { exit }
    }
    in_fm==1 && $1=="version:" { print $2; exit }
  ' SKILL.md
)"

[ -n "$version" ] || {
  echo "未能从 SKILL.md frontmatter 读取版本号" >&2
  exit 1
}

check_contains() {
  local pattern="$1"
  local file="$2"
  local message="$3"

  if ! rg -q --fixed-strings -- "$pattern" "$file"; then
    echo "$message" >&2
    exit 1
  fi
}

check_regex() {
  local pattern="$1"
  local file="$2"
  local message="$3"

  if ! rg -q "$pattern" "$file"; then
    echo "$message" >&2
    exit 1
  fi
}

check_contains "version-${version}-blue.svg" README.md "README badge 版本号未同步到 ${version}"
check_contains "当前 v${version}" README.md "README 顶部当前版本未同步到 v${version}"
check_regex "^### v${version}（" CHANGELOG.md "CHANGELOG.md 缺少 v${version} 版本节"
check_contains "- **v${version}（" README.md "README 最近更新缺少 v${version} 条目"
check_contains "版本 ${version} 开发版" .cursorrules ".cursorrules 版本提示未同步到 ${version}"
check_contains "版本 ${version} 开发版" WARP.md "WARP.md 版本提示未同步到 ${version}"

echo "version sync ok: ${version}"
