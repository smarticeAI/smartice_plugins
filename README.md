# SmartIce Plugin Marketplace

A shared Claude Code plugin marketplace for the SmartIce organization. Features design tools, database utilities, and developer productivity plugins.

SmartIce 组织的共享 Claude Code 插件市场。提供设计工具、数据库工具和开发者生产力插件。

---

## Installation | 安装

Add this marketplace to Claude Code:

将此市场添加到 Claude Code：

```
/plugin marketplace add HengWoo/smartice_plugin_market
```

---

## Available Plugins | 可用插件

| Plugin | Description | Author |
|--------|-------------|--------|
| **design-council** | Multi-model frontend design with Opus + Gemini | HengWoo |
| **design-council-lite** | Lightweight design workflow | HengWoo |
| **db-tools** | Database design review & validation | 杨睿祺 |
| **smartice-tools** | Marketplace contribution tools | HengWoo |

---

### design-council

Multi-model frontend design orchestration using Opus for planning/review and Gemini for code generation.

多模型前端设计编排工具，使用 Opus 进行规划/审查，Gemini 进行代码生成。

**Features | 功能：**
- Turn-based design workflow with multiple AI roles | 多角色轮流协作的设计工作流
- Design Strategist (Opus 4.5) creates specifications | 设计策略师 (Opus 4.5) 创建规格说明
- Code Generator (Gemini 3 Pro) produces frontend code | 代码生成器 (Gemini 3 Pro) 生成前端代码
- Code Reviewer (Opus 4.5) evaluates quality | 代码审查员 (Opus 4.5) 评估质量
- Adaptation Advisor synthesizes feedback for iterations | 适配顾问整合反馈进行迭代

**Install | 安装：**
```
/plugin install design-council@smartice-plugin-market
```

**Usage | 使用：**
```
/design-sprint "Your design description" --rounds=3 --framework=react
```

---

### design-council-lite

Lightweight version for simpler multi-model design workflows.

轻量版多模型设计工作流。

**Features | 功能：**
- Streamlined two-step workflow | 精简的两步工作流
- Claude plans, Gemini generates | Claude 规划，Gemini 生成
- Manual iteration control | 手动迭代控制
- Design templates included | 包含设计模板

**Install | 安装：**
```
/plugin install design-council-lite@smartice-plugin-market
```

---

### db-tools

Database design review toolkit with normalization checks, anti-pattern detection, and Supabase RLS validation.

数据库设计审查工具集，包含规范化检查、反模式检测和 Supabase RLS 验证。

**Features | 功能：**
- 11 automated schema checks | 11 项自动化检查
- 3NF normalization validation | 3NF 规范化验证
- 7 anti-pattern detections | 7 种反模式识别
- Supabase RLS policy checks | Supabase RLS 策略检查

**Install | 安装：**
```
/plugin install db-tools@smartice-plugin-market
```

**Usage | 使用：**
```
"review database" or "check schema" or "审查数据库设计"
```

---

### smartice-tools

Tools for contributing plugins to the marketplace.

向市场贡献插件的工具集。

**Install | 安装：**
```
/plugin install smartice-tools@smartice-plugin-market
```

**Usage | 使用：**
```
/smartice-tools:submit-plugin ./path/to/your-plugin
```

---

## Contributing Plugins | 贡献插件

### For Claude Code Users | Claude Code 用户

The easiest way to contribute - submit directly from Claude Code!

最简单的贡献方式 - 直接从 Claude Code 提交！

**Step 1 | 步骤一：** Install the tools | 安装工具
```
/plugin install smartice-tools@smartice-plugin-market
```

**Step 2 | 步骤二：** Submit your plugin | 提交你的插件
```
/smartice-tools:submit-plugin ./path/to/your-plugin
```

**What happens | 自动完成：**
- Validates plugin structure | 验证插件结构
- Forks the marketplace repo | Fork 市场仓库
- Copies your plugin files | 复制插件文件
- Updates marketplace.json | 更新 marketplace.json
- Creates Pull Request automatically | 自动创建 Pull Request

### Manual Contribution | 手动贡献

1. Fork this repository | Fork 此仓库
2. Add your plugin to `plugins/` | 将插件添加到 `plugins/` 目录
3. Update `.claude-plugin/marketplace.json` | 更新 `.claude-plugin/marketplace.json`
4. Submit a Pull Request | 提交 Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for details | 详见 [CONTRIBUTING.md](CONTRIBUTING.md)

---

## Plugin Requirements | 插件要求

Your plugin must have | 插件必须包含：

```
your-plugin/
├── .claude-plugin/
│   └── plugin.json      # Required | 必需
├── README.md            # Recommended | 推荐
└── skills/ or commands/ or agents/  # At least one | 至少一个
```

**plugin.json required fields | plugin.json 必需字段：**
```json
{
  "name": "your-plugin-name",
  "version": "1.0.0",
  "description": "What your plugin does",
  "author": {
    "name": "Your Name"
  }
}
```

---

## Requirements | 环境要求

### Design Plugins (design-council, design-council-lite)

Require a Gemini API key for code generation:

设计插件需要 Gemini API 密钥用于代码生成：

```bash
export GEMINI_API_KEY="your-api-key-here"
```

Get your API key | 获取密钥：https://makersuite.google.com/app/apikey

### Database Plugin (db-tools)

Requires database connection. Works with Supabase or any PostgreSQL database.

需要数据库连接。支持 Supabase 或任何 PostgreSQL 数据库。

---

## Supported Frameworks | 支持的框架

- React (hooks, functional components)
- Vue 3 (Composition API)
- Svelte
- Next.js (App Router)
- Plain HTML/CSS/JavaScript

---

## License | 许可证

MIT
