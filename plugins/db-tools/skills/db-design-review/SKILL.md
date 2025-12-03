---
name: Database Design Review
description: This skill should be used when the user asks to "review database design", "check table normalization", "audit database schema", "verify RLS configuration", "check if tables follow 3NF", "find database anti-patterns", "审查数据库设计", "检查表规范化", "验证 RLS 配置", or mentions database design issues like redundancy or normalization.
version: 1.0.0
---

# Database Design Review Skill

## Purpose

This skill provides comprehensive guidance for reviewing PostgreSQL/Supabase database designs. It helps identify normalization violations, anti-patterns, and Supabase-specific issues to ensure data integrity and optimal performance.

## Quick Start Review Flow

```
Start Review
    ↓
[1] Check PRIMARY KEY exists?
    → No → Add primary key
    → Yes ↓

[2] Check snake_case naming?
    → No → Rename
    → Yes ↓

[3] Multi-value cells? (comma-separated)
    → Yes → Violates 1NF, create junction table
    → No ↓

[4] Repeated column groups? (item1, item2, item3)
    → Yes → Violates 1NF, create child table
    → No ↓

[5] Composite PK with partial dependency?
    → Yes → Violates 2NF, split table
    → No/N/A ↓

[6] Has X_id + X_name in same table?
    → Yes → Violates 3NF, extract X to separate table
    → No ↓

[7] Foreign key columns indexed?
    → No → Add index
    → Yes ↓

[8] (Supabase) RLS enabled?
    → No → Enable RLS + add policies
    → Yes ↓

✅ Table passes review
```

## Core Concepts: Three Normal Forms

### 1NF: Each Cell Contains Only One Value

| Check | Pass Criteria |
|-------|--------------|
| Single value per cell? (no comma-separated lists) | ✅ |
| Table has primary key? | ✅ |
| No repeated columns? (no phone1, phone2, phone3) | ✅ |

### 2NF: Non-Key Columns Depend on Entire Primary Key

**Only check for composite primary keys**

| Check | Pass Criteria |
|-------|--------------|
| Satisfies 1NF? | ✅ |
| Each non-key column depends on entire composite key? | ✅ |

### 3NF: No Transitive Dependencies Between Non-Key Columns

| Check | Pass Criteria |
|-------|--------------|
| Satisfies 2NF? | ✅ |
| No dependency between non-key columns? | ✅ |
| Each non-key column determined only by primary key? | ✅ |

## Review Workflow

### Step 1: Gather Schema Information

Execute schema inspection queries to collect:
- All table names and column definitions
- Primary key and foreign key constraints
- Index information
- RLS policies (for Supabase)

### Step 2: Run Automated Checks

Use `scripts/check-schema.sql` to perform:
- Primary key existence check
- Column count check (>30 columns = warning)
- Foreign key index check
- Naming convention check (snake_case)
- Repeated column pattern check
- Timestamp type check (should be TIMESTAMPTZ)
- RLS enablement check

### Step 3: Manual Normalization Review

For each table, ask:
1. Are there comma-separated values in any column? → 1NF violation
2. Are there numbered columns (phone1, phone2)? → 1NF violation
3. Does same info appear in multiple rows? → Needs extraction
4. Has X_id AND X_name in same table? → 3NF violation
5. For composite PK: does any column depend on only part of key? → 2NF violation

### Step 4: Generate Report

Output findings in Markdown table format:

```markdown
# Database Design Review Report

## Overview
| Metric | Value |
|--------|-------|
| Total Tables | X |
| Passed | X |
| Needs Fix | X |

## Structure Check Results
| Check | Status | Problem Tables | Recommendation |
|-------|--------|----------------|----------------|
| Primary Key | ✅/❌ | ... | ... |

## Normalization Results
| Table | 1NF | 2NF | 3NF | Issues |
|-------|-----|-----|-----|--------|
| ... | ✅/❌ | ✅/❌ | ✅/❌ | ... |

## Fix Recommendations
| Priority | Table | Issue | Fix |
|----------|-------|-------|-----|
| High | ... | ... | ... |
```

## Available Resources

### Reference Files

For detailed guidance, consult:

- **`references/normalization-guide.md`** - Complete three normal forms guide with examples
- **`references/anti-patterns.md`** - Common anti-patterns and how to fix them
- **`references/supabase-rules.md`** - Supabase/PostgreSQL specific rules and templates

### Scripts

- **`scripts/check-schema.sql`** - Automated schema checking queries

## Key Rules Summary

**Normalization in Three Sentences:**
1. **1NF**: One value per cell, no repeated columns
2. **2NF**: Full dependency on entire key (for composite keys)
3. **3NF**: Direct dependency on primary key only, no transitive dependencies

**Five Design Principles:**
1. Every table must have a primary key (BIGINT/UUID)
2. Foreign keys must have indexes
3. Timestamps must use TIMESTAMPTZ
4. Names must use snake_case
5. Supabase tables must enable RLS

**Three Anti-Pattern Alerts:**
1. See comma-separated values → Need junction table
2. See phone1/phone2/phone3 → Need child table
3. See X_id + X_name together → X needs its own table

## Acceptable Denormalization

The following cases may justify denormalization:

1. **Read-heavy reporting tables** - Pre-computed statistics
2. **High-frequency query fields** - Avoid frequent JOINs
3. **Audit log tables** - Need complete historical snapshots
4. **Full-text search fields** - Combined search columns

**Principle**: Normalize first, denormalize only for proven performance issues, and document the reason.
