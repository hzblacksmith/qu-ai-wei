#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# v0.6.5: 新增 06-12 样本时，如某条 assertion 暂时不达预期，把对应 fixture id 加到
# KNOWN_GAPS 里，对应的 block-specific assertions 会被跳过（但 tests/after/ 里
# 对应的输出保留为证据）。基础的 门检 / 终稿 / 打磨报告 presence 检查仍然执行。
# 条目格式："<id>:<v0.6.6 跟进说明>"
KNOWN_GAPS=()

is_known_gap() {
  local id="$1"
  local gap
  for gap in "${KNOWN_GAPS[@]:-}"; do
    [[ "${gap%%:*}" == "$id" ]] && return 0
  done
  return 1
}

# 提取 ## 终稿 到下一个 ## 章节之间的内容
extract_zhonggao() {
  awk '/^## *终稿/{flag=1; next} /^## /{flag=0} flag' "$1"
}

for file in tests/after/01-output.md \
            tests/after/02-output.md \
            tests/after/03-output.md \
            tests/after/04-output.md \
            tests/after/06-output.md \
            tests/after/07-output.md \
            tests/after/08-output.md \
            tests/after/09-output.md \
            tests/after/10-output.md \
            tests/after/11-output.md \
            tests/after/12-output.md; do
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

# ---------- v0.6.5 block-specific assertions ----------

# 06 — brand voice / negative activation
if ! is_known_gap "06"; then
  rg -q "【门检】判断[:：]AI 生成文本" tests/after/06-output.md || {
    echo "06-output.md 门检未判为 AI 生成文本" >&2
    exit 1
  }
  if rg -q "真人文本（停手）" tests/after/06-output.md; then
    echo "06-output.md 误判为真人文本停手（品牌广告应走 AI 判定）" >&2
    exit 1
  fi
  rg -q "(品牌广告|brand-voice)" tests/after/06-output.md || {
    echo "06-output.md 未识别品牌广告语体" >&2
    exit 1
  }
  extract_zhonggao tests/after/06-output.md | rg -q --fixed-strings "iPhone" || {
    echo "06-output.md 终稿未保留 iPhone" >&2
    exit 1
  }
  extract_zhonggao tests/after/06-output.md | rg -q --fixed-strings "Nike" || {
    echo "06-output.md 终稿未保留 Nike" >&2
    exit 1
  }
fi

# 07 — academic/tech / 语体降级保护
if ! is_known_gap "07"; then
  rg -q "【门检】判断[:：]AI 生成文本" tests/after/07-output.md || {
    echo "07-output.md 门检未判为 AI 生成文本" >&2
    exit 1
  }
  rg -q "(学术|科技)" tests/after/07-output.md || {
    echo "07-output.md 未识别学术 / 科技语体" >&2
    exit 1
  }
  extract_zhonggao tests/after/07-output.md | rg -q --fixed-strings "latency" || {
    echo "07-output.md 终稿未保留技术英文 latency" >&2
    exit 1
  }
  extract_zhonggao tests/after/07-output.md | rg -q --fixed-strings "进行" || {
    echo "07-output.md 终稿未保留学术标记 进行" >&2
    exit 1
  }
  extract_zhonggao tests/after/07-output.md | rg -q --fixed-strings "然而" || {
    echo "07-output.md 终稿未保留学术标记 然而" >&2
    exit 1
  }
  if extract_zhonggao tests/after/07-output.md | rg -q "(群里|哥们|@ 我|兄弟们)"; then
    echo "07-output.md 终稿出现口语化降格标记" >&2
    exit 1
  fi
fi

# 08 — weishendu consulting / #37-A
if ! is_known_gap "08"; then
  rg -q "【门检】判断[:：]AI 生成文本" tests/after/08-output.md || {
    echo "08-output.md 门检未判为 AI 生成文本" >&2
    exit 1
  }
  rg -q "#37" tests/after/08-output.md || {
    echo "08-output.md 未命中 #37" >&2
    exit 1
  }
fi

# 09 — XHS healing / #37-B
if ! is_known_gap "09"; then
  rg -q "【门检】判断[:：]AI 生成文本" tests/after/09-output.md || {
    echo "09-output.md 门检未判为 AI 生成文本" >&2
    exit 1
  }
  rg -q "#37" tests/after/09-output.md || {
    echo "09-output.md 未命中 #37" >&2
    exit 1
  }
  rg -q "#51" tests/after/09-output.md || {
    echo "09-output.md 未命中 #51（第二人称泛化）" >&2
    exit 1
  }
fi

# 10 — B 站 AI 解说稿 / #50-B
if ! is_known_gap "10"; then
  rg -q "【门检】判断[:：]AI 生成文本" tests/after/10-output.md || {
    echo "10-output.md 门检未判为 AI 生成文本" >&2
    exit 1
  }
  rg -q "#50" tests/after/10-output.md || {
    echo "10-output.md 未命中 #50" >&2
    exit 1
  }
fi

# 11 — negation stacking / #48 density
if ! is_known_gap "11"; then
  rg -q "【门检】判断[:：]AI 生成文本" tests/after/11-output.md || {
    echo "11-output.md 门检未判为 AI 生成文本" >&2
    exit 1
  }
  rg -q "#48" tests/after/11-output.md || {
    echo "11-output.md 未命中 #48" >&2
    exit 1
  }
  rg -q "#10" tests/after/11-output.md || {
    echo "11-output.md 未命中 #10（与 #48 联动）" >&2
    exit 1
  }
fi

# 12 — table abuse / #45 first I-category
if ! is_known_gap "12"; then
  rg -q "【门检】判断[:：]AI 生成文本" tests/after/12-output.md || {
    echo "12-output.md 门检未判为 AI 生成文本" >&2
    exit 1
  }
  rg -q "#45" tests/after/12-output.md || {
    echo "12-output.md 未命中 #45" >&2
    exit 1
  }
fi

echo "snapshot smoke ok"
