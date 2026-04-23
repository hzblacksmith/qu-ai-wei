#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

DEFAULT_NAME="qu-ai-wei"
NAME="$DEFAULT_NAME"
MODE="symlink"
FORCE=0
DRY_RUN=0
PLATFORM_ARGS=()
CUSTOM_ROOTS=()

ALL_PLATFORMS=(codex cursor factory slate kiro hermes)

usage() {
  cat <<'EOF'
install-skill.sh [options]

Install this skill to platform-native skills directories.

At least one of:
  --platform <name>    codex | cursor | factory | slate | kiro | hermes | all
                       Can be repeated or comma-separated.
  --to <skills-dir>    Custom skills root directory. Can be repeated.

Optional:
  --name <dir>         Skill directory name under <skills-dir>/ (default: qu-ai-wei)
  --mode <mode>        symlink | copy (default: symlink)
  --force              Replace existing target directory/symlink
  --dry-run            Print planned actions without changing files
  -h, --help           Show this help

Examples:
  bash scripts/install-skill.sh --platform codex
  bash scripts/install-skill.sh --platform cursor --platform slate
  bash scripts/install-skill.sh --platform codex,cursor,factory --name qu-ai-wei
  bash scripts/install-skill.sh --platform all --force
  bash scripts/install-skill.sh --to ~/.my-agent/skills --name qu-ai-wei
EOF
}

normalize_platform() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]'
}

has_item() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    if [ "$item" = "$needle" ]; then
      return 0
    fi
  done
  return 1
}

platform_root() {
  case "$1" in
    codex)   printf '%s/.codex/skills' "$HOME" ;;
    cursor)  printf '%s/.cursor/skills' "$HOME" ;;
    factory) printf '%s/.factory/skills' "$HOME" ;;
    slate)   printf '%s/.slate/skills' "$HOME" ;;
    kiro)    printf '%s/.kiro/skills' "$HOME" ;;
    hermes)  printf '%s/.hermes/skills' "$HOME" ;;
    *) return 1 ;;
  esac
}

run_cmd() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    --platform|--host)
      [ $# -ge 2 ] || { echo "错误: $1 缺少参数" >&2; exit 1; }
      PLATFORM_ARGS+=("$2")
      shift 2
      ;;
    --to)
      [ $# -ge 2 ] || { echo "错误: --to 缺少参数" >&2; exit 1; }
      CUSTOM_ROOTS+=("$2")
      shift 2
      ;;
    --name)
      [ $# -ge 2 ] || { echo "错误: --name 缺少参数" >&2; exit 1; }
      NAME="$2"
      shift 2
      ;;
    --mode)
      [ $# -ge 2 ] || { echo "错误: --mode 缺少参数" >&2; exit 1; }
      MODE="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "错误:未知参数 $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

[ "${#PLATFORM_ARGS[@]}" -gt 0 ] || [ "${#CUSTOM_ROOTS[@]}" -gt 0 ] || {
  echo "错误: 请至少指定 --platform 或 --to" >&2
  usage >&2
  exit 1
}

if [ "$MODE" != "symlink" ] && [ "$MODE" != "copy" ]; then
  echo "错误: --mode 只能是 symlink 或 copy" >&2
  exit 1
fi

TARGET_ROOTS=()
TARGET_LABELS=()

add_target_root() {
  local root="$1"
  local label="$2"
  if [ "${#TARGET_ROOTS[@]}" -eq 0 ]; then
    TARGET_ROOTS+=("$root")
    TARGET_LABELS+=("$label")
    return
  fi
  if ! has_item "$root" "${TARGET_ROOTS[@]}"; then
    TARGET_ROOTS+=("$root")
    TARGET_LABELS+=("$label")
  fi
}

arg=""
entry=""
norm=""
if [ "${#PLATFORM_ARGS[@]}" -gt 0 ]; then
  for arg in "${PLATFORM_ARGS[@]}"; do
    IFS=',' read -r -a entries <<< "$arg"
    for entry in "${entries[@]}"; do
      norm="$(normalize_platform "$entry")"
      [ -n "$norm" ] || continue
      if [ "$norm" = "all" ]; then
        for entry in "${ALL_PLATFORMS[@]}"; do
          add_target_root "$(platform_root "$entry")" "$entry"
        done
        continue
      fi
      if ! platform_root "$norm" >/dev/null 2>&1; then
        echo "错误: 不支持的平台 '$norm'" >&2
        echo "支持: codex, cursor, factory, slate, kiro, hermes, all" >&2
        exit 1
      fi
      add_target_root "$(platform_root "$norm")" "$norm"
    done
  done
fi

root=""
if [ "${#CUSTOM_ROOTS[@]}" -gt 0 ]; then
  for root in "${CUSTOM_ROOTS[@]}"; do
    [ -n "$root" ] || continue
    if [ "${root#~/}" != "$root" ]; then
      root="$HOME/${root#~/}"
    fi
    root="${root%/}"
    add_target_root "$root" "custom"
  done
fi

[ "${#TARGET_ROOTS[@]}" -gt 0 ] || { echo "错误: 没有可安装的目标目录" >&2; exit 1; }

if [ "$MODE" = "copy" ] && ! command -v rsync >/dev/null 2>&1; then
  echo "错误: copy 模式依赖 rsync，但当前环境没有 rsync" >&2
  exit 1
fi

echo "repo:   $REPO_ROOT"
echo "name:   $NAME"
echo "mode:   $MODE"
echo "targets:"
for root in "${TARGET_ROOTS[@]}"; do
  echo "  - $root/$NAME"
done
echo ""

dest=""
idx=0
label=""
for idx in "${!TARGET_ROOTS[@]}"; do
  root="${TARGET_ROOTS[$idx]}"
  label="${TARGET_LABELS[$idx]}"
  dest="$root/$NAME"

  run_cmd mkdir -p "$root"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ "$FORCE" -ne 1 ]; then
      echo "错误: 目标已存在: $dest (加 --force 覆盖)" >&2
      exit 1
    fi
    run_cmd rm -rf "$dest"
  fi

  if [ "$MODE" = "symlink" ]; then
    run_cmd ln -s "$REPO_ROOT" "$dest"
  else
    run_cmd mkdir -p "$dest"
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "[dry-run] rsync -a --delete --exclude .git/ --exclude .gitignore $REPO_ROOT/ $dest/"
    else
      rsync -a --delete --exclude ".git/" --exclude ".gitignore" "$REPO_ROOT/" "$dest/"
    fi
  fi

  echo "✔ [$label] -> $dest"
done

echo ""
echo "完成。"
