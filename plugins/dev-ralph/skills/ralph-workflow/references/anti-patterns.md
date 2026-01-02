# Anti-Patterns and Placeholder Detection

Patterns that indicate incomplete or placeholder code. The verification phase greps for these.

## Default Placeholder Patterns

```yaml
placeholder_patterns:
  - "TODO"
  - "FIXME"
  - "unimplemented"
  - "NotImplementedError"
  - "throw new Error('Not implemented')"
```

## Extended Patterns

### JavaScript/TypeScript

```bash
# Comment-based
grep -rn "// TODO" src/
grep -rn "// FIXME" src/
grep -rn "// HACK" src/
grep -rn "// XXX" src/

# Placeholder errors
grep -rn "throw new Error.*not implemented" src/
grep -rn "throw new Error.*TODO" src/

# Empty implementations
grep -rn "() => {}" src/
grep -rn "function.*{\\s*}" src/
```

### Python

```bash
# Placeholder statements
grep -rn "pass$" src/
grep -rn "raise NotImplementedError" src/
grep -rn "# TODO" src/
grep -rn "# FIXME" src/

# Ellipsis placeholder
grep -rn "\.\.\.$" src/
```

### General

```bash
# Placeholder comments
grep -rn "PLACEHOLDER" src/
grep -rn "STUB" src/
grep -rn "TEMPORARY" src/
grep -rn "REMOVE ME" src/
```

## Why These Matter

### Placeholders indicate incomplete work

```typescript
// BAD: Placeholder
function calculateTax(amount: number): number {
  // TODO: implement tax calculation
  return 0;
}

// GOOD: Full implementation
function calculateTax(amount: number): number {
  const TAX_RATE = 0.08;
  return amount * TAX_RATE;
}
```

### Empty functions hide missing logic

```typescript
// BAD: Empty handler
const handleSubmit = () => {};

// GOOD: Actual implementation
const handleSubmit = () => {
  validateForm();
  submitData();
  showConfirmation();
};
```

### NotImplementedError is a cop-out

```python
# BAD: Deferred implementation
def process_data(self, data):
    raise NotImplementedError("Will implement later")

# GOOD: Actual implementation
def process_data(self, data):
    validated = self.validate(data)
    transformed = self.transform(validated)
    return self.store(transformed)
```

## Exceptions

Some legitimate uses of these patterns:

1. **Abstract base classes**: `NotImplementedError` in abstract methods is correct
2. **Test fixtures**: TODO comments in test setup may be acceptable
3. **Documentation**: TODO in docs (not code) is fine

The verification auditor should use judgment for these cases.

## Verification Grep Command

```bash
# Combined check for common placeholders
grep -rn \
  -e "TODO" \
  -e "FIXME" \
  -e "unimplemented" \
  -e "NotImplementedError" \
  -e "throw new Error.*[Nn]ot implemented" \
  --include="*.ts" \
  --include="*.tsx" \
  --include="*.js" \
  --include="*.jsx" \
  --include="*.py" \
  src/
```

## Handling Violations

When placeholders are found:

1. List each occurrence with file:line
2. Mark verification as FAILED
3. Return to implementation phase
4. Claude must implement the missing functionality
5. Re-run verification after fixes
