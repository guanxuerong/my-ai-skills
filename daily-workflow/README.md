# 前端开发工作流 — 使用说明

## 这是什么

一个 Kiro Skill，用 AI 自动化前端开发全流程：需求分析 → 设计文档 → 代码开发 → 接口联调 → AI CR → 自测 → 提测。同时支持日报、周报、季度/年度总结的自动生成。

所有文档自动创建在飞书 `Kiro/` 目录下，工作进度自动记录在 `daily_work` 表格中。

## 前置准备

### 1. 安装飞书 MCP

本工作流依赖飞书 MCP Server 来读写飞书文档和表格。

在项目根目录创建 `.kiro/settings/mcp.json`（如已有则合并配置）：

```json
{
  "mcpServers": {
    "feishu": {
      "command": "npx",
      "args": ["-y", "@anthropic/feishu-mcp-server@latest"],
      "env": {
        "FEISHU_APP_ID": "你的飞书应用 App ID",
        "FEISHU_APP_SECRET": "你的飞书应用 App Secret"
      },
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

> 如果你用的是其他飞书 MCP 实现（如 lark-mcp），替换 command 和 args 即可，env 中的凭证字段保持一致。

### 2. 获取飞书应用凭证

1. 打开 [飞书开放平台](https://open.feishu.cn/app) → 创建企业自建应用
2. 获取 App ID 和 App Secret，填入上面的配置
3. 在"权限管理"中开通以下权限：
   - `wiki:wiki:read` — 读取知识库
   - `wiki:wiki:write` — 写入知识库
   - `sheets:spreadsheet:read` — 读取表格
   - `sheets:spreadsheet:write` — 写入表格
4. 发布应用版本，管理员审批通过

### 3. 飞书目录准备

在飞书知识库中创建根目录 `Kiro/`，并确保飞书应用有该目录的读写权限。

子目录和表格会在流程中自动创建：
- `Kiro/daily_work` — 工作跟踪表格（首次启动流程时自动创建并初始化表头）
- `Kiro/周报/` — 周报文档
- `Kiro/总结/` — 季度/年度总结

`daily_work` 表格会自动初始化以下表头：

| 需求名 | 分支名 | 当前状态 |
|--------|--------|----------|

> 状态列后面的日期列（日报）会在流程中自动追加。

## 使用方式

### 开始新需求

在 Kiro 对话中说：

```
开启 dw https://xxx.feishu.cn/wiki/xxx（PRD链接）
```

AI 会自动按七步流程推进，每步完成后等你确认再继续。

> 第一步会自动生成 Git 分支名并创建分支（`git checkout -b feature/xxx-yyy`），后续通过分支名自动关联需求上下文。

### 常用命令

| 说什么 | 做什么 |
|--------|--------|
| `开启 dw` + PRD链接 | 启动七步流程 |
| `继续 dw` | 自动通过当前 Git 分支名匹配需求，从断点继续 |
| `更新 dw` + 状态 | 手动更新需求状态（如"已上线"） |
| `写周报` | 自动汇总本周工作生成周报 |
| `写季度总结` / `Q1总结` | 生成季度总结 |
| `年度总结` | 生成年度总结 |

### 流程概览

```
PRD链接 → ① 需求分析 → ② 设计文档 → ③ 代码开发 → ④ 接口联调(可跳过) → ⑤ AI CR → ⑥ 自测 → ⑦ 提测
                                                          ↑
                                                   无接口文档时先 Mock
                                                   有接口文档后联调替换
```

每步都有确认点，你说"确认"才会进入下一步。

## 文件结构

```
.kiro/skills/daily-workflow/
├── SKILL.md                          # Skill 主流程定义（AI 读取）
├── README.md                         # 本文件（使用说明）
└── references/                       # 规范文档（AI 读取）
    ├── requirement-analysis.md       # 需求分析规范
    ├── development-design.md         # 设计文档规范
    ├── coding-standards.md           # 编码规范
    ├── code-review.md                # AI CR 走查规范（引用 cr-general skill）
    ├── self-testing.md               # 自测规范
    ├── test-submission.md            # 提测文档模板
    ├── general-rules.md              # 通用规则
    ├── weekly-report.md              # 周报模板
    └── periodic-summary.md           # 季度/年度总结模板
```

## 常见问题

**Q: 飞书 MCP 连接失败？**
检查 App ID/Secret 是否正确，应用是否已发布并审批通过，权限是否齐全。

**Q: 流程中断了怎么恢复？**
只要你在对应的 Git 分支上，直接说"继续"即可。AI 会通过当前分支名自动匹配 daily_work 表格中的需求，从断点继续。如果不在对应分支上，说"继续 [需求名]"指定。

**Q: 可以同时推进多个需求吗？**
可以，每个需求在 daily_work 表格中独立一行，通过需求名区分。

**Q: 流程规范不合理怎么办？**
AI 会在执行过程中主动识别可优化的点并提出建议。你也可以随时指出问题，确认后 AI 会自动更新 skill.md、references/*.md 和 README.md，规范即刻生效。
