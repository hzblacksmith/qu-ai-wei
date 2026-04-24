#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# v0.6.5: 新增 06-12 样本时，如某条 assertion 暂时不达预期，把对应 fixture id 加到
# KNOWN_GAPS 里，对应的 block-specific assertions 会被跳过（但 tests/after/ 里
# 对应的输出保留为证据）。基础的 门检 / 终稿 / 打磨报告 presence 检查仍然执行。
# v0.6.6: 新增 13-17 小红书样本,覆盖 #47b 占位符 / info-block emoji 微模板 /
# 护肤成分白名单 / 身份标签+CTA 组合 / 老套路 2025-2026 复用。
# 条目格式："<id>:<v0.6.7 跟进说明>"
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
            tests/after/12-output.md \
            tests/after/13-output.md \
            tests/after/14-output.md \
            tests/after/15-output.md \
            tests/after/16-output.md \
            tests/after/17-output.md; do
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

# ---------- v0.6.6 block-specific assertions ----------

# 13 — XHS classic templates + #47b template placeholders
if ! is_known_gap "13"; then
  rg -q "【门检】判断[:：]AI 生成文本" tests/after/13-output.md || {
    echo "13-output.md 门检未判为 AI 生成文本" >&2
    exit 1
  }
  rg -q "#47b" tests/after/13-output.md || {
    echo "13-output.md 未命中 #47b 占位符硬证据" >&2
    exit 1
  }
  rg -q "#37-B" tests/after/13-output.md || {
    echo "13-output.md 未命中 #37-B 小红书老套路复用" >&2
    exit 1
  }
  # 终稿必须保留占位符 XX 路 + 标注"请核对",而不是发明具体地址
  extract_zhonggao tests/after/13-output.md | rg -q --fixed-strings "XX 路" || {
    echo "13-output.md 终稿未保留 XX 路占位符（#47b 规范:不修复不发明）" >&2
    exit 1
  }
  extract_zhonggao tests/after/13-output.md | rg -q "(请核对|待核|待确认)" || {
    echo "13-output.md 终稿未显式标注占位符'请核对'（#47b 规范）" >&2
    exit 1
  }
  # hashtag 压到 3 个左右
  if extract_zhonggao tests/after/13-output.md | rg -q "#吃货薯"; then
    echo "13-output.md 终稿仍含 #吃货薯 平台冗余标签" >&2
    exit 1
  fi
fi

# 14 — XHS OOTD + 已入土流行语 "绝绝子 / 气场两米八"
if ! is_known_gap "14"; then
  rg -q "【门检】判断[:：]AI 生成文本" tests/after/14-output.md || {
    echo "14-output.md 门检未判为 AI 生成文本" >&2
    exit 1
  }
  rg -q "#37-B" tests/after/14-output.md || {
    echo "14-output.md 未命中 #37-B" >&2
    exit 1
  }
  if extract_zhonggao tests/after/14-output.md | rg -q --fixed-strings "绝绝子"; then
    echo "14-output.md 终稿仍含已入土流行语 绝绝子" >&2
    exit 1
  fi
  if extract_zhonggao tests/after/14-output.md | rg -q --fixed-strings "气场两米八"; then
    echo "14-output.md 终稿仍含万能夸张 气场两米八" >&2
    exit 1
  fi
  # 具体单品保留
  extract_zhonggao tests/after/14-output.md | rg -q "(卡其色|风衣)" || {
    echo "14-output.md 终稿未保留具体单品" >&2
    exit 1
  }
fi

