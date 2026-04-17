# Testing Standards and Patterns

**Purpose**: Define comprehensive testing patterns for all SSD implementations
**Version**: 1.0.0

---

## 🎯 Testing Philosophy

| Principle | Description |
|-----------|-------------|
| **Test Behavior, Not Implementation** | Test what, not how |
| **Fast Feedback** | Unit tests run in <100ms |
| **Isolated Tests** | No dependencies between tests |
| **Readable Tests** | Self-documenting test names |

---

## 📊 Test Pyramid

```
        /\
       /  \      E2E Tests (10%)
      /____\     - Few, slow, expensive
     /      \
    /   UI   \   Integration Tests (20%)
   /   Tests  \  - Medium speed, some dependencies
  /__________\
 /            \
/   Unit Tests \  Unit Tests (70%)
/    (70%)      \ - Fast, isolated, cheap
/________________\
```

---

## 🧪 Unit Testing Patterns

### Test Structure (AAA Pattern)
```typescript
describe('calculateDiscount', () => {
    it('should apply 10% discount for orders over $100', () => {
        // Arrange - Setup test data
        const order = { total: 150, customerTier: 'regular' };
        
        // Act - Execute the function
        const result = calculateDiscount(order);
        
        // Assert - Verify the outcome
        expect(result.percentage).toBe(10);
        expect(result.amount).toBe(15);
    });
});
```

### Naming Conventions
```
✅ GOOD: should_return_empty_array_when_input_is_empty
✅ GOOD: should_throw_error_when_user_not_found
✅ GOOD: should_cache_results_for_identical_queries
❌ BAD: test1
❌ BAD: testCalculate
```

### Edge Case Testing
```typescript
describe('validateEmail', () => {
    it('should accept valid email addresses', () => {
        expect(validateEmail('user@example.com')).toBe(true);
    });
    
    it('should reject email without domain', () => {
        expect(validateEmail('user@')).toBe(false);
    });
    
    it('should reject email with spaces', () => {
        expect(validateEmail('user @example.com')).toBe(false);
    });
    
    it('should handle unicode characters', () => {
        expect(validateEmail('üser@example.com')).toBe(true);
    });
    
    it('should handle empty input', () => {
        expect(() => validateEmail('')).toThrow('Email is required');
    });
});
```

---

## 🔄 Mocking Patterns

### Mock Functions
```typescript
// Mock with implementation
const mockFetchUser = vi.fn().mockImplementation((id: string) => {
    if (id === '1') {
        return Promise.resolve({ id: '1', name: 'John' });
    }
    return Promise.reject(new Error('User not found'));
});

// Mock return value
const mockLogger = vi.fn().mockReturnValue(undefined);

// Check call history
expect(mockLogger).toHaveBeenCalledWith('info', 'User logged in');
expect(mockLogger).toHaveBeenCalledTimes(1);
```

### Module Mocking
```typescript
// Mock entire module
vi.mock('./api/client', () => ({
    ApiClient: vi.fn().mockImplementation(() => ({
        get: vi.fn().mockResolvedValue({ data: 'mocked' })
    }))
}));
```

---

## 🎭 Integration Testing

### Database Tests
```typescript
describe('UserRepository', () => {
    let repository: UserRepository;
    
    beforeEach(async () => {
        // Use test database
        repository = new UserRepository(testDbConnection);
        await repository.clear();
    });
    
    it('should create and retrieve user', async () => {
        const user = await repository.create({
            name: 'John',
            email: 'john@example.com'
        });
        
        const found = await repository.findById(user.id);
        
        expect(found.name).toBe('John');
        expect(found.email).toBe('john@example.com');
    });
});
```

### API Tests
```typescript
describe('POST /api/users', () => {
    it('should create user and return 201', async () => {
        const response = await request(app)
            .post('/api/users')
            .send({ name: 'John', email: 'john@example.com' })
            .expect(201);
        
        expect(response.body.id).toBeDefined();
    });
});
```

---

## 🏃 E2E Testing

### Playwright Example
```typescript
import { test, expect } from '@playwright/test';

test('user can log in and view dashboard', async ({ page }) => {
    // Navigate to login
    await page.goto('/login');
    
    // Fill credentials
    await page.fill('[data-testid="email"]', 'user@example.com');
    await page.fill('[data-testid="password"]', 'password123');
    
    // Submit
    await page.click('[data-testid="login-button"]');
    
    // Verify dashboard loads
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('.welcome')).toContainText('Welcome');
});
```

---

## 📈 Coverage Requirements

| Type | Minimum | Target |
|------|---------|--------|
| Statements | 80% | 90% |
| Branches | 75% | 85% |
| Functions | 90% | 95% |
| Lines | 80% | 90% |

---

## 🔧 Test Automation

### CI Pipeline
```yaml
test:
  script:
    - npm run lint
    - npm run type-check
    - npm run test:coverage
    - npm run test:e2e
  coverage: /Coverage: (\d+\.\d+)%/
```

---

## 📝 Self-Documenting Tests

This file improves itself based on test failures and coverage reports.
Patterns that consistently fail or are never hit are analyzed and improved.

*Testing patterns v1.0.0 - Updated 2026-04-17*