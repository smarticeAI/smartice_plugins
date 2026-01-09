# Greeting Module Spec

## Requirements

Create a simple greeting module with two functions.

## Technical Contract

### greeting.ts
```typescript
export function hello(name: string): string {
  return `Hello, ${name}!`
}
```

### farewell.ts
```typescript
export function goodbye(name: string): string {
  return `Goodbye, ${name}!`
}
```

### index.ts
```typescript
export { hello } from './greeting'
export { goodbye } from './farewell'
```

## Success Criteria

- Functions return correct format
- Type-check passes
- Exports work correctly