# 15 — XHS 办公教程 / 技术信息保护
if ! is_known_gap "15"; then
  rg -q "【门检】判断[:：]AI 生成文本" tests/after/15-output.md || {
    echo "15-output.md 门检未判为 AI 生成文本" >&2
    exit 1
  }
  rg -q "#37-B" tests/after/15-output.md || {
    echo "15-output.md 未命中 #37-B" >&2
    exit 1
  }
  # Excel 功能名 / 菜单路径必须保留
  extract_zhonggao tests/after/15-output.md | rg -q --fixed-strings "Ctrl+E" || {
    echo "15-output.md 终稿未保留 Excel 快捷键 Ctrl+E（技术信息保护）" >&2
    exit 1
  }
  extract_zhonggao tests/after/15-output.md | rg -q "快速填充" || {
    echo "15-output.md 终稿未保留功能名 快速填充" >&2
    exit 1
  }
  extract_zhonggao tests/after/15-output.md | rg -q "数据透视表" || {
    echo "15-output.md 终稿未保留功能名 数据透视表" >&2
    exit 1
  }
  # 身份+CTA 组合必须清理
  if extract_zhonggao tests/after/15-output.md | rg -q "不是梦"; then
    echo "15-output.md 终稿仍含 XX 不是梦 反向 CTA" >&2
    exit 1
  fi
fi

# 16 — XHS 护肤 / 成分白名单
if ! is_known_gap "16"; then
  rg -q "【门检】判断[:：]AI 生成文本" tests/after/16-output.md || {
    echo "16-output.md 门检未判为 AI 生成文本" >&2
    exit 1
  }
  rg -q "#37-B" tests/after/16-output.md || {
    echo "16-output.md 未命中 #37-B" >&2
    exit 1
  }
  # 护肤成分必须保留(SKILL.md 新增白名单核心场景)
  extract_zhonggao tests/after/16-output.md | rg -q "神经酰胺" || {
    echo "16-output.md 终稿未保留成分 神经酰胺（护肤白名单）" >&2
    exit 1
  }
  extract_zhonggao tests/after/16-output.md | rg -q --fixed-strings "B5" || {
    echo "16-output.md 终稿未保留成分 B5（护肤白名单）" >&2
    exit 1
  }
  extract_zhonggao tests/after/16-output.md | rg -q "氨基酸" || {
    echo "16-output.md 终稿未保留成分 氨基酸（护肤白名单）" >&2
    exit 1
  }
  extract_zhonggao tests/after/16-output.md | rg -q "皮肤屏障" || {
    echo "16-output.md 终稿未保留行业术语 皮肤屏障" >&2
    exit 1
  }
  # "修护 CP" 应该被 #9 同义词轮换清理掉
  if extract_zhonggao tests/after/16-output.md | rg -q --fixed-strings "修护 CP"; then
    echo "16-output.md 终稿仍含 修护 CP（营销词缝合,应按 #9 清理）" >&2
    exit 1
  fi
fi

# 17 — XHS 家居 / 毒性正能量缝合 + 俚语边界
if ! is_known_gap "17"; then
  rg -q "【门检】判断[:：]AI 生成文本" tests/after/17-output.md || {
    echo "17-output.md 门检未判为 AI 生成文本" >&2
    exit 1
  }
  rg -q "#49" tests/after/17-output.md || {
    echo "17-output.md 未命中 #49 毒性正能量缝合" >&2
    exit 1
  }
  # 毒性正能量缝合典型句式必须清理
  if extract_zhonggao tests/after/17-output.md | rg -q "房子是租的，但生活不是"; then
    echo "17-output.md 终稿仍含 #49 缝合句 房子是租的但生活不是" >&2
    exit 1
  fi
  # 身份+CTA 组合必须清理
  if extract_zhonggao tests/after/17-output.md | rg -q "租房党闭眼入|学生党、租房党闭眼入"; then
    echo "17-output.md 终稿仍含身份+CTA 组合堆叠" >&2
    exit 1
  fi
  # 具体好物类别保留
  extract_zhonggao tests/after/17-output.md | rg -q "暖光灯泡" || {
    echo "17-output.md 终稿未保留具体好物 暖光灯泡" >&2
    exit 1
  }
fi

echo "snapshot smoke ok"
