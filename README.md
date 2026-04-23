# 去 AI 味（qu-ai-wei）

[![Version](https://img.shields.io/badge/version-0.5.5-blue.svg)](https://github.com/hzblacksmith/qu-ai-wei/releases)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)
[![Language](https://img.shields.io/badge/lang-简体中文-red.svg)](#)
[![GitHub stars](https://img.shields.io/github/stars/hzblacksmith/qu-ai-wei?style=social)](https://github.com/hzblacksmith/qu-ai-wei/stargazers)

> ⚠️ **0.5 开发版**：规则、分类和行为仍在迭代中，欢迎提 [issue](https://github.com/hzblacksmith/qu-ai-wei/issues) / [discussion](https://github.com/hzblacksmith/qu-ai-wei/discussions) / PR。
>
> **当前只支持简体中文。** 繁體中文会在后续版本单独维护。

`qu-ai-wei` 是一套“中文去 AI 腔”规则。它做的是文字层面的清理：去掉机械模板感、降低空话密度、修翻译腔残留，同时尽量保留原文信息和语气。

支持平台：Claude Code、OpenCode、Cursor、Windsurf、Warp，以及其他支持自定义指令的模型。

## 这个项目到底做什么

- 输入：一段简体中文（常见于 AI 初稿、营销文案、工作文档）。
- 输出：更自然、更像真人写作节奏的版本。
- 方法：先判“要不要改”，再判语体，再按规则密度改写，不做盲目一刀切。
- 边界：它是清理工具，不是“代你写好文章”的工具。

## 先看边界（建议先读）

### 适合

- 想把 AI 初稿改得不那么像 AI。
- 需要批量清理明显模板腔（邮件、PRD、汇报、技术博客、平台内容）。
- 想保留原意前提下，把文字改得更顺、更像中文母语表达。

### 不适合

- 用来“伪装没写过的内容”或绕过 AI 检测政策。
- 需要深度采访、独到观点、强叙事能力的写作任务（工具无法替代判断力）。
- 对语体稳定性要求极高的文本（如学术、公文、法律），这类文本建议保守使用。

一句话：**它擅长去机械感，不负责补思想。**

## 安装

### Claude Code

```bash
# 方法一：git clone（推荐）
git clone https://github.com/hzblacksmith/qu-ai-wei.git ~/.claude/skills/qu-ai-wei

# 方法二：手动下载
# 从 GitHub 下载 zip，解压到 ~/.claude/skills/qu-ai-wei/
```

### OpenCode

OpenCode 会扫描 `~/.claude/skills/`，如果你已经按 Claude Code 的方式安装，通常会自动识别。也可以放在 `~/.config/opencode/skills/qu-ai-wei/`。

### Cursor / Windsurf

把 `.cursorrules` 复制到项目根目录：

```bash
# 先 clone（如已装 Claude Code 可跳过）
git clone https://github.com/hzblacksmith/qu-ai-wei.git ~/qu-ai-wei

# 复制到项目根
cp ~/qu-ai-wei/.cursorrules /path/to/your-project/.cursorrules
# Windsurf：同时复制一份为 .windsurfrules
cp ~/qu-ai-wei/.cursorrules /path/to/your-project/.windsurfrules
```

### Warp

把 `WARP.md` 放到项目根目录，或 `~/.warp/WARP.md` 全局生效：

```bash
# 先 clone（如已装 Claude Code 可跳过）
git clone https://github.com/hzblacksmith/qu-ai-wei.git ~/qu-ai-wei

# 项目级
cp ~/qu-ai-wei/WARP.md /path/to/your-project/WARP.md
# 或全局
cp ~/qu-ai-wei/WARP.md ~/.warp/WARP.md
```

### 其他支持自定义指令的模型（ChatGPT / DeepSeek / Kimi / 通义 等）

把 [`SKILL.md`](./SKILL.md) 正文粘到系统提示或自定义指令中（跳过顶部 YAML frontmatter）。

## 用法

### 自然语言触发（推荐）

```text
帮我去 AI 味：[粘贴中文]
改得说人话：[粘贴中文]
这段中文太 AI 了，润色一下：[粘贴中文]
让它更像人写的：[粘贴中文]
humanize 这段中文：[粘贴中文]
```

### 显式调用（slash 命令）

```text
/qu-ai-wei

[粘贴你要改写的中文]
```

### 字形范围

**只处理简体中文。** 繁體输入会提示先转简体，不会自动转换。

| 调用 | 行为 |
|---|---|
| `/qu-ai-wei <text>`（简体） | 按 51 条规则 + 语体识别 + 顶层硬约束改写 |
| `/qu-ai-wei <text>`（繁體） | 提示用户先转简体 |
| `/qu-ai-wei`（无参） | 询问用户粘贴文本；可选做轻量语音校准 |

### 语音校准（可选）

```text
/qu-ai-wei

以下是我自己的写作样本，用来做风格参考：
[粘贴 2–3 段你的文字]

现在请改写这段：
[粘贴 AI 写的中文]
```

系统会先提取一份 5 项轻量清单（高频词、平均句长、段首词、标点偏好、整体语域），确认后再改写。

## 工作机制（简版）

1. **门检先行**：先判断是不是“真人文本”。如果是，原则上停手，只做格式清理。
2. **语体识别**：在 9 种语体里先归类（社交、自媒体、商务、书面、特稿、品牌广告、学术、公文、高考应试）。
3. **规则密度触发**：不是“出现就改”，而是看堆叠密度和上下文。
4. **硬约束兜底**：防过度消毒、防事实发明、防语体降级。

## 与 humanizer 的关系

本项目借鉴了 [humanizer](https://github.com/blader/humanizer) 的流程骨架（多轮改写、语音校准、部分模式抽象），但规则体系按中文语法和中文平台语境重建。完整差异与依据见 [`SKILL.md`](./SKILL.md)。

---
## 51 类模式一览（精简版）

完整规则、触发条件和“原文/改后”示例请看 [`SKILL.md`](./SKILL.md)。README 这里保留目录级速览，方便先判断“有没有覆盖到你的场景”。

| 类别 | 范围 | 关注点 |
|---|---|---|
| A. 内容模式 | #1-#6 | 空洞拔高、背景套话、模糊归因 |
| B. 语言模式 | #7-#20 | 高频词堆叠、名词化/后缀化、机械并列 |
| B+. 逻辑连接 | #34 | 连接词空转、逻辑关系虚化 |
| C. 修辞模式 | #21-#25 | 成语/排比模板化、装饰性格式滥用 |
| D. 交流模式 | #26-#29, #51 | 客服腔、谄媚腔、第二人称泛化 |
| E. 填充与模糊 | #30-#32 | 冗余短语、模糊限定、口号式号召 |
| F. 翻译腔 | #33, #39-#44 | 英文句骨残留、中英混杂、列表反射 |
| G. 篇章节奏 | #35-#36 | 句长均质化、指代不敢省 |
| H. 平台文体 | #37-#38, #49-#50 | 自媒体套路、故事 AI 味、B 站模板味 |
| I. 幻觉与格式 | #45-#48 | 表格滥用、Markdown 残留、伪引用 |

常见入口：

- 想看全部规则清单：[`SKILL.md` 的模式章节](./SKILL.md#A-内容模式)
- 想看处理流程：[`SKILL.md` 的处理流程](./SKILL.md#处理流程)
- 想看完整改写样例：[`SKILL.md` 的完整示例](./SKILL.md#完整示例)

---
## 完整示例

**原文（AI 腔很重）：**
> 问得好！下面是关于 AI 编程助手的简要介绍，希望对您有帮助！
>
> 随着人工智能技术的不断发展，AI 辅助编程正以前所未有的方式，赋能千行百业，助力开发者打造高质量、智能化、一体化的产品。这不仅是一场技术革新，更是一次思维变革，它深刻体现了技术对人类生产方式的重塑，彰显了数字化时代的无限可能。
>
> 值得一提的是，业内人士普遍认为，AI 编程工具在多个维度实现了突破：
>
> 1. 🚀 **效率跃升：**代码生成速度显著提升。
> 2. 💡 **质量保障：**通过深度学习，代码质量得到全面优化。
> 3. ✅ **体验升级：**协作体验得到前所未有的改善。
>
> 需要注意的是，尽管面临诸多挑战，但我们有理由相信，在不久的将来，AI 编程必将迎来更加光明的未来。让我们一起，共同见证并书写这个充满无限可能的新篇章！

**自审（初稿之后，再扫一遍）：**

去掉"赋能 / 让我们一起 / emoji 列点"这些显眼 AI 腔只是第一步。再过一遍：

- 每段都在叠工整排比，读起来太整齐了 —— AI 偏爱这种对称
- 收尾"你基本上...判断"——第二人称 + 抽象动作，活脱脱标语句式
- “两种人”这种泛化标签还是抽象。写一个真实朋友的具体场景，比笼统归类更有力

**终稿（扫过自审再改一遍）：**
> AI 编程助手在无聊的部分能帮你提速。不是所有部分。架构这事它不行。
>
> 模板代码它写得挺顺 — 配置文件、测试脚手架、重复的重构。它也挺擅长"看起来对"但实际不对。我接受过几次建议，代码跑起来也过了 lint,后来才发现根本不是我要的，因为我没看。
>
> 我见过两种用法。一个朋友把 Copilot 当补全器，每行都要看过才 tab 下去；另一个直接关掉了 —— 他说它老建议他们项目里两年前就弃用的写法。两种我都理解。
>
> 生产力指标不好拿。GitHub 可以说 Copilot 用户"接受了 30% 的建议",但接受不等于正确。没测试的时候，我分不清它哪次真帮了我，哪次是 lint 放过去的假助攻。

详细的三遍工作流（识别 → 初稿 → 自审 → 终稿）和完整改动摘要参见 [SKILL.md](./SKILL.md#完整示例)。

---

## 给贡献者 / 自己维护的几条提醒

1. **改了 SKILL.md / README 后，把自己动过的散文段落**喂给 qu-ai-wei 自检一遍。规则条目里那些结构化 metadata(问题 / 关键词 / 原文 / 改后 / 语体限定)是**给模型读的骨架，别 humanize** —— 去掉对称反而让模型看不清规则长什么样。**只对解释性散文跑。**
2. **加新规则时检查会不会跟既有规则冲突 / 重叠**。比如"抽象万能动词"跟 #7 AI 高频词、#30 冗余书面化都相邻，要说清楚各自管的是什么。
3. **所有例子都要有"原文 / 改后"对**。单给判断标准没有示范，模型抓不准。
4. **版本号凡升，README 的版本记录、CHANGELOG.md 和 SKILL.md frontmatter 同改**。
5. **遇到真人经典文本（金庸 / 王朔 / 汪曾祺 / 真实采访实录等）不要改**。这是 qu-ai-wei 最常见的灾难，在"🛑 第负一步"明确写了门检。

---
## 版本记录

完整历史版本请看 [`CHANGELOG.md`](./CHANGELOG.md)。

最近更新：

- **v0.5.5（2026-04-22）**：新增 3 条顶层硬约束（事实发明禁令、门检强制输出、语体降级保护），并补充技术博客语体归档。
- **v0.5.4（2026-04-22）**：重写 #16 / #25 的破折号规则，改为语体分层触发。

---
## 参考来源

- [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) — 通用 AI 写作痕迹分类的主要来源
- [WikiProject AI Cleanup](https://en.wikipedia.org/wiki/Wikipedia:WikiProject_AI_Cleanup) — 英文维基的维护组织
- [维基百科:AI生成文的特徵](https://zh.wikipedia.org/wiki/Wikipedia:AI%E7%94%9F%E6%88%90%E6%96%87%E7%9A%84%E7%89%B9%E5%BE%B5) — 中文维基社群的平行信息页(与英文版独立,不是翻译),列有中文具体实例,可作交叉参考
- [中文维基百科 · 汉语语法](https://zh.wikipedia.org/zh-cn/%E6%B1%89%E8%AF%AD%E8%AF%AD%E6%B3%95) — 语序、话题优先、主语省略、助词分工等中文语法条目的权威参考,「语序」规则的理论依据
- [sparanoid · 中文文案排版指北](https://github.com/sparanoid/chinese-copywriting-guidelines/blob/master/README.zh-Hans.md) — 中英文混排、全角标点、盘古之白等**排版美学**规范。本 skill 的目标是"AI 痕迹检测"(机械感 / 空洞感),跟它的目标(可读性 / 美观)**正交**,用途互补:想做版面优化用 sparanoid,想去 AI 味用本 skill
- [**`humanizer`**](https://github.com/blader/humanizer)(作者 **Siqi Chen**,MIT 协议,2025)— 去 AI 腔工具,官方**语言无关**定位,29 条规则实际针对英文写作。本 skill 的**结构、三遍工作流、语音校准、个性与灵魂章节、约 17 条模式概念**的直接来源。
- [**yage.ai《写作中的 AI 味是哪儿来的》**](https://yage.ai/share/ai-chinese-translationese-20260418.html) — 原创观察文章,主张"AI 味 = 翻译腔"。模式 **#39-#42**(思考动作动词 / X 很 Y 冒号 / 抽象名词主语 / 未译英文词)来自这篇文章。

### 致谢

感谢 **Siqi Chen** 和 **humanizer** 项目。没有 humanizer 的骨架、三遍工作流、Voice Calibration 思路和 Personality and Soul 章节,这份中文版不会是现在的样子。

**关于中文特有模式:** 中文维基上有一份平行的社群信息页 [维基百科:AI生成文的特徵](https://zh.wikipedia.org/wiki/Wikipedia:AI%E7%94%9F%E6%88%90%E6%96%87%E7%9A%84%E7%89%B9%E5%BE%B5)(与英文版独立,不是翻译),可作交叉参考。本 skill 里中文特有的痕迹(的的不休、性 / 化 后缀、进行 + V、长破折号解释句、赋能 / 助力 / 打造 词族、翻译腔残留等)主要是我看 LLM 中文输出慢慢整理出来的,**欢迎补充、纠正、反馈**。

---

## 许可证

MIT(见 [LICENSE](./LICENSE))
