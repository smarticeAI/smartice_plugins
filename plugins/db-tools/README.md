# db-tools

数据库设计工具集，包含设计审查、规范化检查、Supabase RLS 验证等功能。

## 功能特性

### 数据库设计审查

- **11 项自动化检查**：缺少主键、外键无索引、命名不规范、RLS 未启用等
- **3NF 规范化验证**：检测 1NF/2NF/3NF 违规
- **7 种反模式识别**：多值列、上帝表、EAV 模式等
- **Supabase 专项检查**：RLS 策略、时区配置、命名规范

### 检查项目

| 检查项 | 说明 |
|--------|------|
| 缺少主键 | 检测没有主键的表 |
| 列数超标 | 检测超过 30 列的"上帝表" |
| 外键无索引 | 外键字段缺少索引影响性能 |
| 命名不规范 | 检测驼峰命名、保留字等 |
| 重复列组 | 如 phone1, phone2, phone3 |
| 时间字段类型 | 应使用 TIMESTAMPTZ |
| VARCHAR 主键 | 不推荐使用字符串作为主键 |
| RLS 未启用 | Supabase 表未启用 RLS |
| RLS 策略缺失 | 启用了 RLS 但无策略 |
| 3NF 违规 | 检测传递依赖 |
| Supabase 规范 | 命名、RLS、时区等 |

## 安装

```
/plugin install db-tools@smartice-plugin-market
```

## 使用方法

### 触发方式

在 Claude Code 中说：
- "审查数据库设计"
- "检查表规范化"
- "验证 RLS 配置"
- "review database"
- "check schema"

### Agent 调用

```
/task db-reviewer
```

### Skill 调用

```
/skill db-design-review
```

## 输出示例

审查报告以 Markdown 表格形式输出：

```markdown
## 数据库审查报告

### 问题汇总

| 严重程度 | 问题类型 | 表名 | 说明 | 建议 |
|----------|----------|------|------|------|
| 高 | 缺少主键 | logs | 无主键定义 | 添加自增或 UUID 主键 |
| 中 | 外键无索引 | orders.user_id | 查询性能问题 | CREATE INDEX ... |
| 低 | 命名不规范 | UserProfile | 使用驼峰命名 | 改为 user_profile |
```

## 包含内容

```
db-tools/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   └── db-reviewer.md          # 数据库审查 Agent
├── skills/
│   └── db-design-review/
│       ├── SKILL.md            # Skill 主文件
│       ├── references/
│       │   ├── normalization-guide.md   # 规范化指南
│       │   ├── anti-patterns.md         # 反模式识别
│       │   └── supabase-rules.md        # Supabase 规范
│       └── scripts/
│           └── check-schema.sql         # 自动检查脚本
└── README.md
```

## 作者

**杨睿祺**

## 许可证

MIT
