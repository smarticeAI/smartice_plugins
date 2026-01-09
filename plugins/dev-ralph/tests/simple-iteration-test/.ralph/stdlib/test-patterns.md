# Test Patterns

This file tests stdlib injection into the build loop.

## Function Naming Convention

All exported functions should use camelCase:
```typescript
// Good
export function greetUser(name: string): string

// Bad
export function GreetUser(name: string): string
export function greet_user(name: string): string
```

## Return Type Convention

Functions that can fail should return explicit types, never throw:
```typescript
// Good
function parseData(input: string): ParseResult | null

// Bad
function parseData(input: string): ParseResult  // throws on failure
```

## Test Pattern

This is a test pattern to verify stdlib injection is working.
If you see this in the build loop context, stdlib injection is working!
