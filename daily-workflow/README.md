# 🚀 前端开发工作流 — 使用说明

> 一个 Kiro Skill，用 AI 自动化前端开发全流程：需求分析 → 设计文档 → 代码开发 → 接口联调 → AI CR → 自测 → 提测。同时支持日报、周报、季度/年度总结的自动生成。

所有文档自动创建在飞书 `Kiro/` 目录下，工作进度自动记录在 `daily_work` 表格中。

---

## 📦 前置准备

### 1. 创建飞书应用

1. 打开 [飞书开放平台](https://open.feishu.cn/app) → 创建企业自建应用
2. 在"权限管理"中开通以下权限：

| 权限 | 权限标识 | 身份 |
|------|----------|------|
| 编辑新版文档 | `docx:document:write_only` | 应用 + 用户 |
| 搜索云文档 | `search:docs:read` | 用户 |
| 创建知识空间节点 | `wiki:node:create` | 应用 + 用户 |
| 查看知识空间节点信息 | `wiki:node:read` | 应用 + 用户 |
| 查看、编辑和管理知识库 | `wiki:wiki` | 应用 + 用户 |
| 查看知识库 | `wiki:wiki:readonly` | 用户 |

3. 发布应用版本，管理员审批通过

### 2. 配置回调地址

在应用的"安全设置"中添加重定向 URL：`http://localhost:8080/callback`

### 3. 获取 Token

1. 将飞书应用的 App ID 和 App Secret 替换到 `feishu_uat.sh` 中
2. 终端执行 `bash feishu_uat.sh`，浏览器弹出授权页面，完成授权
3. 获取到 Token

### 4. 配置 MCP

将 Token 替换到 `~/.kiro/settings/mcp.json`：

```json
{
  "mcpServers": {
    "feishu": {
      "transport": "http",
      "url": "https://mcp.feishu.cn/mcp",
      "headers": {
        "Content-Type": "application/json",
        "X-Lark-MCP-UAT": "你的 token",
        "X-Lark-MCP-Allowed-Tools": "search-doc,create-doc,fetch-doc,update-doc,list-docs,get-comments,add-comments,search-user,get-user,fetch-file"
      },
      "autoApprove": ["fetch-doc","update-doc","search-user","create-doc","list-docs","search-doc","fetch-file"]
    }
  }
}
```

> ⚠️ Token 有效期约 2 小时，过期后重新执行 `bash feishu_uat.sh` 获取新 Token 并替换。

### 5. 飞书目录准备

在飞书知识库中创建根目录 `Kiro/`，子目录和表格会在流程中自动创建。

---

## 🚀 使用方式

### 开始新需求

```
开启 dw https://xxx.feishu.cn/wiki/xxx（PRD链接）
```

AI 会自动按七步流程推进，每步完成后等你确认再继续。

> 第一步会自动生成 Git 分支名并创建分支，后续通过分支名自动关联需求上下文。

---

## 📢 常用命令

| 说什么 | 做什么 |
|--------|--------|
| `开启 dw` + PRD链接 | 🚀 启动七步流程 |
| `开启 dw` + PRD链接 + `模块：xxx` | 🚀 启动流程并指定模块专项规范 |
| `继续 dw` | 🔗 自动通过 Git 分支名匹配需求，从断点继续 |
| `更新 dw` + 状态 | 📝 手动更新需求状态（如"已上线"） |
| `新增模块规范：xxx` | 📦 创建新的模块专项规范文件 |
| `写周报` | 📊 自动汇总本周工作生成周报 |
| `写季度总结` / `Q1总结` | 📋 生成季度总结 |
| `年度总结` | 📋 生成年度总结 |

---

## 📋 流程概览

```
PRD链接 → ① 需求分析 → ② 设计文档 → ③ 代码开发 → ④ 接口联调(可跳过) → ⑤ AI CR → ⑥ 自测 → ⑦ 提测
                                                          ↑
                                                   无接口文档时先 Mock
                                                   有接口文档后联调替换
```

每步都有确认点，你说"确认"才会进入下一步。

> 💡 第六步自测时，可以提供测试同学的测试用例 PDF（XMind 可免费导出为 PDF），AI 会自动合并到自测清单中，提升覆盖度。

---

## 📁 文件结构

```
.kiro/skills/daily-workflow/
├── SKILL.md                          # Skill 主流程定义（AI 读取）
├── README.md                         # 本文件（使用说明）
└── references/                       # 规范文档（AI 读取）
    ├── requirement-analysis.md       # 📝 需求分析规范
    ├── development-design.md         # 📐 设计文档规范
    ├── coding-standards.md           # ✅ 编码规范
    ├── code-review.md                # 🔍 AI CR 走查规范（引用 cr-general skill）
    ├── self-testing.md               # 🧪 自测规范
    ├── test-submission.md            # 📤 提测文档模板
    ├── general-rules.md              # ⚙️ 通用规则
    ├── weekly-report.md              # 📊 周报模板
    ├── periodic-summary.md           # 📋 季度/年度总结模板
    └── modules/                      # 📦 模块专项规范（可选）
        ├── _template.md              # 模板文件，新增模块时复制
        └── xxx.md                    # 各模块专项规范
```

---

## ❓ 常见问题

**Q: 飞书 MCP 连接失败？**
> 检查 App ID/Secret 是否正确，应用是否已发布并审批通过，权限是否齐全。

**Q: 流程中断了怎么恢复？**
> 只要你在对应的 Git 分支上，直接说 `继续 dw` 即可。AI 会通过当前分支名自动匹配需求，从断点继续。

**Q: 可以同时推进多个需求吗？**
> 可以，每个需求在 daily_work 表格中独立一行，通过需求名区分。

**Q: 流程规范不合理怎么办？**
> AI 会主动识别可优化的点：你指出的问题当场响应，AI 自己发现的优化点会攒到当前步骤确认时一并提出，不打断你的工作节奏。确认后 AI 会自动更新规范及所有关联文件，即刻生效。
