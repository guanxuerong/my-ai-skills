# 🧠 AI Skills 仓库

> 一套面向前端开发者的 AI Skills，覆盖从需求分析到代码走查的全流程自动化。基于 React + Antd 5 技术栈，深度集成飞书云文档。
>
> 适用于任何支持 Skill/Prompt 机制的 AI IDE（Kiro、Qoder、Cursor 等），只需将 Skill 文件放入对应 IDE 的配置目录即可。

---

## 📦 Skills 一览

| Skill | 触发词 | 简介 |
|-------|--------|------|
| [daily-workflow](./daily-workflow/) | `开启 dw`、`继续 dw`、`新需求`、`PRD` | 前端开发七步全流程自动化：需求分析 → 设计文档 → 代码开发 → 接口联调 → AI CR → 自测 → 提测 |
| [cr-general](./cr-general/) | `代码走查`、`CR`、`code review` | 通用前端代码走查，支持 6 大维度 + 专项检查，输出飞书走查报告 |

---

## 🔗 Skill 间协作

```
daily-workflow 第五步（AI CR）会自动调用 cr-general 进行代码走查
```

两个 Skill 可以独立使用，也可以在 daily-workflow 流程中自动串联。

---

## 🛠️ 环境依赖

- 支持 Skill/Prompt 机制的 AI IDE（Kiro、Qoder、Cursor 等）
- 飞书 MCP（用于自动创建/更新飞书云文档）
- Git（daily-workflow 会自动创建和管理分支）

飞书 MCP 配置方法详见 [daily-workflow 使用说明](./daily-workflow/README.md#-前置准备)。

---

## 🚀 快速开始

### 接入方式

将本仓库的 Skill 文件复制到你所用 IDE 的 Skill 配置目录下：

| IDE | 配置目录 |
|-----|----------|
| Kiro | `.kiro/skills/` |
| Qoder | 对应的 Skill/Prompt 目录 |
| 其他 | 参考各 IDE 文档 |

### 使用示例

```
# 启动一个新需求的完整开发流程
开启 dw https://xxx.feishu.cn/wiki/xxx

# 单独对某个模块做代码走查
代码走查 src/view/organization/**/*.tsx

# 生成周报
写周报
```

---

## 📁 目录结构

```
skills/
├── README.md                         # 本文件
├── cr-general/                       # 代码走查 Skill
│   ├── SKILL.md                      # Skill 定义
│   ├── README.md                     # 使用说明
│   └── REPORT.md                     # 报告模板
└── daily-workflow/                   # 开发工作流 Skill
    ├── SKILL.md                      # Skill 定义
    ├── README.md                     # 使用说明
    ├── REPORT.md                     # 报告模板
    ├── feishu_uat.sh                 # 飞书 Token 获取脚本
    └── references/                   # 规范文档集
        ├── requirement-analysis.md   # 需求分析规范
        ├── development-design.md     # 设计文档规范
        ├── coding-standards.md       # 编码规范
        ├── code-review.md            # CR 走查规范
        ├── self-testing.md           # 自测规范
        ├── test-submission.md        # 提测文档模板
        ├── general-rules.md          # 通用规则
        ├── weekly-report.md          # 周报模板
        ├── periodic-summary.md       # 季度/年度总结模板
        └── modules/                  # 模块专项规范（可选）
            ├── _template.md          # 模板文件
            └── xxx.md               # 各模块专项规范
```

---

## 🧠 自我学习

两个 Skill 都支持自我学习机制：在使用过程中发现新的问题模式或流程优化点时，AI 会主动提出建议，经用户确认后自动更新规范文档，越用越精准。
