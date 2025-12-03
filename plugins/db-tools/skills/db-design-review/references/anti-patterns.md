# 数据库设计反模式识别与修复

## 反模式识别速查表

| 反模式 | 特征识别 | 修复方法 |
|--------|----------|----------|
| **多值列** | 单列存储逗号分隔值 | 创建关联表 |
| **重复列组** | phone1, phone2, phone3 | 创建子表 |
| **上帝表** | 50+列，大量NULL | 按业务实体拆分 |
| **缺少主键** | 表无PRIMARY KEY | 添加主键 |
| **无外键约束** | 应用层维护引用完整性 | 添加FK约束 |
| **EAV模式** | entity/attribute/value三列结构 | 使用具体列或JSONB |
| **元数据Tribbles** | sales_2023, sales_2024列 | 使用行存储+日期列 |

---

## 详细反模式解析

### 1. 多值列 (Jaywalking)

**特征**：
```sql
-- ❌ 反模式
| product_id | categories            |
|------------|----------------------|
| 1          | "电子,手机,智能设备"  |
```

**问题**：
- 无法使用索引进行高效查询
- 无法使用外键约束保证数据完整性
- 查询必须使用 LIKE 或字符串函数

**修复**：
```sql
-- ✅ 正确设计
products: product_id, name
categories: category_id, name
product_categories: product_id, category_id
```

---

### 2. 重复列组 (Multicolumn Attributes)

**特征**：
```sql
-- ❌ 反模式
| id | tag1  | tag2   | tag3 | tag4 |
|----|-------|--------|------|------|
| 1  | React | Vue    | NULL | NULL |
```

**问题**：
- 列数固定，无法扩展
- 搜索需要检查多列
- 大量 NULL 值浪费空间

**修复**：
```sql
-- ✅ 正确设计
items: id, name
tags: id, item_id, tag_name
```

---

### 3. 上帝表 (God Table)

**特征**：
- 表有 50+ 列
- 大量 NULL 值
- 列名前缀暗示不同实体 (user_name, order_date, product_price)

**问题**：
- 难以维护和理解
- 性能问题（行宽度大）
- 违反单一职责原则

**修复**：
- 按业务实体拆分为多个表
- 使用一对一关系连接相关表

---

### 4. 缺少主键 (ID Required)

**特征**：
```sql
-- ❌ 反模式
CREATE TABLE logs (
    event_time TIMESTAMP,
    event_type VARCHAR(50),
    message TEXT
);
```

**问题**：
- 无法唯一标识行
- 无法建立外键关系
- 难以进行更新和删除操作

**修复**：
```sql
-- ✅ 正确设计
CREATE TABLE logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_time TIMESTAMPTZ,
    event_type VARCHAR(50),
    message TEXT
);
```

---

### 5. 无外键约束 (Phantom Files)

**特征**：
- 应用层代码检查引用完整性
- 存在"孤儿"记录
- 删除父记录不会影响子记录

**问题**：
- 数据完整性无法保证
- 可能存在悬空引用
- 增加应用层复杂度

**修复**：
```sql
-- ✅ 添加外键约束
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id) REFERENCES customers(id)
ON DELETE RESTRICT;
```

---

### 6. EAV 模式 (Entity-Attribute-Value)

**特征**：
```sql
-- ❌ 反模式
| entity_id | attribute_name | attribute_value |
|-----------|----------------|-----------------|
| 1         | color          | red             |
| 1         | size           | large           |
| 1         | price          | 99.99           |
```

**问题**：
- 无法使用正确的数据类型
- 无法添加约束
- 查询复杂且低效

**修复**：
```sql
-- ✅ 使用具体列
CREATE TABLE products (
    id BIGINT PRIMARY KEY,
    color VARCHAR(50),
    size VARCHAR(20),
    price NUMERIC(10,2)
);

-- 或使用 JSONB（PostgreSQL）
CREATE TABLE products (
    id BIGINT PRIMARY KEY,
    attributes JSONB DEFAULT '{}'
);
```

---

### 7. 元数据 Tribbles

**特征**：
```sql
-- ❌ 反模式：按年份创建列
| product_id | sales_2022 | sales_2023 | sales_2024 |
|------------|------------|------------|------------|
| 1          | 1000       | 1200       | 1500       |
```

**问题**：
- 每年需要修改表结构
- 查询需要知道所有列名
- 无法轻松添加新年份

**修复**：
```sql
-- ✅ 使用行存储
CREATE TABLE sales (
    product_id BIGINT REFERENCES products(id),
    year INTEGER,
    amount NUMERIC(12,2),
    PRIMARY KEY (product_id, year)
);
```

---

## 快速诊断清单

执行审查时，对每个表检查以下问题：

| # | 检查项 | 如果"是"则需修复 |
|---|--------|-----------------|
| 1 | 单元格中有逗号分隔的多个值？ | 创建关联表 |
| 2 | 有phone1/phone2/phone3这样的列？ | 创建子表 |
| 3 | 同一信息在多行重复出现？ | 拆分为独立表 |
| 4 | 表中有 X_id 和 X_name 同时存在？ | X应独立成表 |
| 5 | 复合主键表中，有列只依赖部分主键？ | 拆分为多表 |
| 6 | 表超过30列？ | 按实体拆分 |
| 7 | 表没有主键？ | 添加主键 |
| 8 | 外键列没有索引？ | 添加索引 |
| 9 | 有按时间/类别命名的列组？ | 改为行存储 |
| 10 | 使用 VARCHAR 作为主键？ | 改用 BIGINT/UUID |
