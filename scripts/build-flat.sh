#!/usr/bin/env bash
# build-flat.sh — 把模块化的 SKILL.md + references/ 拍平,生成 .cursorrules 和 WARP.md
#
# Claude Code / OpenCode 原生支持 SKILL.md 的 references/ 按需加载;
# Cursor / Windsurf(.cursorrules) / Warp(WARP.md) 不支持 progressive disclosure —— 必须拍平成单文件。
# 本脚本把 SKILL.md 的 references 指针替换成对应 references/*.md 的完整内容,并去掉 SKILL.md 的 YAML frontmatter。
#
# 运行时机:任何时候修改 SKILL.md 或 references/ 后,在 commit 前运行一次。
# 建议挂到 pre-commit hook 或 CI。

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
cd "$DIR"

SKILL="$DIR/SKILL.md"
PATTERNS="$DIR/references/patterns.md"
BRAND="$DIR/references/brand-voice.md"
MODELS="$DIR/references/reference-models.md"
EXAMPLES="$DIR/references/examples.md"
SOURCES="$DIR/references/sources.md"

for f in "$SKILL" "$PATTERNS" "$BRAND" "$MODELS" "$EXAMPLES" "$SOURCES"; do
  [ -f "$f" ] || { echo "错误:找不到 $f"; exit 1; }
done

# 从 SKILL.md frontmatter 读取版本号，避免 .cursorrules / WARP.md 顶部版本提示漂移
SKILL_VERSION="$(
  awk '
    BEGIN { in_fm=0 }
    /^---$/ {
      if (in_fm==0) { in_fm=1; next }
      if (in_fm==1) { exit }
    }
    in_fm==1 && $1=="version:" { print $2; exit }
  ' "$SKILL"
)"
[ -n "$SKILL_VERSION" ] || SKILL_VERSION="0.x"

# 从 references/*.md 去掉顶部"本文件是..." 的 preamble + YAML-like 元注释(保留从第一个 ## 开始的内容)
strip_preamble() {
  awk 'BEGIN{skip=1} /^## /{skip=0} skip==0{print}' "$1"
}

# 把 SKILL.md 里的四个 pointer block("## 完整示例" / "## 正面参考模型" / "## 参考来源" / "## 51 条 AI 腔模式 · 索引表" 末尾)
# 直接保留 —— 因为拍平后的版本应该是**索引 + 详情并存**,而不是替换。
# 详情在文件底部追加一个 "## 附录:规则详情 / 示例 / 参考" 大节,照顺序嵌入。

TMP="$(mktemp)"
trap "rm -f $TMP" EXIT

# 1. SKILL.md 正文(去掉 YAML frontmatter,即前两条 "---" 之间的部分)
# 注意:body 里也有 "---" 作为 section 分隔线,不能一刀切 —— 只跳过前两条。
awk '
  fm<2 && /^---$/ { fm++; next }
  fm<2 { next }
  fm>=2 { print }
' "$SKILL" > "$TMP"

# 2. 附上每个 references/ 文件的内容(去掉 preamble),包一层二级标题作为导航锚
{
  cat "$TMP"
  echo ""
  echo "---"
  echo ""
  echo "# 附录:规则详情与参考资料(flat build)"
  echo ""
  echo "> 此节由 \`scripts/build-flat.sh\` 从 \`references/\` 自动拼接生成,供 Cursor / Windsurf / Warp 等不支持 progressive disclosure 的平台使用。Claude Code / OpenCode 环境请直接读 SKILL.md + references/ 下的对应文件。"
  echo ""
  echo "---"
  echo ""
  strip_preamble "$PATTERNS"
  echo ""
  echo "---"
  echo ""
  strip_preamble "$BRAND"
  echo ""
  echo "---"
  echo ""
  echo "## 正面参考模型(完整)"
  echo ""
  strip_preamble "$MODELS"
  echo ""
  echo "---"
  echo ""
  echo "## 完整示例(完整)"
  echo ""
  strip_preamble "$EXAMPLES"
  echo ""
  echo "---"
  echo ""
  echo "## 参考来源(完整)"
  echo ""
  strip_preamble "$SOURCES"
} > "$DIR/WARP.md.tmp"

# 3. .cursorrules 跟 WARP.md 基本一样,只是前置说明不同
{
  echo "# qu-ai-wei · 去 AI 味 (Cursor / Windsurf rules)"
  echo ""
  echo "> 这是 qu-ai-wei 的 Cursor / Windsurf 兼容版本,与 Claude Code / OpenCode 版本的 \`SKILL.md\` + \`references/\` 内容一致,由 \`scripts/build-flat.sh\` 拍平成单文件(去掉了 YAML frontmatter,references/ 内容附在文末\`附录\`节)。"
  echo ">"
  echo "> **在 Cursor 中使用:** 把本文件放到项目根目录并命名为 \`.cursorrules\`(已是此名),Cursor 会自动作为项目级指令加载。"
  echo "> **在 Windsurf 中使用:** 复制一份并命名为 \`.windsurfrules\`。"
  echo ">"
  echo "> 之后用户说「帮我去 AI 味 / 改得说人话 / 写得更通俗 / humanize 这段中文」等,模型就会按本规则清理中文 AI 腔。"
  echo ">"
  echo "> ⚠️ **版本 ${SKILL_VERSION} 开发版,只支持简体中文。** 繁體版本留给后续迭代。"
  echo ""
  echo ""
  cat "$DIR/WARP.md.tmp"
} > "$DIR/.cursorrules.tmp"

# WARP.md 加自己的前置说明
{
  echo "# qu-ai-wei · 去 AI 味 (Warp rules)"
  echo ""
  echo "> 这是 qu-ai-wei 的 Warp 兼容版本,与 Claude Code / OpenCode 版本的 \`SKILL.md\` + \`references/\` 内容一致,由 \`scripts/build-flat.sh\` 拍平成单文件。"
  echo ">"
  echo "> **在 Warp 中使用:** 把本文件放到项目根目录,或 \`~/.warp/WARP.md\` 全局生效。"
  echo ">"
  echo "> 之后用户说「帮我去 AI 味 / 改得说人话」等,模型就会按本规则清理中文 AI 腔。"
  echo ">"
  echo "> ⚠️ **版本 ${SKILL_VERSION} 开发版,只支持简体中文。**"
  echo ""
  echo ""
  cat "$DIR/WARP.md.tmp"
} > "$DIR/WARP.md.new"

mv "$DIR/.cursorrules.tmp" "$DIR/.cursorrules"
mv "$DIR/WARP.md.new" "$DIR/WARP.md"
rm -f "$DIR/WARP.md.tmp"

echo "build-flat.sh 完成:"
echo "  SKILL.md     $(wc -l < "$DIR/SKILL.md") 行"
echo "  .cursorrules $(wc -l < "$DIR/.cursorrules") 行"
echo "  WARP.md      $(wc -l < "$DIR/WARP.md") 行"
