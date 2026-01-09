# Lessons Learned

This file captures learnings from each iteration.

## Iteration 1: greeting.ts
- Created greeting.ts following the exact spec format
- Type-check passes with no issues
- Pattern: Simple function export with typed parameters works well

## Iteration 2: farewell.ts
- Created farewell.ts following same pattern as greeting.ts
- Consistent function signature: (name: string): string
- Type-check continues to pass

## Iteration 3: index.ts
- Created barrel export file re-exporting both functions
- Pattern: export { fn } from './module' for re-exports
- All 3 implementation items now complete

## Final Summary
- 6 iterations to complete 3 implementation items + 3 success criteria
- Per-item iteration flow worked correctly
- Type-check passed throughout
- No placeholders or TODOs in code
- Clean, simple implementations following spec exactly
