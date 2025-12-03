-- ============================================
-- 数据库设计自动检查脚本
-- 用于 PostgreSQL / Supabase
-- ============================================

-- ============================================
-- 检查 1: 没有主键的表
-- ============================================
SELECT '缺少主键' as check_type,
       t.table_schema,
       t.table_name,
       '添加主键: ALTER TABLE ' || t.table_name || ' ADD COLUMN id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY;' as suggestion
FROM information_schema.tables t
LEFT JOIN information_schema.table_constraints tc
    ON t.table_schema = tc.table_schema
    AND t.table_name = tc.table_name
    AND tc.constraint_type = 'PRIMARY KEY'
WHERE t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
    AND tc.constraint_name IS NULL
ORDER BY t.table_name;

-- ============================================
-- 检查 2: 列数超过 30 的表
-- ============================================
SELECT '列数过多' as check_type,
       table_schema,
       table_name,
       COUNT(*) as column_count,
       '考虑按业务实体拆分表' as suggestion
FROM information_schema.columns
WHERE table_schema = 'public'
GROUP BY table_schema, table_name
HAVING COUNT(*) > 30
ORDER BY column_count DESC;

-- ============================================
-- 检查 3: 外键列没有索引
-- ============================================
WITH fk_columns AS (
    SELECT
        kcu.table_schema,
        kcu.table_name,
        kcu.column_name
    FROM information_schema.key_column_usage kcu
    JOIN information_schema.table_constraints tc
        ON kcu.constraint_name = tc.constraint_name
        AND kcu.table_schema = tc.table_schema
    WHERE tc.constraint_type = 'FOREIGN KEY'
        AND kcu.table_schema = 'public'
),
indexed_columns AS (
    SELECT
        schemaname as table_schema,
        tablename as table_name,
        unnest(string_to_array(indexdef, ',')) as column_part
    FROM pg_indexes
    WHERE schemaname = 'public'
)
SELECT '外键无索引' as check_type,
       fk.table_schema,
       fk.table_name,
       fk.column_name,
       'CREATE INDEX idx_' || fk.table_name || '_' || fk.column_name || ' ON ' || fk.table_name || '(' || fk.column_name || ');' as suggestion
FROM fk_columns fk
WHERE NOT EXISTS (
    SELECT 1 FROM pg_indexes pi
    WHERE pi.schemaname = fk.table_schema
        AND pi.tablename = fk.table_name
        AND pi.indexdef LIKE '%' || fk.column_name || '%'
)
ORDER BY fk.table_name, fk.column_name;

-- ============================================
-- 检查 4: 命名不符合 snake_case 的表
-- ============================================
SELECT '命名不规范-表' as check_type,
       table_schema,
       table_name,
       '表名应使用 snake_case 格式' as suggestion
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
    AND table_name !~ '^[a-z][a-z0-9_]*$'
ORDER BY table_name;

-- ============================================
-- 检查 5: 命名不符合 snake_case 的列
-- ============================================
SELECT '命名不规范-列' as check_type,
       table_schema,
       table_name,
       column_name,
       '列名应使用 snake_case 格式' as suggestion
FROM information_schema.columns
WHERE table_schema = 'public'
    AND column_name !~ '^[a-z][a-z0-9_]*$'
ORDER BY table_name, column_name;

-- ============================================
-- 检查 6: 重复列组模式 (phone1, phone2, item_1, item_2 等)
-- ============================================
SELECT '重复列组' as check_type,
       table_schema,
       table_name,
       column_name,
       '将重复列组转为独立子表' as suggestion
FROM information_schema.columns
WHERE table_schema = 'public'
    AND column_name ~ '(phone|email|address|item|tag|option|field|value)_?\d+$'
ORDER BY table_name, column_name;

-- ============================================
-- 检查 7: 时间字段未使用 TIMESTAMPTZ
-- ============================================
SELECT '时间类型错误' as check_type,
       table_schema,
       table_name,
       column_name,
       data_type,
       '应使用 TIMESTAMPTZ 而非 ' || data_type as suggestion
