# Language-Specific Patterns

**Purpose**: Define patterns for TypeScript/JavaScript development
**Version**: 1.0.0

---

## 🎯 TypeScript Best Practices

### Type Definitions
```typescript
// ✅ GOOD: Explicit types for public APIs
function calculateTotal(items: CartItem[]): number {
    return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}

// ✅ GOOD: Type inference for internal logic
const prices = items.map(item => item.price); // inferred as number[]

// ❌ BAD: Any type (bypasses type safety)
function process(data: any): any { ... }
```

### Interface vs Type
```typescript
// Use interface for object shapes (extensible)
interface User {
    id: string;
    name: string;
    email: string;
}

// Use type for unions, intersections, primitives
type Status = 'pending' | 'active' | 'completed';
type Result<T> = { success: true; data: T } | { success: false; error: Error };
```

---

## 🔄 Async Patterns

### Promise Handling
```typescript
// ✅ GOOD: Async/await with error handling
async function fetchUser(id: string): Promise<User> {
    try {
        const response = await fetch(`/api/users/${id}`);
        if (!response.ok) {
            throw new Error(`Failed to fetch user: ${response.statusText}`);
        }
        return await response.json();
    } catch (error) {
        logger.error('fetchUser failed', { id, error });
        throw error;
    }
}

// ✅ GOOD: Promise.all for parallel operations
const [users, posts] = await Promise.all([
    fetchUsers(),
    fetchPosts()
]);
```

### Error Handling
```typescript
// Custom error classes
class NotFoundError extends Error {
    constructor(resource: string, id: string) {
        super(`${resource} with id ${id} not found`);
        this.name = 'NotFoundError';
    }
}

// Result type for operations that can fail
type Result<T, E = Error> =
    | { ok: true; value: T }
    | { ok: false; error: E };

function safeParse(json: string): Result<unknown> {
    try {
        return { ok: true, value: JSON.parse(json) };
    } catch (e) {
        return { ok: false, error: e as Error };
    }
}
```

---

## 🏗️ Module Patterns

### Export Patterns
```typescript
// Named exports (preferred for tree-shaking)
export function foo() { }
export const bar = 42;

// Default exports (use sparingly)
export default class App { }

// Barrel exports (re-export from index)
export { foo, bar } from './utils';
```

### Import Patterns
```typescript
// Named imports (recommended)
import { useState, useEffect } from 'react';

// Namespace imports
import * as fs from 'fs';

// Type imports (erased at runtime)
import type { User, Post } from './types';
import { type User, type Post } from './types';
```

---

## ⚡ Performance Patterns

### Memoization
```typescript
// useMemo for expensive calculations
const sortedItems = useMemo(
    () => items.sort((a, b) => b.price - a.price),
    [items]  // Only re-sort when items change
);

// useCallback for function references
const handleClick = useCallback(
    (id: string) => setSelected(id),
    []  // Stable reference
);
```

### Lazy Loading
```typescript
// Dynamic imports
const HeavyComponent = React.lazy(() => import('./HeavyComponent'));

// Route-based code splitting
const Dashboard = lazy(() => import('./pages/Dashboard'));
```

---

## 🧪 Testing Utilities

### Test Helpers
```typescript
// Mock functions
const mockFetch = vi.fn().mockResolvedValue({ data: 'test' });

// Wrapper for testing hooks
function renderHook<T>(hook: () => T) {
    const result = ref<T>(null) as { current: T };
    const Component = ({ children }) => {
        result.current = hook();
        return children;
    };
    
    return {
        result,
        render: (ui: ReactElement) => render(ui, { wrapper: Component })
    };
}
```

---

*TypeScript patterns v1.0.0 - Updated 2026-04-17*