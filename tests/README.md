# tests/

回归用的 3 条 AI 腔样本,用来证明 v0.6.2 的"结构重构但行为不变"。

## 目录

- **`fixtures/`** — 原始样本
  - `01-ai-zh-overview.md` — "AI 生成中文内容" 工具罗列式概述。测语体判断(落在书面 / 一般,不是学术 / 科技)、#5 模糊权威归因、#17 中英括注、#47 AI 源 URL 残留、事实发明禁令(原文纯工具名单,不能编 stats)。
  - `02-gongzhonghao-weishendu.md` — "为什么你越努力反而像个废物" 公众号伪深度咨询腔。测 #37-A 主诊断、#48 "这不是 X 而是 Y" 堆叠、#25 破折号滥用、事实发明禁令(原文通篇抽象,不能编"妈妈打电话")。
  - `03-xhs-kimi-anli.md` — 小红书 Kimi 安利案例。测 #37-B 伪疗愈 / 伪搞钱、#24 emoji 装饰、#45 表格滥用(保留结构清装饰)、#29 空洞积极结尾、事实发明禁令(原文有 Moonshot AI / 200万字 / 三个月等具体事实,要保留)。

- **`baseline/`** — v0.6.1 的 SKILL.md(2533 行单文件)对 3 条 fixture 的完整工作流输出。子代理于 2026-04-22 生成,作为重构前的行为快照。

- **`after/`** — v0.6.2 的 SKILL.md(1207 行核心 + references/ 按需加载)对同 3 条 fixture 的完整工作流输出。同日生成,用于跟 baseline 对照。

## 怎么复核

```bash
# 对照 baseline 和 after,看语体判断、rules triggered、事实发明禁令遵守情况是否一致。
diff tests/baseline/01-output.md tests/after/01-output.md | head -100
diff tests/baseline/02-output.md tests/after/02-output.md | head -100
diff tests/baseline/03-output.md tests/after/03-output.md | head -100
```

**判据:** baseline 和 after 在以下维度应当一致(允许文字措辞细微差异):

1. **语体判断一致** — 01 书面 / 一般;02 内容 / 自媒体(#37-A 伪深度);03 内容 / 自媒体(小红书 / 伪疗愈)。
2. **触发规则集合一致**(±1-2 条细枝末节可容忍) — 核心 rules 不漏。
3. **事实发明禁令遵守一致** — 01 / 02 都应选择"报告原文缺乏毛边"而非发明毛边;03 应保留 Moonshot AI / 200万字 / 三个月等原文事实,不增不减。
4. **打磨报告格式一致** — 都是 v0.6.0 六条 craft moves + 可观察指标,例子都是字面引用。
5. **门检行有输出** — 都有 `【门检】判断:AI 生成文本 | 证据:...` 一行。

**如果看到任何差异,先看是否是:** (a) 结构重构本身引入的漂移,要修;(b) 自然语言生成的随机措辞差异,在预期容忍范围。

## 怎么跑新一轮回归

任何改动(新规则、规则合并、语体矩阵调整、硬约束增减)都建议用这 3 条样本跑一次回归:

```bash
# 手工法:用一个干净会话,让模型读 SKILL.md + 当前 references/,逐个处理 fixtures/
# 输出到 tests/after/(或新建 tests/after-<versiontag>/),然后 diff 旧 after。
```

未来可以加自动化(让 build-flat.sh 附带一个 `--eval` 模式调 API 跑这 3 条,参考 README 里提到的 `tests/integration-run/` 本地管道)。目前保持最简单:3 条人工 + 肉眼 diff。