FROM information_schema.columns
WHERE table_schema = 'public'
    AND data_type = 'timestamp without time zone'
ORDER BY table_name, column_name;

-- ============================================
-- 检查 8: VARCHAR 作为主键
-- ============================================
SELECT 'VARCHAR主键' as check_type,
       kcu.table_schema,
       kcu.table_name,
       kcu.column_name,
       c.data_type,
       '主键应使用 BIGINT 或 UUID 而非 VARCHAR' as suggestion
FROM information_schema.key_column_usage kcu
JOIN information_schema.table_constraints tc
    ON kcu.constraint_name = tc.constraint_name
    AND kcu.table_schema = tc.table_schema
JOIN information_schema.columns c
    ON kcu.table_schema = c.table_schema
    AND kcu.table_name = c.table_name
    AND kcu.column_name = c.column_name
WHERE tc.constraint_type = 'PRIMARY KEY'
    AND kcu.table_schema = 'public'
    AND c.data_type IN ('character varying', 'character', 'text')
ORDER BY kcu.table_name;

-- ============================================
-- 检查 9: Supabase RLS 未启用
-- ============================================
SELECT 'RLS未启用' as check_type,
       schemaname as table_schema,
       tablename as table_name,
       'ALTER TABLE ' || tablename || ' ENABLE ROW LEVEL SECURITY;' as suggestion
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename NOT LIKE 'pg_%'
    AND tablename NOT IN (
        SELECT tablename
        FROM pg_tables t
        WHERE t.schemaname = 'public'
            AND EXISTS (
                SELECT 1 FROM pg_class c
                JOIN pg_namespace n ON c.relnamespace = n.oid
                WHERE c.relname = t.tablename
                    AND n.nspname = t.schemaname
                    AND c.relrowsecurity = true
            )
    )
ORDER BY tablename;

-- ============================================
-- 检查 10: 有 RLS 策略但 RLS 未启用的表
-- ============================================
SELECT 'RLS策略未生效' as check_type,
       schemaname as table_schema,
       tablename as table_name,
       '表有 RLS 策略但未启用 RLS' as issue,
       'ALTER TABLE ' || tablename || ' ENABLE ROW LEVEL SECURITY;' as suggestion
FROM pg_tables t
WHERE schemaname = 'public'
    AND EXISTS (
        SELECT 1 FROM pg_policies p
        WHERE p.schemaname = t.schemaname
            AND p.tablename = t.tablename
    )
    AND NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE c.relname = t.tablename
            AND n.nspname = t.schemaname
            AND c.relrowsecurity = true
    )
ORDER BY tablename;

-- ============================================
-- 检查 11: 可能违反 3NF 的表 (有 X_id 和 X_name 同时存在)
-- ============================================
WITH id_columns AS (
    SELECT table_schema, table_name,
           regexp_replace(column_name, '_id$', '') as entity
    FROM information_schema.columns
    WHERE table_schema = 'public'
        AND column_name ~ '_id$'
        AND column_name != 'id'
),
name_columns AS (
    SELECT table_schema, table_name,
           regexp_replace(column_name, '_(name|title|code|type)$', '') as entity
    FROM information_schema.columns
    WHERE table_schema = 'public'
        AND column_name ~ '_(name|title|code|type)$'
)
SELECT '可能违反3NF' as check_type,
       i.table_schema,
       i.table_name,
       i.entity || '_id 和 ' || i.entity || '_name/code/type 同时存在' as issue,
       '考虑将 ' || i.entity || ' 拆分为独立表' as suggestion
FROM id_columns i
JOIN name_columns n
    ON i.table_schema = n.table_schema
    AND i.table_name = n.table_name
    AND i.entity = n.entity
ORDER BY i.table_name, i.entity;

-- ============================================
-- 汇总统计
-- ============================================
SELECT '=== 检查完成 ===' as message;

SELECT 'public schema 表总数' as metric,
       COUNT(*)::text as value
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE';
