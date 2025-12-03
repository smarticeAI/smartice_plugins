# PostgreSQL/Supabase 设计规范

## 命名规范

| 对象类型 | 规则 | 示例 |
|----------|------|------|
| 表名 | snake_case复数 | `users`, `order_items` |
| 列名 | snake_case | `created_at`, `user_id` |
| 主键 | `id` 或 `{table}_id` | `id`, `user_id` |
| 外键 | `{referenced_table单数}_id` | `user_id`, `order_id` |
| 布尔字段 | `is_` 或 `has_` 前缀 | `is_active`, `has_verified` |
| 时间戳 | `_at` 后缀 | `created_at`, `updated_at` |
| 索引 | `idx_{table}_{column}` | `idx_users_email` |

### 命名检查正则

```regex
-- 表名和列名应匹配此模式
^[a-z][a-z0-9_]*$
```

---

## 主键选择指南

| 场景 | 推荐类型 | 原因 |
|------|----------|------|
| 默认选择 | `BIGINT GENERATED ALWAYS AS IDENTITY` | 高性能、空间小 |
| 公开API/分布式 | `UUID` | 不可预测、无需协调 |
| Supabase用户表 | `UUID REFERENCES auth.users(id)` | 与认证系统集成 |

### 主键定义示例

```sql
-- 推荐的主键定义（高性能）
id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY

-- 或使用UUID（Supabase场景/公开API）
id UUID PRIMARY KEY DEFAULT gen_random_uuid()

-- 用户表关联 auth.users
id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE
```

---

## 数据类型选择

| 用途 | 推荐 | 避免 | 原因 |
|------|------|------|------|
| 字符串 | `TEXT` 或 `VARCHAR(n)` | `CHAR(n)` | CHAR会填充空格 |
| 金额 | `NUMERIC(10,2)` | `FLOAT`, `DOUBLE` | 浮点有精度问题 |
| 时间 | `TIMESTAMPTZ` | `TIMESTAMP` | 需要时区信息 |
| JSON数据 | `JSONB` | `JSON`, `TEXT` | JSONB可索引和查询 |
| 布尔 | `BOOLEAN` | `INTEGER` | 语义清晰 |
| 枚举 | `ENUM`类型 或 `TEXT` + CHECK | `VARCHAR` | 限制有效值 |

---

## 标准表模板

```sql
CREATE TABLE {table_name} (
    -- 主键
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    -- 外键（如有）
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- 业务字段
    name TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    metadata JSONB DEFAULT '{}',

    -- 时间戳
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 外键列必须建索引
CREATE INDEX idx_{table}_user_id ON {table}(user_id);

-- 常用查询字段建索引
CREATE INDEX idx_{table}_name ON {table}(name);

-- 启用 RLS
ALTER TABLE {table} ENABLE ROW LEVEL SECURITY;

-- 更新时间戳触发器
CREATE TRIGGER set_{table}_updated_at
    BEFORE UPDATE ON {table}
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();
```

---

## Supabase RLS 必须遵守的规则

### 1. 所有 public 表必须启用 RLS

```sql
-- 启用 RLS
ALTER TABLE {table} ENABLE ROW LEVEL SECURITY;
```

### 2. 策略中使用 SELECT 包装 auth.uid()

```sql
-- ❌ 错误（性能差）
CREATE POLICY "Users can view own data" ON {table}
FOR SELECT USING (auth.uid() = user_id);

-- ✅ 正确（性能更好）
CREATE POLICY "Users can view own data" ON {table}
FOR SELECT USING ((SELECT auth.uid()) = user_id);
```

### 3. 为 RLS 涉及的列建索引

```sql
-- user_id 用于 RLS 策略，必须有索引
CREATE INDEX idx_{table}_user_id ON {table}(user_id);
```

### 4. 常用 RLS 策略模板

```sql
-- 用户只能查看自己的数据
CREATE POLICY "Users can view own data" ON {table}
FOR SELECT USING ((SELECT auth.uid()) = user_id);

-- 用户只能插入自己的数据
CREATE POLICY "Users can insert own data" ON {table}
FOR INSERT WITH CHECK ((SELECT auth.uid()) = user_id);

-- 用户只能更新自己的数据
CREATE POLICY "Users can update own data" ON {table}
FOR UPDATE USING ((SELECT auth.uid()) = user_id);

-- 用户只能删除自己的数据
CREATE POLICY "Users can delete own data" ON {table}
FOR DELETE USING ((SELECT auth.uid()) = user_id);

-- 管理员可以访问所有数据
CREATE POLICY "Admins can do anything" ON {table}
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM user_roles
        WHERE user_id = (SELECT auth.uid())
        AND role = 'admin'
    )
);
```

---

## Supabase 特定检查清单

| # | 检查项 | 通过标准 |
|---|--------|----------|
| 1 | public表启用RLS？ | `ALTER TABLE x ENABLE ROW LEVEL SECURITY` |
| 2 | 有对应的RLS策略？ | SELECT/INSERT/UPDATE/DELETE策略存在 |
| 3 | 策略使用`(SELECT auth.uid())`？ | 非直接调用`auth.uid()` |
| 4 | user_id列有索引？ | `CREATE INDEX idx_x_user_id` |
| 5 | 敏感表不在public schema？ | 内部表使用private schema |
| 6 | 外键引用auth.users？ | 用户相关表正确关联 |
| 7 | 使用 TIMESTAMPTZ？ | 非 TIMESTAMP WITHOUT TIME ZONE |

---

## 索引最佳实践

### 必须建索引的情况

1. **外键列** - 每个外键都需要索引
2. **RLS 策略涉及的列** - 如 user_id
3. **WHERE 条件常用列** - 高频查询条件
4. **ORDER BY 常用列** - 排序字段
5. **唯一约束列** - email, username 等

### 索引命名规范

```sql
-- 单列索引
CREATE INDEX idx_{table}_{column} ON {table}({column});

-- 复合索引
CREATE INDEX idx_{table}_{col1}_{col2} ON {table}({col1}, {col2});

-- 唯一索引
CREATE UNIQUE INDEX idx_{table}_{column}_unique ON {table}({column});

-- 部分索引
CREATE INDEX idx_{table}_{column}_active ON {table}({column}) WHERE is_active = true;
```

---

## 常见错误及修复

### 错误 1: 时间戳没有时区

```sql
-- ❌ 错误
created_at TIMESTAMP DEFAULT NOW()

-- ✅ 正确
created_at TIMESTAMPTZ DEFAULT NOW()
```

### 错误 2: 使用 VARCHAR 作为主键

```sql
-- ❌ 错误
id VARCHAR(50) PRIMARY KEY

-- ✅ 正确
id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY
-- 或
id UUID PRIMARY KEY DEFAULT gen_random_uuid()
```

### 错误 3: 外键没有索引

```sql
-- ❌ 只有外键约束
FOREIGN KEY (user_id) REFERENCES users(id)

-- ✅ 外键约束 + 索引
FOREIGN KEY (user_id) REFERENCES users(id),
CREATE INDEX idx_{table}_user_id ON {table}(user_id);
```

### 错误 4: RLS 未启用

```sql
-- 检查 RLS 状态
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';

-- 启用 RLS
ALTER TABLE {table} ENABLE ROW LEVEL SECURITY;
```

### 错误 5: 金额使用浮点类型

```sql
-- ❌ 错误（精度问题）
price FLOAT

-- ✅ 正确
price NUMERIC(10,2)
```
